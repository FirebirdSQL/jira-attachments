using System;
using System.Data;

using FirebirdSql.Data.FirebirdClient;
using NUnit.Framework;

namespace FirebirdSql.Data.UnitTests
{
	/// <summary>
	/// All the test in this TestFixture are using implicit transaction support.
	/// </summary>
	[TestFixture]
	public class GuidTests : TestsBase
	{
		#region · Constructors ·

		public GuidTests()
			: base()
		{
		}

		#endregion

		#region · Unit Tests ·

		[Test]
		public void GuidMappingTest()
		{
			FbCommand createTable = new FbCommand("CREATE TABLE GUID_TEST (INT_FIELD INTEGER, GUID_FIELD CHAR(16) CHARACTER SET OCTETS)", Connection);
			createTable.ExecuteNonQuery();
			createTable.Dispose();

		  var patternGuid = Guid.NewGuid();

			// Insert the Guid
			FbCommand insert = new FbCommand("INSERT INTO GUID_TEST (INT_FIELD, GUID_FIELD) VALUES (@IntField, @GuidValue)", Connection);
			insert.Parameters.Add("@IntField", FbDbType.Integer).Value = this.GetId();
      insert.Parameters.Add("@GuidValue", FbDbType.Guid).Value = patternGuid;
			insert.ExecuteNonQuery();
			insert.Dispose();

			// Select the value
      FbCommand select = new FbCommand("SELECT INT_FIELD, GUID_FIELD, UUID_TO_CHAR(GUID_FIELD) AS FBGUID FROM GUID_TEST", Connection);
			using (FbDataReader r = select.ExecuteReader())
			{
				if (r.Read())
				{
				  var providerGuid = r.GetGuid(1);
          Console.WriteLine("patternGuid  = {0}", patternGuid);
          Console.WriteLine("providerGuid = {0}", providerGuid);
          Assert.AreEqual(patternGuid, providerGuid);
				  var fbGuidStr = r.GetString(2);
				  var fbGuid = new Guid(fbGuidStr);
          Console.WriteLine("rfc4122Guid  = {0}", fbGuid);
          Assert.AreEqual(patternGuid, fbGuid);
				}
			}
		}	
    

		#endregion
	}
}
