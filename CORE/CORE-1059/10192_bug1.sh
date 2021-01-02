#!/bin/sh

echo 'select * from calc_all;' | isql -u root -p root $1

