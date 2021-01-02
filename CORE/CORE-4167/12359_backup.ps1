###############################################################
#
# ������ �������� � ������������� ��������� ����� ���� ������,
# �������� �������������� �������, ����� � ������� �������
# �����: ������� �����
# Copyright (c) Silentium 2013
#
###############################################################

# ����� ����� ������� �������� �������� �����
Set-Alias -Name fbsvcmgr -Value "C:\Program Files\Firebird\Firebird_2_5\bin\fbsvcmgr.exe"
Set-Alias -Name rgbak -Value "f:\Utils\remote_backup.bat"
Set-Alias -Name gbak -Value "C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe"
Set-Alias -Name zip7 -Value "c:\Program Files\7-Zip\7z.exe"

$ArchiveDir  = "F:\Archives"        # ���� � ����� � ��������
$FBPassword  = "vniik80"            # ������ ������������ SYSDBA 
$FBDataDir   = "F:\FBData"          # ���� � ������
$FBDumpDir   = "F:\FBDump"          # ���� � �����
$RemoteDir   = "F:\Horses\Remote"   # ���� � ���������� ETNI
$LogDir      = "F:\Horses\Log"      # ���� � ����� ETNI
$MessagesDir = "F:\Horses\Messages" # ���� � ����� ��������� ETNI
$PicturesDir = "F:\Horses\Pictures" # ���� � ��������� ETNI
$ReportsDir  = "F:\Horses\Reports"  # ���� � ������� ETNI

$ExpiredDayInterval = 30            # ����� �������� ������� (� ����)

# �������� ������� ����
$CurrentDate = Get-Date 
# �������� � � ������� ���-�����-����
$BackupDir = "{0:yyyy-MM-dd}" -f $CurrentDate
# �������� ���� ������
$DayOfWeek = "{0:dddd}" -f $CurrentDate
# ������ �������� ������ ���� � ����� �������� ������
$BackupDir = $ArchiveDir + '\' + $BackupDir

# ������� ���������� �����
Remove-Item $FBDumpDir\*
if (Test-Path $FBDumpDir\horses.dmp) {
	Remove-Item $FBDumpDir\horses.dmp
}
if (Test-Path $FBDataDir\horses_new.fdb) {
	Remove-Item $FBDataDir\horses_new.fdb
}
# ������ ���� �����
#fbsvcmgr baseserver:service_mgr -user sysdba -password $FBPassword action_backup -dbname horses -bkp_file stdout > $FBDumpDir\horses.dmp
rgbak
# ��� �� ������������� �
gbak -c -v -user SYSDBA -pas $FBPassword -se localhost:service_mgr $FBDumpDir\horses.dmp $FBDataDir\horses_new.fdb -Y $FBDumpDir\restore.log
if (Test-Path  $FBDataDir\horses_new.fdb) {
	# ������������� Firebird (��� �������� ���� ��� ����������)
	Stop-Service -Name FirebirdServerDefaultInstance
	# ������� ������ ���� ��
	if (Test-Path $FBDataDir\horses_old.fdb) {
		Remove-Item $FBDataDir\horses_old.fdb
	}
    if (Test-Path $FBDataDir\horses.fdb) {
		Rename-Item $FBDataDir\horses.fdb $FBDataDir\horses_old.fdb
	}
	# ��������������� ���� ��
	Rename-Item $FBDataDir\horses_new.fdb $FBDataDir\horses.fdb
	# ��������� Firebird
	Start-Service -Name FirebirdServerDefaultInstance	
}

# ������� ����� � ������ ������, �� ������ ���� ��� �������� ������������
if (Test-Path $BackupDir) {
	Remove-Item $BackupDir -Recurse
}
# ������ ����� ��� �������
mkdir $BackupDir
# ���������� ��� ����
zip7 a -tzip -pplay $BackupDir\dump.zip $FBDumpDir\*.*
# ���������� Remote
zip7 a -tzip -pplay $BackupDir\remote.zip $RemoteDir\*.* -r "-x!*.access" "-x!~*.*"
# ���������� Messages
zip7 a -tzip -pplay $BackupDir\messages.zip $MessagesDir\*.*
# ���������� ����
zip7 a -tzip -pplay $BackupDir\log.zip $LogDir\*.* -r "-x!*.jpg"

# ���� ������� �������, �� ��� ��������� ����������� �������
if ($DayOfWeek = "�������") { 
    zip7 a -tzip -pplay $BackupDir\reports.zip $ReportsDir\*.* -r "-x!~*.*" 
}

# ������ ������� ������ ������
Get-ChildItem $ArchiveDir | ForEach {
    $dirdate = [datetime]$_.Name
	if ($dirdate -lt (Get-Date).AddDays(-$ExpiredDayInterval)) {
		Remove-Item $_.FullName -Recurse
	}
}