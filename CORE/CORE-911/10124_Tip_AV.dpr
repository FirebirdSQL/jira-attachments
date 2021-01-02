program Tip_AV;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  IBSQL,
  IBDatabase,
  IBDatabaseInfo,
  IBIntf,
  DB;

procedure Doit;
var
  sDatabase  : String;
  db1, db2   : TIBDatabase;
  dbInfo     : TIBDatabaseInfo;
  tr1, tr2   : TIBTransaction;
  sql1, sql2 : TIBSQL;
  i          : Integer;
begin
  sDatabase := ParamStr(1);

  db1 := TIBDatabase.Create(nil);
  db1.DatabaseName := sDatabase;
  db1.Params.Text := 'page_size 1024';
  db1.CreateDatabase;
  dbInfo := TIBDatabaseInfo.Create(nil);
  dbInfo.Database := db1;
  WriteLn(dbInfo.Version);
  db1.Close;

  db1.LoginPrompt := False;
  db1.Params.Values['force_write'] := '0';
  db1.Open;

  tr1 := TIBTransaction.Create(nil);
  tr1.DefaultDatabase := db1;

  sql1 := TIBSQL.Create(nil);
  sql1.Database    := db1;
  sql1.Transaction := tr1;

  tr1.StartTransaction;
  sql1.SQL.Text := 'CREATE TABLE T (ID INT)';
  sql1.ExecQuery;
  tr1.Commit;

  tr1.Params.Add('read_committed');
  tr1.Params.Add('rec_version');
  tr1.Params.Add('nowait');
  tr1.Params.Add('read');
  tr1.StartTransaction;


  db2 := TIBDatabase.Create(nil);
  db2.DatabaseName := sDatabase;
  db2.LoginPrompt := False;
  db2.Open;

  tr2 := TIBTransaction.Create(nil);
  tr2.DefaultDatabase := db2;

  for i := 0 to 4016 do
  begin
    tr2.StartTransaction;
    tr2.Commit;
  end;

  sql2 := TIBSQL.Create(nil);
  sql2.Database    := db2;
  sql2.Transaction := tr2;

  tr2.StartTransaction;
  sql2.SQL.Text := 'INSERT INTO T VALUES (CURRENT_TRANSACTION)';
  sql2.ExecQuery;
  tr2.Commit;

  for i := 0 to 4016 do
  begin
    tr2.StartTransaction;
    tr2.Commit;
  end;

  db2.Close;



  sql1.SQL.Text := 'SELECT ID FROM T';
  sql1.ExecQuery;
  WriteLn('ID = ', sql1.Fields[0].AsInteger);
  sql1.Close;
  tr1.Commit;

  db1.DropDatabase;
end;

begin
  try
    doit;
  except on E : Exception do
    writeln(E.message);
  end;
end.
