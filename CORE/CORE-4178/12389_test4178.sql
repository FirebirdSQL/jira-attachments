shell rm -f t4178.fdb;

create database 't4178.fdb';

create table tt
(
  char30w1251 char(30) character set win1251,
  varchar60utf8 varchar(60) character set utf8,
  short smallint,
  lng int,
  sfloat float,
  sdouble double precision,
  num3_1 numeric(3,1),
  num8_3 numeric(8,3),
  num15_2 numeric(15,2),
  num19_2 numeric(15,2),
  ts timestamp,
  t time,
  d date,
  blb866 blob sub_type 1 segment size 128 character set dos866,
  longint bigint,
  b boolean
);

commit;

insert into tt values ('abc', 'УТФ', 1, 2, 3.75, 6.77668899, 2.5, 56.789, 4.56, 3.62, NULL, NULL, NULL, NULL, 437578435, TRUE);
commit;
