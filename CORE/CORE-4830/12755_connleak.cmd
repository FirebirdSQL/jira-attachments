@echo off
setlocal
set db=%~pd0\connleak.fdb
set init=%~pd0\connleak_init.sql
set tst=%~pd0\connleak_test.sql
set mem=%~pd0\connleak_mem.sql
set wait=%~pd0\connleak_wait
set usr=SYSDBA
set pwd=masterkey
set cycles=10000

if "%1"=="init" goto init_
if "%1"=="run" goto run_
if "%1"=="internal" goto internal_
echo First: call connleak init
echo Second: call connleak run
exit /B

:init_
if exist %db% (
echo Sorry, connleak.fdb already exists
echo Delete it and try again
exit /B
)

echo create database '%db%' user '%USR%' password '%PWD%' page_size 8192;>%init%
echo exit;>>%init%

echo connect '%db%' user '%USR%' password '%PWD%';>%tst%
echo select * from RDB$BACKUP_HISTORY;>>%tst%
echo select * from RDB$CHECK_CONSTRAINTS;>>%tst%
echo select * from RDB$DATABASE;>>%tst%
echo select * from RDB$EXCEPTIONS;>>%tst%
echo select * from RDB$FIELD_DIMENSIONS;>>%tst%
echo select * from RDB$FILTERS;>>%tst%
echo select * from RDB$FUNCTIONS;>>%tst%
echo select * from RDB$GENERATORS;>>%tst%
echo select * from RDB$INDICES;>>%tst%
echo select * from RDB$PAGES;>>%tst%
echo select * from RDB$PROCEDURE_PARAMETERS;>>%tst%
echo select * from RDB$RELATIONS;>>%tst%
echo select * from RDB$RELATION_FIELDS;>>%tst%
echo select * from RDB$SECURITY_CLASSES;>>%tst%
echo select * from RDB$TRIGGERS;>>%tst%
echo select * from RDB$TYPES;>>%tst%
echo select * from RDB$VIEW_RELATIONS;>>%tst%
echo select * from RDB$CHARACTER_SETS;>>%tst%
echo select * from RDB$COLLATIONS;>>%tst%
echo select * from RDB$DEPENDENCIES;>>%tst%
echo select * from RDB$FIELDS;>>%tst%
echo select * from RDB$FILES;>>%tst%
echo select * from RDB$FORMATS;>>%tst%
echo select * from RDB$FUNCTION_ARGUMENTS;>>%tst%
echo select * from RDB$INDEX_SEGMENTS;>>%tst%
echo select * from RDB$LOG_FILES;>>%tst%
echo select * from RDB$PROCEDURES;>>%tst%
echo select * from RDB$REF_CONSTRAINTS;>>%tst%
echo select * from RDB$RELATION_CONSTRAINTS;>>%tst%
echo select * from RDB$ROLES;>>%tst%
echo select * from RDB$TRANSACTIONS;>>%tst%
echo select * from RDB$TRIGGER_MESSAGES;>>%tst%
echo select * from RDB$USER_PRIVILEGES;>>%tst%
echo exit;>>%tst%

echo connect '%db%' user '%USR%' password '%PWD%';>%mem%
echo set list;>>%mem%
echo select cast('NOW' as timestamp) TS, m.*, (select count(*) from mon$attachments) ATTACHMENTS, (select count(*) from mon$statements) STATEMENTS from mon$memory_usage m where m.mon$stat_group=0;>>%mem%
echo commit;>>%mem%
echo shell %0 internal;>>%mem%
echo select cast('NOW' as timestamp) TS, m.*, (select count(*) from mon$attachments) ATTACHMENTS, (select count(*) from mon$statements) STATEMENTS from mon$memory_usage m where m.mon$stat_group=0;>>%mem%
echo commit;>>%mem%
echo shell echo Now, when you press the key again, isql will be closed and memory released;>>%mem%
echo shell pause;>>%mem%

isql -q -i %init%
gfix %DB% -buffers 8192 -user %USR% -password %PWD%

exit /B

:run_
if exist %wait%1 del %wait%1
if exist %wait%2 del %wait%2
if exist %wait%3 del %wait%3
if exist %wait%4 del %wait%4

isql -q -i %mem%
exit /B

:internal_
start "Test 1" cmd /C (for /L %%i in (1,1,%cycles%) do @isql -q -i %tst%^>nul ^& @echo %%i) ^& echo Ended^>%wait%1
start "Test 2" cmd /C (for /L %%i in (1,1,%cycles%) do @isql -q -i %tst%^>nul ^& @echo %%i) ^& echo Ended^>%wait%2
start "Test 3" cmd /C (for /L %%i in (1,1,%cycles%) do @isql -q -i %tst%^>nul ^& @echo %%i) ^& echo Ended^>%wait%3
start "Test 4" cmd /C (for /L %%i in (1,1,%cycles%) do @isql -q -i %tst%^>nul ^& @echo %%i) ^& echo Ended^>%wait%4

:wait_
ping localhost -t 2 -w 2000>nul
if not exist %wait%1 goto wait_
if not exist %wait%2 goto wait_
if not exist %wait%3 goto wait_
if not exist %wait%4 goto wait_