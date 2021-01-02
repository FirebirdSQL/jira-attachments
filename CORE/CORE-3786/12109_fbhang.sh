#!/bin/ksh


FB=/Library/Frameworks/Firebird.framework/Versions/A/Resources/bin
DB=/tmp/hang.db

rm -f "${DB}"
printf "Note: hangs only on Lion first time after reboot!\n"
printf "\n"

printf "creating database: %s\n" "${DB}"

(
printf "create database '%s' user 'SYSDBA' password 'masterkey';\n" "${DB}"
printf "quit;\n"
) | "${FB}/isql" -q
printf "\n"

printf "database created:\n" 
ls -al "${DB}"
printf "\n"

exit 0


