UPDATE rdb$database SET rdb$character_set_name='ISO8859_1';
COMMIT;

CREATE TABLE WORD
(
    ID BIGINT NOT NULL ,
    GRADE SMALLINT DEFAULT 0,
    PRIMARY KEY (ID)
);

CREATE INDEX  IDX_GRADE_WORD ON WORD (GRADE);

CREATE GENERATOR gen_WORD_ID;

SET TERM ^ ;
CREATE TRIGGER trg_WORD_ID FOR WORD
ACTIVE BEFORE INSERT POSITION 0 AS
BEGIN IF (NEW.ID IS NULL) THEN NEW.ID = GEN_ID(gen_WORD_ID, 1);
END^
SET TERM ; ^
COMMIT;


select A1.ID from(select A2.ID from(select A3.ID from(select A4.ID from(select A5.ID from(select A6.ID from(select A7.ID from(select A8.ID from (select A9.ID from(select A10.ID from(select WORD.ID from WORD where  WORD.GRADE = 1) as A10 
union select WORD.ID from WORD where  WORD.GRADE = 2) as A9 
union select WORD.ID from WORD where  WORD.GRADE = 3) as A8
union select WORD.ID from WORD where  WORD.GRADE = 4) as A7
union select WORD.ID from WORD where  WORD.GRADE = 5) as A6
union select WORD.ID from WORD where  WORD.GRADE = 6) as A5
union select WORD.ID from WORD where  WORD.GRADE = 7) as A4
union select WORD.ID from WORD where  WORD.GRADE = 8) as A3
union select WORD.ID from WORD where  WORD.GRADE = 9) as A2
union select WORD.ID from WORD where  WORD.GRADE = 10) as A1
union select WORD.ID from WORD where  WORD.GRADE = 11