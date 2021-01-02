create database 'x.fdb'!

create sequence s1!

-- test computed expressions
create table t1 (
  n integer primary key,
  x integer,
  cn computed by (coalesce(n + 0, null)),
  cx computed by (coalesce(x + 0, null))
)!

-- test update or insert
update or insert into t1 values (next value for s1, 10)!
update or insert into t1 values (next value for s1, 20)!
update or insert into t1 values (next value for s1, 30)!

select * from t1!

-- test sequence value after update or insert
select gen_id(s1, 0) from rdb$database!

-- test update or insert using coalesce
update or insert into t1
  values (coalesce((select first 1 n from t1 order by n), null), coalesce(40 + 60, 0))!

-- test update or insert in PSQL
execute block returns (n integer, x integer, cn integer, cx integer)
as
  declare z integer = 200;
begin
  update or insert into t1
    values (coalesce((select first 1 skip 1 n from t1 order by n), null), :z);

  for select n, x, cn, cx from t1 into n, x, cn, cx do
      suspend;
end!

select gen_id(s1, 0) from rdb$database!

-- test view
create view v1 as
  select t1.*, coalesce(n + 0, null) vcn from t1!

select * from v1!

-- test update or insert into a view
update or insert into v1 values (next value for s1, 40)!

-- test update or insert into a view in PSQL
execute block returns (n integer, x integer, cn integer, cx integer)
as
  declare z integer = 300;
begin
  update or insert into v1 values ((select first 1 skip 2 n from t1 order by n), :z);

  for select n, x, cn, cx from v1 into n, x, cn, cx do
      suspend;
end!

-- test view trigger
create trigger v1_bi before insert on v1
as
  declare z integer = 1000;
begin
  insert into t1 values (coalesce(new.n + :z, null), new.x);
end!

insert into v1 values (8, 88)!

select * from v1!

-- test coalesce
select coalesce(n * 1, null) from v1!
select coalesce(n * 1, null) from t1 group by coalesce(n * 1, null)!
select coalesce(n * 1, null) from v1 group by coalesce(n * 1, null)!
select coalesce(n * 1, null) from v1 group by 1!
select coalesce(n * 1, null) from v1 group by 1 having coalesce(n * 1, null) < 100!
select coalesce(n * 10, null) from v1 order by 1!
select coalesce(n * 10, null), coalesce(x * 10, null) from v1 order by 2 desc, 1 desc!
select coalesce(n * 10, null), coalesce(x * 10, null) from v1 order by 1 desc, 2 desc!

-- test case
select case n * 1 when 1 then n * 1 else n + 0 end
  from v1 group by case n * 1 when 1 then n * 1 else n + 0 end!
select case n * 1 when 1 then n * 1 else n + 0 end from v1 group by 1!
select case n * 1 when 1 then n * 1 else n + 0 end
  from v1 group by 1 having case n * 1 when 1 then n * 1 else n + 0 end < 100!
select case n * 1 when 1 then n * 1 else n + 0 end from v1 order by 1 desc!

-- test non-valid statements
select coalesce(n * 1, null) from v1 group by 1 having coalesce(n * 0, null) < 100!
select case n * 1 when 1 then n * 1 else n + 0 end
  from v1 group by case n * 1 when 1 then n * 1 else n + 1 end!
select case n * 1 when 1 then n * 1 else n + 0 end
  from v1 group by 1 having case n * 1 when 1 then n * 1 else n + 1 end < 100!

create procedure p1 returns (n integer)
as
begin
  select coalesce(n * 1, null) from t1 group by coalesce(n * 1, null) into n;
  suspend;
end!
commit!
-- set blob all!
-- select rdb$procedure_blr from rdb$procedures where rdb$procedure_name = 'P1'!

-- test coalesce in view condition
create view v2 as
  select t1.n n, coalesce(n + 1, null) x1, coalesce(n + 2, null) x2 from t1
    where coalesce(0 + 0, null) = coalesce(0 + 0, null)!

select * from v2!

-- test coalesce in view using distinct
create view v3 as
  select distinct
      t1.n n,
      coalesce(n + 1, null) + coalesce(n + 11, null) x1,
      coalesce(n + 2, null) + coalesce(n + 22, null) x2
    from t1!

select * from v3!

-- test coalesce with subselect with coalesce in view
create view v4 as
  select
      t1.n n,
      coalesce((select coalesce(0 + 1, null) from rdb$database), null) x1,
      coalesce((select coalesce(2 + 1, null) from rdb$database), null) x2
    from t1!

select * from v4!

-- test coalesce in view using union
create view v5 (n, x1, x2) as
  select
      t1.n n,
      coalesce(n + 1, null) + coalesce(n + 11, null) x1,
      coalesce(n + 2, null) + coalesce(n + 22, null) x2
    from t1
  union all
  select
      t1.n n,
      coalesce(n + 1, null) + coalesce(n + 11, null) x1,
      coalesce(n + 2, null) + coalesce(n + 22, null) x2
    from t1!

select * from v5!

-- test constraint
alter table t1
  add constraint t1_n check (coalesce(n + 0, null) < 10),
  add constraint t1_cx check (coalesce(cx + 0, null) < 10)!

insert into t1 values (5, 5)!
insert into t1 values (50, 5)!
insert into t1 values (5, 50)!

-- test domain constraint
create domain dc1 as integer check (coalesce(value + 0, null) < 10)!
create domain dc2 as integer check (coalesce(value + 0, null) < 10)!

alter table t1
  add dc1 dc1,
  add dc2 dc2!

insert into t1 (n, dc1) values (6, 6)!
insert into t1 (n, dc2) values (7, 7)!
insert into t1 (n, dc1) values (8, 10)!
insert into t1 (n, dc2) values (8, 10)!

-- add bad computed expression with coalesce
alter table t1
  add bc computed by (coalesce(n / (n - 2), null))!

select bc from t1 order by n!

-- test parameters
set sqlda_display on!

select coalesce(1 + cast(? as integer), 2 + cast(? as integer))
  from rdb$database
  where coalesce(3 + cast(? as bigint), null) = 0!

