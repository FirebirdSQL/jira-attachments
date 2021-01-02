set echo on;

create database 'some_remote_server:/fbsql/test.fdb' user 'SYSDBA' password 'masterkey';

create table testing (
id varchar(10) not null primary key,
data blob
);

commit;

insert into testing values ('first', @'C:\Downloads\VCS.img');

commit;

exit;