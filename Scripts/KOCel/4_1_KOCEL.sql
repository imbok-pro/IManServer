-- Основной скрипт создания схемы KOCEL 
-- create 25.04.2009
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 28.01.2010 05.11.2010 26.03.2011 28.08.2014 17.08.2021
--
--*****************************************************************************
-- Удаляем пользователей "KOCEL" и "KOCELSYS".
declare
  tmpVar NUMBER;
begin
  select count(*) into tmpVar from ALL_USERS where USERNAME='KOCEL';
	if tmpVar>0 then
	  execute immediate('DROP USER "KOCEL" Cascade');
  end if;  
  select count(*) into tmpVar from ALL_USERS where USERNAME='KOCELSYS';
	if tmpVar>0 then
	  execute immediate('DROP USER "KOCELSYS" Cascade');
  end if;  
end;
/
--
CREATE USER "KOCEL" IDENTIFIED BY "K"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;
--	
CREATE USER "KOCELSYS" IDENTIFIED BY "K"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;
--
GRANT CREATE SESSION TO "KOCEL" ;
GRANT CREATE PROCEDURE  TO "KOCEL" ;
GRANT CREATE TABLE  TO "KOCEL" ;
GRANT CREATE VIEW  TO "KOCEL" ;
--
GRANT SELECT ON SYS.V_$SESSION TO "KOCELSYS";
GRANT ALTER SYSTEM TO "KOCELSYS";
GRANT execute on SYS.dbms_LOCK to "KOCELSYS";
--
CREATE SEQUENCE KOCELSYS.SCRIPT_SEQ
  START WITH 1
  INCREMENT BY 1
  MINVALUE 1
  NOCYCLE 
  NOORDER
  NOCACHE;
/
CREATE SEQUENCE KOCEL.SEQ
  START WITH 100
  INCREMENT BY 100
  MINVALUE 100
  NOCYCLE 
  NOORDER
  CACHE 10;
/
CREATE SEQUENCE KOCEL.FORMAT_SEQ
  START WITH 100
  INCREMENT BY 100
  MINVALUE 100
  NOCYCLE 
  NOORDER
  NOCACHE;
/
-- Типы.
@"KOCEL_TFORMAT.tps"
GRANT execute on KOCEL.TFormat to public;
@"KOCEL_TYPES.sql"
-- Таблицы.
@"KOCELSYS_TABLES.sql"
@"KOCEL_TABLES.sql"
insert into KOCEL.FORMATS (Fmt) values (0);
-- Тригггера.
@"KOCEL-TRIGGERS.trg"
-- процедуры API FLEXCEL
@"KOCEL-PROCEDURES.prc"
--Тестовые строки.
begin
  KOCEL.UPDATE_CELL(1,1,
  null,null,'A1',null,
	'Q','Q');
  KOCEL.UPDATE_CELL(1,2,
  null,null,'B1',null,
	'Q','Q');
  KOCEL.UPDATE_CELL(2,1,
  null,null,'A2',null,
	'Q','Q');
  KOCEL.UPDATE_CELL(2,2,
  null,null,'B2',null,
	'Q','Q');
	commit;
end;
/
-- Системный пакет.
@"KOCELSYS-S.pks"
-- Пакет форматирования.
@"KOCEL-FORMAT.pks"
-- Системные процедуры.
@"KOCELSYS-PROCEDURES.prc"
-- Системные триггеры.
GRANT ADMINISTER DATABASE TRIGGER to KOCELSYS;
@"KOCELSYS-TRIGGERS.trg"
-- Пакет для использования в скриптах обработки данных.
@"KOCEL-CELL.pks"
-- Пакет запросов к данным книг.
@"KOCEL-BOOK.pks"
-- Тела типов и пакетов.
@"KOCEL-CELL.pkb"
@"KOCEL-TROW.tpb"
@"KOCEL-TSROW.tpb"
@"KOCEL-TVALUE.tpb"
@"KOCEL_TFORMAT.tpb"
@"KOCEL-FORMAT.pkb"
@"KOCEL-BOOK.pkb"
--
GRANT EXECUTE on KOCEL.CELL to public;
CREATE OR REPLACE public synonym CELL for KOCEL.CELL;
GRANT EXECUTE on KOCEL.BOOK to public;
CREATE OR REPLACE public synonym BOOK for KOCEL.CELL;
GRANT EXECUTE on KOCEL.FORMAT to public;
CREATE OR REPLACE public synonym KFM for KOCEL.FORMAT;
GRANT EXECUTE on KOCEL.TFORMAT to public;
CREATE OR REPLACE public synonym TFORMAT for KOCEL.TFORMAT;
-- Представления.
@"KOCEL-Views.vw"
-- Перекомпилируем объекты с ошибками и выводим результат.
declare
  tmpVar VARCHAR2(38);
begin
  select to_char(count(*)) into tmpVar from DBA_OBJECTS o 
     where  (o.STATUS='INVALID') and (o.OWNER='KOCEL');
	O('KOCEL Invalid Obj before: '||tmpVar);	 
   sys.utl_recomp.recomp_serial('KOCEL');
  select to_char(count(*)) into tmpVar from DBA_OBJECTS o 
     where  (o.STATUS='INVALID') and (o.OWNER='KOCEL');
	O('after: '||tmpVar);	 
  select to_char(count(*)) into tmpVar from DBA_OBJECTS o 
     where  (o.STATUS='INVALID') and (o.OWNER='KOCELSYS');
	O('KOCELSYS Invalid Obj before: '||tmpVar);	 
   sys.utl_recomp.recomp_serial('KOCELSYS');
  select to_char(count(*)) into tmpVar from DBA_OBJECTS o 
     where  (o.STATUS='INVALID') and (o.OWNER='KOCELSYS');
	O('after: '||tmpVar);
end;
/

-- Конец скрипта создания KOCEL.