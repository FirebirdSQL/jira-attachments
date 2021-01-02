@echo off
echo **************************** > %2
date /t >> %2
time /t >> %2
echo Szhely.gdb3 >> %2
"c:\Program files\firebird\firebird_2_5\bin\gbak.exe" -b -g -user sysdba -pas masterkey 172.16.1.34/3050:/home/firebird/Szhely.gdb3s e:\mentes\%1\Szhely.bak >e:\mentes\%1\szhely.log
if exist e:\mentes\%1\Szhely.bak goto libra
echo Szhely.gdb3s mentése sikertelen >>%2
:libra
time /t >> %2
echo Libra3s.gdb3 >> %2
"c:\Program files\firebird\firebird_2_5\bin\gbak.exe" -b -g -user sysdba -pas masterkey 172.16.1.34/3050:/home/firebird/Libra3s.gdb3s e:\mentes\%1\Libra3s.bak >e:\mentes\%1\libra.log
time /t >> %2
