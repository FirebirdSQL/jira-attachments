
set term ^ ;

create or alter package PKG_TEST
as
begin
  function F_TEST_INSIDE_PKG
  returns smallint;
end^
set term ; ^

set term ^ ;
recreate package body PKG_TEST
as
begin
  function F_TEST_INSIDE_PKG
  returns smallint
  as
  begin
    return 1;
  end
end^
set term ; ^

set term ^ ;
create or alter function F_TEST_OUTSIDE_PKG
returns smallint
as
begin
  return -1;
end^

set term ; ^

