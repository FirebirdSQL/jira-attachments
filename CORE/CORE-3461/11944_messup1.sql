create database 'aa.fdb';

create table test_tbl(id integer);

create procedure test_proc(id integer) as begin end;

create table test_tbl2(id integer);


set term ^ ;

create procedure test_tbl_proc as
declare id integer;
begin
  select id from test_tbl2 into :id;
end
^
