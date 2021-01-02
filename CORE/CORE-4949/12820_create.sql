set auto off;
create database 'test_fmt.fdb';

CREATE TABLE TAB_1 (
    ID   varchar(10)
);
commit;
set term ^ ;
create or alter procedure proc_1
returns (
  res integer
)
as
begin
end^
commit^

alter table tab_1 alter column id type varchar(100)^

create or alter procedure proc_2
as
  declare variable res integer;
begin
  select res from proc_1 into :res;
end^

commit^