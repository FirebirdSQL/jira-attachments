set autoddl off;
set term ^ ;

drop table test_tbl ^

alter procedure test_proc(id integer) as begin end ^

alter table test_tbl2 add id2 integer ^

alter procedure test_tbl_proc as
declare id integer;
declare id2 integer;
begin
  select id, id2 from test_tbl2 into :id, :id2;
end

^

commit ^
