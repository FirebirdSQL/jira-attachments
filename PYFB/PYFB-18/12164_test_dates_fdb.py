import os
import fdb as dbmod
#~ import kinterbasdb as dbmod

TEST_DB_PATH = './test.fdb'

def test(database, user='sysdba', password='masterkey', host='127.0.0.1',
                         charset='UTF8', port=3050, pagesize=16384):
    dbmod.create_database(
            "create database '%(database)s' page_size %(pagesize)s user '%(user)s' "
            "password '%(password)s' DEFAULT CHARACTER SET %(charset)s" %
            {'user': user, 'password': password, 'host': host, 'database': database,
             'charset': charset, 'port': port, 'pagesize': pagesize})
    
    create_table = '''

    Create Table table1  (
        ID Integer,
        d1 Date
    );
    '''
    
    
    conn = dbmod.connect(host=host, database=database, user=user, password=password)
    cur = conn.cursor()
    cur.execute(create_table)
    conn.commit()
    
    # fails with fdb, passes with kinterbasdb
    cur.execute('insert into table1 (ID, d1) values(1, ?)', ('2010-01-01', ))
    

if __name__ == '__main__':
    db = os.path.abspath(TEST_DB_PATH)
    if os.path.exists(db):
        os.unlink(db)

    test(db)
