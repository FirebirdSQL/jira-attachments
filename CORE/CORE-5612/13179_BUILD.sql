create or alter procedure BUILD (
    VIEW_COUNT integer)
AS
  declare I integer;
  declare LViewIndex integer;
  declare LSQL blob sub_type 1 segment size 80;

  declare CSelectStatement varchar(2000) = '
    (select rdb$description from rdb$database where rdb$relation_id = D.rdb$relation_id),
    (select rdb$relation_id from rdb$database where rdb$relation_id = D.rdb$relation_id),
    (select rdb$security_class from rdb$database where rdb$relation_id = D.rdb$relation_id),
    (select rdb$character_set_name from rdb$database where rdb$relation_id = D.rdb$relation_id),
    (select rdb$description from rdb$database where rdb$relation_id = D.rdb$relation_id)';
  declare CSelectCount integer = 5;

  declare CFieldCount integer = 250;
begin
  LViewIndex = 0;
  while (LViewIndex < VIEW_COUNT) do
  begin
    LSQL =
      'CREATE OR ALTER VIEW test_' || cast(LViewIndex as varchar(50)) || '(';

    I = 0;
    while (I < CFieldCount) do
    begin
      LSQL = LSQL || iif(I > 0, ',', '') || '
        f_' || cast(I as varchar(50));
      I = I + 1;
    end

    LSQL = LSQL || ')
      AS
      SELECT';

    I = 0;
    while (I < CFieldCount) do
    begin
      LSQL = LSQL || iif(I > 0, ',', '') || CSelectStatement;
      I = I + CSelectCount;
    end

    LSQL = LSQL || '
      FROM rdb$database D;';

    execute statement LSQL;

    LViewIndex = LViewIndex + 1;
  end
end
