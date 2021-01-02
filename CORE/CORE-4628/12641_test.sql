EXECUTE BLOCK
RETURNS (
    rn INTEGER,
    dFetch INTEGER,
    dSelect INTEGER,
    dUpdate INTEGER)
AS
DECLARE VARIABLE dbkey CHAR(8);
DECLARE VARIABLE ref TIMESTAMP;
DECLARE VARIABLE nw TIMESTAMP;
BEGIN
  ref = 'NOW';
  FOR SELECT t.RDB$DB_KEY
      FROM rpt_tmp_1191700_94 t
      ORDER BY fk_tetel__fkisz_id NULLS LAST,
          fk_tetel__szla NULLS LAST,
          fk_tetel__bizonylat NULLS LAST,
          sum_level,
          fk_tetel__fkisz_id,
          fk_tetel__piktato  
      INTO dbkey
  DO BEGIN
    dFetch = DATEDIFF(MILLISECOND, ref, cast('NOW' as timestamp));
    ref = 'NOW';
    rn = (
        SELECT t.rowno
        FROM rpt_tmp_1191700_94 t
        WHERE t.rowno > -1
        ORDER BY t.rowno DESC ROWS 1);
    dSelect = DATEDIFF(MILLISECOND, ref, cast('NOW' as timestamp));
    rn = COALESCE(rn, 0) + 1;
    ref = 'NOW';
    UPDATE rpt_tmp_1191700_94 t SET
        t.rowno = :rn
    WHERE t.RDB$DB_KEY = :dbkey;
    dUpdate = DATEDIFF(MILLISECOND, ref, cast('NOW' as timestamp));
    SUSPEND;
    ref = 'NOW';
  END
END
