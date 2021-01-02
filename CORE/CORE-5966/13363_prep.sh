#!/bin/bash

set +x

DB="/home/roman/var/prep.fdb"

rm -f ${DB} 

CREATE_DB="
create database 'localhost:${DB}';
create or alter user u password 'masterkey';
create table t_mem(pk integer not null primary key, val double precision);
grant select, update on t_mem to u;
commit;
"

echo ${CREATE_DB} | ./isql -q

rm -f pipe
mkfifo pipe

./isql localhost:${DB} -U $2 -P masterkey -i pipe &

for (( i=0; i < $1; i++ ))
do 
	echo "update t_mem set val=0;" > pipe
done

wait
