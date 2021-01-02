set echo on;

create database 'localhost:/tmp/26133.fdb';
create or alter user u password 'pass';
create table t(f1 int, f2 int);
create role r1;
create role r2;
commit;show grants;

-- GRANT OPTION --
------------------

-- check revoke grant option for all table --
---------------------------------------------
grant update(f1, f2) on table t to u with grant option;
commit;show grants;

revoke grant option for update on table t from u;
commit;show grants;

revoke all on all from u;
commit;show grants;

-- check revoke grant option for the first field --
---------------------------------------------------
grant update(f1, f2) on table t to u with grant option;
commit;show grants;

revoke grant option for update(f1) on table t from u;
commit;show grants;

revoke all on all from u;
commit;show grants;

-- check revoke grant option for the second field --
----------------------------------------------------
grant update(f1, f2) on table t to u with grant option;
commit;show grants;

revoke grant option for update(f2) on table t from u;
commit;show grants;

revoke all on all from u;
commit;show grants;

-- check revoke grant option for every field --
-----------------------------------------------
grant update(f1, f2) on table t to u with grant option;
commit;show grants;

revoke grant option for update(f1, f2) on table t from u;
commit;show grants;

revoke all on all from u;
commit;show grants;
 
-- UPDATE --
------------

-- check revoke update for all table --
---------------------------------------
grant update(f1, f2) on table t to u with grant option;
commit;show grants;

revoke update on table t from u;
commit;show grants;

revoke all on all from u;
commit;show grants;

-- check revoke update for the first field --
---------------------------------------------
grant update(f1, f2) on table t to u with grant option;
commit;show grants;

revoke update(f1) on table t from u;
commit;show grants;

revoke all on all from u;
commit;show grants;

-- check revoke update the second field --
------------------------------------------
grant update(f1, f2) on table t to u with grant option;
commit;show grants;

revoke update(f2) on table t from u;
commit;show grants;

revoke all on all from u;
commit;show grants;

-- check revoke update for every field --
-----------------------------------------
grant update(f1, f2) on table t to u with grant option;
commit;show grants;

revoke update(f1, f2) on table t from u;
commit;show grants;

revoke all on all from u;
commit;show grants;

-- ROLES --
-----------

-- check revoke role --
-----------------------
grant r1 to role r2;
commit; show grants;

revoke r1 from role r2;
commit; show grants;

-- check revoke default of role --
----------------------------------
grant default r1 to role r2;
commit; show grants;

revoke default r1 from role r2;-- revoke only default option
commit; show grants;

revoke r1 from role r2;-- revoke whole role
commit; show grants;

-- check revoke whole default role --
-------------------------------------
grant default r1 to role r2;
commit; show grants;

revoke r1 from role r2;
commit; show grants;

-- check revoke admin option --
-------------------------------
grant r1 to role r2 with admin option;
commit; show grants;

revoke admin option for r1 from role r2;
commit; show grants;

-- check revoke default from role granted with admin option --
--------------------------------------------------------------
grant default r1 to role r2 with admin option;
commit; show grants;

revoke default r1 from role r2;
commit; show grants;


-- check revoke admin option from default role --
-------------------------------------------------
grant default r1 to role r2 with admin option;
commit; show grants;

revoke admin option for r1 from role r2;
commit; show grants;


-- check revoke both GO and AO from granted role --
---------------------------------------------------
grant default r1 to role r2 with admin option;
commit; show grants;

revoke admin option for default r1 from role r2;
commit; show grants;


-- adding options to role grants --
-----------------------------------
drop role r1;
create role r1;
drop role r2;
create role r2;
grant default r1 to role r2;
grant r1 to role r2 with admin option;
show grants;

recreate table t (i int);
grant select on t to u;
show grants;

grant select on t to u with grant option;
show grants;

grant select on t to u;
show grants;

drop role r1;
drop role r2;
create role r1;
create role r2;
grant r1 to role r2;
show grants;

grant r1 to role r2 with admin option;
show grants;

grant default r1 to role r2 with admin option;
show grants;

grant default r1 to role r2;
show grants;

drop role r1;
drop role r2;
create role r1;
create role r2;
grant default r1 to role r2;
show grants;
grant r1 to role r2 with admin option;
show grants;
