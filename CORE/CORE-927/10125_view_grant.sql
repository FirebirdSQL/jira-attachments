drop view VIEW_A;
drop procedure A;

set term ^ ;
create procedure A
returns (RESULT integer)
as
begin
 RESULT = 1;
 suspend;
end^
set term ; ^

create view VIEW_A (
 RESULT
)
as
select (select RESULT from A)
  from RDB$DATABASE;

grant execute on procedure A to view VIEW_A;
grant select on VIEW_A to TEST; -- test user without any rights
