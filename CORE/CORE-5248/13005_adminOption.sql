shell rm -f adm adm.sav;

create database 'adm' user 'SYSDBA';
grant create role to user u0;
commit;

connect 'adm' user 'u0';	-- owner of role
create role r1;
commit;

connect 'adm' user 'SYSDBA';
grant r1 to u1 with admin option;
grant r1 to u3;
commit;

connect 'adm' user 'u1';
grant r1 to u2;
commit;
set echo on;



-- 1. revoke - avoid cascade grants delete
set echo off;
connect employee;
shell cp adm adm.sav;
set echo on;

connect 'adm.sav' user 'SYSDBA';
revoke r1 from u1;
commit;
show grants;
commit;


-- 2. revoke - avoid revoking own grant
set echo off;
connect employee;
shell cp adm adm.sav;
set echo on;

connect 'adm.sav' user 'u1';
revoke r1 from u1;
commit;
show grants;
commit;


-- 3. revoke - check role owner rights
set echo off;
connect employee;
shell cp adm adm.sav;
set echo on;

connect 'adm.sav' user 'u0';
revoke r1 from u3;
commit;
show grants;
commit;


-- 4. revoke - check admin option
set echo off;
connect employee;
shell cp adm adm.sav;
set echo on;

connect 'adm.sav' user 'u1';
revoke r1 from u3;
commit;
show grants;
commit;


-- 5a. drop role - should fail
set echo off;
connect employee;
shell cp adm adm.sav;
set echo on;

connect 'adm.sav' user 'xxx';
drop role r1;
commit;
show roles;
commit;


-- 5. drop role - check role owner rights
set echo off;
connect employee;
shell cp adm adm.sav;
set echo on;

connect 'adm.sav' user 'u0';
drop role r1;
commit;
show roles;
commit;


-- 6. drop role - check admin option
set echo off;
connect employee;
shell cp adm adm.sav;
set echo on;

connect 'adm.sav' user 'u1';
drop role r1;
commit;
show roles;
commit;
