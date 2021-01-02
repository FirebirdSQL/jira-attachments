using FirebirdSql.Data.FirebirdClient;
using System;
using System.Diagnostics;
using System.IO;

namespace FirebirdTest
{
	class Program
	{
		static string installationFolder = Environment.CurrentDirectory;
		static string databaseFilePath = Path.Combine(installationFolder, "Database\\EMPLOYEE.FDB");

		private static string clientLibraryPath = Path.Combine(installationFolder, "Firebird\\fbclient.dll");

		static string embeddedConnectionString =
			"initial catalog={0};user id=SYSDBA;password=masterkey;server type=Embedded;character set=UTF8;no garbage collect=False;client library={1};pooling=True;dialect=3;max pool size=200;min pool size=1";

		static string serverConnectionString =
			"initial catalog={0};user id=SYSDBA;password=masterkey2;DataSource=localhost;Port=3051;character set=UTF8;no garbage collect=False;pooling=True;dialect=3;max pool size=200;min pool size=1";

		static string connectionString = String.Format(embeddedConnectionString, databaseFilePath, clientLibraryPath);

		public static void Main(string[] args)
		{
			const int limit = 1000;
			var counter = 1;

			Stopwatch watch = Stopwatch.StartNew();

			while (true)
			{
				ReadAllCountries();

				if (counter >= limit)
				{
					var time = watch.Elapsed;
					Console.WriteLine("Time for {0} read commands: {1:ss\\.fff}", limit, time);
					watch.Restart();
					counter = 1;
				}
				else
				{
					counter++;
				}
			}
		}

		private static void ReadAllCountries()
		{
			using (var connection = new FbConnection(connectionString))
			{
				connection.Open();
				using (var command = connection.CreateCommand())
				{
					command.CommandText = "SELECT FIRST 1 COUNTRY FROM COUNTRY";

					using (var reader = command.ExecuteReader())
					{
						while (reader.Read())
						{
							var country = reader.GetString(0);
						}
					}
				}
			}
		}
	}
}