CONNECT 'localhost:C:\BU\security_copy.fdb'
 USER 'SYSDBA' PASSWORD 'masterkey';
CREATE TABLE SYS_USERS (
  USER_NAME VARCHAR(128) CHARACTER SET UNICODE_FSS NOT NULL,
  SYS_USER_NAME VARCHAR(128) CHARACTER SET UNICODE_FSS,
  GROUP_NAME VARCHAR(128) CHARACTER SET UNICODE_FSS,
  UID INTEGER,
  GID INTEGER,
  PASSWD VARCHAR(64) CHARACTER SET OCTETS NOT NULL,
  PRIVILEGE INTEGER,
  COMMENT BLOB SUB_TYPE 1 SEGMENT SIZE 80,
  FIRST_NAME VARCHAR(32) CHARACTER SET UNICODE_FSS DEFAULT '',
  MIDDLE_NAME VARCHAR(32) CHARACTER SET UNICODE_FSS DEFAULT '',
  LAST_NAME VARCHAR(32) CHARACTER SET UNICODE_FSS DEFAULT '');
CREATE UNIQUE INDEX SYS_USER_NAME_INDEX ON SYS_USERS (USER_NAME);
insert into SYS_USERS(
  USER_NAME,
  SYS_USER_NAME,
  GROUP_NAME,
  UID,
  GID,
  PASSWD,
  PRIVILEGE,
  COMMENT,
  FIRST_NAME,
  MIDDLE_NAME,
  LAST_NAME)
select
  USER_NAME,
  SYS_USER_NAME,
  GROUP_NAME,
  UID,
  GID,
  PASSWD,
  PRIVILEGE,
  COMMENT,
  FIRST_NAME,
  MIDDLE_NAME,
  LAST_NAME
from USERS;
Commit;

drop table users; /* for FB15 */
drop view users; /* for FB20 */
Commit;

create view users (
  USER_NAME,
  SYS_USER_NAME,
  GROUP_NAME,
  UID,
  GID,
  PASSWD,
  PRIVILEGE,
  COMMENT,
  FIRST_NAME,
  MIDDLE_NAME,
  LAST_NAME,
  FULL_NAME)
as
select distinct
  USER_NAME,
  SYS_USER_NAME,
  GROUP_NAME,
  UID,
  GID,
  case USER
    when user_name then PASSWD
    when 'SYSDBA' then PASSWD
    when '' then PASSWD
    else null
  end,
  PRIVILEGE,
  COMMENT,
  FIRST_NAME,
  MIDDLE_NAME,
  LAST_NAME,
  FIRST_NAME || ' ' || MIDDLE_NAME || ' ' || LAST_NAME
from SYS_USERS;
GRANT SELECT,UPDATE ON USERS TO PUBLIC;
Commit;

CREATE EXCEPTION USER_INFO_EXCEPTION 'Cant update user info';
CREATE EXCEPTION USER_PASSWORD_EXCEPTION 'Only own passwords allowed';
SET TERM ^ ;
CREATE TRIGGER TBI_USERS FOR USERS
ACTIVE BEFORE INSERT POSITION 0
as
begin
  insert into SYS_USERS(
    USER_NAME,
    SYS_USER_NAME,
    GROUP_NAME,
    UID,
    GID,
    PASSWD,
    PRIVILEGE,
    COMMENT,
    FIRST_NAME,
    MIDDLE_NAME,
    LAST_NAME)
  values (
    new.USER_NAME,
    new.SYS_USER_NAME,
    new.GROUP_NAME,
    new.UID,
    new.GID,
    new.PASSWD,
    new.PRIVILEGE,
    new.COMMENT,
    new.FIRST_NAME,
    new.MIDDLE_NAME,
    new.LAST_NAME);
end ^
CREATE TRIGGER TBU_USERS FOR USERS
ACTIVE BEFORE UPDATE POSITION 0
as
begin
  if (user<>'SYSDBA') then
  begin
    if ((new.user_name<>user) or
        (old.user_name<>user))
    then
      exception user_password_exception;
    if (
      (new.first_name<>old.first_name) or
      (new.middle_name<>old.middle_name) or
      (new.last_name<>old.last_name))
    then
      exception user_info_exception;
  end
  update SYS_USERS set
    USER_NAME = new.USER_NAME,
    SYS_USER_NAME = new.SYS_USER_NAME,
    GROUP_NAME = new.GROUP_NAME,
    UID = new.UID,
    GID = new.GID,
    PASSWD = new.PASSWD,
    PRIVILEGE = new.PRIVILEGE,
    COMMENT = new.COMMENT,
    FIRST_NAME = new.FIRST_NAME,
    MIDDLE_NAME = new.MIDDLE_NAME,
    LAST_NAME = new.LAST_NAME
  where
    USER_NAME = old.USER_NAME;
end ^
CREATE TRIGGER TBD_USERS FOR USERS
ACTIVE BEFORE DELETE POSITION 0
as
begin
  delete from SYS_USERS
  where
    USER_NAME = old.USER_NAME;
end ^
SET TERM ; ^
GRANT DELETE ON SYS_USERS TO TRIGGER TBD_USERS;
GRANT INSERT ON SYS_USERS TO TRIGGER TBI_USERS;
GRANT UPDATE ON SYS_USERS TO TRIGGER TBU_USERS;
