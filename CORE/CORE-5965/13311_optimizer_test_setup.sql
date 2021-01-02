/**
 * creating the table and indices
 */

create generator gen_opt_test_id;
create generator gen_order_no; 

create table opt_test (
    id         bigint not null,
    sysid      integer not null,
    clid       integer not null,
    cust_type  integer not null,
    cust_id    integer not null,
    order_no   bigint not null
);

alter table opt_test add constraint pk_opt_test primary key (id);

set term ^ ;

create or alter trigger opt_test_bi for opt_test
active before insert position 0
as
begin
  if (new.id is null) then
    new.id = gen_id(gen_opt_test_id,1);
end
^

set term ; ^

commit;
/**
 * gererating data (approx. )
 * this could take a while
 * time for coffee
 */

set term ^ ;

execute block
as
declare max_rows integer = 150000;
declare sysid_dist integer = 1;
declare clid_dist integer = 50;
declare cust_type_dist integer = 2;
declare cust_id_dist integer = 500;
declare row_pos integer = 1;
declare sysid integer;
declare clid integer;
declare cust_type integer;
declare cust_id integer;
begin
    while (:row_pos <= :max_rows) do begin
        sysid = ceil(rand()*:sysid_dist);
        clid = ceil(rand()*:clid_dist);
        cust_type = ceil(rand()*:cust_type_dist);
        cust_id = ceil(rand()*:cust_id_dist);
    
        insert into opt_test (sysid, clid, cust_type, cust_id, order_no) values (:sysid, :clid, :cust_type, :cust_id, gen_id(gen_order_no, 1));
        row_pos = :row_pos + 1;
    end
end

^

set term ; ^
commit;

/**
 * creating indices
 */

create index opt_test_idx1 on opt_test (clid, cust_type, cust_id);
create index opt_test_idx2 on opt_test (sysid, clid);
create descending index opt_test_idx3 on opt_test (sysid, clid, order_no);
    
set statistics index opt_test_idx1;
set statistics index opt_test_idx2;
set statistics index opt_test_idx3;
set statistics index pk_opt_test;