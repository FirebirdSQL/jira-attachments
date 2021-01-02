create or alter procedure TASK_GET_INFO (
    ID_TASK ID_TYPE)
returns (
    START_DATE TDATETIME,
    FINISH_DATE TDATETIME,
    WORKSHOPS TENUM_CODES,
    FEATURES TNOTE,
    ID_SUPPLY_LIST TENUM_CODES,
    PLAN_DATE_START TDATETIME,
    PLAN_DATE_END TDATETIME,
    EXEC_DATE_START TDATETIME,
    EXEC_DATE_END TDATETIME,
    ID_SUBCONTRACTOR ID_TYPE,
    ID_PROJECT ID_TYPE,
    ID_WORKSHOP ID_TYPE,
    TRANSFER_STATUS TSTATUS,
    LIMIT_CARD_LIST TLIST_DOCS,
    OWNERSHIP TENUMERATION,
    SUPPLY_DOCS TLIST_DOCS,
    EXPEND_DOCS TLIST_DOCS,
    CERT_DOCS TLIST_DOCS,
    WARNINGS TLIST_IDS_SHORT,
    EXTRA_NOTE TNOTE)
AS
declare variable id_exec_revision ID_TYPE;
  declare variable id_resource_revision ID_TYPE;
  declare variable id_workhop_assignment ID_TYPE;
  declare variable id_subcontractor_assignment ID_TYPE;
  declare variable class_usage tenum_codes;
  declare variable nouse varchar(50);
  declare variable id_expend_order ID_TYPE;
  declare variable supply_list tlist_ids_short;
  declare variable expend_list tlist_ids_short;
  declare variable cert_list tlist_ids_short;
  declare variable t_dbkey tdbkey;
begin
  execute procedure TASK_GET_DOCS$INT(:id_task)
  returning_values  :supply_list, :supply_docs, :expend_list, :expend_docs, :cert_list, :cert_docs;

  select coalesce(T.ID_EXEC_REVISION, T.ID_CURRENT_REVISION, T.ID_NEXT_REVISION),
         T.ID_EXEC_REVISION, T.RDB$DB_KEY,
         T.ID_CONTRAGENT, SP.ID_INVENT_PRODUCTION
  from   TASK T
         left outer join STOCK_PRODUCTION SP on SP.ID_STOCK_PRODUCTION = T.ID_STOCK
  where  T.ID_TASK = :id_task
  into   :id_resource_revision,
         :id_exec_revision, :t_dbkey,
         :id_subcontractor, :id_workshop;
  workshops = :id_workshop;

  execute procedure TASK_GET_INFO$INT(:t_dbkey)
  returning_values  :plan_date_start, :plan_date_end, :exec_date_start,
                    :exec_date_end, :features, :class_usage, :ownership, :warnings;

  select substring(list(distinct TS.ID_LIMIT_CARD) from 1 for 60)
  from   TASK_SOURCE TS
  where  TS.ID_TASK = :id_task
  into   :limit_card_list;

  select list(TS.ID_SUPPLY, ',')
  from   TASK_SUPPLY TS
  where  TS.ID_TASK = :id_task
  into   :id_supply_list;

  start_date = :exec_date_start;
  finish_date = :exec_date_end;

  suspend;
end
