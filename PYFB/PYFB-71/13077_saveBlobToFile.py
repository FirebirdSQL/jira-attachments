import os.path
import fdb

# open connection
con = fdb.connect(dsn='localhost:k4.fdb', user='sysdba', password='masterkey')
cur = con.cursor()

# Retrieval using the "file-like" methods of BlobReader:
cur.execute("select obj from exp_obj where obj_id = 1")
cur.set_stream_blob('OBJ') # Note the capital letters
readerA = cur.fetchone()[0]

# write file
pic=open("cheetah.jpg",'wb')
pic.write( readerA.read() ) 
pic.close()

# close connection
con.commit()
con.close()
