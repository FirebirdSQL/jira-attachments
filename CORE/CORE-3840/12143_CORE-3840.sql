SET NAMES UTF8;

CREATE DATABASE 'localhost:testdb'
USER 'SYSDBA' PASSWORD 'masterkey'
PAGE_SIZE 4096
DEFAULT CHARACTER SET UTF8 COLLATION UTF8;

CREATE TABLE test (
    id    INTEGER NOT NULL,
    terms  VARCHAR(20) NOT NULL COLLATE UNICODE_CI
);


INSERT INTO test (id, terms) VALUES (1, 'ааа');
INSERT INTO test (id, terms) VALUES (2, 'абб');
INSERT INTO test (id, terms) VALUES (3, 'асс');
INSERT INTO test (id, terms) VALUES (4, 'абс');
set term ^;
execute block as
declare i integer=10000;
begin
while (i>5) do
 begin
  INSERT INTO test (id, terms) VALUES (:i, 'www'||:i);
  i = i-1;
 end
end^
set term ;^

COMMIT WORK;

ALTER TABLE test ADD CONSTRAINT pktest PRIMARY KEY (id);
CREATE UNIQUE INDEX itest_term ON test (terms);
COMMIT;
set stats on;

select * from test t where  t.terms STARTING WITH 'а';
select * from test t where  t.terms STARTING WITH 'аб';
