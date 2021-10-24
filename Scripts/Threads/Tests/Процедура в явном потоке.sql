begin
  THREADS.EXEC.FlagDebug:= true;
end;
/

call o(to_.str(THREADS.EXEC.FlagDebug));

call o(THREADS.EXEC.STARTNEWTHREAD(1));

select * from table (THREADS.EXEC.GET_THREADS());

call o(THREADS.Exec.Proc(1,
                         'begin do(to_char(THREADS.JOBID),''привет''); end;',
                         0,
                         'Starting'));

declare
st THREADS.EXEC.TSTATE;
id number;
begin
  id := 1 ; 
  st := THREADS.EXEC.ISREADY(id);
  o('thread=> '||id||', state =>'||THREADS.state2String(st));
end;
/

call o(THREADS.EXEC.REPAIR(1));

call o(THREADS.EXEC.StopThread(1));


