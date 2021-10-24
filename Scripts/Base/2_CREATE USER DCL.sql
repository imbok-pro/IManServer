-- Скрипт создания схемы экспорта-импорта
-- by Nikolai Krasilnikov
-- create 18.12.2012
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 
--*****************************************************************************
--
-- Выполнять от sys sysdba
declare
  tmpVar NUMBER;
begin
  select count(*)into tmpVar from dual where exists 
  (select * from All_Users where USERNAME='DCL');
  if tmpVar!=0 then 
    execute immediate('
      DROP USER "DCL" CASCADE
    ');
  end if;
end;
/

CREATE USER "DCL" IDENTIFIED BY "DCL"
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;


-- end of script
