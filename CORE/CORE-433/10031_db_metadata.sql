/*
CREATE TABLE annual_payment (
  id int not null primary key,
  ref_student int default 0,
  study_year int default 0,
  sum_grn decimal(9,2) default 0.00
);


CREATE TABLE arrival_line (
  id int not null primary key,
  arrival_center varchar(45) default null,
  ref_city int default 0
);

CREATE TABLE bank (
  id int not null primary key,
  name varchar(45) default null,
  mfo varchar(45) default null,
  branch varchar(45) default null,
  ref_city int default 0,
  ref_region int default 0
);


CREATE TABLE city (
  id int not null primary key,
  name varchar(45) default null
);



CREATE TABLE contract (
  id int not null primary key,
  ref_student int not null,
  ref_contracttype int default 0,
  date_of_transaction date default null,
  contract_value decimal(9,2) default null,
  contract_number varchar(45) default null,
  ref_juridcomp int default 0
);



CREATE TABLE contract_type (
  id int not null primary key,
  name varchar(45) default null
);



CREATE TABLE country (
  id int not null primary key,
  name varchar(45) default null
);



CREATE TABLE rate (
  month_number int not null primary key,
  course_value decimal(9,2) default 0.00
);



CREATE TABLE dedact_order_project (
  id int not null primary key,
  order_number varchar(45) default null,
  order_date date default null,
  note varchar(100) default null,
  state int default 0
);



CREATE TABLE education_form (
  id int not null primary key,
  name varchar(45) default null
);



CREATE TABLE education_level (
  id int not null primary key,
  name varchar(45) default null
);



CREATE TABLE education_program (
  id int not null primary key,
  name varchar(45) default null
);



CREATE TABLE faculty (
  id int not null primary key,
  name varchar(45) default null
);



CREATE TABLE financial_item (
  id int not null primary key,
  name varchar(45) default null,
  ref_faculty int default 0
);



CREATE TABLE info (
  id int not null primary key,
  info_key varchar(45) default null,
  infO_value varchar(45) default null
);



CREATE TABLE juridical_company (
  id int not null primary key,
  name varchar(45) default null,
  ref_country int default null
);



CREATE TABLE languages (
  id int not null primary key,
  name varchar(45) default null
);



CREATE TABLE level_by_program (
  id int not null primary key,
  ref_level int default 0,
  ref_program int default 0
);



--DROP TABLE IF EXISTS `hnustudent`.`order_project`;
CREATE TABLE order_project (
  id int not null primary key,
  order_number varchar(45) default null,
  order_date date default null,
  state int default 0
);



--DROP TABLE IF EXISTS hnustudent.payment;
CREATE TABLE payment (
  id int not null primary key,
  ref_student int default null,
  sum_grn decimal(9,2) default null,
  sum_usd decimal(9,2) default null,
  paydate date default null,
  regdate date default null,
  ref_reason int default 0,
  ref_paymentform int default 0,
  ref_bank int default 0,
  payment_basis varchar(45) default null,
  payer varchar(45) default null,
  ref_paymentyear int default 0
);



CREATE TABLE payment_form (
  id int not null primary key,
  name varchar(45) default null
);



CREATE TABLE payment_type (
  id int not null primary key,
  name varchar(45) default null
);



CREATE TABLE payment_year (
  id int not null primary key,
  name varchar(45) default null,
  current_year int default 0
);



CREATE TABLE reason (
  id int not null primary key,
  name varchar(45) default null,
  ref_paymenttype int default 0
);



CREATE TABLE region (
  id int not null primary key,
  name varchar(45) default null,
  ref_country int default 0
);



CREATE TABLE speciality (
  id int not null primary key,
  name varchar(45) default null,
  ref_faculty int default 0
);



CREATE TABLE status (
  id int not null primary key,
  name varchar(45) default null
);



CREATE TABLE student (
  id int not null primary key,
  studsurname varchar(45) not null,
  studname varchar(45) default null,
  studmiddlename varchar(45) default null,
  ref_speciality int default 0,
  ref_finitem int default 0,
  ref_orderproject int default 0,
  ref_dedactorderproject int default 0,
  ref_ltop int default 0,
  ref_educform int default 0,
  ref_country int default 0,
  ref_region int default 0,
  ref_arrivalline int default 0,
  payer varchar(100) default null,
  datein date default null,
  plandateout date default null,
  course int default 0,
  ref_language int default 0,
  student_status int default 0,
  years decimal(2,1) default 0.0,
  comments varchar(100) default null,
  ref_usualpaymentform int default 0
);
*/
