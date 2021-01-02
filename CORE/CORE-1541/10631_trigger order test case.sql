--drop table DETAIL;
--drop table MASTER;
--drop table LOG;


create table MASTER (ID_MASTER integer not null, DESCRIPTION varchar(20) not null);
create table DETAIL (ID_DETAIL integer not null, ID_MASTER integer not null, DESCRIPTION varchar(20) not null);
alter table MASTER add constraint PK_MASTER primary key (ID_MASTER);
alter table DETAIL add constraint PK_DETAIL primary key (ID_DETAIL);
alter table DETAIL add constraint FK_DETAIL_MASTER foreign key (ID_MASTER) references MASTER on update cascade on delete cascade;
create table LOG (LOG varchar(255));

create trigger MASTER_BD for MASTER
active before delete position 0
AS
begin
  insert into LOG values ('before delete master (' || old.DESCRIPTION || ')');
end;

create trigger MASTER_AD for MASTER
active after delete position 0
AS
begin
  insert into LOG values ('after delete master (' || old.DESCRIPTION || ')');
end;

create trigger DETAIL_BD for DETAIL
active before delete position 0
AS
begin
  insert into LOG values ('before delete detail (' || old.DESCRIPTION || ')');
  insert into LOG values ('master record description (' || (select M.DESCRIPTION from MASTER M where M.ID_MASTER = old.ID_MASTER) || ')');
end;

create trigger DETAIL_AD for DETAIL
active after delete position 0
AS
begin
  insert into LOG values ('after delete detail (' || old.DESCRIPTION || ')');
end;

insert into MASTER values (1, 'master');
insert into DETAIL values (1, 1, 'detail1');
insert into DETAIL values (2, 1, 'detail2');
commit;

delete from MASTER;
commit;
--select * from LOG;

