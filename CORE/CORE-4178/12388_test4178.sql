shell rm -f t4178.fdb;

create database 't4178.fdb';

create table tt
(
  char30none char(30) character set none,
  varchar60utf8 varchar(60) character set utf8,
  short smallint,
  lng int,
  sfloat float,
  sdouble double precision,
  num3_1 numeric(3,1),
  num8_3 numeric(8,3),
  num15_2 numeric(15,2),
  ts timestamp,
  t time,
  d date,
  blb blob sub_type 1 segment size 128 character set utf8,
  longint bigint,
  b boolean
);
