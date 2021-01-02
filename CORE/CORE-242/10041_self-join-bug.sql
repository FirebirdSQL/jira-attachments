/*
 Test-Database for a complete wrong "self"-join with alias.
 */

CREATE TABLE "XATest" (
    ID VARCHAR (10) CHARACTER SET NONE NOT NULL COLLATE NONE,
    NAME VARCHAR (32) CHARACTER SET NONE COLLATE NONE);

CREATE TABLE "XRefTest" (
    ID VARCHAR (10) CHARACTER SET NONE NOT NULL COLLATE NONE,
    REFTYPE VARCHAR (6) CHARACTER SET NONE NOT NULL COLLATE NONE,
    REFID VARCHAR (10) CHARACTER SET NONE NOT NULL COLLATE NONE);


ALTER TABLE "XRefTest" ADD CONSTRAINT "PK_XRefTest" PRIMARY KEY (ID, REFTYPE, REFID);
ALTER TABLE "XATest" ADD CONSTRAINT "PK_XATest" PRIMARY KEY (ID);

/*
  This query does not work:
 */

CREATE VIEW "XAVTest" (
    "MainID",
    "Company",
    "Type",
    "Partner")
AS
SELECT
  "XATest".ID, "XATest".NAME, "XRefTest".REFTYPE, "Partner".NAME
FROM
  ("XATest" LEFT JOIN "XRefTest" ON "XATest".ID = "XRefTest".ID)
            LEFT JOIN "XATest" "Partner" ON "XRefTest".REFID = "Partner".ID

;

insert into "XATest" (ID, NAME) values ('0000000001', 'Sun Microsystems');
insert into "XATest" (ID, NAME) values ('0000000002', 'IBM');
insert into "XATest" (ID, NAME) values ('0000000003', 'Microsoft');
insert into "XATest" (ID, NAME) values ('0000000004', 'Borland');
insert into "XRefTest" (ID, REFTYPE, REFID) values ('0000000001', 'SELF', '0000000001');
insert into "XRefTest" (ID, REFTYPE, REFID) values ('0000000002', 'SELF', '0000000002');
insert into "XRefTest" (ID, REFTYPE, REFID) values ('0000000003', 'SELF', '0000000003');
insert into "XRefTest" (ID, REFTYPE, REFID) values ('0000000004', 'SELF', '0000000004');
insert into "XRefTest" (ID, REFTYPE, REFID) values ('0000000001', 'PART', '0000000003');
insert into "XRefTest" (ID, REFTYPE, REFID) values ('0000000002', 'PART', '0000000003');
insert into "XRefTest" (ID, REFTYPE, REFID) values ('0000000004', 'NEED', '0000000002');
insert into "XRefTest" (ID, REFTYPE, REFID) values ('0000000001', 'HATE', '0000000003');
insert into "XRefTest" (ID, REFTYPE, REFID) values ('0000000004', 'HATE', '0000000001');

/*
 On Firebird:
 select * from "XAVTest"
          ID                            NAME  REFTYPE                      NAME1
  ------------------------------------------------------------------------------
  0000000001                Sun Microsystems     SELF           Sun Microsystems
  0000000001                Sun Microsystems     HATE           Sun Microsystems
  0000000002                             IBM     NEED                        IBM
  0000000002                             IBM     SELF                        IBM
  0000000003                       Microsoft     PART                  Microsoft
  0000000003                       Microsoft     SELF                  Microsoft
  0000000003                       Microsoft     PART                  Microsoft
  0000000003                       Microsoft     HATE                  Microsoft
  0000000004                         Borland     SELF                    Borland

 On Microsoft Access 2.0:
  
          ID                         Company     Type                    Partner
  ------------------------------------------------------------------------------
  0000000001                Sun Microsystems     SELF           Sun Microsystems
  0000000001                Sun Microsystems     PART                    Borland
  0000000001                Sun Microsystems     HATE                    Borland
  0000000002                             IBM     SELF                        IBM
  0000000002                             IBM     PART                    Borland
  0000000004                       Microsoft     SELF                  Microsoft
  0000000004                       Microsoft     NEED                        IBM
  0000000004                       Microsoft     HATE           Sun Microsystems
  0000000003                         Borland     SELF                    Borland
 */
