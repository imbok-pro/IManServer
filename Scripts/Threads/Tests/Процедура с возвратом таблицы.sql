
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
begin
 Threads.Exec.FlagDebug:=false ;
 -- им€ трубы устанавливать при инициализации пакета SP.MACRO
 THREADS.EXEC.STARTTUBE:=G.DaemonPipe;
 o(to_.Str(Threads.Exec.FlagDebug));
end;

call o(SP.IM.SET_PARS('SysObjects.#Native Object'));
select * from SP.WORK_COMMAND_PAR_S;

select * from v$JOBS;
select * from SYS.V_$DB_Pipes;

call SP.StartServers(1);
call SP.StopServers();

call o(to_char(Threads.Exec.StartNewThread(1)));
--call o(to_char(Threads.Exec.StartNewThread));

select * from table (THREADS.EXEC.GET_THREADS());

call o(to_char(THreads.Exec.Proc(1,
'SP.setSession('''||S_User||''');
 THREADS.SendState(0, ''«агрузили параметры сессии'');')));


call o(to_char(THreads.Exec.Proc(1,
'd(SP.IM.SET_PARS(''SysObjects.#Native Object''),''test Function'');
 THREADS.SendState(50, ''«агрузили данные'');',
 'SP.WORK_COMMAND_PAR_S',
 100,
'ѕерегрузили данные')));

select * from SP.WORK_COMMAND_PAR_S;

delete from SP.WORK_COMMAND_PAR_S;
-- Ѕез commit будет взаимна€ блокировка.
commit;

call o(Threads.Exec.Repair(1));
call o(Threads.Exec.StopThread(1));
call o(Threads.Exec.KillThread(1));

