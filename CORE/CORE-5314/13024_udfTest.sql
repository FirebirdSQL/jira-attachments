/*create database "db.fdb" user "sysdba" password "masterkey";*/

/* declaring UDFs */

declare external function f_2cstring_100
cstring(100), cstring(100)
returns integer by value
entry_point 'fn_2cstring' module_name 'glds_udflib';  

declare external function f_2cstring_32000
cstring(32000), cstring(32000)
returns integer by value
entry_point 'fn_2cstring' module_name 'glds_udflib';  

declare external function f_2varchar_100
varchar(100), varchar(100)
returns integer by value
entry_point 'fn_2varchar' module_name 'glds_udflib';  

declare external function f_2varchar_32000
varchar(32000), varchar(32000)
returns integer by value
entry_point 'fn_2varchar' module_name 'glds_udflib';  

declare external function f_2byDescriptor_100
varchar(100) by descriptor, varchar(100) by descriptor
returns integer by value
entry_point 'fn_2byDescriptor' module_name 'glds_udflib';  

declare external function f_2byDescriptor_32000
varchar(32000) by descriptor, varchar(32000) by descriptor
returns integer by value
entry_point 'fn_2byDescriptor' module_name 'glds_udflib';  

commit;

/* test UDF and declarations, expect 1, 2, 3, 1, 2, 3 */
select f_2cstring_100('', ''), f_2varchar_100('', ''), f_2byDescriptor_100('', ''), f_2cstring_32000('', ''), f_2varchar_32000('', ''), f_2byDescriptor_32000('', '') from rdb$database;


set term ^;
create or alter procedure sp_test_udf
returns (
  action varchar(30),
  duration_in_seconds double precision,
  cycles integer
) as
  declare variable started timestamp;
  declare variable finished timestamp;
  declare variable i integer;
  declare variable j integer;
  declare variable s varchar(32000);
  declare variable s2 varchar(32000);
begin
  cycles=1000000;
  s='';
  s2='';

  action='empty loop';
  i=0;
  started=cast('NOW' as timestamp);
  while (i<cycles) do begin
    i=i+1;
  end
  finished=cast('NOW' as timestamp);
  duration_in_seconds=(finished-started)*24*60*60;
  suspend;

  action='position';
  i=0;
  started=cast('NOW' as timestamp);
  while (i<cycles) do begin
    j=position(s, s2);
    i=i+1;
  end
  finished=cast('NOW' as timestamp);
  duration_in_seconds=(finished-started)*24*60*60;
  suspend;

  action='2 cstring 100';
  i=0;
  started=cast('NOW' as timestamp);
  while (i<cycles) do begin
    j=f_2cstring_100(s, s2);
    i=i+1;
  end
  finished=cast('NOW' as timestamp);
  duration_in_seconds=(finished-started)*24*60*60;
  suspend;

  action='2 varchar 100';
  i=0;
  started=cast('NOW' as timestamp);
  while (i<cycles) do begin
    j=f_2varchar_100(s, s2);
    i=i+1;
  end
  finished=cast('NOW' as timestamp);
  duration_in_seconds=(finished-started)*24*60*60;
  suspend;

  action='2 by descriptor 100';
  i=0;
  started=cast('NOW' as timestamp);
  while (i<cycles) do begin
    j=f_2byDescriptor_100(s, s2);
    i=i+1;
  end
  finished=cast('NOW' as timestamp);
  duration_in_seconds=(finished-started)*24*60*60;
  suspend;

  action='2 cstring 32000';
  i=0;
  started=cast('NOW' as timestamp);
  while (i<cycles) do begin
    j=f_2cstring_32000(s, s2);
    i=i+1;
  end
  finished=cast('NOW' as timestamp);
  duration_in_seconds=(finished-started)*24*60*60;
  suspend;

  action='2 varchar 32000';
  i=0;
  started=cast('NOW' as timestamp);
  while (i<cycles) do begin
    j=f_2varchar_32000(s, s2);
    i=i+1;
  end
  finished=cast('NOW' as timestamp);
  duration_in_seconds=(finished-started)*24*60*60;
  suspend;

  action='2 by descriptor 32000';
  i=0;
  started=cast('NOW' as timestamp);
  while (i<cycles) do begin
    j=f_2byDescriptor_32000(s, s2);
    i=i+1;
  end
  finished=cast('NOW' as timestamp);
  duration_in_seconds=(finished-started)*24*60*60;
  suspend;
  
end
^
set term ;^
commit;

/* testing */
select * from sp_test_udf;
select * from sp_test_udf;

/*results on i5:
ACTION                             DURATION_IN_SECONDS       CYCLES 
============================== ======================= ============ 
empty loop                          0.1989792000000000      1000000 
position                            0.4009824000000000      1000000 
2 cstring 100                       0.5640192000000001      1000000 
2 varchar 100                       0.5979744000000000      1000000 
2 by descriptor 100                 0.4650048000000000      1000000 
2 cstring 32000                      20.49001920000000      1000000 
2 varchar 32000                      23.53501440000000      1000000 
2 by descriptor 32000                20.17396800000000      1000000 
*/

/* cleaning up */
drop procedure sp;
drop external function f_2cstring_100;
drop external function f_2cstring_32000;
drop external function f_2varchar_100;
drop external function f_2varchar_32000;
drop external function f_2byDescriptor_100;
drop external function f_2byDescriptor_32000;
commit;

