/*
 *	Firebird ADO.NET Data provider for .NET and Mono 
 * 
 *	   The contents of this file are subject to the Initial 
 *	   Developer's Public License Version 1.0 (the "License"); 
 *	   you may not use this file except in compliance with the 
 *	   License. You may obtain a copy of the License at 
 *	   http://www.firebirdsql.org/index.php?op=doc&id=idpl
 *
 *	   Software distributed under the License is distributed on 
 *	   an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either 
 *	   express or implied. See the License for the specific 
 *	   language governing rights and limitations under the License.
 * 
 *	Copyright (c) 2002, 2006 Carlos Guzman Alvarez
 *	All Rights Reserved.
 */

using System;
using System.Collections;
using System.Threading;

namespace FirebirdSql.Data.FirebirdClient
{
    internal sealed class FbPoolManager
    {
        #region · Static Fields ·

        private static readonly FbPoolManager instance = new FbPoolManager();

        #endregion

		#region · Static Properties ·

		public static FbPoolManager Instance
		{
			get { return FbPoolManager.instance; }
		}

		#endregion

		#region · Fields ·

		private Hashtable	pools;
        private Hashtable	handlers;
		private object		syncObject;

        #endregion

        #region · Properties ·

        public int PoolsCount
        {
            get
            {
                if (this.pools != null)
                {
                    return this.pools.Count;
                }
                return 0;
            }
        }

        #endregion

        #region · Private Properties ·

        private Hashtable Pools
        {
            get
            {
                if (this.pools == null)
                {
                    this.pools = Hashtable.Synchronized(new Hashtable());
                }

                return this.pools;
            }
        }

        private Hashtable Handlers
        {
            get
            {
                if (this.handlers == null)
                {
                    this.handlers = Hashtable.Synchronized(new Hashtable());
                }

                return this.handlers;
            }
        }

        private object SyncObject
        {
            get
            {
                if (this.syncObject == null)
                {
                    Interlocked.CompareExchange(ref this.syncObject, new object(), null);
                }

                return this.syncObject;
            }
        }

        #endregion

        #region · Constructors ·

        private FbPoolManager()
        {
        }

        #endregion

        #region · Methods ·

        public FbConnectionPool GetPool(string connectionString)
        {
            FbConnectionPool pool = this.FindPool(connectionString);

            if (pool == null)
            {
                pool = this.CreatePool(connectionString);
            }

            return pool;
        }

        public FbConnectionPool FindPool(string connectionString)
        {
            FbConnectionPool pool = null;

            lock (this.SyncObject)
            {
                int hashCode = connectionString.GetHashCode();

                if (this.Pools.ContainsKey(hashCode))
                {
                    pool = (FbConnectionPool)pools[hashCode];
                }
            }

            return pool;
        }

        public FbConnectionPool CreatePool(string connectionString)
        {
            FbConnectionPool pool = null;

            lock (this.SyncObject)
            {
                pool = this.FindPool(connectionString);

                if (pool == null)
                {
                    lock (this.pools.SyncRoot)
                    {
                        int hashcode = connectionString.GetHashCode();

                        // Create an empty pool	handler
                        EmptyPoolEventHandler handler = new EmptyPoolEventHandler(this.OnEmptyPool);

                        this.Handlers.Add(hashcode, handler);

                        // Create the new connection pool
                        pool = new FbConnectionPool(connectionString);

                        this.pools.Add(hashcode, pool);

                        pool.EmptyPool += handler;
                    }
                }
            }

            return pool;
        }

        public void ClearAllPools()
        {
            lock (this.SyncObject)
            {
				if(this.pools != null)
				{
					lock (this.pools.SyncRoot)
					{
						FbConnectionPool[] tempPools = new FbConnectionPool[this.pools.Count];
	
						this.pools.Values.CopyTo(tempPools, 0);
	
						foreach (FbConnectionPool pool in tempPools)
						{
							// Clear pool
							pool.Clear();
						}
	
						// Clear Hashtables
						this.pools.Clear();
						this.handlers.Clear();
					}
                }
            }
        }

        public void ClearPool(string connectionString)
        {
            lock (this.SyncObject)
            {
				if(this.pools != null)
				{
					lock (this.pools.SyncRoot)
					{
						int hashCode = connectionString.GetHashCode();
	
						if (this.pools.ContainsKey(hashCode))
						{
							FbConnectionPool pool = (FbConnectionPool)this.pools[hashCode];
	
							// Clear pool
							pool.Clear();
						}
					}
                }
            }
        }

        public int GetPooledConnectionCount(string connectionString)
        {
            FbConnectionPool pool = this.FindPool(connectionString);

            return (pool != null) ? pool.Count : 0;
        }

        #endregion

		#region · Event Handlers ·

		private void OnEmptyPool(object sender, EventArgs e)
        {
            lock (this.Pools.SyncRoot)
            {
                int hashCode = (int)sender;

                if (this.pools.ContainsKey(hashCode))
                {
                    FbConnectionPool pool = (FbConnectionPool)this.Pools[hashCode];

                    lock (pool.SyncObject)
                    {
                        EmptyPoolEventHandler handler = (EmptyPoolEventHandler)this.Handlers[hashCode];

                        pool.EmptyPool -= handler;

                        this.Pools.Remove(hashCode);
                        this.Handlers.Remove(hashCode);

                        pool    = null;
                        handler = null;
                    }
                }
            }
        }

        #endregion
    }
}
