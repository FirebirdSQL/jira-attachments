drop table s_test;
set echo on;
create table s_test (f integer);
recreate table errs(f integer, msg varchar(30));
set term ^;
create trigger boom for s_test after update or insert as
declare variable a integer;
begin
 if (new.f>=10) then
  begin
   a = 1/0;
  end
end^
insert into s_test values (1)^
commit^
execute block as
declare variable a integer;
begin
 update s_test set f=2;
 begin
  update s_test set f=3;
  begin
   update s_test set f=4;
   begin
    update s_test set f=5;
    begin
     update s_test set f=6;
     begin
      update s_test set f=10;
     end
    end
   end
  when gdscode arith_except do insert into errs (f, msg) select f, 'gdscode '||gdscode from s_test;
  when sqlcode -802 do insert into errs (f, msg) select f, 'sqlcode '||sqlcode from s_test;
  when any do insert into errs (f, msg) select f, 'any' from s_test;
  when any do a=1/0;
  end
 when any do insert into errs (f, msg) select f, 'any2' from s_test;
 end
end^
commit^
select f from s_test^
select * from errs^
commit^
set term ;^
