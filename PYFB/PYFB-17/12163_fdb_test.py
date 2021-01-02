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
        sort Integer NOT Null
    );
    '''
    
    create_trigger = '''CREATE TRIGGER BIU_Trigger FOR table1
    ACTIVE BEFORE INSERT OR UPDATE POSITION 0
    as
    begin
      if (new.sort IS NULL) then
      begin
        new.sort = 1;
      end
    end
    '''
    
    conn = dbmod.connect(host=host, database=database, user=user, password=password)
    cur = conn.cursor()
    cur.execute(create_table)
    cur.execute(create_trigger)
    conn.commit()
    
    # fails with fdb, passes with kinterbasdb
    cur.execute('insert into table1 (ID, sort) values(1, ?)', (None, ))

if __name__ == '__main__':
    db = os.path.abspath(TEST_DB_PATH)
    if os.path.exists(db):
        os.unlink(db)

    test(db)
