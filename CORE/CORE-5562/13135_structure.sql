/******************************************************************************/
/****         Generated by IBExpert 2017.4.24.1 7-6-2017 22:28:07          ****/
/******************************************************************************/

SET SQL DIALECT 3;

SET NAMES NONE;

SET CLIENTLIB 'C:\Program Files (x86)\HK-Software\IBExpert\fb3\fbclient.dll';

CREATE DATABASE 'localhost/30555:D:\0\Test.fdb'
USER 'SYSDBA' PASSWORD 'masterkey'
PAGE_SIZE 8192
DEFAULT CHARACTER SET NONE COLLATION NONE;



/******************************************************************************/
/****                     User defined functions (UDF)                     ****/
/******************************************************************************/

DECLARE EXTERNAL FUNCTION VERSION_START2

    RETURNS BIGINT BY VALUE
    ENTRY_POINT 'StartVersion2' MODULE_NAME 'Fast';

