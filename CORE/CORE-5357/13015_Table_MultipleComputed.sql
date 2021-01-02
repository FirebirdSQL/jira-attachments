
CREATE TABLE T1 (
  T1_ID            Integer NOT NULL,
  T1_T3_ID         Integer NOT NULL,
  T1_DATE          Date
);


CREATE TABLE T2 (
  T2_ID            Integer NOT NULL,
  T2_T3_ID         Integer NOT NULL,
  T2_T4_ID         Integer NOT NULL,
  T2_STATUS        Integer,
  T2_PREEMPT       Integer NOT NULL,
  T2_DATE          Date,
  T2_WEEK          Date
);

CREATE TABLE T3 (
  T3_ID            Integer NOT NULL
  ,T3_STATUS       Integer
  ,T3_ISINVOICED   COMPUTED BY (
    (select first 1 1
     from T2
     where
       T2_T4_id is not null
       and (
         T2_T3_id = T3_id
         or T2_preempt = T3_id
       )
     )
  )
  ,T3_FIRSTDATE    COMPUTED BY (
    (select min( T2_date+0)
     from T2
     where
       T3_STatus <> 10003
       and t2_T3_id = T3_id
       and (
         T2_Status <> 11003
         and exists(
           select 1
           from T1
           where
             T1.T1_T3_id = T3_id
             and T1.T1_date= T2_week
         )
       )
    )
  )
);


CREATE TABLE ADLINE (
  T3_ID                      Integer NOT NULL,
  T3_SLU_ID_LINESTATUS       Integer
);

ALTER TABLE ADLINE
  ADD T3_ISINVOICED              COMPUTED BY (
    (select first 1 1
     from adlinespot als
     where
       als.als_inb_id is not null
       and (
         als.als_adl_id = T3_id
         or als.als_adl_id_preempt = T3_id
       )
     )
  )
;

ALTER TABLE ADLINE
  ADD T3_FIRSTAIREDDATE          COMPUTED BY (
    (select min(T2_logdate+0)
     from adlinespot als
     where
       T3_slu_id_linestatus<>10003
       and als.als_adl_id=adl_id
       and (
         als.als_slu_id_spotstatus<>11003
         and exists(
           select 1
           from adlineflightdate T1
           where
             T1.T1_adl_id=adl_id
             and T1.T1_date=als.als_targetweek
         )
       )
    )
  )
;



