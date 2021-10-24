-- Скрипт создания схемы модульных тестов
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 06.03.2017
-- update 09.03.2017
--*****************************************************************************
--
-- Выполнять от sys sysdba
declare
  tmpVar NUMBER;
begin
  select count(*)into tmpVar from dual where exists 
  (select * from All_Users where USERNAME='SP_TEST');
  if tmpVar!=0 then 
    execute immediate('
      DROP USER "SP_TEST" CASCADE
    ');
  end if;
end;
/

CREATE USER "SP_TEST" IDENTIFIED BY "SP_TEST"
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;

GRANT SELECT ON SYS.DBA_TAB_COLUMNS TO "SP_TEST";
GRANT SELECT ON SYS.DBA_OBJECTS TO "SP_TEST";
GRANT SELECT ANY TABLE TO "SP_TEST";


-- end of script
