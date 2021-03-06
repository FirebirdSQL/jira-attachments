/******************************************************************************/
/***         Generated by IBExpert 2019.4.14.1 04.09.2019 21:36:59          ***/
/******************************************************************************/

SET NAMES WIN1251;


CREATE DATABASE 'LOCALHOST:TEST.FDB'
USER 'SYSDBA' PASSWORD 'masterkey'
PAGE_SIZE 16384
DEFAULT CHARACTER SET WIN1251 COLLATION WIN1251;



/******************************************************************************/
/***                                 Tables                                 ***/
/******************************************************************************/



CREATE TABLE TMP_LABELBARCODE (
    ID       INTEGER NOT NULL,
    BARCODE  CHAR(20) NOT NULL,
    IDLABEL  INTEGER NOT NULL
);

INSERT INTO TMP_LABELBARCODE (ID, BARCODE, IDLABEL) VALUES (222054, '2000000017631', 288366);
REINSERT (224079, '10,74607139270968', 3529);
REINSERT (224423, '4627136039368', 278164);
REINSERT (229834, '*�����4660013110187', 302343);
REINSERT (229835, '*4630017110667', 302348);
REINSERT (229927, '*4603322247885', 65667);
REINSERT (231656, '9785783323805', 305635);
REINSERT (231657, '*������4607057560172', 304537);
REINSERT (231888, '*��4603322115283', 73578);
REINSERT (231889, '*����4603322115498', 73503);

COMMIT WORK;



/******************************************************************************/
/***                              Primary keys                              ***/
/******************************************************************************/

ALTER TABLE TMP_LABELBARCODE ADD PRIMARY KEY (ID);


/******************************************************************************/
/***                                Indices                                 ***/
/******************************************************************************/

CREATE INDEX TMLB_BARCODE ON TMP_LABELBARCODE (BARCODE);
CREATE INDEX TMLB_IDLABEL ON TMP_LABELBARCODE (IDLABEL);
CREATE UNIQUE INDEX TMP_LABELBARCODE_IDX1 ON TMP_LABELBARCODE (BARCODE, IDLABEL);