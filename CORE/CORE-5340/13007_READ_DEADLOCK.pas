program READ_DEADLOCK;

{$MODE DELPHI}

uses Firebird;

var
  master:IMaster;
  dispatcher:IProvider;
  attachment:IAttachment;
  status:IStatus;
  transaction_rw,transaction_ro:ITransaction;
  util:Firebird.IUtil;
  s:string;
  TPB:array of Byte;
  resultset:IResultSet;
  metadata:IMessageMetadata;
  message:array of Byte;

begin
  try
    master:=fb_get_master_interface;
    dispatcher:=master.getDispatcher;
    status:=master.getStatus;
    util:=master.getUtilInterface;
    attachment:=dispatcher.createDatabase(status,'READ_DEADLOCK.FDB',0,nil);

    SetLength(TPB, 5);
    TPB[0]:=isc_tpb_version3;
    TPB[1]:=isc_tpb_read_committed;
    TPB[2]:=isc_tpb_no_rec_version;
    TPB[3]:=isc_tpb_wait;
    TPB[4]:=isc_tpb_write;
    transaction_rw:=attachment.startTransaction(status,Length(TPB),@TPB[0]);

    attachment.execute(status,transaction_rw,0,'CREATE TABLE TBL_TRA_TEST(ID BIGINT);',3,nil,nil,nil,nil);
    transaction_rw.commit(status);

    transaction_rw:=attachment.startTransaction(status,Length(TPB),@TPB[0]);
    attachment.execute(status,transaction_rw,0,'INSERT INTO TBL_TRA_TEST (ID) VALUES (1);',3,nil,nil,nil,nil);

    TPB[0]:=isc_tpb_version3;
    TPB[1]:=isc_tpb_read_committed;
    TPB[2]:=isc_tpb_no_rec_version;
    TPB[3]:=isc_tpb_wait;
    TPB[4]:=isc_tpb_read;
    transaction_ro:=attachment.startTransaction(status,Length(TPB),@TPB[0]);
    resultset:=attachment.openCursor(status,transaction_ro,0,'SELECT * FROM TBL_TRA_TEST;',3,nil,nil,nil,nil,0);
    metadata:=resultset.getMetadata(status);

    SetLength(message,metadata.getMessageLength(status));

    while (resultset.fetchNext(status,@message)=Firebird.IStatus.RESULT_OK) do
     begin
     end;
  except
   on e:FbException do
    begin
      SetLength(s,2000);
      SetLength(s,util.formatStatus(PAnsiChar(s),2000,e.getStatus));
      WriteLn('Exception: ',AnsiString(s));
   end;
  end;
end.

