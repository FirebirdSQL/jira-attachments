

SET SQL DIALECT 3;

CREATE DATABASE 'Bug291.gdb' PAGE_SIZE 4096;
commit;

/* Table: T1, Owner: SYSDBA */

CREATE TABLE "T1" 
(
  "DATA"	INTEGER,
  "FLAG"	INTEGER
);

SET TERM ^ ;

CREATE TRIGGER "TRIG1" FOR "T1" 
ACTIVE BEFORE UPDATE POSITION 1
as
begin
if (new.Flag = 16 and new.Data = 1) then begin
  update t1 set Data = 2 where Flag = 46;
  update t1 set Data = 3 where Flag = 46;
end
if (new.Flag = 46 and new.Data = 2) then begin
  update t1 set Data = 4 where Flag = 14;
  update t1 set Data = 5 where Flag = 15;
end
if (new.Flag = 14 and new.Data = 4) then begin
  update t1 set Data = 6 where Flag = 46;
end
if (new.Flag = 15 and new.Data = 5) then begin
  update t1 set Data = 7 where Flag = 46;
end
if (new.Flag = 46 and new.Data = 3) then begin
  update t1 set Data = 8 where Flag = 46;
end
end
 ^

COMMIT WORK ^
SET TERM ;^

insert into t1(Flag) values(14);
insert into t1(Flag) values(15);
insert into t1(Flag) values(16);
insert into t1(Flag) values(46);
commit;

update t1 set Data=1 where Flag = 16;
