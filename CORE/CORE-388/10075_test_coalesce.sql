SET NAMES WIN1252;

SET SQL DIALECT 3;

CREATE DATABASE ':c:\temp\testdb.fdb'
 USER 'SYSDBA' PASSWORD 'masterkey'
PAGE_SIZE 4096  DEFAULT CHARACTER SET WIN1252;

RECREATE TABLE TRANS_TABLE
(
                           TCODE             SMALLINT         NOT NULL,
                            CODE             SMALLINT         NOT NULL,
                            NAME              VARCHAR(    10),
 CONSTRAINT TRANS_TABLE_PRIMARYKEY PRIMARY KEY (TCODE, CODE)
);

RECREATE TABLE CLASS1
(
                      CLASS_NAME              VARCHAR(    10) NOT NULL,
                       CLASS_NUM             SMALLINT         NOT NULL,
                      TEACHER_ID              INTEGER,
 CONSTRAINT PK_CLASS1 PRIMARY KEY (CLASS_NAME, CLASS_NUM)
);

RECREATE TABLE CLASS2
(
                      CLASS_NAME              VARCHAR(    10) NOT NULL,
                       CLASS_NUM             SMALLINT         NOT NULL,
                      TEACHER_ID              INTEGER,
 CONSTRAINT PK_CLASS2 PRIMARY KEY (CLASS_NAME, CLASS_NUM)
);

SET TERM ^^ ;
CREATE TRIGGER CLASS1 FOR CLASS1 ACTIVE BEFORE INSERT POSITION 0 AS
/*
  Trigger:

  Author   : Opher Shachar
  Date     : 2003-10-29
  Purpose  : Convert from class code to name
*/
  declare variable name varchar(10);
begin
  select name from TRANS_TABLE c where c.tcode=2 and c.code=new.CLASS_NAME
  into :name;
  new.CLASS_NAME = case when :name is null then new.CLASS_NAME else :name end;
/*  new.CLASS_NAME = coalesce(:name, new.CLASS_NAME);*/
end
^^
CREATE TRIGGER CLASS2 FOR CLASS2 ACTIVE BEFORE INSERT POSITION 0 AS
/*
  Trigger:

  Author   : Opher Shachar
  Date     : 2003-10-29
  Purpose  : Convert from class code to name
*/
  declare variable name varchar(10);
begin
  select name from TRANS_TABLE c where c.tcode=2 and c.code=new.CLASS_NAME
  into :name;
/*  new.CLASS_NAME = case when :name is null then new.CLASS_NAME else :name end;*/
  new.CLASS_NAME = coalesce(:name, new.CLASS_NAME);
end
^^
SET TERM ; ^^
COMMIT;

INSERT INTO TRANS_TABLE(TCODE, CODE, NAME) VALUES (2, 1, 'à');
COMMIT;

/* This executes OK */
INSERT INTO CLASS1(CLASS_NAME, CLASS_NUM, TEACHER_ID) VALUES (1, 1, NULL);
COMMIT;

/* !!! This FAILS !!! */
INSERT INTO CLASS2(CLASS_NAME, CLASS_NUM, TEACHER_ID) VALUES (1, 1, NULL);
COMMIT;
