using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using FirebirdSql.Data.FirebirdClient;

namespace FireBirdTools.Data
{
    public class FbBulkCopy : IDisposable
    {
        private bool disposedValue;

        /// <summary>
        /// Aktuelle Verbinding zum Server
        /// </summary>
        protected FbConnection Connection { get; }
        /// <summary>
        /// Ziel Tabellenname
        /// </summary>
        public string DestinationTableName { get; set; }
        /// <summary>
        /// Anzahl Zeilen Commitgrenze
        /// </summary>
        public long BatchSize { get; set; } = -1;
        /// <summary>
        /// Anzahl Zeilen Fortschritt
        /// </summary>
        public long NotifyAfter { get; set; } = long.MaxValue;
        public event EventHandler<FbRowsCopiedEventArgs> FbRowsCopied;
        public FbBulkCopy(FbConnection connection)
        {
            Connection = connection;
        }
        /// <summary>
        /// maximale Länge des Scripts
        /// </summary>
        protected int MaxCommandLength { get; } = 62000;
        /// <summary>
        /// Schema der Zieltablle
        /// </summary>
        protected DataTable SchemaTable { get; set; }
        /// <summary>
        /// Liste der Grundparameter (Satz 1)
        /// </summary>        
        List<InputParameter> ParameterSet { get; } = new List<InputParameter>();
        /// <summary>
        /// Auszuführendes Kommando
        /// </summary>
        FbCommand InsertCommand { get; set; }

        /// <summary>
        /// Schreiben der Daten in die Zieltabelle mittel Reader
        /// </summary>
        /// <param name="reader"></param>
        public void WriteToServer(IDataReader reader)
        {
            SchemaTable = Connection.GetSchema("Columns", new string[] { string.Empty, string.Empty, DestinationTableName });
            SchemaTable.DefaultView.Sort = "COLUMN_NAME";

            // Tabelle der Zielnamen
            ParameterSet.Clear();

            if (reader.FieldCount != SchemaTable.Rows.Count)
            {
                throw new InvalidOperationException($"Columns of reader differs from table {DestinationTableName}");
            }

            // Mapping Ziel-Felder => Reader-Felder
            int[] mapIndex = new int[reader.FieldCount];
            Dictionary<string, int> mapNames = new Dictionary<string, int>();
            for (int i = 0; i < reader.FieldCount; i++)
            {
                mapNames[reader.GetName(i)] = i;
            }
            InsertCommand = Connection.CreateCommand();

            foreach (DataRow row in SchemaTable.Rows)   // Reihenfolge der Zieltablle
            {
                string name = $"{row["COLUMN_NAME"]}".Trim();
                if (!mapNames.TryGetValue(name, out int pos))
                {
                    throw new InvalidOperationException($"Column {name} not found in table {DestinationTableName}");
                }
                mapIndex[Convert.ToInt32(row["ORDINAL_POSITION"])] = pos;        // Spaltenmapping

                string columncast = "BLOB SUB_TYPE 0";      // unbekannt
                InputParameter parameter = new InputParameter();
                parameter.DbType = DbType.Object;

                switch ($"{row["COLUMN_DATA_TYPE"]}".ToUpper())
                {
                    case "DATE":
                        columncast = "date";
                        parameter.DbType = DbType.DateTime;
                        break;
                    case "CHAR":
                        columncast = $"char({(int)row["COLUMN_SIZE"]})";
                        parameter.DbType = DbType.String;
                        break;
                    case "VARCHAR":
                        columncast = $"varchar({(int)row["COLUMN_SIZE"]})";
                        if ($"{row["CHARACTER_SET_NAME"]}".Trim() == "NONE")
                        {
                            columncast += " CHARACTER SET NONE";
                        }
                        parameter.DbType = DbType.String;
                        break;
                    case "DOUBLE PRECISION":
                        columncast = "double precision";
                        parameter.DbType = DbType.Double;
                        break;
                    case "BIGINT":
                        columncast = "bigint";
                        parameter.DbType = DbType.Int64;
                        break;
                    case "INTEGER":
                        columncast = "integer";
                        parameter.DbType = DbType.Int32;
                        break;
                    case "DECIMAL":
                        columncast = $"decimal({(int)row["NUMERIC_PRECISION"]},{(int)row["NUMERIC_SCALE"]})";
                        parameter.DbType = DbType.Decimal;
                        break;
                    case "BLOB SUB_TYPE 1":
                        columncast = "BLOB SUB_TYPE 1 SEGMENT SIZE 80 CHARACTER SET UTF8";
                        parameter.DbType = DbType.String;
                        break;
                }

                parameter.CastValue=$"{columncast}=?";
                ParameterSet.Add(parameter);
            }

            int numRows = CreateInsertCommand(int.MaxValue);    

            long currentRows = 0;
            int insertRows = 0;
            int numFields = reader.FieldCount;

            InsertCommand.Transaction = Connection.BeginTransaction(IsolationLevel.ReadCommitted);

            List<object[]> rowValues = new List<object[]>(numRows);
            try
            {
                object[] values = new object[numFields];
                while (reader.Read())
                {
                    reader.GetValues(values);

                    object[] mapValues = new object[numFields];
                    for (int i = 0; i < numFields; i++)
                    {
                        mapValues[i] = values[mapIndex[i]];
                    }
                    rowValues.Add(mapValues);
                    currentRows++;              // Anzahl insgesamt

                    if (currentRows % NotifyAfter == 0) 
                    {
                        FbRowsCopiedEventArgs args = new FbRowsCopiedEventArgs(currentRows);
                        FbRowsCopied?.Invoke(this, args);
                        if (args.Abort)
                        {
                            throw new OperationCanceledException("Operation canceled!");
                        }
                    }

                    insertRows++;               // eingefügte Zeilen
                    if (rowValues.Count == numRows)
                    {
                        ExecuteInsert(rowValues);
                        rowValues.Clear();      // wieder freigeben

                        if (insertRows >= BatchSize)
                        {
                            insertRows = 0;
                            InsertCommand.Transaction.Commit();
                            InsertCommand.Transaction = Connection.BeginTransaction();
                        }
                    }
                }

                if (rowValues.Count > 0)
                {
                    CreateInsertCommand(rowValues.Count);
                    ExecuteInsert(rowValues);
                }
                InsertCommand.Transaction.Commit();
            }
            catch (Exception exBulk)
            {
                InsertCommand.Transaction.Rollback();
                throw;
            }
        }

        private void ExecuteInsert(List<object[]> rowValues)
        {
            int parmIndex = 0;
            foreach(var values in rowValues)
            {
                foreach(var value in values)
                {
                    InsertCommand.Parameters[parmIndex++].Value = value;
                }
            }
            InsertCommand.ExecuteNonQuery();
        }

        private int CurrentInsertCount { get; set; }

        private int CreateInsertCommand(int maxRows)
        {
            int firstMaxRows = 0;
            int currentMaxRows = maxRows;
            int currentMinRows = 0;
            int createRows = currentMaxRows;

            while (true)
            {
                try
                {
                    CreateBestInsertCommand(createRows);
                    if (currentMinRows == CurrentInsertCount) 
                    {
                        break;
                    }
                    currentMinRows = CurrentInsertCount;
                    createRows = currentMinRows + (currentMaxRows - currentMinRows) / 2;
                    continue;
                }
                catch (FbException ex)
                {
                    if (ex.Message.Contains("block size exceeds"))
                    {
                        if (firstMaxRows == 0)
                        {
                            firstMaxRows = CurrentInsertCount;
                        }
                        currentMaxRows = CurrentInsertCount;
                        createRows = currentMinRows + (currentMaxRows - currentMinRows) / 2;
                        continue;
                    }
                    throw;
                }
            }
            return CurrentInsertCount;
        }

        private void CreateBestInsertCommand(int maxRows)
        {
            int numRows = 0;
            List<string> paramRows = new List<string>();
            List<string> insertStantement = new List<string>();
            int parmLength = 0;
            int insertLength = 0;
            int parmNum = 0;

            for (int r = 0; r < maxRows; r++)
            {
                List<string> inputParms = new List<string>();
                List<string> insertValues = new List<string>();

                for (int c = 0; c < ParameterSet.Count; c++)
                {
                    string parName = $"P{parmNum++}";
                    inputParms.Add($"{parName} {ParameterSet[c].CastValue}");
                    insertValues.Add($":{parName}");
                }
                string paramNames = string.Join("\n,", inputParms);
                string insertRow = $"insert into {DestinationTableName} values({ string.Join(",", insertValues.Select(x => x))});";

                if (parmLength + insertLength + insertRow.Length + paramNames.Length > MaxCommandLength)
                {
                    break;
                }

                paramRows.Add(paramNames);
                parmLength += paramNames.Length;
                insertStantement.Add(insertRow);
                insertLength += insertRow.Length;
                foreach(InputParameter parameter in ParameterSet)
                {
                    FbParameter rowParam = InsertCommand.CreateParameter();
                    rowParam.DbType = parameter.DbType;
                    //rowParam.IsNullable = parameter.IsNullable;
                    InsertCommand.Parameters.Add(rowParam);
                }
                numRows++;
            }

            CurrentInsertCount = numRows;

            InsertCommand.CommandText = (new StringBuilder("execute block (")
                                .Append(string.Join(",\n", paramRows))
                                .Append(")\nas begin\n")
                                .Append(string.Join("\n", insertStantement))
                                .Append("\nend")
                                .ToString());

            InsertCommand.Prepare();
        }

        public void WriteToServer(DataTable dataTable)
        {
            WriteToServer(new DataTableReader(dataTable));
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!disposedValue)
            {
                if (disposing)
                {
                    // TODO: Verwalteten Zustand (verwaltete Objekte) bereinigen
                    InsertCommand?.Transaction?.Rollback();
                    InsertCommand?.Dispose();
                    InsertCommand = null;
                }

                // TODO: Nicht verwaltete Ressourcen (nicht verwaltete Objekte) freigeben und Finalizer überschreiben
                // TODO: Große Felder auf NULL setzen
                disposedValue = true;
            }
        }

        // // TODO: Finalizer nur überschreiben, wenn "Dispose(bool disposing)" Code für die Freigabe nicht verwalteter Ressourcen enthält
        // ~FbBulkCopy()
        // {
        //     // Ändern Sie diesen Code nicht. Fügen Sie Bereinigungscode in der Methode "Dispose(bool disposing)" ein.
        //     Dispose(disposing: false);
        // }

        public void Dispose()
        {
            // Ändern Sie diesen Code nicht. Fügen Sie Bereinigungscode in der Methode "Dispose(bool disposing)" ein.
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }
    }

    internal struct InputParameter
    {
        public string CastValue { get; set; } 
        public DbType DbType { get; set; }
    }
    public class FbRowsCopiedEventArgs
    {
        internal FbRowsCopiedEventArgs(long rows)
        {
            RowsCopied = rows;
        }
        public bool Abort { get; set; } = false;
        public long RowsCopied { get; }
    }
}
