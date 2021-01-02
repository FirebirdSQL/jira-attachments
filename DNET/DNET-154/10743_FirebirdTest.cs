using System;
using System.Collections.Generic;
using System.Text;

using FirebirdSql.Data.FirebirdClient;

namespace FirebirdTest
{
    class Program
    {
        static void Main(string[] args)
        {
            FbConnectionStringBuilder fbcsb = new FbConnectionStringBuilder();
            fbcsb.DataSource = "firebird21";
            fbcsb.UserID = "SYSDBA";
            fbcsb.Password = "masterkey";
            fbcsb.Database = "employee";
            FbConnection connection = new FbConnection(fbcsb.ToString());
            connection.Open();

            string badCmd = "INSERT INTO CUSTOMER (CONTACT_FIRST) VALUES ('TEST') RETURNING CUST_NO";
            string goodCmd = "INSERT INTO CUSTOMER (CUSTOMER) VALUES ('TEST') RETURNING CUST_NO";

            FbTransaction trans = connection.BeginTransaction();
            FbCommand cmd = new FbCommand(badCmd, connection, trans);
            
            int custNo;
            try
            {
                custNo = (int)cmd.ExecuteScalar();
                trans.Commit();
            }
            catch(FbException fbex)
            {
                Console.WriteLine(fbex.ToString());
                trans.Rollback();
            }

            cmd.CommandText = goodCmd;
            trans = connection.BeginTransaction();
            cmd.Transaction = trans;
            custNo = (int)cmd.ExecuteScalar();
            trans.Commit();
            Console.WriteLine("CUST_NO: {0}", custNo);

        }
    }
}
