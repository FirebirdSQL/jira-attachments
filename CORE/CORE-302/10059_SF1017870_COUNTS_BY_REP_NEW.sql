CREATE PROCEDURE COUNTS_BY_REP_NEW(
    START_DATE DATE)
RETURNS (
    LBL VARCHAR(50) CHARACTER SET ASCII,
    JAN FLOAT,
    FEB FLOAT,
    MAR FLOAT,
    APR FLOAT,
    MAY FLOAT,
    JUN FLOAT,
    JUL FLOAT,
    AUG FLOAT,
    SEP FLOAT,
    OCT FLOAT,
    NOV FLOAT,
    DCM FLOAT,
    TOTAL FLOAT)
AS
DECLARE VARIABLE TMP FLOAT;
DECLARE VARIABLE YearValue Integer;
DECLARE VARIABLE MonthValue Integer;
DECLARE VARIABLE TotalComplaint Integer;
begin

  TotalComplaint = 0;
  
  select extract(year from :START_DATE) from RDB$Database INTO YearValue;

  LBL = 'Recurring Root';
  FOR

    select
      extract(month from C.ENT_DATE),
      count(*)
    from COMPLAINTS C
    join RESPONSE R on R.ID = C.ID
    join APPROVE A on A.ID = R.ID
    where
       (A.RECURRING_ROOT <> '0') and
       extract(year from C.ENT_DATE) = :YearValue
    Group by 1
    INTO
      :MonthValue,
      :TMP
  DO
  BEGIN
  
    if (MonthValue = 1) then
      JAN = TMP;
    else
    if (MonthValue = 2) then
      FEB = TMP;
    else
    if (MonthValue = 3) then
      MAR = TMP;
    else
    if (MonthValue = 4) then
      APR = TMP;
    else
    if (MonthValue = 5) then
      MAY = TMP;
    else
    if (MonthValue = 6) then
      JUN = TMP;
    else
    if (MonthValue = 7) then
      JUL = TMP;
    else
    if (MonthValue = 8) then
      AUG = TMP;
    else
    if (MonthValue = 9) then
      SEP = TMP;
    else
    if (MonthValue = 10) then
      OCT = TMP;
    else
    if (MonthValue = 11) then
      NOV = TMP;
    else
    if (MonthValue = 12) then
      DCM = TMP;

    Total = Total + TMP;

  END

  suspend;

  LBL = 'Recurring Co/Location';
  FOR

    select
      extract(month from C.ENT_DATE),
      count(*)
    from COMPLAINTS C
    join RESPONSE R on R.ID = C.ID
    join APPROVE A on A.ID = R.ID
    where
       (A.RECURRING <> '0') and
       extract(year from C.ENT_DATE) = :YearValue
    Group by 1
    INTO
      :MonthValue,
      :TMP
  DO
  BEGIN

    if (MonthValue = 1) then
      JAN = TMP;
    else
    if (MonthValue = 2) then
      FEB = TMP;
    else
    if (MonthValue = 3) then
      MAR = TMP;
    else
    if (MonthValue = 4) then
      APR = TMP;
    else
    if (MonthValue = 5) then
      MAY = TMP;
    else
    if (MonthValue = 6) then
      JUN = TMP;
    else
    if (MonthValue = 7) then
      JUL = TMP;
    else
    if (MonthValue = 8) then
      AUG = TMP;
    else
    if (MonthValue = 9) then
      SEP = TMP;
    else
    if (MonthValue = 10) then
      OCT = TMP;
    else
    if (MonthValue = 11) then
      NOV = TMP;
    else
    if (MonthValue = 12) then
      DCM = TMP;

    Total = Total + TMP;

  END

  suspend;

  LBL = '% / Total';

  JAN = 0.0;
  FEB = 0.0;
  MAR = 0.0;
  APR = 0.0;
  MAY = 0.0;
  JUN = 0.0;
  JUL = 0.0;
  AUG = 0.0;
  SEP = 0.0;
  OCT = 0.0;
  NOV = 0.0;
  DCM = 0.0;
  FOR

    /* Start By Getting the total Number of Complaints for each month  */

    select
      extract(month from C.ENT_DATE),
      (count(*) * 100)
    from COMPLAINTS C
    where
       extract(year from C.ENT_DATE) = :YearValue
    Group by 1
    INTO
      :MonthValue,
      :TMP
  DO
  BEGIN

    TotalComplaint = TotalComplaint + TMP;

    if (MonthValue = 1) then
      JAN = TMP;
    else
    if (MonthValue = 2) then
      FEB = TMP;
    else
    if (MonthValue = 3) then
      MAR = TMP;
    else
    if (MonthValue = 4) then
      APR = TMP;
    else
    if (MonthValue = 5) then
      MAY = TMP;
    else
    if (MonthValue = 6) then
      JUN = TMP;
    else
    if (MonthValue = 7) then
      JUL = TMP;
    else
    if (MonthValue = 8) then
      AUG = TMP;
    else
    if (MonthValue = 9) then
      SEP = TMP;
    else
    if (MonthValue = 10) then
      OCT = TMP;
    else
    if (MonthValue = 11) then
      NOV = TMP;
    else
    if (MonthValue = 12) then
      DCM = TMP;

    select
      (count(*) * 100)
    from COMPLAINTS C
       join RESPONSE R on R.ID = C.ID
       join APPROVE A on A.ID = R.ID
    where
      ((A.RECURRING <> '0') or A.RECURRING_ROOT <> '0') and
      (extract(year from C.ENT_DATE) = :YearValue) and
      (extract(month from C.ENT_DATE) = :MonthValue)
    into :TMP;

    if (MonthValue = 1) then
      JAN = (TMP / JAN);
    else
    if (MonthValue = 2) then
      FEB = (TMP / FEB);
    else
    if (MonthValue = 3) then
      MAR = (TMP / MAR);
    else
    if (MonthValue = 4) then
      APR = (TMP / APR);
    else
    if (MonthValue = 5) then
      MAY = (TMP / MAY);
    else
    if (MonthValue = 6) then
      JUN = (TMP / JUN);
    else
    if (MonthValue = 7) then
      JUL = (TMP / JUL);
    else
    if (MonthValue = 8) then
      AUG = (TMP / AUG);
    else
    if (MonthValue = 9) then
      SEP = (TMP / SEP);
    else
    if (MonthValue = 10) then
      OCT = (TMP / OCT);
    else
    if (MonthValue = 11) then
      NOV = (TMP / NOV);
    else
    if (MonthValue = 12) then
      DCM = (TMP / DCM);

    Total = Total + TMP;

   END

   Total = coalesce( (Total / TotalComplaint), 0.0);

   suspend;

end
