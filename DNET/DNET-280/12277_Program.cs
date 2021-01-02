using System;
using System.Data.Common;
using System.Data.Odbc;

using FirebirdSql.Data.FirebirdClient;

namespace FBNetProviderSpeedTest
{
    class Program
    {
        static void Test(DbConnection connection, string connectionType )
        {
            const int recCount = 100000;

            connection.Open();
            try
            {
                using (var cmd = connection.CreateCommand())
                {
                    cmd.CommandText = "CREATE OR ALTER PROCEDURE sp_test_empty AS BEGIN END";
                    cmd.ExecuteNonQuery();

                    cmd.CommandText = "EXECUTE PROCEDURE sp_test_empty";
                    cmd.Prepare();

                    DateTime start = DateTime.Now;
                    for (var n = 0; n < recCount; ++n)
                        cmd.ExecuteNonQuery();
                    DateTime finish = DateTime.Now;

                    var seconds = (finish - start).TotalSeconds;

                    Console.WriteLine("{0}: {1} commands in {2} seconds; {3} commands per second", connectionType, recCount, seconds, recCount / seconds);
                }
            }
            finally
            {
                connection.Close();
            }
        }

        static void Main(string[] args)
        {
            const string databaseName = @"D:\Temp\Test.fdb";
            Test(new FbConnection(@"server=LOCALHOST;database=" + databaseName + ";username=SYSDBA;password=masterkey;"), "FB.Net");
            Test(new OdbcConnection(@"DRIVER=Firebird/InterBase(r) driver;UID=SYSDBA;PWD=masterkey;DBNAME=" + databaseName + ";"), "ODBC");
            Console.ReadLine();
        }
    }
}
