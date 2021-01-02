connect "D:\Projekte\SQL\cls_table\cls.gdb" user SYSDBA password masterkey;
drop database;
create database 'D:\Projekte\SQL\cls_table\cls.gdb' user 'SYSDBA' password 'masterkey' page_size 16384 default character set utf8; 

create table cls (
  id numeric(18)
    constraint cls_id_ck_c not null,
  id_parent numeric(18)
    constraint cls_idparent_ck_c not null,
  id_child numeric(18)
    constraint cls_idchild_ck_c not null,
  depth numeric(18)
    constraint cls_depth_ck_c not null,
  constraint cls_ui1_c unique(id_parent, depth, id_child),
  constraint cls_ui2_c unique(id_child, id_parent),
  constraint cls_pk_c primary key (id)
);

--   insert into cls values(6, 7, 10, 1);
--   insert into cls values(5, 2, 10, 2);
--   insert into cls values(4, 2, 7, 1);
--   insert into cls values(3, 10, 10, 0);
--   insert into cls values(2, 7, 7, 0);
--   insert into cls values(1, 2, 2, 0);

insert into cls values(1, 2, 2, 0);
insert into cls values(2, 7, 7, 0);
insert into cls values(3, 10, 10, 0);
insert into cls values(4, 2, 7, 1);
insert into cls values(5, 2, 10, 2);
insert into cls values(6, 7, 10, 1);

commit;

--   delete
--     from cls
--    where id in (
--                 4, 5
--                );

  delete
    from cls
   where id in (
                select c.id
                  from cls c
                       inner join
                       cls p
                       on c.id_parent = p.id_parent
                 where p.id_child = 7
                   and p.depth = 1
                   and c.depth >= 1
               );

commit;

exit;
