--set echo on;

set term ^;
create or alter procedure fill_test_table2 (
    num1 integer,
    num2 integer
) as 
begin 
    exit; 
end 
^

create or alter procedure test3 as 
begin 
   exit; 
end 
^
set term ;^
commit;

recreate table test_table2 (id integer);
commit;

set term ^;
execute block as
begin
    execute statement 'drop generator gn_test2';
    when any do begin end
end
^
set term ;^
commit;

create generator gn_test2;

recreate table test_table2 (id integer not null,
        field1 integer,
        field2 integer,
        val varchar(255),
        flag smallint,
constraint pk_test_table2 primary key (id));
commit;

set term ^;
alter procedure fill_test_table2 (
    num1 integer,
    num2 integer
) as 
    declare val varchar(255);
    declare field1 integer;
    declare field2 integer;
begin

  while(num1 > 0) do begin
    field1 = num1-cast((num1/4-0.5) as integer)*4;
    field2 = num2-cast((num2/3-0.5) as integer)*3;
    val = case field1
            when 0 then 'slldlof,,dllsss'
            when 1 then 'bcbcbsikkskskla'
            when 2 then 'dslle[wfuwjsmsk'
            when 3 then 's;;soiejmdvjjvl'
            else 'slwlw,s,s,,ss'
          end;

    insert into test_table2(field1,field2,val)
    values (:field1,:field2,:val);

    num1 = num1 - 1;
    num2 = num2 - 1;
  end
end 
^

alter procedure test3 as 
begin
  update test_table2
  set field1 = 11,
      field2 = 12;
end 
^
set term ;^
commit;

set term ^;
create or alter trigger t_test2_insert for test_table2 active before insert position 0 as
begin
  if (new.id is null) then
     new.id = gen_id(gn_test2,1);
end 
^
set term ;^
commit;

EXECUTE PROCEDURE FILL_TEST_TABLE2(1000000,33223244); -- ~ 45 sec
commit;

set stat on;
set echo on;

execute procedure TEST3;

execute procedure TEST3;


show version;
