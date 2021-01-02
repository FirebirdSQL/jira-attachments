set auto off;
connect 'test_fmt.fdb';

set term ^ ;

alter table tab_1 alter column id type varchar(100)^

create or alter procedure proc_2
as
  declare variable res integer;
begin
  select res from proc_1 into :res;
end^

commit^