-- KARBUILDER Threads Admin PROCEDURES & FUNCTIONS
-- by Nikolai Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 11.11.2006
-- update 31.07.2007 11.08.2007 17.08.2007 21.08.2008 02.09.2007 04.11.2009
--        28.01.2009 21.04.2010 05.11.2010 04.01.2011 24.12.2015 28.12.2015
--        29.12.2015-31.12.2015 26.01.2016 28.01.2016-04.02.2016 26.02.2016
--        29.02.2016 19.11.2020
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION THREADS.StartServer( 
  t_name in VARCHAR2 default 'StartThread',
  t_out in NUMBER default 100)
return NUMBER
-- Запуск универсального сервера потоков
-- Чем больше количество серверов,
-- тем больше потоков может работать одновременно. 
-- t_name - имя трубы для инициации потоков,
-- можно создавать отдельные пулы серверов для различных операций
-- t_out - время ожидания сообщения по трубею
-- (THREADS-ADMIN_PROCEDURES.fnc)
AS
temp NUMBER;
cmd VARCHAR2(4000);
begin
cmd := 'THREADS.Server('''||t_name||''','||to_char(t_out)||');';
-- После завершения операции поток отдыхает одну секунду.
dbms_JOB.submit(temp,cmd,SysDate,'SysDate+1/(24*60*60)');
insert into THREADS.JOBS 
  values (0,temp,t_name,sys_context('userenv', 'session_user'),null,null,0);
commit;
return temp;
end;
/
grant EXECUTE on THREADS.StartServer to "THREADS_ADMIN";
--
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE THREADS.StartServers(
  N in NUMBER,
  t_name in VARCHAR2 default 'StartThread',
  t_out in NUMBER default 100)
-- Запуск нескольких серверов 1..100.
-- (THREADS-ADMIN_PROCEDURES.fnc)
AS
temp NUMBER;
begin
  if (N is null) or not (N between 1 and 100) then return; end if;
  for i in 1..N
  loop
    temp:=THREADS.StartServer(t_name, t_out);
  end loop;
end;
/
grant EXECUTE on THREADS.StartServers to "THREADS_ADMIN";
--
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE THREADS.StopServer( Server IN NUMBER)
-- Удаление сервера.
-- Даже SYS не убивает чужую сломанную работу и не чинит! 
-- Только тот пользователь может убить, кто создал. 
-- (THREADS-ADMIN_PROCEDURES.fnc)
AS
begin
  begin
    -- Если не починить сломанную работу, то виснет сессия удаления задания.
    sys.dbms_IJOB.broken(Server,false,sysdate+1);
    sys.dbms_IJOB.remove(Server);
  exception
    when no_data_found then
      -- не удаляем задание из таблицы, оскольку у нас просто нет привилегий
      -- на работу с этим заданием!
      d('StopServer нет привилегий! '||SQLERRM,'ERROR in Threads');
      raise;
    when others then
      d('StopServer '||SQLERRM,'ERROR in Threads');
  end;  
  delete from THREADS.JOBS j where j.JOB_ID=Server; 
  commit;
end;
/
grant EXECUTE on THREADS.StopServer to "THREADS_ADMIN";
--
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE THREADS.StopServers
-- Удаление всех серверов 
-- (THREADS-ADMIN_PROCEDURES.fnc)
AS
begin
  -- Останавливаем только сервера с полномочиями  
  for c in (select JOB_ID from THREADS.VJOBS)
  loop
    THREADS.StopServer(c.JOB_ID);
  end loop;
end;
/
grant EXECUTE on THREADS.StopServers to "THREADS_ADMIN";
--
-------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE THREADS.Server_Vars
  -- (THREADS-ADMIN_PROCEDURES.fnc)
as
CallerAID NUMBER; -- AID сессии, запустившей задание на сервере. 
end Server_Vars;
/
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION THREADS.CallerAID return NUMBER
-- Функция возвращает AID сессии, запустившей задание на сервере. 
-- (THREADS-ADMIN_PROCEDURES.fnc)
AS
begin
  return THREADS.Server_Vars.CallerAID;
end;
/
--
GRANT EXECUTE on THREADS.CallerAID to public;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION THREADS.JobID return NUMBER
-- (THREADS-ADMIN_PROCEDURES.fnc)
AS
begin
return to_number(sys_context('userenv', 'BG_JOB_ID'));
end;
/
GRANT EXECUTE on THREADS.JobID to public;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION THREADS.SessionID return NUMBER
-- (THREADS-ADMIN_PROCEDURES.fnc)
AS
begin
return to_number(sys_context('userenv', 'SID'));
end;
/
GRANT EXECUTE on THREADS.SessionID to public;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE THREADS.Server(
  t_name in VARCHAR2 default 'StartThread',
  t_out in NUMBER default 100)
-- Выполняет полученную от процедуры ExecProc команду,
-- переданную по частной трубе с именем StartTread
-- Ошибки, возникшие при выполнении потока записываются в таблицу
-- THREADS.ERRORS_LOG.
-- (THREADS-ADMIN_PROCEDURES.fnc)
AUTHID CURRENT_USER
AS
tempVar NUMBER;
CallerName VARCHAR(30);
ProcName VARCHAR2(4000);
Err VARCHAR2(4000);
begin
--  D('begin t_name => '||nvl(t_name,'null')||
--    ' t_out => '||nvl(to_char(t_out),'null'),
--    'THREADS.Server');
  update THREADS.JOBS j 
    set S_DATE=sysdate,
        AID=null,
        BROKEN=0
    where j.JOB_ID=THREADS.JobID;
	commit;
  STOP_WATCH.RESET;
--  D('start resieving '||DEBUG_LOG.STOP_WATCH.Result,'THREADS.Server');
  tempVar := dbms_PIPE.receive_message(t_name,t_out);
--  D('recieved message '||tempVar||'   '||DEBUG_LOG.STOP_WATCH.Result
--    ,'THREADS.Server');
  if tempVar = 0 then
	  dbms_pipe.reset_buffer;
    dbms_PIPE.unpack_message(ProcName);
		dbms_PIPE.unpack_message(THREADS.Server_Vars.CallerAID);
		update THREADS.JOBS j set 
		  S_DATE=sysdate,
		  AID=THREADS.Server_Vars.CallerAID 
		  where j.JOB_ID=THREADS.JobID;
		commit;	
    begin
      execute immediate (ProcName);
    exception
      when others then
	      Err := SqlErrm;
        begin
          select USERNAME into CallerName  from V$SESSION 
            where AUDSID=THREADS.Server_Vars.CallerAID;
        exception
          when no_data_found then 
            CallerName:=null;
        end;
        insert into THREADS.ERRORS_LOG 
          values (null,ProcName,CallerName,SysDate,Err);
--        D('ERROR '||SqlErrm,'ERROR in THREADS.Server');
    end;
--  D('end if','THREADS.Server');
  end if;
--  D('end','THREADS.Server');
	update THREADS.JOBS j 
    set S_DATE=null,
        AID=null
		where j.JOB_ID=THREADS.JobID;
	commit;	 
--  D('return','THREADS.Server');
exception
  when others then 
    D('ERROR '||SqlErrm,'THREADS.Server');
    Err := SqlErrm;
    insert into THREADS.ERRORS_LOG 
       values (null,ProcName,null,SysDate,Err);
	   update THREADS.JOBS j 
        set S_DATE=null,
            AID=null,
            BROKEN=1  
       where j.JOB_ID=THREADS.JobID;
    commit;  
    D('END ERROR ','THREADS.Server');
    return;
end;
/
GRANT EXECUTE on THREADS.Server to THREADS_ADMIN;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION THREADS.IExecProc
(
                           CmdLine IN VARCHAR2,
                           DEBUG_MODE IN BOOLEAN default false,
                           T_Name IN VARCHAR2 default 'StartThread',  
													 TimOut IN NUMBER default 1
)
return NUMBER																				 
  -- Используется для запуска CmdLine
  -- 0 ok
  -- 1 timeOut
  -- -1 error
  -- (THREADS-ADMIN_PROCEDURES.fnc)
AS
tmpVar NUMBER;
Err VARCHAR2(4000);
CallerName VARCHAR2(30);
begin
  -- Если отладка, то просто исполняем CmdLine 
  if DEBUG_MODE then
	  THREADS.Server_Vars.CallerAID:=S_Session;
		begin
      execute immediate (CmdLine);
    exception
      when others then
	      Err := SqlErrm;
        begin
          select USERNAME into CallerName  from V$SESSION 
            where AUDSID=THREADS.Server_Vars.CallerAID;
        exception
          when no_data_found then 
            CallerName:=null;
        end;
        insert into THREADS.ERRORS_LOG 
          values (null,CmdLine,CallerName,SysDate,Err);
				commit;  
        raise;
    end;
		return 0;
  else  
	  -- Передаем строку на исполнение демону.
		dbms_pipe.reset_buffer;
    dbms_pipe.pack_message(CmdLine);
	  -- передаём идентификатор сессии
	  dbms_pipe.pack_message(S_Session);
    tmpVar := dbms_pipe.send_message(T_Name,TimOut);
	  return tmpVar;
	end if;
end;
/
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION THREADS.ExecProc
(
                           CmdLine IN VARCHAR2,
                           DEBUG_MODE IN BOOLEAN default false,
                           T_Name IN VARCHAR2 default 'StartThread',  
													 TimOut IN NUMBER default 1
)
return NUMBER																					 
  -- Публичная обёртка для функции THREADS.IExecProc
  -- 0 ok
  -- 1 timeOut
  -- -1 error
  -- (THREADS-ADMIN_PROCEDURES.fnc)
AS
begin
	-- проверяем имеет ли юзер роль THREADS_EXEC
	if HasUserRole (S_User,'THREADS_EXEC')then
    return THREADS.IExecProc(CmdLine, DEBUG_MODE, T_Name, TimOUT);
	else
	  raise_application_error(-20044,'THREADS.ExecProc. '||
      S_user||' - недостаточно привилегий!');
	end if;
  return -1;
end;
/
GRANT execute on THREADS.ExecProc to Public;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE THREADS.KILLALL
-- Удаляем всех демонов.
-- (THREADS-ADMIN_PROCEDURES.fnc)
as
begin
  THREADS.EXEC.KillAll;
end;
/
GRANT execute on THREADS.KILLALL to Public;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE THREADS.RemovePipes
-- Удаляем все управляющие трубы.
-- (THREADS-ADMIN_PROCEDURES.fnc)
as
r NUMBER;
begin
  for c in (select distinct JOB_TUBE from THREADS.JOBS)
  loop
    r:=dbms_pipe.remove_pipe(c.JOB_TUBE);
  end loop;
end;
/
GRANT execute on THREADS.RemovePipes to Threads_Admin;
--
-- Конец файла процедур.
