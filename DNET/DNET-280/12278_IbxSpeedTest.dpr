program IbxSpeedTest;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  IBDatabase, IBSQL;

procedure Test;
const
  RECORD_COUNT = 100000;
var
  Db: TIBDatabase;
  Tr: TIBTransaction;
  Sql: TIBSQL;
  Start, Finish: TDateTime;
  Seconds: Double;
  i: Integer;
begin
  Db := TIBDatabase.Create(nil);
  try
    Db.DatabaseName := 'D:\Temp\Test.fdb';
    Db.Params.Add('user_name=sysdba');
    Db.Params.Add('password=masterkey');
    Db.LoginPrompt := False;
    Db.Open;

    Tr := TIBTransaction.Create(Db);
    Tr.DefaultDatabase := Db;
    Tr.StartTransaction;

    Sql := TIBSQL.Create(Db);
    Sql.Transaction := Tr;

    Sql.SQL.Text := 'CREATE OR ALTER PROCEDURE sp_test_empty AS BEGIN END';
    Sql.ExecQuery;

    Sql.SQL.Text := 'EXECUTE PROCEDURE sp_test_empty';
    Sql.Prepare;

    Start := Now;
    for i := 1 to RECORD_COUNT do
      Sql.ExecQuery;
    Finish := Now;

    Seconds := (Finish - Start) * 24 * 60 * 60;

    WriteLn(Format('IBX: %d commands in %g seconds; %g commands per second', [RECORD_COUNT, Seconds, RECORD_COUNT / Seconds]));
    Readln;
  finally
    Db.Free;
  end;
end;

begin
  try
    Test;
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
end.

