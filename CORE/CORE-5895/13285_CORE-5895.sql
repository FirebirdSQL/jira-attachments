create domain d1 as char(2) collate unicode_ci_ai;
commit work;

select f.rdb$field_name,
       f.rdb$field_type,
       f.rdb$field_length,
       f.rdb$character_set_id,
       f.rdb$collation_id
  from rdb$fields f
 where f.rdb$field_name = 'D1'; 
commit work;

alter domain d1 type char(3);
commit work;

select f.rdb$field_name,
       f.rdb$field_type,
       f.rdb$field_length,
       f.rdb$character_set_id,
       f.rdb$collation_id
  from rdb$fields f
 where f.rdb$field_name = 'D1';
commit work;
