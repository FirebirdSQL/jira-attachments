SET SQL DIALECT 3; 

CONNECT ".\PxRetail.fdb" user 'SYSDBA' password 'masterkey';

/*
When doing several "SELECT FIRST :rec_num SKIP :skip_count ..." 
from stored procedure with "FOR EXECUTE STATEMENT ... DO SUSPEND;" 
fbserver will be inaccessible if

 - after each select we doing end of transaction (COMMIT or ROLLBACK)
 - and in third (or greater) select values REC_NUM and SKIP_COUNT 
   parameters in sum greater than records count in table.
*/

/*************************  Prepare for demo  *******************************/

CREATE TABLE TABLE1 (FIELD1 INTEGER);

INSERT INTO TABLE1(FIELD1) VALUES (1);
INSERT INTO TABLE1(FIELD1) VALUES (2);
INSERT INTO TABLE1(FIELD1) VALUES (3);
INSERT INTO TABLE1(FIELD1) VALUES (4);
INSERT INTO TABLE1(FIELD1) VALUES (5);

SET TERM ^ ;

CREATE PROCEDURE SEL1_TABLE1 RETURNS (FIELD1 INTEGER)
AS
BEGIN
  FOR SELECT FIELD1 FROM TABLE1 INTO :FIELD1
    DO SUSPEND;
END
^

CREATE PROCEDURE SEL2_TABLE1 RETURNS (FIELD1 INTEGER)
AS
BEGIN
  FOR EXECUTE STATEMENT 'SELECT FIELD1 FROM TABLE1' INTO :FIELD1
    DO SUSPEND;
END
^

SET TERM ; ^

COMMIT; 

/**********************     All work correct     ****************************/

SELECT FIRST 2 SKIP 0 * FROM TABLE1;
COMMIT;

SELECT FIRST 2 SKIP 2 * FROM TABLE1;
COMMIT;

SELECT FIRST 2 SKIP 4 * FROM TABLE1;
COMMIT;

/**********************     All work correct     ****************************/

SELECT FIRST 2 SKIP 0 * FROM SEL1_TABLE1;
COMMIT;

SELECT FIRST 2 SKIP 2 * FROM SEL1_TABLE1;
COMMIT;

SELECT FIRST 2 SKIP 4 * FROM SEL1_TABLE1;
COMMIT;


/**********************     All work correct     ****************************/

SELECT FIRST 2 SKIP 0 * FROM SEL2_TABLE1;
-- without COMMIT;

SELECT FIRST 2 SKIP 2 * FROM SEL2_TABLE1;
-- without COMMIT;

SELECT FIRST 2 SKIP 4 * FROM SEL2_TABLE1;
COMMIT;

/**********************     All work correct     ****************************/

SELECT FIRST 2 SKIP 0 * FROM SEL2_TABLE1;
COMMIT;

SELECT FIRST 2 SKIP 2 * FROM SEL2_TABLE1;
COMMIT;

-- 1 + 4 = 5 <= records in table
SELECT FIRST 1 SKIP 4 * FROM SEL2_TABLE1; 
COMMIT;

/***************    ERROR! Server will be inaccessible    ******************/

SELECT FIRST 2 SKIP 0 * FROM SEL2_TABLE1;
-- with end transaction;
COMMIT;

SELECT FIRST 2 SKIP 2 * FROM SEL2_TABLE1;
-- with end transaction;
COMMIT;

-- third (or greater) select 
-- 2 + 4 = 6 > records in table
SELECT FIRST 2 SKIP 4 * FROM SEL2_TABLE1;
COMMIT;


QUIT;
