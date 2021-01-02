﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using FirebirdSql.Data.FirebirdClient;
using System.Configuration;
using System.Data;

namespace FirebirdConnector
{
    public class FbConnectionException : Exception
    {
        public FbConnectionException(FbException ex) : base("Fb Exception", ex)
        {

        }
        public FbConnectionException(NullReferenceException ex, string item) : base($"{item} Exception", ex)
        {

        }
    }
    public class FirebirdConnector : IDisposable
    {
        private readonly string _interminal = "0101010C";
        private readonly string _outterminal = "0101011D";
        private readonly string _connectionString;

        public FirebirdConnector()
        {
            _connectionString = ConfigurationManager.ConnectionStrings["DatabaseConnection"].ConnectionString;
        }

        public DateTime IntToDateTime(string date, string time)
        {
            var year = Convert.ToInt32(date.Substring(0, 4));
            var month = Convert.ToInt32(date.Substring(4, 2));
            var day = Convert.ToInt32(date.Substring(6, 2));
            var hour = Convert.ToInt32(time.Substring(0, 2));
            var minute = Convert.ToInt32(time.Substring(2, 2));
            var second = Convert.ToInt32(time.Substring(4, 2));
            return new DateTime(year, month, day, hour, minute, second);
        }


        public List<Transact> GetLastRecords()
        {
            using (var connection = new FbConnection(_connectionString))
            {
                try
                {
                    var dates = DateTime.Now;
                    //dates = dates.AddMonths(-4);
                    //dates = dates.AddDays(-18);
                    var transactions = new List<Transact>();
                    //var select = "SELECT TR_SQ,TR_DATE,TR_TIME,TR_TAGCODE,TR_MSTSQ,TR_TAGTYPE,TR_DIRECTION" +
                    //             " FROM transack WHERE TR_TERMSLA IN( '" + _interminal + "','" + _outterminal + "')" +
                    //" AND TR_DATE = " + dates.Year.ToString() + dates.Month.ToString().PadLeft(2, '0') +
                    //dates.Day.ToString().PadLeft(2, '0') + " AND TR_TIME < " + dates.Hour.ToString() +
                    //dates.Minute.ToString().PadLeft(2, '0') + dates.Second.ToString().PadLeft(2, '0');

                    var select = "SELECT FIRST 10 TR_SQ,TR_DATE,TR_TIME,TR_TAGCODE,TR_MSTSQ,TR_TAGTYPE,TR_DIRECTION FROM transack";

                    using (var command = new FbCommand(select, connection))
                    {
                        connection.Open();
                        var result = command.ExecuteReader(CommandBehavior.CloseConnection);
                        if (result == null) return transactions;

                        if (!result.HasRows) return transactions;
                        while (result.Read())
                        {
                            var date = result.TestNull("TR_DATE").ToString();
                            var time = result.TestNull("TR_TIME").ToString().PadLeft(6, '0');
                            transactions.Add(new Transact()
                            {
                                Id = Convert.ToInt64(result.TestNull("TR_SQ")),
                                Date = IntToDateTime(date, time),
                                TagCode = result.TestNull("TR_TAGCODE").ToString(),
                                Mstsqs = result.TestNull("TR_MSTSQ").ToString(),
                                TagType = result.TestNull("TR_TAGTYPE").ToString(),
                                Direction = Convert.ToInt16(result.TestNull("TR_DIRECTION")),
                            });

                        }
                    }
                    return transactions;
                }
                catch (StackOverflowException ex)
                {
                    throw;
                }
                catch (NullReferenceException ex)
                {
                    throw new FbConnectionException(ex, "Firebird Exception");
                }
                catch (FbException ex)
                {
                    throw new FbConnectionException(ex);
                }
                catch (Exception ex)
                {
                    throw;
                }
            }
        }
        
        

        public void Dispose()
        {
            GC.SuppressFinalize(this);
        }
    }

    public static class Extensions
    {

        public static object TestNull(this FbDataReader item, string field)
        {
            if (item[field] == null || item[field] is DBNull)
            {
                throw new Exception($"{field} is null");
            }
            return item[field];
        }
    }
}
