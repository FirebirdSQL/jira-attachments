create table tbl_bugcheck291
(
 ID integer NOT NULL PRIMARY KEY,
 DATA integer
);

commit;

insert into tbl_bugcheck291 (id, data) values (1,100);

commit;

create trigger bu_tbl_bugcheck291 for tbl_bugcheck291
 before update
as
begin
 if(new.data is not null)then
 begin
  if(new.data<110)then
  begin
   update tbl_bugcheck291 x set x.data=new.data+1 where x.id=new.id;
  end
 end
end;

commit;

/*ok*/
update tbl_bugcheck291 set data=105 where id=1;

commit;

/*ok*/
update tbl_bugcheck291 set data=105 where id=1;

/*FB2.5: internal Firebird consistency check (cannot find record back version (291), file: vio.cpp line: 5014).*/
update tbl_bugcheck291 set data=105 where id=1;

/*internal Firebird consistency check (can't continue after bugcheck).*/
update tbl_bugcheck291 set data=105 where id=1;
update tbl_bugcheck291 set data=105 where id=1;
update tbl_bugcheck291 set data=105 where id=1;
update tbl_bugcheck291 set data=105 where id=1;
