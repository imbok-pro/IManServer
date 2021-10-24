-- Скрипт создания схемы экспорта-импорта
-- by Nikolai Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 24.09.2010
-- update 03.06.2012 08.07.2015 24.12.2015 26.10.2018
--*****************************************************************************
--
-- Выполнять от sys sysdba
declare
  tmpVar NUMBER;
begin
  select count(*)into tmpVar from dual where exists 
  (select * from All_Users where USERNAME='SP_IO');
  if tmpVar!=0 then 
    execute immediate('
      DROP USER "SP_IO" CASCADE
    ');
  end if;
end;
/

CREATE USER "SP_IO" IDENTIFIED BY "SP_IO"
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;

CREATE TABLE SP_IO.CLIENT_SCRIPTS(
  SCRIPT VARCHAR2(256)not null,
  LINE_NUM NUMBER(9) not null,
	LINE VARCHAR2(4000)
);
COMMENT ON TABLE SP_IO.CLIENT_SCRIPTS
  IS 'Таблица экспорта - импорта данных SP.';
  
COMMENT ON COLUMN SP_IO.CLIENT_SCRIPTS.SCRIPT
  IS 'Имя скрипта.';  
COMMENT ON COLUMN SP_IO.CLIENT_SCRIPTS.LINE_NUM
  IS 'Номер строки скрипта.';  
COMMENT ON COLUMN SP_IO.CLIENT_SCRIPTS.LINE
  IS 'Строка скрипта.'; 
   
CREATE UNIQUE INDEX SP_IO.CLIENT_SCRIPTS 
  ON SP_IO.CLIENT_SCRIPTS (upper(SCRIPT),LINE_NUM);

CREATE OR REPLACE PROCEDURE SP_IO.Clear
-- Процедура очищает таблицу скриптов.
-- (CREATE USER SP_IO.sql)
AS
BEGIN
  execute immediate('truncate table SP_IO.CLIENT_SCRIPTS');
END;
/

declare
  tmpVar NUMBER;
begin
  select count(*)into tmpVar from dual where exists 
  (select * from All_Users where USERNAME='SP');
  if tmpVar!=0 then 
    execute immediate('
      GRANT SELECT,UPDATE,DELETE,INSERT on SP_IO.CLIENT_SCRIPTS to SP
    ');
    execute immediate('
      GRANT EXECUTE on SP_IO.Clear to SP
    ');
  end if;
end;
/

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

GRANT "SP_ADMIN_ROLE" TO "PROG";
GRANT SELECT,UPDATE,DELETE,INSERT on SP_IO.CLIENT_SCRIPTS to "SP_ADMIN_ROLE";

-- end of script
