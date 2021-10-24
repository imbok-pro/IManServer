-- KOCELSYS procedures
-- create 25.04.2009
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 08.05.2009 28.01.2009

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION KOCELSYS.RegisterScript return VARCHAR2
-- Регистрируем скрипт в таблице скриптов.
-- (KOCELSYS-PROCEDURES.prc)
is
tmpVar NUMBER;
begin
  -- заносим идентификатор скрипта в таблицу и в переменную пакета S
  select KOCELSYS.SCRIPT_SEQ.NEXTVAL into tmpVar from DUAL;
  insert into KOCELSYS.SCRIPTS 
	  values (tmpVar,to_number(sys_context('userenv', 'sessionid')));
	commit;
	KOCELSYS.S.ID:=tmpVar;
	return to_char(tmpVar);
end;
/

grant EXECUTE on KOCELSYS.RegisterScript to PUBLIC;


-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCELSYS.AbortScript(UScript in VARCHAR2) 
-- Убиваем сессию, выполняющую скрипт.
-- (KOCELSYS-PROCEDURES.prc)
is
  SQLStr VARCHAR2(255);
	tmpVar NUMBER;
begin
  tmpVar:=to_number(UScript);
  select to_char(v.sid)||','||to_char(v.serial#) into SQLStr
         from V$session v, KOCELSYS.SCRIPTS k
         where (v.audsid=k.ScriptSession)
				   and (k.SCRIPT=tmpVar);
  SQLStr:='ALTER SYSTEM KILL SESSION '''||SQLStr||''' IMMEDIATE';
  execute immediate(SQLStr);
end;
/
grant EXECUTE on KOCELSYS.AbortScript to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION KOCELSYS.CompileScript(Script in VARCHAR2,
                                                  Errors out NOCOPY VARCHAR2)
return NUMBER 
authid current_user
-- Проверяем ошибки в скрипте.
-- (KOCELSYS-PROCEDURES.prc)
is
	DCursor NUMBER;
begin
  DCursor :=dbms_sql.open_cursor;
  dbms_sql.parse(DCursor,regexp_replace(Script,
                 chr(13)||chr(10)||'/|'||chr(13)||chr(10),chr(10)),1);
  dbms_SQL.close_cursor(DCursor);
	return 0;
exception
  -- можно ещё получить и индекс в тексте скрипта и его подссветить!!!
  when others then
	  Errors:=regexp_replace(SQLERRM,chr(13)||'|'||chr(10),chr(13)||chr(10));
    dbms_SQL.close_cursor(DCursor);
	  return 1;	
end;
/

grant EXECUTE on KOCELSYS.CompileScript to PUBLIC;


-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION KOCELSYS.ExecuteScript(Script in VARCHAR2,
                                                  Errors out NOCOPY VARCHAR2)
return NUMBER 
authid current_user
-- Запускаем скрипт на выполнение.
-- (KOCELSYS-PROCEDURES.prc)
is
	DCursor NUMBER;
	tmpVar NUMBER;
begin
  DCursor :=dbms_sql.open_cursor;
  dbms_sql.parse(DCursor,regexp_replace(Script,
                 chr(13)||chr(10)||'/|'||chr(13)||chr(10),chr(10)),1);
	tmpVar:=dbms_sql.execute(DCursor);							 
  dbms_SQL.close_cursor(DCursor);
	return 0;
exception
  -- можно ещё получить и индекс в тексте скрипта и его подссветить!!!
  when others then
	  Errors:=regexp_replace(SQLERRM,chr(13)||'|'||chr(10),chr(13)||chr(10));
		dbms_SQL.close_cursor(DCursor);
	  return 1;	
end;
/

grant EXECUTE on KOCELSYS.ExecuteScript to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION KOCELSYS.FIND_MD_FIELD(Q1 in VARCHAR2,
                                                  Q2 in VARCHAR2,
                                                  FIELD out NOCOPY VARCHAR2)
return NUMBER
authid current_user
-- Функция сравнивает два запроса и находит у них общее поле.
-- Функция возвращяет:
-- 0 - OK!,
-- 1 - поле отсутствует,
-- 2 - полей много,
-- 3 - ошибка в первом запросе,
-- 4 - ошибка во втором запросе.
-- (KOCELSYS-PROCEDURES.prc)
is
Cursor1 NUMBER;
Cursor2 NUMBER;
Desc1 DBMS_SQL.DESC_TAB2;
Desc2 DBMS_SQL.DESC_TAB2;
FCount1 NUMBER;
FCount2 NUMBER;
Fields1 KOCEL.TStrings;
Fields2 KOCEL.TStrings;
Result NUMBER;
begin
  Cursor1 :=dbms_sql.open_cursor;
  Cursor2:=dbms_sql.open_cursor;
	begin
	  dbms_sql.parse(Cursor1,regexp_replace(Q1,
	                 chr(13)||chr(10)||'/|'||chr(13)||chr(10),chr(10)),1);
	exception
	  when others then 
      dbms_SQL.close_cursor(Cursor1);
      dbms_SQL.close_cursor(Cursor2);
		  return 3;
	end;								 
	begin
	  dbms_sql.parse(Cursor2,regexp_replace(Q2,
	                 chr(13)||chr(10)||'/|'||chr(13)||chr(10),chr(10)),1);
	exception
	  when others then
      dbms_SQL.close_cursor(Cursor1);
      dbms_SQL.close_cursor(Cursor2);
		  return 4;
	end;	
	dbms_sql.describe_columns2(Cursor1,FCount1,Desc1);
	Fields1:=KOCEL.TStrings();
	Fields1.extend(FCount1);
	for i in 1..FCount1 
	loop
	  Fields1(i):=Desc1(i).col_name;
	end loop;
	dbms_sql.describe_columns2(Cursor2,FCount2,Desc2);
	Fields2:=KOCEL.TStrings();
	Fields2.extend(FCount2);
	for i in 1..FCount2 
	loop
	  Fields2(i):=Desc2(i).col_name;
	end loop;
	begin
	  select f1.column_value into Field 
		  from table (Fields1) f1, table (Fields2) f2 
	    where f1.column_value=f2.column_value;
		result:=0;	
	exception
	  when no_data_found then result:=1;
	  when too_many_rows then result:=2;
	end;	
  dbms_SQL.close_cursor(Cursor1);
  dbms_SQL.close_cursor(Cursor2);
	return Result;
end;
/

grant EXECUTE on KOCELSYS.FIND_MD_FIELD to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCELSYS.SLEEP(Seconds in NUMBER)
-- Засыпаем на ... секунд.
-- (KOCELSYS-PROCEDURES.prc)
is
begin
  dbms_lock.sleep(seconds);
end;
/

grant EXECUTE on KOCELSYS.SLEEP to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCELSYS.ClearScriptTable 
-- Очищаем таблицу скриптов, если у сессии есть зарегистрированные скрипты.
-- (KOCELSYS-PROCEDURES.prc)
is
begin
	if KOCELSYS.S.ID is not null then
	  delete from KOCELSYS.SCRIPTS where SCRIPT=KOCELSYS.S.ID;
		commit;
	end if;
end;
/
grant EXECUTE on KOCELSYS.ClearScriptTable to PUBLIC;

