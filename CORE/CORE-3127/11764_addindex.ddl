drop index fix_bug1;
commit;
create unique index fix_bug1 on patients (soundex_name, office_id, deact_code, billto_id, patient_id);
commit;
exit;
