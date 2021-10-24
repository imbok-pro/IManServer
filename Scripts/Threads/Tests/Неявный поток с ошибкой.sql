begin
  THREADS.EXEC.FlagDebug:= true;
end;
/

call o(to_.str(THREADS.EXEC.FlagDebug));

call o(THREADS.Exec.Proc(null,
                         'begin do(to_char(THREADS.JOBID),''привет''); end;',
                         0,
                         'Starting'));

declare
st THREADS.EXEC.TSTATE;
begin
  st := THREADS.EXEC.ISREADY(1);
  o('state =>'||st.State||', prBar =>'||st.prBar||':'||st.Moment||
    ', Message=> '||st.Mess||', EM=>'||st.ERR);
end;
/

call o(THREADS.EXEC.REPAIR(1));

call o(THREADS.EXEC.StopThread(1));

