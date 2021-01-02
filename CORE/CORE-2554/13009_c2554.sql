shell del C:\MIX\firebird\QA\fbt-repo\tmp\c2554.fdb 2>nul;
create database 'localhost:C:\MIX\firebird\QA\fbt-repo\tmp\c2554.fdb' user sysdba password 'masterkey';

set wng off;
set list on;                              

create or alter user tmp$c2554_boss password '123' revoke admin role;
create or alter user tmp$c2554_acnt password '456' revoke admin role;
commit;
revoke all on all from tmp$c2554_boss;
revoke all on all from tmp$c2554_acnt;
commit;

recreate table test(id int);
commit;
insert into test values(1);
commit;

set term ^;
create procedure strlen_sp(s varchar(32765)) returns (sp_result int) as begin sp_result = 3 * char_length(s); suspend; end
^
create function strlen_psql(s varchar(32765)) returns int as begin return 2 * char_length(s); end
^ 
set term ;^
commit;

declare external function strlen cstring(32767) returns integer by value
entry_point 'IB_UDF_strlen'
module_name 'ib_udf';
commit;

grant execute on procedure strlen_sp to user tmp$c2554_boss with grant option;  -- NB: with GRANT option!
grant execute on function strlen_psql to user tmp$c2554_boss with grant option; -- NB: with GRANT option!
grant execute on function strlen to user tmp$c2554_boss with grant option;      -- NB: with GRANT option!
grant select on test to user tmp$c2554_boss with grant option;                  -- NB: with GRANT option!
commit;
show grants;
commit;

set echo on;

-- First try as ACNT: all of subsequent statements should FAIL because this user has not yet any rights:
connect 'localhost:C:\MIX\firebird\QA\fbt-repo\tmp\c2554.fdb' user tmp$c2554_acnt password '456';

select current_user, p.* from strlen_sp('i_am_acnt_and_try_to_use_procedure') p;              -- should FAIL
select current_user, strlen_psql('i_am_acnt_and_try_to_use_PSQL_function') from rdb$database; -- should FAIL
select current_user, strlen('i_am_acnt_and_try_to_use_UDF_function') from rdb$database;       -- should FAIL
select current_user, id from test;                                                            -- should FAIL

commit;

-- Now try as BOSS. He should be able to execute UDF and PSQL functions, and also to query table 'test':
connect 'localhost:C:\MIX\firebird\QA\fbt-repo\tmp\c2554.fdb' user tmp$c2554_boss password '123';

select current_user, p.* from strlen_sp('i_am_acnt_and_try_to_use_procedure') p;              -- should PASS!
select current_user, strlen_psql('i_am_boss_and_try_to_use_PSQL_function') from rdb$database; -- should PASS!
select current_user, strlen('i_am_acnt_and_try_to_use_UDF_function') from rdb$database;       -- should PASS!
select current_user, id from test;                                                            -- should PASS!

-- BOSS should be able to grant rights to another user ?

grant execute on procedure strlen_sp to user tmp$c2554_acnt; -- with grant option; -- should PASS ?
grant execute on function strlen_psql to user tmp$c2554_acnt; -- with grant option; -- should PASS ?
grant execute on function strlen to user tmp$c2554_acnt; -- with grant option;      -- should PASS ?
grant select on test to user tmp$c2554_acnt;                                        -- should PASS ?
commit;

show grants; -- <<< should table, SP, UDF and PSQL-function for tmp$c2554_ACNT appear in this list ?

-- Let's try again as ACNT:
connect 'localhost:C:\MIX\firebird\QA\fbt-repo\tmp\c2554.fdb' user tmp$c2554_acnt password '456';

select current_user, p.* from strlen_sp('i_am_acnt_and_try_to_use_procedure') p;              -- should PASS ?

select current_user, strlen_psql('i_am_acnt_and_try_to_use_PSQL_function') from rdb$database; -- should PASS ?

select current_user, strlen('i_am_acnt_and_try_to_use_UDF_function') from rdb$database;       -- should PASS ?

select current_user, id from test;                                                            -- should PASS ?
commit;

show version;
