del rNI.txt
del r.txt

c:\ib\bin\gbak.exe c:\sql_data\gbak_test_rest.gbk c:\sql_data\rNI.ib  -user SYSDBA -password "masterkey" -C -P 16384 -O -N -I -V > rNI.txt
c:\ib\bin\gbak.exe c:\sql_data\gbak_test_rest.gbk c:\sql_data\r.ib  -user SYSDBA -password "masterkey" -C -P 16384 -O -V > r.txt


c:\ib\bin\isql -user SYSDBA -m -p masterkey -charset WIN1251 -i r.sql -o r.log 127.0.0.1:c:\sql_data\r.ib
c:\ib\bin\isql -user SYSDBA -m -p masterkey -charset WIN1251 -i r.sql -o rNI.log 127.0.0.1:c:\sql_data\rNI.ib
