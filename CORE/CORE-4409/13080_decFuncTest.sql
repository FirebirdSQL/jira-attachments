set echo on;

select a, normalize_decfloat(a) from q2;
select b, normalize_decfloat(b) from q2;
select a, b, compare_decfloat(a,b) from q2;
select a, b, totalorder(a,b) from q2;
select a, quantize(a, '999.999') from q2;
select a, quantize(a, '999.99') from q2;
select a, b, quantize(a, b) from q2;

select a, normalize_decfloat(a) from d2;
select b, normalize_decfloat(b) from d2;
select a, b, compare_decfloat(a,b) from d2;
select a, b, totalorder(a,b) from d2;
select a, quantize(a, '999.999') from d2;
select a, quantize(a, '999.99') from d2; 
select a, b, quantize(a, b) from d2;
