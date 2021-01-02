CREATE TABLE T_ACCOUNTS (
    ID                    integer NOT NULL
);

ALTER TABLE T_ACCOUNTS ADD CONSTRAINT PK_T_ACCOUNTS PRIMARY KEY (ID);

SET TERM ^ ;

CREATE PROCEDURE P_ACC_BALANCE (
    FK_ACCOUNT INTEGER,
    ONDATE DATE)
RETURNS (
    ID INTEGER,
    FC_OUT NUMERIC(18,2),
    FC_OUT_BS NUMERIC(18,2))
AS
begin
  select first 1 id,fc_out,fc_out_bs
    from t_acc_balances b
    where fd_date<=:ondate and b.fk_account=:fk_account
    order by fd_date desc
    into id,fc_out,fc_out_bs;
  if (fc_out is null) then
    fc_out=0;
  if (fc_out_bs is null) then
    fc_out_bs = 0;
  if (fc_out<0) then
    fc_out = -fc_out;
  if (fc_out_bs<0) then
    fc_out_bs = -fc_out_bs;
  suspend;
end
^

SET TERM ; ^


CREATE TABLE T_ACC_BALANCES (
    ID             D_KEY NOT NULL /* D_KEY = INTEGER */,
    FK_ACCOUNT     D_KEY NOT NULL /* D_KEY = INTEGER */,
    FD_DATE        D_DATE NOT NULL /* D_DATE = DATE */,
    FC_OUT         D_MONEY NOT NULL /* D_MONEY = NUMERIC(18,2) DEFAULT 0 */,
    FC_TURN_DB     D_MONEY DEFAULT 0 NOT NULL /* D_MONEY = NUMERIC(18,2) DEFAULT 0 */,
    FC_TURN_CR     D_MONEY DEFAULT 0 NOT NULL /* D_MONEY = NUMERIC(18,2) DEFAULT 0 */,
    FC_OUT_BS      D_MONEY NOT NULL /* D_MONEY = NUMERIC(18,2) DEFAULT 0 */,
    FC_TURN_DB_BS  D_MONEY DEFAULT 0 NOT NULL /* D_MONEY = NUMERIC(18,2) DEFAULT 0 */,
    FC_TURN_CR_BS  D_MONEY DEFAULT 0 NOT NULL /* D_MONEY = NUMERIC(18,2) DEFAULT 0 */
);




/******************************************************************************/
/***                              Primary Keys                              ***/
/******************************************************************************/

ALTER TABLE T_ACC_BALANCES ADD PRIMARY KEY (ID);


/******************************************************************************/
/***                              Foreign Keys                              ***/
/******************************************************************************/

ALTER TABLE T_ACC_BALANCES ADD CONSTRAINT FK_T_ACC_BALANCES FOREIGN KEY (FK_ACCOUNT) REFERENCES T_ACCOUNTS (ID) ON DELETE CASCADE ON UPDATE CASCADE;


/******************************************************************************/
/***                                Indices                                 ***/
/******************************************************************************/

CREATE UNIQUE INDEX IX_T_ACC_BALANCES1 ON T_ACC_BALANCES (FK_ACCOUNT, FD_DATE);


/******************************************************************************/
/***                                Triggers                                ***/
/******************************************************************************/


SET TERM ^ ;




/* Trigger: T_ACC_BALANCES_BI */
CREATE TRIGGER T_ACC_BALANCES_BI FOR T_ACC_BALANCES
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
  if (NEW.ID is null) then
    NEW.ID = GEN_ID(GEN_T_ACC_BALANCES_ID,1);
END
^


SET TERM ; ^

