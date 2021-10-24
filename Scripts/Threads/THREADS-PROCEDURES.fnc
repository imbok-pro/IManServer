-- KARBUILDER PROCEDURES & FUNCTIONS for calling inside threads
-- by Nikolai Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 11.11.2006
-- update 31.07.2007 11.08.2007 17.08.2007 21.08.2008 02.09.2007 04.11.2009
--        28.01.2009 21.04.2010 05.11.2010 04.01.2011 24.12.2015 28.12.2015
--        29.12.2015-31.12.2015 26.01.2016 28.01.2016-04.02.2016 26.02.2016
--        29.02.2016 22.12.2017
--
-- Процедуры, для использовании в теле потока.
--*****************************************************************************
--
-------------------------------------------------------------------------------
CREATE or REPLACE PROCEDURE THREADS.SendState(ProgressBarPos in NUMBER,
                                              Mess IN VARCHAR2)
-- Передает сообщение в основной поток о состоянии выполнения задания.
-- (THREADS-PROCEDURES.fnc)
AS
tmpVar PLS_INTEGER;
begin
if THREADS.JobID is Null then
  begin
    tmpVar := THREADS.ExecI.DebugThreadID; 
    THREADS.ExecI.Pars(tmpVar).State.PrBar:=ProgressBarPos;
	  THREADS.ExecI.Pars(tmpVar).State.Mess:=Mess;
	exception
	  when others then
	  	RAISE_APPLICATION_ERROR(-20044,
			  'Ошибка записи состояния '||Mess||' в режиме отладки! ');
	end;
else
  THREADS.ExecI.SendStateI(ProgressBarPos,Mess);
end if;
end;
/
GRANT EXECUTE on THREADS.SendState to PUBLIC;
--
-------------------------------------------------------------------------------
CREATE or REPLACE PROCEDURE THREADS.SendError(Err IN VARCHAR2)
-- Передает сообщение в основной поток об ошибке из потока.
-- (THREADS-PROCEDURES.fnc)
AS
begin
  if THREADS.JobID is Null then
    begin
      THREADS.ExecI.Pars(THREADS.ExecI.DebugThreadID).State.Err:=Err;
    exception
      when others then
        RAISE_APPLICATION_ERROR(-20044,
          'Ошибка записи ошибки '||Err||' в режиме отладки! ');
    end;
  else
    THREADS.ExecI.SendErrorI(Err);
  end if;
end;
/
GRANT EXECUTE on THREADS.SendError to PUBLIC;
--
-------------------------------------------------------------------------------
CREATE or REPLACE PROCEDURE THREADS.AbortThread
-- Прерывает выполнение потока и переводит его в состояние завершён.
-- (THREADS-PROCEDURES.fnc)
AS
begin
  if THREADS.JobID is Null then
    begin
      THREADS.ExecI.Pars(THREADS.ExecI.DebugThreadID).State.State:=-4;
      THREADS.ExecI.Pars(THREADS.ExecI.DebugThreadID).State.Mess:='Aborted';
    exception
      when others then
        RAISE_APPLICATION_ERROR(-20044,  
          'THREADS.AbortThread. Непредвиденная ошибка потока'
          ||THREADS.ExecI.DebugThreadID||' в режиме отладки! ');
    end;
  else
    RAISE_APPLICATION_ERROR(-20045,'AbortThread!');
  end if;
end;
/
GRANT EXECUTE on THREADS.AbortThread to PUBLIC;
--
-------------------------------------------------------------------------------
CREATE or REPLACE FUNCTION THREADS.GetSignal return VARCHAR2
-- Принимает сигнал из основного потока, если сигнала нет, то возвращает null.
-- (THREADS-PROCEDURES.fnc)
AS
begin
  if THREADS.JobID is Null then
    begin
      return THREADS.ExecI.Pars(THREADS.ExecI.DebugThreadID).DebugSignal;
    exception
      when others then
        RAISE_APPLICATION_ERROR(-20044,
          'Ошибка чтения сигнала в режиме отладки! ');
    end;
  else
    return THREADS.ExecI.GetSignal;
  end if;
end;
/
GRANT EXECUTE on THREADS.GetSignal to PUBLIC;
--
-------------------------------------------------------------------------------
CREATE or REPLACE FUNCTION THREADS.isDebug return BOOLEAN
-- Проверяет, выполняется ли вызывающая функция или процедура, в потоке,
-- работающим в отладочном режиме.
-- Для выяснения работает ли поток в режиме отладки из основной сессиии нужно
-- использовать описание потока (THREADS.Exec.get_Thread(ThreadID).FlagDebug).
-- (THREADS-PROCEDURES.fnc)
AS
begin
  return THREADS.JobID is Null;
end;
/
GRANT EXECUTE on THREADS.isDebug to PUBLIC;
--
-------------------------------------------------------------------------------
CREATE or REPLACE FUNCTION THREADS.State2String(st in THREADS.EXEC.TState) 
return VARCHAR2
-- Функция преобразует состояние потока в строку.
-- (THREADS-PROCEDURES.fnc)
AS
begin
  return 'state =>'||st.State||', prBar =>'||st.prBar||':'||st.Moment||
    ', Message=> '||st.Mess||', EM=>'||st.ERR;
end;
/
GRANT EXECUTE on THREADS.State2String to PUBLIC;
--
-------------------------------------------------------------------------------
CREATE or REPLACE FUNCTION THREADS.State2Name(state in NUMBER) 
return VARCHAR2
-- Функция преобразует "идентификатор состояния" потока в строку.
-- (THREADS-PROCEDURES.fnc)
AS
begin
  return  case state
    when  0 then 'Ready'
    when  1 then 'Busy'
    when  2 then 'ReceivingTable'
    when -1 then 'WaitingDaemon'
    when -2 then 'notInitiated'
    when -3 then 'Error'
    when -4 then 'Stoped'
    end;
end;
/
GRANT EXECUTE on THREADS.State2Name to PUBLIC;
--
-------------------------------------------------------------------------------
CREATE or REPLACE FUNCTION THREADS.Command2Name(command in NUMBER) 
return VARCHAR2
-- Функция преобразует команду потоку в строку.
-- (THREADS-PROCEDURES.fnc)
AS
begin
  return 
    case command
      when 1 then 'Receive array'
      when 2 then 'Execute function'
      when 3 then 'Execute procedure'
      when 4 then 'Exit thread'
      when 5 then 'Repair thread'
      when 6 then 'Receive table'
      when 7 then 'Execute procedure and receive table'
    else 'unknown'  
    end;
end;
/
GRANT EXECUTE on THREADS.Command2Name to PUBLIC;
    
-- Конец файла процедур.
