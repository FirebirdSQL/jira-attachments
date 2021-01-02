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
 *  Copyright (c) 2004, 2005 Carlos Guzman Alvarez
 *  All Rights Reserved.
 */

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data.Common;
using System.Globalization;
using System.Reflection;
using System.Transactions;

namespace FirebirdSql.Data.FirebirdClient
{
    public sealed class FbConnectionStringBuilder : DbConnectionStringBuilder
    {
        #region Fields
        private static Dictionary<string, string> _keywords;
        private static Dictionary<string, PropertyDefaultValue> defaultValues;
        #endregion

        #region Constructors
        static FbConnectionStringBuilder()
        {
            InitializeKeywords();
            InitializeDefaults();
        }

        public FbConnectionStringBuilder()
            : this(String.Empty)
        {
        }

        public FbConnectionStringBuilder(string connectionString)
        {
            base.ConnectionString = connectionString;
        }
        #endregion

        #region Properties
        /// <summary>
        /// Gets or sets the firebird User account for login.
        /// </summary>
        [Category("Security")]
        [DisplayName("User ID")]
        [Description("Indicates the User ID to be used when connecting to the data source.")]
        [DefaultValue("")]
        [RefreshProperties(RefreshProperties.All)]
        public string UserID
        {
            get { return Convert.ToString(base["User Id"]); }
            set { base["User Id"] = value; }
        }

        /// <summary>
        /// Gets ort sets the password for the Firebird user account.
        /// </summary>
        [Category("Security")]
        [DisplayName("Password")]
        [Description("Indicates the password to be used when connecting to the data source.")]
        [PasswordPropertyText(true)]
        [DefaultValue("")]
        [RefreshProperties(RefreshProperties.All)]
        public string Password
        {
            get { return Convert.ToString(base["Password"]); }
            set { base["Password"] = value; }
        }


        /// <summary>
        /// Gets the name of the Firebird Server to which to connect. 
        /// </summary>
        /// <value>The server.</value>
        [Category("Connection")]
        [DisplayName("DataSource")]
        [Description("The name of the Firebird server to which to connect.")]
        [DefaultValue("")]
        [RefreshProperties(RefreshProperties.All)]
        public string DataSource
        {
            get { return Convert.ToString(base["Data Source"]); }
            set { base["Data Source"] = value; }
        }

        /// <summary>
        /// Gets the name of the actual database or the database to be used 
        /// when a connection is open. 
        /// </summary>
        [Category("Connection")]
        [DisplayName("Database")]
        [Description("The name of the actual database or the database to be used when a connection is open.")]
        [DefaultValue("")]
        [RefreshProperties(RefreshProperties.All)]
        public string Database
        {
            get { return Convert.ToString(base["Initial Catalog"]); }
            set { base["Initial Catalog"] = value; }
        }
        /// <summary>
        /// Gets or sets the port number in the server for establish the 
        /// connection.
        /// </summary>
        [Category("Connection")]
        [DisplayName("Port")]
        [Description("Port to use for TCP/IP connections")]
        [DefaultValue(3050)]
        [RefreshProperties(RefreshProperties.All)]
        public int Port
        {
            get { return Convert.ToInt32(base["Port Number"]); }
            set { base["Port Number"] = value; }
        }

        /// <summary>
        /// Gets or sets the size (in bytes) of network packets used to 
        /// communicate with an instance of Firebird Server. 
        /// </summary>
        [Category("Advanced")]
        [DisplayName("PacketSize")]
        [Description("The size (in bytes) of network packets. PacketSize may be in the range 512-32767 bytes.")]
        [DefaultValue(8192)]
        [RefreshProperties(RefreshProperties.All)]
        public int PacketSize
        {
            get { return Convert.ToInt32(base["Packet Size"]); }
            set { base["Packet Size"] = value; }
        }

        /// <summary>
        /// Gets or sets the user role name.
        /// </summary>
        [Category("Security")]
        [DisplayName("Role")]
        [Description("The user role.")]
        [DefaultValue("")]
        [RefreshProperties(RefreshProperties.All)]
        public string Role
        {
            get { return Convert.ToString(base["Role Name"]); }
            set { base["Role Name"] = value; }
        }

        /// <summary>
        /// Gets or sets the database dialect.
        /// </summary>
        [Category("Advanced")]
        [DisplayName("Dialect")]
        [Description("The database dialect.")]
        [DefaultValue(3)]
        [RefreshProperties(RefreshProperties.All)]
        public int Dialect
        {
            get { return Convert.ToInt32(base["Dialect"]); }
            set { base["Dialect"] = value; }
        }

        /// <summary>
        /// Gets or sets the connection character set.
        /// </summary>
        [Category("Advanced")]
        [DisplayName("Character Set")]
        [Description("The connection character set")]
        [DefaultValue("NONE")]
        [RefreshProperties(RefreshProperties.All)]
        public string Charset
        {
            get { return Convert.ToString(base["Character Set"]); }
            set { base["Character Set"] = value; }
        }

        /// <summary>
        /// Gets the time to wait while trying to establish a connection before 
        /// terminating the attempt and generating an error. 
        /// </summary>
        [Category("Connection")]
        [DisplayName("Connection Timeout")]
        [Description("The time (in seconds) to wait for a connection to open.")]
        [DefaultValue(15)]
        [RefreshProperties(RefreshProperties.All)]
        public int ConnectionTimeout
        {
            get { return Convert.ToInt32(base["Connection Timeout"]); }
            set { base["Connection Timeout"] = value; }
        }

        /// <summary>
        /// Gets or sets the status of the connection pooling
        /// (enabled/disabled).
        /// </summary>
        [Category("Advanced")]
        [DisplayName("Pooling")]
        [Description("The connection is created and added to the appropriate pool.")]
        [DefaultValue(true)]
        [RefreshProperties(RefreshProperties.All)]
        public bool Pooling
        {
            get { return Convert.ToBoolean(base["Pooling"]); }
            set { base["Pooling"] = value; }
        }

        /// <summary>
        /// Gets or sets the lifetime of a connection in the pool.
        /// </summary>
        [Category("Connection")]
        [DisplayName("Connection LifeTime")]
        [Description("When a connection is returned to the pool, its creation " +
            "time is compared with the current time, and the connection is " +
            "destroyed if that time span (in seconds) exceeds the value " +
            "specified by connection lifetime.")]
        [DefaultValue(0)]
        [RefreshProperties(RefreshProperties.All)]
        public int ConnectionLifeTime
        {
            get { return Convert.ToInt32(base["Connection Lifetime"]); }
            set { base["Connection Lifetime"] = value; }
        }

        /// <summary>
        /// Gets or sets the minumun pool size.
        /// </summary>
        [Category("Advanced")]
        [DisplayName("MinPoolSize")]
        [Description("The minimun number of connections allowed in the pool.")]
        [DefaultValue(0)]
        [RefreshProperties(RefreshProperties.All)]
        public int MinPoolSize
        {
            get { return Convert.ToInt32(base["Min Pool Size"]); }
            set { base["Min Pool Size"] = value; }
        }

        /// <summary>
        /// Gets or sets the maximun pool size.
        /// </summary>
        [Category("Advanced")]
        [DisplayName("MaxPoolSize")]
        [Description("The maximum number of connections allowed in the pool.")]
        [DefaultValue(100)]
        [RefreshProperties(RefreshProperties.All)]
        public int MaxPoolSize
        {
            get { return Convert.ToInt32(base["Max Pool Size"]); }
            set { base["Max Pool Size"] = value; }
        }

        /// <summary>
        /// Indicates the number of rows that will be fetched at the same time 
        /// on read calls into the internal row buffer.
        /// </summary>
        [Category("Advanced")]
        [DisplayName("FetchSize")]
        [Description("The maximun number of rows to be fetched in a single " +
            "call to read into the internal row buffer.")]
        [DefaultValue(200)]
        [RefreshProperties(RefreshProperties.All)]
        public int FetchSize
        {
            get { return Convert.ToInt32(base["Fetch Size"]); }
            set { base["Fetch Size"] = value; }
        }

        /// <summary>
        /// Gets or sets the server type to wich we want to connect.
        /// </summary>
        [Category("Connection")]
        [DisplayName("ServerType")]
        [Description("The type of server used.")]
        [DefaultValue(FbServerType.Default)]
        [RefreshProperties(RefreshProperties.All)]
        public FbServerType ServerType
        {
            get { return (FbServerType)Enum.Parse(typeof(FbServerType), base["Server Type"].ToString()); }
            set { base["Server Type"] = value; }
        }

        /// <summary>
        /// Gets or sets the default Isolation Level for implicit transactions.
        /// </summary>
        [Category("Advanced")]
        [DisplayName("IsolationLevel")]
        [Description("The default Isolation Level for implicit transactions.")]
        [DefaultValue(IsolationLevel.ReadCommitted)]
        [RefreshProperties(RefreshProperties.All)]
        public IsolationLevel IsolationLevel
        {
            get { return (IsolationLevel)Enum.Parse(typeof(IsolationLevel), base["Isolation Level"].ToString()); }
            set { base["Isolation Level"] = value; }
        }

        /// <summary>
        /// Gets or sets the situation where it can get the number of rows 
        /// affected by the command.
        /// </summary>
        [Category("Advanced")]
        [DisplayName("Records Affected")]
        [Description("Get the number of rows affected by a command when true.")]
        [DefaultValue(true)]
        [RefreshProperties(RefreshProperties.All)]
        public bool ReturnRecordsAffected
        {
            get { return Convert.ToBoolean(base["Records Affected"]); }
            set { base["Records Affected"] = value; }
        }

        /// <summary>
        /// Gets or sets the situation where connection should use the Fyracle 
        /// External Procedure Engine GDS.
        /// </summary>
        [Category("Advanced")]
        [DisplayName("ContextConnection")]
        //[Description("")]
        [DefaultValue(false)]
        [RefreshProperties(RefreshProperties.All)]
        public bool ContextConnection
        {
            get { return Convert.ToBoolean(base["Context Connection"]); }
            set { base["Context Connection"] = value; }
        }

        [Category("Advanced")]
        [DisplayName("Enlist")]
        //[Description("")]
        [DefaultValue(false)]
        [RefreshProperties(RefreshProperties.All)]
        public bool Enlist
        {
            get { return Convert.ToBoolean(base["Enlist"]); }
            set { base["Enlist"] = value; }
        }

        [Category("Advanced")]
        [DisplayName("Client Library")]
        //[Description("")]
        [DefaultValue("fbembed")]
        [RefreshProperties(RefreshProperties.All)]
        public string ClientLibrary
        {
            get { return Convert.ToString(base["Client Library"]); }
            set { base["Client Library"] = value; }
        }

        [Category("Advanced")]
        [DisplayName("Db Cache Pages")]
        //[Description("")]
        [DefaultValue(0)]
        [RefreshProperties(RefreshProperties.All)]
        public int DbCachePages
        {
            get { return Convert.ToInt32(base["Cache Pages"]); }
            set { base["Cache Pages"] = value; }
        }

        public override bool IsFixedSize
        {
            get { return true; }
        }

        public override object this[string keyword]
        {
            get
            {
                string mapped = MapKeyword(keyword);
                if (this.ContainsKey(mapped))
                {
                    return base[mapped];
                }
                else
                {
                    return defaultValues[mapped].DefaultValue;
                }
            }
            set { SetValue(keyword, value); }
        }
        #endregion

        #region Methods
        public override bool ContainsKey(string keyword)
        {
            keyword = keyword.ToUpper().Trim();
            if (_keywords.ContainsKey(keyword))
            {
                return base.ContainsKey(_keywords[keyword]);
            }
            return false;
        }

        public override bool Remove(string keyword)
        {
            if (!ContainsKey(keyword))
            {
                return false;
            }
            this[keyword] = null;
            return true;
        }

        public override bool ShouldSerialize(string keyword)
        {
            if (!ContainsKey(keyword))
            {
                return false;
            }

            // Assuming passwords cannot be serialized.
            keyword = keyword.ToUpper().Trim();
            if (_keywords[keyword] == "PASSWORD")
            {
                return false;
            }

            return base.ShouldSerialize(_keywords[keyword]);
        }

        public override bool TryGetValue(string keyword, out object value)
        {
            if (!ContainsKey(keyword))
            {
                keyword = MapKeyword(keyword);
                if (defaultValues.ContainsKey(keyword))
                {
                    value = defaultValues[keyword].DefaultValue;
                    return true;
                }
                value = null;
                return false;
            }

            keyword = MapKeyword(keyword);
            bool result = base.TryGetValue(_keywords[keyword.ToUpper().Trim()], out value);

            if (defaultValues[keyword].Type.IsEnum)
            {
                value = Enum.Parse(defaultValues[keyword].Type, value.ToString());
            }
            else
            {
                value = Convert.ChangeType(value, defaultValues[keyword].Type);
            }

            return result;
        }
        #endregion

        #region Private Methods
        private string MapKeyword(string keyword)
        {
            keyword = keyword.ToUpper().Trim();
            if (!_keywords.ContainsKey(keyword))
                throw new ArgumentException("Keyword not supported :" + keyword);
            return _keywords[keyword];
        }

        private void SetValue(string key, object value)
        {
            if (key == null)
                throw new ArgumentNullException("Key cannot be null!");

            string mappedKey = MapKeyword(key);

            base.Remove(mappedKey);
            if (value != null)
            {
                if (defaultValues[mappedKey].Type.IsEnum == true)
                {
                    base[mappedKey] = Enum.Parse(defaultValues[mappedKey].Type, value.ToString());
                }
                else
                {
                    base[mappedKey] = Convert.ChangeType(value, defaultValues[mappedKey].Type);
                }
            }
        }

        private static void InitializeKeywords()
        {
            _keywords = new Dictionary<string, string>();

            _keywords["USER ID"] = "User Id";
            _keywords["USERID"] = "User Id";
            _keywords["UID"] = "User Id";
            _keywords["USER"] = "User Id";
            _keywords["USERNAME"] = "User Id";
            _keywords["USER NAME"] = "User Id";
            _keywords["PASSWORD"] = "Password";
            _keywords["PWD"] = "Password";
            _keywords["USER PASSWORD"] = "Password";
            _keywords["USERPASSWORD"] = "Password";
            _keywords["DATA SOURCE"] = "Data Source";
            _keywords["DATASOURCE"] = "Data Source";
            _keywords["SERVER"] = "Data Source";
            _keywords["ADDRESS"] = "Data Source";
            _keywords["ADDR"] = "Data Source";
            _keywords["NETWORK ADDRESS"] = "Data Source";
            _keywords["HOST"] = "Data Source";
            _keywords["INITIAL CATALOG"] = "Initial Catalog";
            _keywords["DATABASE"] = "Initial Catalog";
            _keywords["PORT"] = "Port Number";
            _keywords["PORTNUMBER"] = "Port Number";
            _keywords["PORT NUMBER"] = "Port Number";
            _keywords["PACKETSIZE"] = "Packet Size";
            _keywords["PACKET SIZE"] = "Packet Size";
            _keywords["ROLE"] = "Role Name";
            _keywords["ROLENAME"] = "Role Name";
            _keywords["DIALECT"] = "Dialect";
            _keywords["CHARSET"] = "Character Set";
            _keywords["CHAR SET"] = "Character Set";
            _keywords["CHARACTERSET"] = "Character Set";
            _keywords["CHARACTER SET"] = "Character Set";
            _keywords["TIMEOUT"] = "Connection Timeout";
            _keywords["CONNECT TIMEOUT"] = "Connection Timeout";
            _keywords["CONNECTION TIMEOUT"] = "Connection Timeout";
            _keywords["CONNECTIONTIMEOUT"] = "Connection Timeout";
            _keywords["POOLING"] = "Pooling";
            _keywords["CONNECT LIFETIME"] = "Connection Lifetime";
            _keywords["CONNECTION LIFETIME"] = "Connection Lifetime";
            _keywords["CONNECTIONLIFETIME"] = "Connection Lifetime";
            _keywords["MIN POOL SIZE"] = "Min Pool Size";
            _keywords["MINPOOLSIZE"] = "Min Pool Size";
            _keywords["MAX POOL SIZE"] = "Max Pool Size";
            _keywords["MAXPOOLSIZE"] = "Max Pool Size";
            _keywords["FETCHSIZE"] = "Fetch Size";
            _keywords["FETCH SIZE"] = "Fetch Size";
            _keywords["SERVERTYPE"] = "Server Type";
            _keywords["SERVER TYPE"] = "Server Type";
            _keywords["ISOLATIONLEVEL"] = "Isolation Level";
            _keywords["ISOLATION LEVEL"] = "Isolation Level";
            _keywords["RECORDS AFFECTED"] = "Records Affected";
            _keywords["RECORDSAFFECTED"] = "Records Affected";
            _keywords["CONTEXT CONNECTION"] = "Context Connection";
            _keywords["CONTEXTCONNECTION"] = "Context Connection";
            _keywords["ENLIST"] = "Enlist";
            _keywords["CLIENT LIBRARY"] = "Client Library";
            _keywords["CLIENTLIBRARY"] = "Client Library";
            _keywords["DB CACHE PAGES"] = "Cache Pages";
            _keywords["CACHE PAGES"] = "Cache Pages";
            _keywords["CACHEPAGES"] = "Cache Pages";
            _keywords["PAGEBUFFERS"] = "Cache Pages";
            _keywords["PAGE BUFFERS"] = "Cache Pages";
        }

        private static void InitializeDefaults()
        {
            defaultValues = new Dictionary<string, PropertyDefaultValue>(StringComparer.OrdinalIgnoreCase);

            PropertyInfo[] properties = typeof(FbConnectionStringBuilder).GetProperties();
            foreach (PropertyInfo pi in properties)
                AddKeywordFromProperty(pi);
        }

        private static void AddKeywordFromProperty(PropertyInfo pi)
        {
            string name = pi.Name.ToLower(CultureInfo.InvariantCulture);
            string displayName = name;

            // now see if we have defined a display name for this property
            object[] attr = pi.GetCustomAttributes(false);
            foreach (Attribute a in attr)
            {
                if (a is DisplayNameAttribute)
                {
                    displayName = (a as DisplayNameAttribute).DisplayName;
                    displayName = _keywords[displayName.ToUpper(CultureInfo.InvariantCulture)];
                    break;
                }
            }

            foreach (Attribute a in attr)
            {
                if (a is DefaultValueAttribute)
                {
                    defaultValues[displayName] = new PropertyDefaultValue(pi.PropertyType,
                            Convert.ChangeType((a as DefaultValueAttribute).Value, pi.PropertyType, CultureInfo.CurrentCulture));
                }
            }
        }

        #endregion
    }

    internal struct PropertyDefaultValue
    {
        public PropertyDefaultValue(Type t, object v)
        {
            Type = t;
            DefaultValue = v;
        }

        public Type Type;
        public object DefaultValue;
    }
}
