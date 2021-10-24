--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
begin
 Threads.Exec.FlagDebug:=false ;
 -- имя трубы устанавливать при инициализации пакета SP.MACRO
 THREADS.EXEC.STARTTUBE:=G.DaemonPipe;
 o(to_.Str(Threads.Exec.FlagDebug));
end;

select * from v$JOBS;
select * from SYS.V_$DB_Pipes;

call SP.StartServers(1);
call SP.StopServers();

call o(to_char(Threads.Exec.StartNewThread));

select * from table (THREADS.EXEC.GET_THREADS());

call o(to_char(THreads.Exec.Proc(1,
'Declare'||
'  s varchar2(1000); '||
'Begin'||
' loop'||
' s:= THREADS.getSignal;'||
' d(s,''test Signal'');'||
' if s = ''abort'' then exit; end if;'||
' DBMS_LOCK.sleep(10);'||
' end loop;'||
'end;')));

call o(to_char(THREADS.EXEC.SETSIGNAL(1,'SP.IM.WORK_COMMAND_PAR_S')));

call o(to_char(THREADS.EXEC.SETSIGNAL(1,'abort')));

call o(Threads.Exec.Repair(1));
call o(Threads.Exec.StopThread(1));
