SET NAMES NONE;

CONNECT '...test.fdb' USER 'SYSDBA' PASSWORD 'masterkey';

DELETE FROM T1;
COMMIT;

EXECUTE PROCEDURE T1_FILL(50000);
COMMIT;

UPDATE T1 SET F2 = 0;
COMMIT;

DELETE FROM T1;
COMMIT;

EXECUTE PROCEDURE T1_FILL(50000);
COMMIT;


UPDATE T1 SET F2 = 0;
COMMIT;

DELETE FROM T1;
COMMIT;

EXECUTE PROCEDURE T1_FILL(50000);
COMMIT;


UPDATE T1 SET F2 = 0;
COMMIT;

DELETE FROM T1;
COMMIT;

EXECUTE PROCEDURE T1_FILL(50000);
COMMIT;


UPDATE T1 SET F2 = 0;
COMMIT;

DELETE FROM T1;
COMMIT;

EXECUTE PROCEDURE T1_FILL(50000);
COMMIT;


UPDATE T1 SET F2 = 0;
COMMIT;

DELETE FROM T1;
COMMIT;

EXECUTE PROCEDURE T1_FILL(50000);
COMMIT;


UPDATE T1 SET F2 = 0;
COMMIT;

DELETE FROM T1;
COMMIT;

EXECUTE PROCEDURE T1_FILL(50000);
COMMIT;


UPDATE T1 SET F2 = 0;
COMMIT;

DELETE FROM T1;
COMMIT;

EXECUTE PROCEDURE T1_FILL(50000);
COMMIT;


UPDATE T1 SET F2 = 0;
COMMIT;

DELETE FROM T1;
COMMIT;

EXECUTE PROCEDURE T1_FILL(50000);
COMMIT;


UPDATE T1 SET F2 = 0;
COMMIT;

DELETE FROM T1;
COMMIT;

EXECUTE PROCEDURE T1_FILL(50000);
COMMIT;


UPDATE T1 SET F2 = 0;
COMMIT;

DELETE FROM T1;
COMMIT;

EXECUTE PROCEDURE T1_FILL(50000);
COMMIT;


EXIT;

