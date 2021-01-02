/*
 *  Firebird ADO.NET Data provider for .NET and Mono 
 * 
 *     The contents of this file are subject to the Initial 
 *     Developer's Public License Version 1.0 (the "License"); 
 *     you may not use this file except in compliance with the 
 *     License. You may obtain a copy of the License at 
 *     http://www.firebirdsql.org/index.php?op=doc&id=idpl
 *
 *     Software distributed under the License is distributed on 
 *     an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either 
 *     express or implied.  See the License for the specific 
 *     language governing rights and limitations under the License.
 * 
 *  Copyright (c) 2002, 2007 Carlos Guzman Alvarez
 *  Copyright (c) 2008 Jiri Cincura (jiri@cincura.net)
 *  All Rights Reserved.
 *  
 */

using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.Common;
using System.Globalization;
using System.Text;
using FirebirdSql.Data.Common;

namespace FirebirdSql.Data.FirebirdClient
{
	public sealed class FbDataReader : DbDataReader
	{
		#region · Constants ·

		private const int STARTPOS = -1;

		#endregion

		#region · Fields ·

		private DataTable schemaTable;
		private FbCommand command;
		private FbConnection connection;
		private DbValue[] row;
		private Descriptor fields;
		private CommandBehavior commandBehavior;
		private bool eof;
		private bool isClosed;
		private int position;
		private int recordsAffected;
		private Dictionary<string, int> columnsIndexesOrdinal;
		private Dictionary<string, int> columnsIndexesOrdinalCI;
		private Dictionary<string, int> columnsIndexesInvariantCI;

		#endregion

		#region · DbDataReader Indexers ·

		public override object this[int i]
		{
			get { return this.GetValue(i); }
		}

		public override object this[string name]
		{
			get { return this.GetValue(this.GetOrdinal(name)); }
		}

		#endregion

		#region · Constructors ·

		internal FbDataReader()
			: base()
		{
		}

		internal FbDataReader(
			FbCommand command,
			FbConnection connection,
			CommandBehavior commandBehavior)
		{
			this.position = STARTPOS;
			this.command = command;
			this.connection = connection;
			this.commandBehavior = commandBehavior;
			this.fields = this.command.GetFieldsDescriptor();

			this.UpdateRecordsAffected();
		}

		#endregion

		#region · Finalizer ·

		~FbDataReader()
		{
			this.Dispose(false);
		}

		#endregion

		#region · IDisposable methods ·

		//protected override void Dispose(bool disposing)
		//{
		//    if (!this.disposed)
		//    {
		//        try
		//        {
		//            if (disposing)
		//            {
		//                // release any managed resources
		//                this.Close();
		//            }

		//            // release any unmanaged resources
		//        }
		//        finally
		//        {
		//        }

		//        this.disposed = true;
		//    }
		//}

		#endregion

		#region · DbDataReader overriden Properties ·

		public override int Depth
		{
			get
			{
				this.CheckState();

				return 0;
			}
		}

		public override bool HasRows
		{
			get { return this.command.IsSelectCommand; }
		}

		public override bool IsClosed
		{
			get { return this.isClosed; }
		}

		public override int FieldCount
		{
			get
			{
				this.CheckState();

				return this.fields.Count;
			}
		}

		public override int RecordsAffected
		{
			get { return this.recordsAffected; }
		}

		public override int VisibleFieldCount
		{
			get
			{
				this.CheckState();

				return this.fields.Count;
			}
		}

		#endregion

		#region · DbDataReader overriden methods ·

		public override void Close()
		{
			if (!this.IsClosed)
			{
				try
				{
					if (this.command != null && !this.command.IsDisposed)
					{
						if (this.command.CommandType == CommandType.StoredProcedure)
						{
							// Set values of output parameters
							this.command.SetOutputParameters();
						}

						if (this.command.HasImplicitTransaction)
						{
							// Commit implicit transaction if needed
							this.command.CommitImplicitTransaction();
						}

						// Set null the active reader of the command
						this.command.ActiveReader = null;
					}
				}
				catch
				{
				}
				finally
				{
					if (this.connection != null && this.IsCommandBehavior(CommandBehavior.CloseConnection))
					{
						this.connection.Close();
					}

					this.isClosed = true;
					this.position = STARTPOS;
					this.command = null;
					this.connection = null;
					this.row = null;
					this.schemaTable = null;
					this.fields = null;
				}
			}
		}

		public override bool Read()
		{
			this.CheckState();

			bool retValue = false;

			if (this.IsCommandBehavior(CommandBehavior.SingleRow) &&
				this.position != STARTPOS)
			{
			}
			else
			{
				if (this.IsCommandBehavior(CommandBehavior.SchemaOnly))
				{
				}
				else
				{
					this.row = this.command.Fetch();

					if (this.row != null)
					{
						this.position++;
						retValue = true;
					}
					else
					{
						this.eof = true;
					}
				}
			}

			return retValue;
		}

        /// <summary>
        /// Get Sql Schema Base Query for generating Dynamic Querys
        /// </summary>
        /// <returns>Base Metadata query</returns>
        private static string GetSchemaCommandTextBase()
        {
            string sql =
                @"SELECT
					fld.rdb$computed_blr AS computed_blr,
					fld.rdb$computed_source AS computed_source,
					(SELECT COUNT(*) FROM rdb$relation_constraints rel 
					  INNER JOIN rdb$indices idx ON rel.rdb$index_name = idx.rdb$index_name
					  INNER JOIN rdb$index_segments seg ON idx.rdb$index_name = seg.rdb$index_name
					WHERE rel.rdb$constraint_type = 'PRIMARY KEY'
					  AND rel.rdb$relation_name = rfr.rdb$relation_name
					  AND seg.rdb$field_name = rfr.rdb$field_name) AS primary_key,
					(SELECT COUNT(*) FROM rdb$relation_constraints rel
					  INNER JOIN rdb$indices idx ON rel.rdb$index_name = idx.rdb$index_name
					  INNER JOIN rdb$index_segments seg ON idx.rdb$index_name = seg.rdb$index_name
					WHERE rel.rdb$constraint_type = 'UNIQUE'
					  AND rel.rdb$relation_name = rfr.rdb$relation_name
					  AND seg.rdb$field_name = rfr.rdb$field_name) AS unique_key,
					fld.rdb$field_precision AS numeric_precision
				  FROM rdb$relation_fields rfr
					INNER JOIN rdb$fields fld ON rfr.rdb$field_source = fld.rdb$field_name
				  WHERE ";

            return sql;
        }
        

        /// <summary>
        /// Class for keeping FB Column MetaData
        /// </summary>
        private sealed class RDBTableInfo
        {
            public string RelationName = String.Empty;
            public string FieldName = String.Empty;
            public int Ordinal = 0;
            public bool isKeyColumn = false;
            public bool isUnique = false;
            public bool isReadOnly = false;
            public int precision = 0;
            public bool isExpression = false;      
            public Int16 BatchID = 0;
        }
        
        /// <summary>
        /// Allows to get complete field's param expression for batch query. Example: (?,?,?,?)
        /// </summary>
        /// <param name="iParams">Size of batch param List</param>
        /// <returns>Param Expression</returns>
        private string GetParamExpression(int iParams)
        {
            List<string> lParams = new List<string>(iParams);

            for (Int16 i= 0; i < iParams; i++)
                lParams.Add("?");

            return  String.Format("({0})",String.Join(",",lParams.ToArray(),0,iParams)); 
        }    
        
        public override DataTable GetSchemaTable()
        {
            this.CheckState();

            if (this.schemaTable != null)
                return this.schemaTable;

            #region Variables
            DataRow schemaRow = null;
            int tableCount = 0;
            string currentTable = string.Empty;
            this.schemaTable = GetSchemaTableStructure();
            const Int16 batchLimit = 90; //Could be adjusted as needed.
            Int16 paramCounter = 0; //Counter for the whole batch process
            Int16 batchRounds = 0; //counter for each batch (limited by batchlimit)
            Hashtable relationList = new Hashtable(); //HashTable to store the query's unique Field Tables Names.
            List<RDBTableInfo> fieldList = new List<RDBTableInfo>(this.fields.Count+1); //List to store the whole statement Schema Field Values.
            const Int16 metadataColSize = 31; //Firebird MAX Column Size.
            Int16 batchID=0; //Batch marker. When batchlimit reaches its limit it increases by one the value.
            StringBuilder sb = new StringBuilder(); //Stores dynamic generated schema query.            
            #endregion


            // Prepare statement for schema fields information	
            //Asign current active schema command connection and transaccion
            FbCommand schemaCmd = new FbCommand();
            schemaCmd.Connection = this.command.Connection;
            schemaCmd.Transaction = this.command.Connection.InnerConnection.ActiveTransaction;        

            for (paramCounter = 0; paramCounter < this.FieldCount; paramCounter++)
            {
                if (batchRounds >= batchLimit) //Process field params until batch limit is reached.
                {                    
                    batchID++;
                    batchRounds = 0;
                }
               
                RDBTableInfo rdbinfo = new RDBTableInfo();
                rdbinfo.Ordinal = paramCounter;
                rdbinfo.FieldName = this.fields[paramCounter].Name;
                rdbinfo.RelationName = this.fields[paramCounter].Relation;
                rdbinfo.BatchID = batchID;
                fieldList.Add(rdbinfo);                
                
                batchRounds++;
            }

            //Process batch schema query
            for (Int16 i = 0; i <= batchID; i++)
            {
                sb.Length = 0;
                relationList.Clear();
                List<RDBTableInfo> rdblBatch = new List<RDBTableInfo>(this.fields.Count+1);
                //Find all RDBTableInfo elements according to batchID
                rdblBatch = fieldList.FindAll(rdbti=>rdbti.BatchID==i);                
                
                //Just add the needed tables according to the fieldnames on the current batch.
                for (Int16 j = 0; j < rdblBatch.Count; j++)
                {
                    //Keep a list of unique relation names (tables) from all the fieldlist.
                    if (!relationList.ContainsValue(rdblBatch[j].RelationName))
                        relationList.Add (relationList.Count,rdblBatch[j].RelationName);               
                }
                
                if (schemaCmd.Parameters.Count > 0) //Clear previous command parameters.
                    schemaCmd.Parameters.Clear();

                //Get the Base Squema query to start generating Dynamic Schema query
                sb.Append(GetSchemaCommandTextBase());

                //Perform batch field query against table schema
                //Add relation (table names) to schemaCmd
                for (int j = 0; j < relationList.Count; j++)
                {
                    if (j > 0) //More than one table in query statement
                        sb.Append(" OR ");

                    List<RDBTableInfo> tmpList = rdblBatch.FindAll(rdbti=>rdbti.RelationName.Equals(relationList[j]));
                    sb.AppendFormat(" (rfr.rdb$field_name in {0} AND rfr.rdb$relation_name='{1}') ", GetParamExpression(tmpList.Count), relationList[j]);

                    for (int k = 0; k < tmpList.Count; k++)
                        schemaCmd.Parameters.Add("@COLUMN_NAME", FbDbType.Char, metadataColSize).Value = tmpList[k].FieldName;

                    tmpList=null;
                }
                //set order to schema query
                sb.Append(" ORDER BY rfr.rdb$relation_name, rfr.rdb$field_position");

                schemaCmd.CommandText = sb.ToString();
                schemaCmd.Prepare();
                schemaTable.BeginLoadData();

                //Reset Column Values                
                int Ordinal = 0;
                int batchCount = 0;

                //perform batch query
                using (FbDataReader r = schemaCmd.ExecuteReader())
                {
                    batchCount = 0;//reset batch counter
                    while (r.Read())
                    {                        
                        rdblBatch[batchCount].isReadOnly = (IsReadOnly(r) || IsExpression(r)) ? true : false;
                        rdblBatch[batchCount].isKeyColumn = (r.GetInt32(2) == 1) ? true : false;
                        rdblBatch[batchCount].isUnique = (r.GetInt32(3) == 1) ? true : false;
                        rdblBatch[batchCount].precision = r.IsDBNull(4) ? -1 : r.GetInt32(4);
                        rdblBatch[batchCount].isExpression = IsExpression(r);                      
                        batchCount++;
                    }
                }

                for (int j = 0; j < rdblBatch.Count; j++)
                {
                    Ordinal = rdblBatch[j].Ordinal;
                    // Create new row for the Schema Table
                    schemaRow = schemaTable.NewRow();
                    schemaRow["ColumnName"] = this.GetName(Ordinal);
                    schemaRow["ColumnOrdinal"] = Ordinal;

                    schemaRow["ColumnSize"] = this.fields[Ordinal].GetSize();
                    if (fields[Ordinal].IsDecimal())
                    {
                        schemaRow["NumericPrecision"] = schemaRow["ColumnSize"];
                        if (rdblBatch[j].precision > 0)
                        {
                            schemaRow["NumericPrecision"] = rdblBatch[j].precision;
                        }
                        schemaRow["NumericScale"] = this.fields[Ordinal].NumericScale * (-1);
                    }
                    schemaRow["DataType"] = this.GetFieldType(Ordinal);
                    schemaRow["ProviderType"] = this.GetProviderType(Ordinal);
                    schemaRow["IsLong"] = this.fields[Ordinal].IsLong();
                    schemaRow["AllowDBNull"] = this.fields[Ordinal].AllowDBNull();
                    schemaRow["IsRowVersion"] = false;
                    schemaRow["IsAutoIncrement"] = false;
                    schemaRow["IsReadOnly"] = rdblBatch[j].isReadOnly;
                    schemaRow["IsKey"] = rdblBatch[j].isKeyColumn;
                    schemaRow["IsUnique"] = rdblBatch[j].isUnique;
                    schemaRow["IsAliased"] = this.fields[Ordinal].IsAliased();
                    schemaRow["IsExpression"] = rdblBatch[j].isExpression;
                    schemaRow["BaseSchemaName"] = DBNull.Value;
                    schemaRow["BaseCatalogName"] = DBNull.Value;
                    schemaRow["BaseTableName"] = this.fields[Ordinal].Relation;
                    schemaRow["BaseColumnName"] = this.fields[Ordinal].Name;

                    schemaTable.Rows.Add(schemaRow);

                    if (!String.IsNullOrEmpty(this.fields[Ordinal].Relation) && currentTable != this.fields[Ordinal].Relation)
                    {
                        tableCount++;
                        currentTable = this.fields[Ordinal].Relation;
                    }
                }
                schemaTable.EndLoadData();
                rdblBatch=null;
            }//Finish Batch Round Iteration          


            schemaCmd.Close();
            if (tableCount > 1)
            {
                foreach (DataRow row in schemaTable.Rows)
                {
                    row["IsKey"] = false;
                    row["IsUnique"] = false;
                }
            }

            //Dispose command
            schemaCmd.Dispose();
            relationList = null;
            fieldList = null;
            return schemaTable;
        }
        

		
		public override int GetOrdinal(string name)
		{
			this.CheckState();

			return this.GetColumnIndex(name);
		}

		public override string GetName(int i)
		{
			this.CheckState();
			this.CheckIndex(i);

			if (this.fields[i].Alias.Length > 0)
			{
				return this.fields[i].Alias;
			}
			else
			{
				return this.fields[i].Name;
			}
		}

		public override string GetDataTypeName(int i)
		{
			this.CheckState();
			this.CheckIndex(i);

			return TypeHelper.GetDataTypeName(this.fields[i].DbDataType);
		}

		public override Type GetFieldType(int i)
		{
			this.CheckState();
			this.CheckIndex(i);

			return this.fields[i].GetSystemType();
		}

		public override Type GetProviderSpecificFieldType(int i)
		{
			return this.GetFieldType(i);
		}

		public override object GetProviderSpecificValue(int i)
		{
			return this.GetValue(i);
		}

		public override int GetProviderSpecificValues(object[] values)
		{
			return this.GetValues(values);
		}

		public override object GetValue(int i)
		{
#if ((NET_35 && ENTITY_FRAMEWORK) || (NET_40))
			// type coercions for EF
			// I think only bool datatype needs to be done explicitly
			if (this.command.ExpectedColumnTypes != default(System.Data.Metadata.Edm.PrimitiveType[]))
				if (this.command.ExpectedColumnTypes[i].ClrEquivalentType == typeof(bool))
				{
					return this.GetBoolean(i);
				}
#endif

			this.CheckState();
			this.CheckPosition();
			this.CheckIndex(i);

			return CheckedGetValue(() => this.row[i].Value);
		}

		public override int GetValues(object[] values)
		{
			this.CheckState();
			this.CheckPosition();

			for (int i = 0; i < this.fields.Count; i++)
			{
				values[i] = CheckedGetValue(() => this.GetValue(i));
			}

			return values.Length;
		}

		public override bool GetBoolean(int i)
		{
			this.CheckPosition();
			this.CheckIndex(i);

			return CheckedGetValue(() => this.row[i].GetBoolean());
		}

		public override byte GetByte(int i)
		{
			this.CheckPosition();
			this.CheckIndex(i);

			return CheckedGetValue(() => this.row[i].GetByte());
		}

		public override long GetBytes(
			int i,
			long dataIndex,
			byte[] buffer,
			int bufferIndex,
			int length)
		{
			this.CheckPosition();
			this.CheckIndex(i);

			int bytesRead = 0;
			int realLength = length;

			if (buffer == null)
			{
				if (this.IsDBNull(i))
				{
					return 0;
				}
				else
				{
					return CheckedGetValue(() => (byte[])row[i].GetBinary()).Length;
				}
			}
			else
			{
				byte[] byteArray = CheckedGetValue(() => (byte[])row[i].GetBinary());

				if (length > (byteArray.Length - dataIndex))
				{
					realLength = byteArray.Length - (int)dataIndex;
				}

				Array.Copy(byteArray, (int)dataIndex, buffer, bufferIndex, realLength);

				if ((byteArray.Length - dataIndex) < length)
				{
					bytesRead = byteArray.Length - (int)dataIndex;
				}
				else
				{
					bytesRead = length;
				}

				return bytesRead;
			}
		}

		[EditorBrowsable(EditorBrowsableState.Never)]
		public override char GetChar(int i)
		{
			this.CheckPosition();
			this.CheckIndex(i);

			return CheckedGetValue(() => this.row[i].GetChar());
		}

		public override long GetChars(
			int i,
			long dataIndex,
			char[] buffer,
			int bufferIndex,
			int length)
		{
			this.CheckPosition();
			this.CheckIndex(i);

			if (buffer == null)
			{
				if (this.IsDBNull(i))
				{
					return 0;
				}
				else
				{
					return (CheckedGetValue(() => (string)this.GetValue(i))).ToCharArray().Length;
				}
			}
			else
			{

				char[] charArray = (CheckedGetValue(() => (string)this.GetValue(i))).ToCharArray();

				int charsRead = 0;
				int realLength = length;

				if (length > (charArray.Length - dataIndex))
				{
					realLength = charArray.Length - (int)dataIndex;
				}

				System.Array.Copy(charArray, (int)dataIndex, buffer,
					bufferIndex, realLength);

				if ((charArray.Length - dataIndex) < length)
				{
					charsRead = charArray.Length - (int)dataIndex;
				}
				else
				{
					charsRead = length;
				}

				return charsRead;
			}
		}

		public override Guid GetGuid(int i)
		{
			this.CheckPosition();
			this.CheckIndex(i);

			return CheckedGetValue(() => this.row[i].GetGuid());
		}

		public override Int16 GetInt16(int i)
		{
			this.CheckPosition();
			this.CheckIndex(i);

			return CheckedGetValue(() => this.row[i].GetInt16());
		}

		public override Int32 GetInt32(int i)
		{
			this.CheckPosition();
			this.CheckIndex(i);

			return CheckedGetValue(() => this.row[i].GetInt32());
		}

		public override Int64 GetInt64(int i)
		{
			this.CheckPosition();
			this.CheckIndex(i);

			return CheckedGetValue(() => this.row[i].GetInt64());
		}

		public override float GetFloat(int i)
		{
			this.CheckPosition();
			this.CheckIndex(i);

			return CheckedGetValue(() => this.row[i].GetFloat());
		}

		public override double GetDouble(int i)
		{
			this.CheckPosition();
			this.CheckIndex(i);

			return CheckedGetValue(() => this.row[i].GetDouble());
		}

		public override string GetString(int i)
		{
			this.CheckPosition();
			this.CheckIndex(i);

			return CheckedGetValue(() => this.row[i].GetString());
		}

		public override Decimal GetDecimal(int i)
		{
			this.CheckPosition();
			this.CheckIndex(i);

			return CheckedGetValue(() => this.row[i].GetDecimal());
		}

		public override DateTime GetDateTime(int i)
		{
			this.CheckPosition();
			this.CheckIndex(i);

			return CheckedGetValue(() => this.row[i].GetDateTime());
		}

		public override bool IsDBNull(int i)
		{
			this.CheckPosition();
			this.CheckIndex(i);

			return this.row[i].IsDBNull();
		}

		public override IEnumerator GetEnumerator()
		{
			return new DbEnumerator(this, this.IsCommandBehavior(CommandBehavior.CloseConnection));
		}

		public override bool NextResult()
		{
			return false;
		}

		#endregion

		#region · Private Methods ·

		private void CheckPosition()
		{
			if (this.eof || this.position == STARTPOS)
			{
				throw new InvalidOperationException("There are no data to read.");
			}
		}

		private void CheckState()
		{
			if (this.IsClosed)
			{
				throw new InvalidOperationException("Invalid attempt of read when the reader is closed.");
			}
		}

		private void CheckIndex(int i)
		{
			if (i < 0 || i >= this.FieldCount)
			{
				throw new IndexOutOfRangeException("Could not find specified column in results.");
			}
		}

		private FbDbType GetProviderType(int i)
		{
			return (FbDbType)this.fields[i].DbDataType;
		}

		private void UpdateRecordsAffected()
		{
			if (this.command != null && !this.command.IsDisposed)
			{
				if (this.command.RecordsAffected != -1)
				{
					this.recordsAffected = this.recordsAffected == -1 ? 0 : this.recordsAffected;
					this.recordsAffected += this.command.RecordsAffected;
				}
			}
		}

		private bool IsCommandBehavior(CommandBehavior behavior)
		{
			return this.commandBehavior.HasFlag(behavior);
		}

		private void InitializeColumnsIndexes()
		{
			columnsIndexesOrdinal = new Dictionary<string, int>(this.fields.Count, StringComparer.Ordinal);
			columnsIndexesOrdinalCI = new Dictionary<string, int>(this.fields.Count, StringComparer.OrdinalIgnoreCase);
			columnsIndexesInvariantCI = new Dictionary<string, int>(this.fields.Count, StringComparer.InvariantCultureIgnoreCase);
			for (int i = 0; i < this.fields.Count; i++)
			{
				string fieldName = this.fields[i].Alias;
				if (!columnsIndexesOrdinal.ContainsKey(fieldName))
					columnsIndexesOrdinal.Add(fieldName, i);
				if (!columnsIndexesOrdinalCI.ContainsKey(fieldName))
					columnsIndexesOrdinalCI.Add(fieldName, i);
				if (!columnsIndexesInvariantCI.ContainsKey(fieldName))
					columnsIndexesInvariantCI.Add(fieldName, i);
			}
		}

		private int GetColumnIndex(string name)
		{
			if (columnsIndexesOrdinal == null || columnsIndexesOrdinalCI == null || columnsIndexesInvariantCI == null)
			{
				this.InitializeColumnsIndexes();
			}
			int index;
			if (!columnsIndexesOrdinal.TryGetValue(name, out index))
				if (!columnsIndexesOrdinalCI.TryGetValue(name, out index))
					if (!columnsIndexesInvariantCI.TryGetValue(name, out index))
							throw new IndexOutOfRangeException("Could not find specified column in results.");
			return index;
		}

		#endregion

		#region · Static Methods ·

		private static bool IsReadOnly(FbDataReader r)
		{
			return IsExpression(r);
		}

		public static bool IsExpression(FbDataReader r)
		{
			/* [0] = COMPUTED_BLR
			 * [1] = COMPUTED_SOURCE
			 */
			if (!r.IsDBNull(0) || !r.IsDBNull(1))
			{
				return true;
			}

			return false;
		}

		private static DataTable GetSchemaTableStructure()
		{
			DataTable schema = new DataTable("Schema");

			// Schema table structure
			schema.Columns.Add("ColumnName", System.Type.GetType("System.String"));
			schema.Columns.Add("ColumnOrdinal", System.Type.GetType("System.Int32"));
			schema.Columns.Add("ColumnSize", System.Type.GetType("System.Int32"));
			schema.Columns.Add("NumericPrecision", System.Type.GetType("System.Int32"));
			schema.Columns.Add("NumericScale", System.Type.GetType("System.Int32"));
			schema.Columns.Add("DataType", System.Type.GetType("System.Type"));
			schema.Columns.Add("ProviderType", System.Type.GetType("System.Int32"));
			schema.Columns.Add("IsLong", System.Type.GetType("System.Boolean"));
			schema.Columns.Add("AllowDBNull", System.Type.GetType("System.Boolean"));
			schema.Columns.Add("IsReadOnly", System.Type.GetType("System.Boolean"));
			schema.Columns.Add("IsRowVersion", System.Type.GetType("System.Boolean"));
			schema.Columns.Add("IsUnique", System.Type.GetType("System.Boolean"));
			schema.Columns.Add("IsKey", System.Type.GetType("System.Boolean"));
			schema.Columns.Add("IsAutoIncrement", System.Type.GetType("System.Boolean"));
			schema.Columns.Add("IsAliased", System.Type.GetType("System.Boolean"));
			schema.Columns.Add("IsExpression", System.Type.GetType("System.Boolean"));
			schema.Columns.Add("BaseSchemaName", System.Type.GetType("System.String"));
			schema.Columns.Add("BaseCatalogName", System.Type.GetType("System.String"));
			schema.Columns.Add("BaseTableName", System.Type.GetType("System.String"));
			schema.Columns.Add("BaseColumnName", System.Type.GetType("System.String"));

			return schema;
		}

        private static string GetSchemaCommandText()
        {
            const string sql =
                @"SELECT
					fld.rdb$computed_blr AS computed_blr,
					fld.rdb$computed_source AS computed_source,
					(SELECT COUNT(*) FROM rdb$relation_constraints rel 
					  INNER JOIN rdb$indices idx ON rel.rdb$index_name = idx.rdb$index_name
					  INNER JOIN rdb$index_segments seg ON idx.rdb$index_name = seg.rdb$index_name
					WHERE rel.rdb$constraint_type = 'PRIMARY KEY'
					  AND rel.rdb$relation_name = rfr.rdb$relation_name
					  AND seg.rdb$field_name = rfr.rdb$field_name) AS primary_key,
					(SELECT COUNT(*) FROM rdb$relation_constraints rel
					  INNER JOIN rdb$indices idx ON rel.rdb$index_name = idx.rdb$index_name
					  INNER JOIN rdb$index_segments seg ON idx.rdb$index_name = seg.rdb$index_name
					WHERE rel.rdb$constraint_type = 'UNIQUE'
					  AND rel.rdb$relation_name = rfr.rdb$relation_name
					  AND seg.rdb$field_name = rfr.rdb$field_name) AS unique_key,
					fld.rdb$field_precision AS numeric_precision
				  FROM rdb$relation_fields rfr
					INNER JOIN rdb$fields fld ON rfr.rdb$field_source = fld.rdb$field_name
				  WHERE rfr.rdb$relation_name = ?
					AND rfr.rdb$field_name = ?
				  ORDER BY rfr.rdb$relation_name, rfr.rdb$field_position";

            return sql;
        }      
   
        

    
		private static T CheckedGetValue<T>(System.Func<T> f)
		{
			try
			{
				return f();
			}
			catch (IscException ex)
			{
				throw new FbException(ex.Message, ex);
			}
		}

		#endregion
	}
}
