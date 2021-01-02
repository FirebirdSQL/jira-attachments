set term ^;

create or alter exception ex_tra_start 'transaction @1 aborted'
^

create or alter procedure tx_trig_log(msg varchar(255))
as
declare s varchar(255);
begin
  s = rdb$get_context('USER_SESSION', 'tx_trig_log');
  if (s <> '')
  then begin 
    s = s || ASCII_CHAR(10) || msg || current_transaction;
    rdb$set_context('USER_SESSION', 'tx_trig_log', :s);
  end
end
^

create or alter trigger tx_start on transaction start as
declare s varchar(255);
begin
  execute procedure tx_trig_log('start ');
  
  if (rdb$get_context('USER_SESSION', 'tx_abort') = 1)
  then begin
	rdb$set_context('USER_SESSION', 'tx_abort', 0);
	execute procedure tx_trig_log('exception ');
    exception ex_tra_start using (current_transaction);
  end
end
^

create or alter trigger tx_commit on transaction commit as
declare s varchar(255);
begin
  execute procedure tx_trig_log('commit ');
end
^

create or alter trigger tx_rollback on transaction rollback as
declare s varchar(255);
begin
  execute procedure tx_trig_log('rollback ');
end
^

create or alter procedure tx_autonomous as
begin
  rdb$set_context('USER_SESSION', 'tx_abort', 1);
  in autonomous transaction do
     execute procedure tx_trig_log('autonomous ');  
end
^

set term ;^
