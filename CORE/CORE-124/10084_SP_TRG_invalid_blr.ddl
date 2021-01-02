/*
  These two scripts demonstrate the problem when an attempt is 
  made to modify a trigger that calls a stored procedure whose 
  parameter count  has changed.
  
 */

/*
	Script one - generate the test database
 */ 
 
CONNECT 'localhost:c:\temp\invalid_blr.gdb' USER 'SYSDBA' PASSWORD 'masterkey';
drop database;
commit;

CREATE DATABASE 'localhost:c:\temp\invalid_blr.gdb' USER 'SYSDBA' PASSWORD 'masterkey';

create table tab1 (f1 integer, f2 integer, f3 integer);

set term ^;
create procedure pro1 (par1 integer, par2 integer) returns (par3 integer)
as begin
   exit;
end^

create trigger trig1 for tab1 active after insert position 0
as
declare variable var1 integer;

begin
    execute procedure pro1  (:new.f1, :new.f2)
        returning_values :var1;
end^

set term ;^

commit;




/*
 >== >== CUT HERE >== >==
 */
 
 /*
 	Script two - generate the error
	
	  invalid request BLR at offset NNN
	  -parameter mismatch for procedure XYZ
  */
 
CONNECT 'localhost:c:\temp\invalid_blr.gdb' USER 'SYSDBA' PASSWORD 'masterkey';

set autoddl off;

set term ^;

alter procedure pro1 (par1 integer, par2 integer, par3 integer) returns (par4 integer)
as begin
   exit;
end^


alter TRIGGER trig1 active after insert position 0
as
declare variable var1 integer;

begin
    execute procedure pro1 ( :new.f1, :new.f2, :new.f3)
        returning_values :var1;
end^

set term ;^

commit;

set autoddl on; 




