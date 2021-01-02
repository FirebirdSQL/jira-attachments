program test;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows;

procedure OneTry;
type
  ISCStatus = Integer;
  PISCStatus = ^ISCStatus;
  isc_db_handle = PPointer;
  IscDbHandle = type isc_db_handle;
  PIscDbHandle = ^IscDbHandle;

const
  fb_shutrsn_svc_stopped      = -1;
  fb_shutrsn_app_stopped      = -3;
  ISC_STATUS_LENGTH = 20;
  CLASS_MASK = $F0000000; // Defines the code as warning, error, info, or other

type
  TStatusVector = array[0..ISC_STATUS_LENGTH - 1] of ISCStatus;

var
  isc_attach_database: function(user_status: PISCStatus; file_length: Smallint; file_name: PAnsiChar; handle: PIscDbHandle; dpb_length: Smallint; dpb: PAnsiChar): ISCStatus; stdcall;
  isc_detach_database: function(user_status: PISCStatus; handle: PIscDbHandle): ISCStatus; stdcall;
  fb_shutdown: function(timeout: Cardinal; const reason: Integer): Integer; stdcall;

  procedure CheckApiCall(const Status: ISCStatus);

    function GetClass(code: ISCStatus): Word;
    begin
      Result := (code and CLASS_MASK) shr 30;
    end;

  begin
    if (Status <> 0) and (GetClass(Status) = 0) then
      raise Exception.Create('Error: ' + IntToStr(Status));
  end;

  procedure AttachDatabase(const FileName: AnsiString; var DbHandle: IscDbHandle; Params: AnsiString);
  var
    StatusVector: TStatusVector;
  begin
    FillChar(StatusVector, SizeOf(StatusVector), 0);
    CheckApiCall(isc_attach_database(@StatusVector, Length(FileName), Pointer(FileName),
      @DBHandle, Length(Params), PAnsiChar(Params)));
  end;

  procedure DetachDatabase(var DbHandle: IscDbHandle);
  var
    StatusVector: TStatusVector;
  begin
    FillChar(StatusVector, SizeOf(StatusVector), 0);
    CheckApiCall(isc_detach_database(@StatusVector, @DbHandle));
    DbHandle := nil;
  end;

var
  Handle: THandle;
  fb_shutdownRes: Integer;
  DbHandle: IscDbHandle;
begin
  // Handle := Windows.LoadLibrary('fbembed.dll');
  Handle := Windows.LoadLibrary( PChar(ParamStr(1)) );

  if Handle <= HINSTANCE_ERROR then
    RaiseLastOSError;

  isc_attach_database := GetProcAddress(Handle, 'isc_attach_database');
  Assert(Assigned(isc_attach_database));

  isc_detach_database := GetProcAddress(Handle, 'isc_detach_database');
  Assert(Assigned(isc_detach_database));

  fb_shutdown := GetProcAddress(Handle, 'fb_shutdown');
  Assert(Assigned(fb_shutdown));

  DbHandle := nil;
  AttachDatabase(ExtractFilePath(ParamStr(0)) + 'Data.fdb', DbHandle, #1'?'#1#3'0'#7'WIN1251'#$1C#6'SYSDBA'#$1D#9'masterkey');
  DetachDatabase(DbHandle);

  fb_shutdownRes := 0; //fb_shutdown(60000, fb_shutrsn_app_stopped); // other good connections had been dropped
  if fb_shutdownRes <> 0
  then WriteLn('shutdownRes = ', fb_shutdownRes);

  FreeLibrary(Handle);
end;

var
  I: Integer;
  s: String;
begin
  SetLength(s, 255);
  GetEnvironmentVariable('FIREBIRD', @s[1], Length(s)-1);
  SetLength(s, StrLen(@s[1]));

  if s = ''
  then begin
    s := ParamStr(1);
    s := ExtractFilePath(s);
    Delete(s, length(s), 1);
    if (ExtractFileName(ParamStr(1)) = 'fbembed.dll')
    then s := Copy(s, 1, LastDelimiter('\', s)-1);

    SetEnvironmentVariable('FIREBIRD', PChar(s));
  end;

  Writeln('FIREBIRD = ', s);
  Writeln('ready');
  ReadLn;

  try
    for I := 1 to 100000 do
    begin
      WriteLn(I);
      OneTry;
    end;
  except
    on E:Exception do
      WriteLn('Exception: ', E.message);
  end;

  Writeln('done');
  ReadLn;
end.

