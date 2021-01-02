/*

-- 1st small view
CREATE VIEW QSPECIALITY (
    ID_SPECIALITY,
    SPECIALITY_NAME,
    FACULTY_NAME)
AS
SELECT speciality.id, speciality.name, faculty.name
FROM faculty RIGHT JOIN speciality ON faculty.id = speciality.ref_faculty;


-- 2nd small view
CREATE VIEW QLEVEL_BY_PROGRAM (
    EDUCLEVEL_NAME,
    EDUCPROG_NAME,
    ID_LTOP)
AS
SELECT education_level.name, education_program.name, level_by_program.id
FROM education_program RIGHT JOIN (education_level RIGHT JOIN level_by_program ON education_level.id = level_by_program.ref_level) ON education_program.id = level_by_program.ref_program;


-- 3rd small view
CREATE VIEW QCONTRACT (
    ID_CONTRACT,
    REF_STUDENT,
    CONTRACT_NUMBER,
    CONTRACT_VALUE,
    CONTRACTTYPE_NAME)
AS
SELECT contract.id, contract.ref_student, contract.contract_number, contract.contract_value, contract_type.name
FROM contract_type RIGHT JOIN contract ON contract_type.id = contract.ref_contracttype;


-- T2 view with 100000 records
CREATE VIEW PAYMENT_BASIC (
    ID,
    REF_STUDENT,
    SUM_GRN,
    SUM_USD,
    PAYDATE,
    REGDATE,
    REF_REASON,
    REF_PAYMENTFORM,
    REF_BANK,
    PAYMENT_BASIS,
    PAYER,
    REF_PAYMENTYEAR)
AS
SELECT payment.id, payment.ref_student, payment.sum_grn, payment.sum_usd, payment.paydate, payment.regdate, payment.ref_reason, payment.ref_paymentform, payment.ref_bank, payment.payment_basis, payment.payer, payment.ref_paymentyear
FROM payment
WHERE ref_reason IN (-1, -2, 1);


-- NEWVIEW: intermediate view
CREATE VIEW COMMON_STUDENT_TABLE (
    ID_STUDENT,
    STUDSURNAME,
    STUDNAME,
    STUDMIDDLENAME,
    COURSE,
    FACULTY_NAME,
    SPECIALITY_NAME,
    EDUCFORM_NAME,
    EDUCLEVEL_NAME,
    EDUCPROG_NAME,
    LANGUAGE_NAME,
    COUNTRY_NAME,
    REGION_NAME,
    STATUS_NAME,
    ARRIVAL_CENTER,
    CONTRACT_NUMBER,
    CONTRACTTYPE_NAME,
    PAYMENTFORM_NAME,
    YEARS)
AS
SELECT student.id, student.studsurname, student.studname, student.studmiddlename, student.course, qspeciality.faculty_name, qspeciality.speciality_name, education_form.name, qlevel_by_program.educlevel_name, qlevel_by_program.educprog_name, languages.name, country.name, region.name, status.name, arrival_line.arrival_center, qcontract.contract_number, qcontract.contracttype_name, payment_form.name, student.years
FROM (((qcontract RIGHT JOIN (status RIGHT JOIN (region RIGHT JOIN (languages RIGHT JOIN (education_form RIGHT JOIN (country RIGHT JOIN (arrival_line RIGHT JOIN student ON arrival_line.id = student.ref_arrivalline) ON country.id = student.ref_country) ON education_form.id = student.ref_educform) ON languages.id = student.ref_language) ON region.id = student.ref_region) ON status.id = student.student_status) ON qcontract.ref_student = student.id) LEFT JOIN qlevel_by_program ON student.ref_ltop = qlevel_by_program.id_ltop) LEFT JOIN qspeciality ON student.ref_speciality = qspeciality.id_speciality) LEFT JOIN payment_form ON student.ref_usualpaymentform = payment_form.id;


-- NEWVIEW2: destination view
CREATE VIEW COMMON_STUDENT_SUMMARY_TABLE (
    ID_STUDENT,
    STUDSURNAME,
    STUDNAME,
    STUDMIDDLENAME,
    COURSE,
    FACULTY_NAME,
    SPECIALITY_NAME,
    EDUCFORM_NAME,
    EDUCLEVEL_NAME,
    EDUCPROG_NAME,
    LANGUAGE_NAME,
    COUNTRY_NAME,
    REGION_NAME,
    STATUS_NAME,
    ARRIVAL_CENTER,
    CONTRACT_NUMBER,
    CONTRACTTYPE_NAME,
    PAYMENTFORM_NAME,
    YEARS,
    SUM1,
    SUM2)
AS
SELECT common_student_table.id_student, common_student_table.studsurname, common_student_table.studname, common_student_table.studmiddlename, common_student_table.course, common_student_table.faculty_name, common_student_table.speciality_name, common_student_table.educform_name, common_student_table.educlevel_name, common_student_table.educprog_name, common_student_table.language_name, common_student_table.country_name, common_student_table.region_name, common_student_table.status_name, common_student_table.arrival_center, common_student_table.contract_number, common_student_table.contracttype_name, common_student_table.paymentform_name, common_student_table.years, SUM(payment_basic.sum_grn), SUM(payment_basic.sum_usd)
FROM payment_basic RIGHT JOIN common_student_table ON payment_basic.ref_student = common_student_table.id_student
GROUP BY common_student_table.id_student, common_student_table.studsurname, common_student_table.studname, common_student_table.studmiddlename, common_student_table.course, common_student_table.faculty_name, common_student_table.speciality_name, common_student_table.educform_name, common_student_table.educlevel_name, common_student_table.educprog_name, common_student_table.language_name, common_student_table.country_name, common_student_table.region_name, common_student_table.status_name, common_student_table.arrival_center, common_student_table.contract_number, common_student_table.contracttype_name, common_student_table.paymentform_name, common_student_table.years;
*/