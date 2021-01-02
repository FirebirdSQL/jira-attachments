set echo on;
set heading off;
shell del c:\temp\tmptest.fdb 2>nul;

create database 'localhost:c:\temp\tmptest.fdb' user 'SYSDBA' password 'masterkey';
commit;

recreate view v_test1 as select 1 id from rdb$database;
recreate view v_test2 as select 1 id from rdb$database;
create or alter procedure sp_min as begin end;
create or alter procedure sp_max as begin end;
create or alter procedure sp_zero_div as begin end;
commit;

recreate exception ex_zero_div_not_allowed 'Can not delete @1 by zero';
commit;

set term ^;
execute block as
begin
    begin
        execute statement 'drop domain dm_int128_great';
    when any do begin end
    end

    begin
        execute statement 'drop domain dm_int128_least';
    when any do begin end
    end
end
^
set term ;^

create domain dm_int128_great as int128 default 170141183460469231731687303715884105727;
create domain dm_int128_least as int128 default -170141183460469231731687303715884105728;

---------------------------------------------------------


recreate table test( i_min int128, i_max int128);
commit;

insert into test(i_min, i_max) values(-170141183460469231731687303715884105728, 170141183460469231731687303715884105727);
commit;

select 170141183460469231731687303715884105727 from rdb$database;

select -170141183460469231731687303715884105727 from rdb$database;

select -170141183460469231731687303715884105728 from rdb$database;

recreate view v_test1 as select -170141183460469231731687303715884105728 as v_min from rdb$database;

select * from v_test1;
commit;

recreate view v_test2 as select 170141183460469231731687303715884105727 as v_min from rdb$database;

select * from v_test2;
commit;



set term ^;
create or alter procedure sp_min(
    a_min type of column test.i_min default -170141183460469231731687303715884105728
) returns(
    p_min type of column test.i_min
) as
begin
   select i_max from test where i_min >= :a_min rows 1 into p_min;
   suspend;
end
^

create or alter procedure sp_max(
    a_max type of column test.i_max default 170141183460469231731687303715884105727
) returns(
    p_max type of column test.i_max
) as
begin
   select i_min from test where i_min <= :a_max rows 1 into p_max;
   suspend;
end
^

create or alter procedure sp_zero_div(a_delimiter int128 ) returns(p_min type of column test.i_min) as
    declare v_min type of column test.i_min;
begin
   select min(i_min) from test into v_min;
   begin
       p_min = v_min / a_delimiter;
   when sqlstate '22012' do --  335544778
       exception ex_zero_div_not_allowed using( v_min );
   when any do
       exception;
   end

   suspend;
end
^
set term ;^
commit;

select * from sp_min;

select * from sp_max;

select * from sp_zero_div(0);
rollback;

-- :::::::::::::::::::::::::::::::::::::::::::

recreate table test2( x int128 default -170141183460469231731687303715884105728, y int128 default 170141183460469231731687303715884105727);
commit;

insert into test2 default values;
rollback;
 
recreate table test3( x int128 check (x > -170141183460469231731687303715884105728) );
commit;

insert into test3(x) values( 0 );
 
rollback;

-- :::::::::::::::::::::::::::::::::::::::::::::

recreate table test4( x int128, y int128);
 
insert into test4( x, y ) values( -170141183460469231731687303715884105728, 170141183460469231731687303715884105727);
commit;
set term ^;
create procedure sp_test4( a_x type of column test4.x) returns(z type of column test4.x) as
begin
    for select 1 from test4 where :a_x in (x, y) rows 1
    into z
    do
        suspend;
end
^
set term ;^
commit;

select * from sp_test4( 170141183460469231731687303715884105727);

select * from sp_test4(-170141183460469231731687303715884105728);
