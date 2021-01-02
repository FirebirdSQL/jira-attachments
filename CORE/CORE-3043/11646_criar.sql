create database 'c:\testecharset.gdb' PAGE_SIZE 8192 USER 'SYSDBA' PASSWORD 'masterkey' DEFAULT CHARACTER SET ISO8859_1;

set names ISO8859_1;

create table teste (
  campo char(1) constraint cc_campo check (campo in ('A', 'É')));


