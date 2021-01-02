set term ^;
create or alter procedure dsql_field_err1 as
  declare i int;
begin
  select "" from rdb$database into i; -- Column unknown.
end 
^

create or alter procedure dsql_field_err2 as
  declare i int;
begin
  select foo from rdb$database into i;
end
^

create or alter procedure dsql_count_mismatch as
  declare i int;
  declare k int;
begin
  select 1 from rdb$database into i, k; -- Count of column list and variable list do not match.
end 
^

create or alter procedure dsql_invalid_expr  as
  declare i int;
  declare j varchar(64);
  declare k int;
begin
  select RDB$RELATION_ID,RDB$CHARACTER_SET_NAME, count(*) 
  from rdb$database 
  group by 1
  into i, j, k;
end 
^

create or alter procedure dsql_agg_where_err as
  declare i int;
begin
  select count(*) 
  from rdb$database 
  group by count(*) -- Cannot use an aggregate function in a GROUP BY clause.
  into i;
end 
^

create or alter procedure dsql_agg_nested_err as
  declare i int;
begin
  select count( max(1) )  -- Nested aggregate functions are not allowed.
  from rdb$database 
  into i;
end 
^

create or alter procedure dsql_column_pos_err as
  declare i int;
begin
  select 1
  from rdb$database 
  order by 1, 2     -- Invalid column position used in the @1 clause
  into i;
end 
^
set term ;^ 

