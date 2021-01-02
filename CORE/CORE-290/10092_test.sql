CREATE TABLE "Test"
(
  "Test_Field"    VARCHAR(30) NOT NULL,
CONSTRAINT "PK_Test" PRIMARY KEY ("Test_Field")
);

/* populate it with some values */
insert into"Test"("Test_Field") values ('4');
insert into"Test"("Test_Field") values ('41');
insert into"Test"("Test_Field") values ('411');

/* this one doesn't work as expected - it goes through index */
select "Test_Field" from "Test" where '411.1' starting with "Test_Field";

/* this one works well, but because of cast - rtrim can be used instead - uses plan(natural) */
select "Test_Field" from "Test" where '411.1' starting with CAST("Test_Field" As VARCHAR(30));

