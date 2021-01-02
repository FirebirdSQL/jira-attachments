###############################################################
#
# Скрипт создания и архивирования резервных копий базы данных,
# настроек информационной системы, логов и готовых отчётов
# Автор: Симонов Денис
# Copyright (c) Silentium 2013
#
###############################################################

# Задаём алиас утилите создания резевной копии
Set-Alias -Name fbsvcmgr -Value "C:\Program Files\Firebird\Firebird_2_5\bin\fbsvcmgr.exe"
Set-Alias -Name rgbak -Value "f:\Utils\remote_backup.bat"
Set-Alias -Name gbak -Value "C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe"
Set-Alias -Name zip7 -Value "c:\Program Files\7-Zip\7z.exe"

$ArchiveDir  = "F:\Archives"        # Путь к папке с архивами
$FBPassword  = "vniik80"            # Пароль пользователя SYSDBA 
$FBDataDir   = "F:\FBData"          # Путь к данным
$FBDumpDir   = "F:\FBDump"          # Путь к дампу
$RemoteDir   = "F:\Horses\Remote"   # Путь к настройкам ETNI
$LogDir      = "F:\Horses\Log"      # Путь к логам ETNI
$MessagesDir = "F:\Horses\Messages" # Путь к файлу сообщений ETNI
$PicturesDir = "F:\Horses\Pictures" # Путь к картинкам ETNI
$ReportsDir  = "F:\Horses\Reports"  # Путь к отчётам ETNI

$ExpiredDayInterval = 30            # Время хранения архивов (в днях)

# Получаем текущую дату
$CurrentDate = Get-Date 
# Приводим её к формату год-месяц-день
$BackupDir = "{0:yyyy-MM-dd}" -f $CurrentDate
# Получаем день недели
$DayOfWeek = "{0:dddd}" -f $CurrentDate
# Теперь получаем полный путь к папке текущего архива
$BackupDir = $ArchiveDir + '\' + $BackupDir

# Удаляем предыдущую копию
Remove-Item $FBDumpDir\*
if (Test-Path $FBDumpDir\horses.dmp) {
	Remove-Item $FBDumpDir\horses.dmp
}
if (Test-Path $FBDataDir\horses_new.fdb) {
	Remove-Item $FBDataDir\horses_new.fdb
}
# Создаём саму копию
#fbsvcmgr baseserver:service_mgr -user sysdba -password $FBPassword action_backup -dbname horses -bkp_file stdout > $FBDumpDir\horses.dmp
rgbak
# Тут же разворачиваем её
gbak -c -v -user SYSDBA -pas $FBPassword -se localhost:service_mgr $FBDumpDir\horses.dmp $FBDataDir\horses_new.fdb -Y $FBDumpDir\restore.log
if (Test-Path  $FBDataDir\horses_new.fdb) {
	# Останавливаем Firebird (это временно пока нет репликации)
	Stop-Service -Name FirebirdServerDefaultInstance
	# Удаляем старый файл БД
	if (Test-Path $FBDataDir\horses_old.fdb) {
		Remove-Item $FBDataDir\horses_old.fdb
	}
    if (Test-Path $FBDataDir\horses.fdb) {
		Rename-Item $FBDataDir\horses.fdb $FBDataDir\horses_old.fdb
	}
	# Переименовываем файл БД
	Rename-Item $FBDataDir\horses_new.fdb $FBDataDir\horses.fdb
	# Запускаем Firebird
	Start-Service -Name FirebirdServerDefaultInstance	
}

# Удаляем папку с данным именем, на случай если она случайно образовалась
if (Test-Path $BackupDir) {
	Remove-Item $BackupDir -Recurse
}
# Создаём папку для архивов
mkdir $BackupDir
# Архивируем наш дамп
zip7 a -tzip -pplay $BackupDir\dump.zip $FBDumpDir\*.*
# Архивируем Remote
zip7 a -tzip -pplay $BackupDir\remote.zip $RemoteDir\*.* -r "-x!*.access" "-x!~*.*"
# Архивируем Messages
zip7 a -tzip -pplay $BackupDir\messages.zip $MessagesDir\*.*
# Архивируем логи
zip7 a -tzip -pplay $BackupDir\log.zip $LogDir\*.* -r "-x!*.jpg"

# Если сегодня суббота, то ещё добавляем копирование отчётов
if ($DayOfWeek = "Суббота") { 
    zip7 a -tzip -pplay $BackupDir\reports.zip $ReportsDir\*.* -r "-x!~*.*" 
}

# Теперь удаляем старые архивы
Get-ChildItem $ArchiveDir | ForEach {
    $dirdate = [datetime]$_.Name
	if ($dirdate -lt (Get-Date).AddDays(-$ExpiredDayInterval)) {
		Remove-Item $_.FullName -Recurse
	}
}