-- Threads for ORACLE
-- by Nikolai Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 11.11.2006
-- update 12.08.2007 24.08.2007 05.11.2010 04.01.2011 24.11.2015 21.12.2015
--        24.12.2015 28.12.2015 30.12.2015 25.01.2016 28.02.2016-29.01.2016  
--        03.02.2016 29.02.2016 21.11.2016 13.09.2017 17.06.2021
--    
-------------------------------------------------------------------------------
-- Перез повторным выполнением данного скрипта, необходимо перезапустить 
-- экземпляр базы.
-- Если фоновые процессы запрещены, то разрешаем 100 процессов.
declare
tmpVar number;
begin
select to_number(p.value) into tmpVar from SYS.V$PARAMETER p 
  where name = 'job_queue_processes';
if tmpVar = 0 then
 execute immediate ('ALTER SYSTEM SET job_queue_processes=100');
end if;
end;
/   
--
-------------------------------------------------------------------------------
-- Удаляем пользователей "THREADS" и "THREADS_ADMIN".
declare
  tmpVar NUMBER;
begin
-- Перед удалением пользователя нужно остановить все демоны и закрыть трубу.
-- Иначе придётся перезапускать базу!
  select count(*) into tmpVar from ALL_PROCEDURES ap 
	  where (ap.OBJECT_NAME='STOPSERVERS') and (ap.OWNER='THREADS');                           
	if tmpVar>0 then
	  execute immediate('begin THREADS.StopServers; THREADS.RemovePipes; end;');
	end if;	
  select count(*) into tmpVar from ALL_USERS where USERNAME='THREADS';
	if tmpVar>0 then
	  execute immediate('DROP USER "THREADS" Cascade');
  end if;  
  select count(*) into tmpVar from ALL_USERS where USERNAME='THREADS_ADMIN';
	if tmpVar>0 then
	  execute immediate('DROP USER "THREADS_ADMIN" Cascade');
  end if;  
end;
/
-- Создаём пространство таблиц BDR, если оно не существует.
declare 
  tmpVar NUMBER;
begin
  select count(*) into tmpVar from SYS.DBA_TABLESPACES t 
	  where t.TABLESPACE_NAME='BDR';                           
	if tmpVar = 0 then
	  execute immediate('
	  CREATE TABLESPACE BDR
    DATAFILE ''BDR.dbf'' SIZE 200 M REUSE 
    AUTOEXTEND ON NEXT 300 M MAXSIZE UNLIMITED
    LOGGING
    DEFAULT NOCOMPRESS
    ONLINE
    PERMANENT
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE
    ');
	end if;	
end;
/  
--  THREADS
CREATE USER "THREADS" IDENTIFIED BY "th"
  DEFAULT TABLESPACE BDR
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON BDR;
--GRANT CREATE SESSION TO "THREADS" ;
--GRANT CREATE PROCEDURE  TO "THREADS" ;
-- !!! под вопросом
GRANT EXECUTE ON  "SYS"."DBMS_JOB" TO "THREADS";
GRANT EXECUTE ON  "SYS"."DBMS_IJOB" TO "THREADS";
GRANT EXECUTE ON  "SYS"."DBMS_PIPE" TO "THREADS";
GRANT EXECUTE ON  "SYS"."DBMS_LOCK" TO "THREADS";
GRANT EXECUTE ON  "SYS"."DBMS_ALERT" TO "THREADS";
GRANT ALTER SYSTEM TO "THREADS";
-- !!! ограничить
GRANT SELECT ANY DICTIONARY TO "THREADS";
GRANT SELECT ON SYS.V_$SESSION TO THREADS;
--
-- THREADS_ADMIN
CREATE USER "THREADS_ADMIN" IDENTIFIED BY "ta"
  DEFAULT TABLESPACE BDR
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON BDR;
GRANT CREATE SESSION TO "THREADS_ADMIN";
--
GRANT EXECUTE ON SYS.DBMS_JOB TO THREADS_ADMIN;
GRANT EXECUTE ON SYS.DBMS_IJOB TO THREADS_ADMIN;
GRANT SELECT ON SYS.V_$SESSION TO THREADS_ADMIN;
GRANT SELECT ON SYS.DBA_JOBS_RUNNING TO THREADS_ADMIN;
GRANT SELECT ON SYS.DBA_JOBS TO THREADS_ADMIN;
--
begin
  if DBMS_DB_VERSION.VERSION > 11 then
    execute immediate'GRANT INHERIT PRIVILEGES on user "SYS" TO "THREADS"';
    execute immediate'GRANT INHERIT ANY PRIVILEGES TO "THREADS"';
  end if;  
end;
/
-- Типы
@"THREADS-TYPES.tps"
--
--Таблицы
-------------------------------------------------------------------------------
CREATE TABLE THREADS.JOBS(
  ID NUMBER PRIMARY KEY,
  JOB_ID NUMBER,
  JOB_TUBE VARCHAR(1000),
  JOB_USER VARCHAR2(30),
  S_DATE DATE,
  AID NUMBER,
  BROKEN NUMBER(1) not null
);
--
COMMENT ON TABLE THREADS.JOBS 
  IS 'Демоны.';
--  
COMMENT ON COLUMN THREADS.JOBS.ID
  IS 'Уникальный идентификатор.';
COMMENT ON COLUMN THREADS.JOBS.JOB_ID
  IS 'Системный идентификатор демона.';
COMMENT ON COLUMN THREADS.JOBS.S_DATE
  IS 'Время старта демона или потока.';
COMMENT ON COLUMN THREADS.JOBS.AID
  IS 'Идентификационный номер сессии, запустившей поток на демоне.';
COMMENT ON COLUMN THREADS.JOBS.JOB_USER
  IS 'Имя пользователя от имени которого запущен демон.';         
COMMENT ON COLUMN THREADS.JOBS.BROKEN
  IS 'Если значение этого поля не равно нулю, то демон сломан.';         
COMMENT ON COLUMN THREADS.JOBS.JOB_TUBE
  IS 'Имя командной трубы демона.';  
--		
-------------------------------------------------------------------------------
CREATE TABLE THREADS.ERRORS_LOG(
  ID NUMBER PRIMARY KEY,
  PROC_NAME VARCHAR2(4000),
  USER_NAME VARCHAR2(30),
  S_DATE DATE,
  ERROR VARCHAR2(4000)
);
--
COMMENT ON TABLE THREADS.ERRORS_LOG 
  IS 'Ошибки при выполнении потоков.';
--  
COMMENT ON COLUMN THREADS.ERRORS_LOG.ID
  IS 'Уникальный идентификатор.';  
COMMENT ON COLUMN THREADS.ERRORS_LOG.PROC_NAME
  IS 'Имя процедуры, вызвавшей ошибку.'; 
COMMENT ON COLUMN THREADS.ERRORS_LOG.USER_NAME
  IS 'Имя пользователя, от имени которого выполнялась процедура.'; 
COMMENT ON COLUMN THREADS.ERRORS_LOG.S_DATE
  IS 'Дата ошибки.'; 
COMMENT ON COLUMN THREADS.ERRORS_LOG.ERROR
  IS 'Текст сообщения об ошибке.'; 
--  
GRANT SELECT, DELETE, INSERT ON  THREADS.ERRORS_LOG to PUBLIC;
--
-------------------------------------------------------------------------------
CREATE SEQUENCE THREADS.SEQ
  START WITH 100
  INCREMENT BY 100
  MINVALUE 100
  NOCYCLE 
  NOORDER
  CACHE 10;
/
--
CREATE SEQUENCE THREADS.TubeName
	START WITH 0
	INCREMENT BY 1
	MINVALUE 0
	MAXVALUE 1000000
	CACHE 50
	CYCLE 
	NOORDER;
/
--
-------------------------------------------------------------------------------
-- !!! добавлено на время отладки 
GRANT SELECT  ON  THREADS.tubeName to PROG;
--   
GRANT ADMINISTER DATABASE TRIGGER to THREADS;
@"THREADS-TRIGGERS.trg"
@"THREADS-ExecInner.pks"
@"THREADS-Exec.pks"
@"THREADS-GetArrs.pks"
@"THREADS-ADMIN_PROCEDURES.fnc"
@"THREADS-PROCEDURES.fnc"
--
GRANT EXECUTE ON THREADS.GETARRS TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM THARRS FOR THREADS.GETARRS;
GRANT EXECUTE ON THREADS.EXEC TO PUBLIC;
--
@"THREADS_THREAD_REC.tpb"
--
@"THREADS-Exec.plb"
@"THREADS-ExecI.plb"
--
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW THREADS.VJOBS(
ID,
JOB_ID,
JOB_USER,
JOB_PRIV,
JOB_TUBE,
JOB_SID,
JOB_SER#,
STATE,
S_DATE,
USER_NAME,
USER_SID,
USER_SER#
)
AS
select
  tj.ID, 
  tj.JOB_ID, 
  tj.JOB_USER,
  j.PRIV_USER JOB_PRIV,
  tj.JOB_TUBE,
  js.JOB_SID,
  js.JOB_SER#,
  case 
	  when (tj.BROKEN !=0 ) or (j.broken != 'N') then 'BROKEN !'
	  when (js.JOB_SID is null) then 'Sleeping'
	  when (tj.AID is null) and (tj.S_DATE is null) then 'Sleeping'
	  when (tj.AID is null) and (tj.S_DATE is not null) then 'Waiting'
	else
	  'Working'
	end STATE,
	tj.S_DATE S_DATE,
	usr.USERNAME USER_NAME, 
	usr.SID USR_SID,
	usr.SERIAL# USER_SER# 	 	 
  from THREADS.JOBS tj
	  left join 
	    (select vs.SID JOB_SID,vs.SERIAL# JOB_SER#,rj.JOB JOB 
		     from V$SESSION vs, DBA_JOBS_RUNNING rj
         where rj.SID=vs.SID
      ) js
		on	tj.JOB_ID=js.JOB,
		  THREADS.JOBS tj1
		left join	V$SESSION usr on tj1.AID = usr.AUDSID,
		  THREADS.JOBS tj2
		left join	DBA_JOBS j on tj2.JOB_ID = j.JOB
  where  tj.ID=tj1.ID
    and  tj.ID=tj2.ID
WITH READ ONLY;
/
CREATE OR REPLACE PUBLIC SYNONYM V$JOBS FOR THREADS.VJOBS;
GRANT SELECT ON THREADS.VJOBS TO PUBLIC;
--
COMMENT ON TABLE THREADS.VJOBS 
  IS 'Мониторинг выполнения потоков.';
--
COMMENT ON COLUMN THREADS.VJOBS.ID
  IS 'Уникальный идентификатор записи.';  
COMMENT ON COLUMN THREADS.VJOBS.JOB_ID
  IS 'Системный идентификатор демона.';  
COMMENT ON COLUMN THREADS.VJOBS.JOB_SID
  IS 'Идентификационный номер сессии демона.'; 
COMMENT ON COLUMN THREADS.VJOBS.JOB_SER#
  IS 'Серийный номер сессии демона.'; 
COMMENT ON COLUMN THREADS.VJOBS.STATE
  IS 'Состояние демона: "Sleeping" - демон ожидает запуска "JOB", "Waiting" -  демон запущен и ожидает команды по трубе, "Working" - демон выполняет задание, полученное от другой сессии, "BROKEN" - демон сломан.'; 
COMMENT ON COLUMN THREADS.VJOBS.S_DATE
  IS 'Время старта демона или потока из другой сессии в нём в нём.'; 
COMMENT ON COLUMN THREADS.VJOBS.USER_NAME
  IS 'Имя пользователя чья сессия, запустила поток на демоне.'; 
COMMENT ON COLUMN THREADS.VJOBS.USER_SID
  IS 'Идентификационный номер сессии, запустившей поток на демоне.'; 
COMMENT ON COLUMN THREADS.VJOBS.USER_SER#
  IS 'Серийный номер сессии, запустившей поток на демоне.';         
COMMENT ON COLUMN THREADS.VJOBS.JOB_USER
  IS 'Имя пользователя запустившего демон.';         
COMMENT ON COLUMN THREADS.VJOBS.JOB_PRIV
  IS 'Имя пользователя привилегиями которого обладает демон.';         
COMMENT ON COLUMN THREADS.VJOBS.JOB_TUBE
  IS 'Имя командной трубы демона.';  
         
--!! Написать триггера управления серверами.
-- Добавление, удаление.
-- Добавить поле ошибка и сделать починку по обновлению,
-- причём всех сломанных.
-- Можно сделать обновление параметров интервала, ожидания активности. 
-- Удаляем роль "THREADS_EXEC", если она существует.
declare
  tmpVar NUMBER;
begin
  select count(*)into tmpVar from dual where exists 
  (select * from DBA_ROLES where ROLE='THREADS_EXEC');
  if tmpVar!=0 then 
    execute immediate('
      DROP ROLE "THREADS_EXEC" 
    ');
  end if;
end;
/
--
CREATE ROLE "THREADS_EXEC" NOT IDENTIFIED;
GRANT "THREADS_EXEC" TO THREADS;
GRANT "THREADS_EXEC" TO THREADS_ADMIN;
--
-- !!! Добавлено для отладки.
--GRANT THREADS_EXEC TO BUILDER_CREATOR_ROLE;
GRANT THREADS_EXEC TO PROG_ROLE;
--
declare
  tmpVar VARCHAR2(38);
begin
  select to_char(count(*)) into tmpVar from DBA_OBJECTS o 
     where  (o.STATUS='INVALID') and (o.OWNER='THREADS');
	O('THREADS Invalid Obj before: '||tmpVar);	 
   utl_recomp.recomp_serial('THREADS');
end;
/
-- Поднимаем триггер OnLogOff
alter trigger THREADS.ON_LOGOFF compile;
--
declare
  tmpVar VARCHAR2(38);
begin
  select to_char(count(*)) into tmpVar from DBA_OBJECTS o 
     where  (o.STATUS='INVALID') and (o.OWNER='THREADS');
	O('after: '||tmpVar);	 
end;
/
-- Конец скрипта создания потоков.        