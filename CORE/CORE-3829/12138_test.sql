with totalk (kk1, variant, tt, qq, mm, ff, f1, f2, f3, f4, f5) as
(select ll.kk1, ll.variant,
sum (iif(ll.selector_y_n='Y', 1, 0)),
count(*),      -- <<<< problem here
-- count(1),   --  <<<< this doesn't work either
-- sum(1),     --  <<<<< this neither
-- sum(iif(ll.variant=1,1,1)), -- <<<< workaround
sum (iif(ll.selector_m_f='M' and ll.selector_y_n='Y', 1, 0)),
sum (iif(ll.selector_m_f='F' and ll.selector_y_n='Y', 1, 0)),
sum(iif(ll.selector_1_5='1' and ll.selector_y_n='Y', 1, 0)),
sum(iif(ll.selector_1_5='2' and ll.selector_y_n='Y', 1, 0)),
sum(iif(ll.selector_1_5='3' and ll.selector_y_n='Y', 1, 0)),
sum(iif(ll.selector_1_5='4' and ll.selector_y_n='Y', 1, 0)),
sum(iif(ll.selector_1_5='5' and ll.selector_y_n='Y', 1, 0))
from testcte ll
group by 1, 2 )
select
ff.kk1, ff.descrkk,
  sum(t1.tt) "TT 1",
  sum(t2.tt) "TT 2",
  sum(t1.qq) "QQ 1",
  sum(t2.qq) "QQ 2",
  sum(t1.mm) "MM 1",
  sum(t2.mm) "MM 2",
  sum(t1.ff) "FF 1",
  sum(t2.ff) "FF 2",
  sum(t1.f1) "G1 1",
  sum(t2.f1) "G1 2",
  sum(t1.f2) "G2 1",
  sum(t2.f2) "G2 2",
  sum(t1.f3) "G3 1",
  sum(t2.f3) "G3 2",
  sum(t1.f4) "G4 1",
  sum(t2.f4) "G4 2",
  sum(t1.f5) "G5 1",
  sum(t2.f5) "G5 2"
from testmain ff left outer join
    totalk t1 on t1.kk1=ff.kk1 and t1.variant = 1
  left outer join
    totalk t2 on t2.kk1=ff.kk1 and t2.variant = 2
group by 1, 2
;
