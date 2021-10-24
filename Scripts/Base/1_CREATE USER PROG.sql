-- Скрипт создания суперпользователя
-- by Nikolai Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 24.06.2004
-- update 22.06.2012 04.01.2015 25.03.2015 15.06.2015 02.09.2015 24.12.2015
--        15.08.2016 07.09.2016
--*****************************************************************************
--
-- Выполнять от sys sysdba
@"Create PROG_ROLE.sql"

-- Для 12 ORACLE добавить параметр SQLNET.ALLOWED_LOGON_VERSION=8
-- в файл oracle/network/admin/sqlnet.ora
-- Выбрать параметры именно нужной базы!!! (лучше обновить во всех местах)

-- Настройка базы - убирание времени жизни пароля.
ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED; 

declare
  tmpVar NUMBER;
begin
  select count(*)into tmpVar from dual where exists 
  (select * from ALL_USERS where USERNAME='PROG');
  if tmpVar!=0 then 
    execute immediate('
      DROP USER "PROG" CASCADE
    ');
  end if;
end;
/

CREATE USER "PROG" IDENTIFIED BY p
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;

GRANT "PROG_ROLE" TO "PROG";
ALTER USER "PROG" DEFAULT ROLE ALL;

GRANT execute any procedure to "PROG";
GRANT EXECUTE ON  "SYS"."DBMS_LOCK" TO "PROG"; 
GRANT EXECUTE ON  "SYS"."DBMS_JOB" TO "PROG"; 
GRANT EXECUTE ON  "SYS"."DBMS_IJOB" TO "PROG"; 
GRANT EXECUTE ON  "SYS"."DBMS_SQL" TO "PROG";
GRANT EXECUTE ON "SYS"."DBMS_PIPE" TO "PROG";
GRANT EXECUTE ON "SYS"."DBMS_DEBUG" TO "PROG";
GRANT EXECUTE ON "SYS"."UTL_RECOMP" TO "PROG";
GRANT SELECT ON SYS.SESSION_ROLES TO "PROG";
GRANT SELECT ON SYS.ROLE_ROLE_PRIVS TO "PROG";
GRANT SELECT ANY DICTIONARY TO "PROG";
GRANT EXP_FULL_DATABASE TO "PROG";
GRANT IMP_FULL_DATABASE TO "PROG";

declare
  tmpVar NUMBER;
begin
  select count(*)into tmpVar from dual where exists 
  (select * from DBA_ROLES where ROLE='SP_USER_ROLE');
  if tmpVar=0 then 
    execute immediate('
      CREATE ROLE "SP_USER_ROLE" NOT IDENTIFIED
    ');
  end if;
end;
/

declare
  tmpVar NUMBER;
begin
  select count(*)into tmpVar from dual where exists 
  (select * from DBA_ROLES where ROLE='SP_ADMIN_ROLE');
  if tmpVar=0 then 
    execute immediate('
      CREATE ROLE "SP_ADMIN_ROLE" NOT IDENTIFIED
    ');
  end if;
end;
/

declare
  tmpVar NUMBER;
begin
  select count(*)into tmpVar from dual where exists 
  (select * from DBA_ROLES where ROLE='PD_USER_ROLE');
  if tmpVar=0 then 
    execute immediate('
      CREATE ROLE "PD_USER_ROLE" NOT IDENTIFIED
    ');
  end if;
end;
/

declare
  tmpVar NUMBER;
begin
  select count(*)into tmpVar from dual where exists 
  (select * from DBA_ROLES where ROLE='PD_ADMIN_ROLE');
  if tmpVar=0 then 
    execute immediate('
      CREATE ROLE "PD_ADMIN_ROLE" NOT IDENTIFIED
    ');
  end if;
end;
/

GRANT "SP_ADMIN_ROLE" TO "PROG";
GRANT "SP_USER_ROLE" TO "SP_ADMIN_ROLE" WITH ADMIN OPTION;
GRANT "PD_ADMIN_ROLE" TO "PROG";
GRANT "PD_USER_ROLE" TO "PD_ADMIN_ROLE" WITH ADMIN OPTION;
GRANT SELECT ON SYS.DBA_ROLE_PRIVS TO "SP_ADMIN_ROLE";
GRANT SELECT ON SYS.ROLE_ROLE_PRIVS TO "SP_ADMIN_ROLE";
GRANT SELECT ANY DICTIONARY TO "SP_ADMIN_ROLE";
GRANT EXP_FULL_DATABASE TO "SP_ADMIN_ROLE";
GRANT IMP_FULL_DATABASE TO "SP_ADMIN_ROLE";

