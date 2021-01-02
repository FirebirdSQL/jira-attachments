
SET SQL DIALECT 3; 

/* CREATE DATABASE '127.0.0.1/3051:D:\user\AMS\test.fdb' PAGE_SIZE 16384 DEFAULT CHARACTER SET ISO8859_1; */


/*  External Function declarations */
DECLARE EXTERNAL FUNCTION F_TEST_INSIDE_PKG

RETURNS  BY VALUE 
ENTRY_POINT '' MODULE_NAME '';

DECLARE EXTERNAL FUNCTION F_TEST_OUTSIDE_PKG

RETURNS  BY VALUE 
ENTRY_POINT '' MODULE_NAME '';


SET AUTODDL OFF;
SET TERM ^ ;

/* Package headers */

/* Package header: PKG_TEST, Owner: BECKMANN */
CREATE PACKAGE PKG_TEST AS
begin
  function F_TEST_INSIDE_PKG
  returns smallint;
end^

SET TERM ; ^
COMMIT WORK;
SET AUTODDL ON;
SET AUTODDL OFF;
SET TERM ^ ;

/* Package bodies */

/* Package body: PKG_TEST, Owner: BECKMANN */
CREATE PACKAGE BODY PKG_TEST AS
begin
  function F_TEST_INSIDE_PKG
  returns smallint
  as
  begin
    return 1;
  end
end^

SET TERM ; ^
COMMIT WORK;
SET AUTODDL ON;
