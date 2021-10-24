
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
 THREADS.SendState(50, ''«агрузили данные'');')));

call o(to_char(THreads.Exec.Func(1,
'SP.MACRO_I.getPars',
'SP.WORK_COMMAND_PAR_S',
100,
'Q'
)));

select * from SP.WORK_COMMAND_PAR_S;

delete from SP.WORK_COMMAND_PAR_S;

call o(Threads.Exec.Repair(1));
call o(Threads.Exec.StopThread(1));
call o(Threads.Exec.KillThread(1));


call o(to_char(THreads.Exec.Func(1,
'PROG.testThread.ff()',
'PROG.NAMES',
100,
'Q'
)));

declare
st THREADS.EXEC.TSTATE;
id number;
begin
  id := 1 ; 
  st := THREADS.EXEC.ISREADY(id);
  o('thread=> '||id||', state =>'||THREADS.state2String(st));
end;
/


select * from PROG.NAMES;

CREATE GLOBAL TEMPORARY TABLE "PROG"."NAMES" 
   (	"NAME" VARCHAR2(4000 BYTE)
   ) ON COMMIT PRESERVE ROWS ;

create or replace package prog.testThread
is
function ff return SP.TSTRINGS pipelined;
end;
/
grant execute on prog.testThread to public;
grant all on PROG.NAMES to THREADS;

create or replace package body prog.testThread
is
function ff return SP.TSTRINGS pipelined
is
S varchar2(4000);
begin
for c in (select COMMENTS from SP.COMMANDS order by ID)
loop
pipe row(c.COMMENTS);
end loop;
end;
end;
/

select * from table(PROG.testThread.ff());
