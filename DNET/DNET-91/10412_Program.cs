using System;
using System.IO;
using System.Threading;
using System.Transactions;
using FirebirdSql.Data.FirebirdClient;

namespace TestFirebird
{
    // This program simulates a bad outcome of a race condition
    // cause by the internal connection being placed back inthe connection pool when
    // FbConnection.Close is called.
    //
    // The program uses a lock to ensure the problem always occurs.  In actual use
    // the problem will intermitent
    internal class Program
    {
        private static object _lock = new object();
        private static int _state = 0;

        private static string _connectString =
            "Database=junk.fdb;ServerType=1;enlist=true;pooling=true;connection lifetime=10";

        private static WaitCallback _thread0 = delegate
                                                   {
                                                       FbConnection connect = new FbConnection(_connectString);
                                                       using (TransactionScope t = new TransactionScope())
                                                       {
                                                           // open pulls an internal connection out of the pool 
                                                           connect.Open();
                                                           // close puts the internal connection back, which is wrong
                                                           // Microsoft examples show Close being called within the TransactionScope
                                                           // so this should work.
                                                           connect.Close();

                                                           // this code makes the race condition occur
                                                           // any time another thread runs between the time Close is called
                                                           // and the transaction completes, problems can occur
                                                           lock (_lock)
                                                           {
                                                               _state = 1;
                                                               Monitor.PulseAll(_lock);
                                                               while (_state < 2)
                                                               {
                                                                   Monitor.Wait(_lock);
                                                               }
                                                           }
                                                       }

                                                       // let the main complete
                                                       lock (_lock)
                                                       {
                                                           _state = 3;
                                                           Monitor.PulseAll(_lock);
                                                       }
                                                   };

        private static WaitCallback _thread1 = delegate
                                                   {
                                                       FbConnection connect = new FbConnection(_connectString);
                                                       // wait for the other thread to close its connection
                                                       lock (_lock)
                                                       {
                                                           while (_state < 1)
                                                           {
                                                               Monitor.Wait(_lock);
                                                           }
                                                       }
                                                       using (TransactionScope t = new TransactionScope())
                                                       {
                                                           try
                                                           {
                                                               // this fails because inner connection is placed back in the pool while its transaction is still active
                                                               // the Open statement grabs the pooled internal connection that the other thread put back in the pool
                                                               // with an active tranaction.
                                                               connect.Open();

                                                               // never gets here
                                                               Console.WriteLine("Open succeeded");
                                                               connect.Close();
                                                           }
                                                           catch (Exception e)
                                                           {
                                                               Console.WriteLine(e);
                                                           }


                                                           lock (_lock)
                                                           {
                                                               // let the other transaction complete
                                                               _state = 2;
                                                               Monitor.PulseAll(_lock);
                                                           }
                                                       }
                                                   };

        private static void Main(string[] args)
        {
            if (File.Exists("junk.fdb"))
            {
                File.Delete("junk.fdb");
            }
            FbConnection.CreateDatabase(_connectString);
            ThreadPool.QueueUserWorkItem(_thread0);
            ThreadPool.QueueUserWorkItem(_thread1);

            // wait for both threads to finish
            lock (_lock)
            {
                while (_state < 3)
                {
                    Monitor.Wait(_lock);
                }
            }
        }
    }
}