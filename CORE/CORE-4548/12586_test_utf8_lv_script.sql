﻿SET NAMES UTF8;

/*SET CLIENTLIB 'C:\install\ibexpert\gds32.dll';*/

/*
CREATE DATABASE 'localhost:C:/test_lv2_utf8.fdb'
USER 'SYSDBA' PASSWORD 'masterkey'
PAGE_SIZE 4096
DEFAULT CHARACTER SET UTF8;
*/


CREATE TABLE TEST_LV_SORT (
    TEXT        VARCHAR(30) COLLATE UTF8,
    SORTIROVKA  VARCHAR(15)
);

CREATE COLLATION test_lv_utf8
for UTF8 
from UNICODE 
case sensitive
ACCENT SENSITIVE 
'LOCALE=lv_LV;ICU-VERSION=4.8';   
   
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Ab', '1');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Az', '2');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Āb', '3');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Āz', '4');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Cb', '5');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Cz', '6');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Čb', '7');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Čz', '8');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Eb', '9');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Ez', '10');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Ēb', '11');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Ēz', '12');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Gb', '13');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Gz', '14');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Ģb', '15');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Ģz', '16');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Ib', '17');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Iz', '18');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Īb', '19');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Īz', '20');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Kb', '21');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Kz', '22');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Ķb', '23');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Ķz', '24');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Lb', '25');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Lz', '26');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Ļb', '27');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Ļz', '28');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Nb', '29');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Nz', '30');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Ņb', '31');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Ņz', '32');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Sb', '33');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Sz', '34');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Šb', '35');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Šz', '36');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Ub', '37');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Uz', '38');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Ūb', '39');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Ūz', '40');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Zb', '41');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Zz', '42');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Žb', '43');
INSERT INTO TEST_LV_SORT (TEXT, SORTIROVKA) VALUES ('Žz', '44');

COMMIT WORK;


/*
select *
from TEST_LV_SORT tls
order by tls.text COLLATE test_lv_utf8;

COMMIT WORK;
*/