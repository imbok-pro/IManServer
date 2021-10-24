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

call o(SP.IM.SET_PARS('SysObjects.#Native Object'));
select * from SP.WORK_COMMAND_PAR_S;

call o(to_char(THreads.Exec.setTable(1,
'SP.WORK_COMMAND_PAR_S')));

truncate table SP.WORK_COMMAND_PAR_S; 

call o(to_char(THreads.Exec.Func(1,
'SP.IM.WORK_COMMAND_PAR_S',
'SP.WORK_COMMAND_PAR_S',
100,
'Перегрузили данные'
)));

call o(Threads.Exec.Repair(1));
call o(Threads.Exec.StopThread(1));
