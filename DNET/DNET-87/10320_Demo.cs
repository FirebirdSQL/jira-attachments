using System;
using System.Threading;
using FirebirdSql.Data.FirebirdClient;

class Demo
{
    static int threadCount = 25;
    static int maxCycles = 500000;

    static void Main(string[] args)
    {
        Console.WriteLine("{0} start, {1} threads, {2} cycles", DateTime.Now, threadCount, maxCycles);

        Thread[] thread = new Thread[threadCount];
        DataAccess[] dataAccess = new DataAccess[threadCount];

        for (int i = 0; i < threadCount; i++)
        {
            dataAccess[i] = new DataAccess(i + 1);

            thread[i] = new Thread(new ThreadStart(dataAccess[i].RunInstance));
            thread[i].Start();
        }

        Console.WriteLine("{0} working ...", DateTime.Now);

        for (int i = 0; i < threadCount; i++)
        {
            thread[i].Join();
        }

        Console.WriteLine("{0} finished", DateTime.Now);
        Console.WriteLine("press any key to close ...");
        Console.ReadLine();
    }

    class DataAccess
    {
        // adapt connection string for your database
        string connectionString = "Server=localhost;Database=Test;User=SYSDBA;Password=masterkey";
        // use a random query on your database
        string commandText = "SELECT 123 FROM RDB$DATABASE";

        int id;
        FbConnection connection;
        FbCommand multipleUsedCommand;

        public DataAccess(int id)
        {
            this.id = id;

            connection = new FbConnection(connectionString);
            multipleUsedCommand = new FbCommand(commandText, connection);
        }

        public void RunInstance()
        {
            int i = 0;
            int errors = 0;
            // restrict number of errors here to avoid endless output
            int maxErrors = 5;

            while (i < maxCycles)
            {
                FbCommand singleUsedCommand = new FbCommand(commandText, connection);

                try
                {
                    connection.Open();

                    object result1 = multipleUsedCommand.ExecuteScalar();
                    object result2 = singleUsedCommand.ExecuteScalar();

                    // following line prevents errors
                    //singleUsedCommand.Dispose();
                }
                catch (Exception ex)
                {
                    Console.WriteLine("{0} instance {1}, cycle {2}, {3}", DateTime.Now, id, i + 1, ex.Message);
                    if (errors < maxErrors) errors++; else break;
                }
                finally
                {
                    connection.Close();
                    i++;
                }

                // inner connection can be used by another instance
                Thread.Sleep(50);
            }
        }
    }
}    
