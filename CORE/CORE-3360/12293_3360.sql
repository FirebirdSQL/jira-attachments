-- as dbo
create table THE_TABLE (WRITEABLE_COLUMN varchar(50), NON_WRITEABLE_COLUMN int);
grant select on THE_TABLE to public;
grant update (WRITEABLE_COLUMN) on THE_TABLE to public;
insert into THE_TABLE values('nothing', -3);
commit;

-- as regular user
UPDATE THE_TABLE set WRITEABLE_COLUMN = 'something' where WRITEABLE_COLUMN = 'nothing' RETURNING NON_WRITEABLE_COLUMN;
rollback;
