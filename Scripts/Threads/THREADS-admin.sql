begin
 o(THREADS.STARTserver('StartThread'));
end; 

select * from v$JOBS
;
select * from SYS.V_$DB_Pipes
;
select * from DBA_JOBS
;
select * from DBA_JOBS_RUNNING
;
--GRANT "THREADS_EXEC" TO "PROG";

call dbms_JOB.remove(144);

call o(dbms_pipe.remove_pipe('SIGNALPIPE_KTUBE_3'));

call stop_watch.reset();

call o(to_char(stop_watch.result));

call THREADS.STOPserver(586);

begin 
THREADS.StopServers;
end;

begin
o(THREADS.ExecProc('begin d(to_char(THREADS.JOBID),''привет''); end;',false));
end;
/

begin
o(THREADS.Exec.Proc(null,
'begin 
 d(to_char(THREADS.JOBID),''привет Exec'');
 sendState(100,''привет''); 
 end;'
 ,0,'Starting'));
end;
/
begin
o(THREADS.Exec.Proc(1,'begin d(to_char(THREADS.JOBID),''привет''); end;',0,'Starting'));
end;
/
begin
o(THREADS.state2string(THREADS.Exec.isReady(1)));
end;
/
begin
  o(THREADS.EXEC.REPAIR(2));
end;
/
select * from table (THREADS.EXEC.GET_THREADS());

begin
  o(THREADS.EXEC.StopThread(1));
end;
/

begin
o(dbms_pipe.create_pipe('StartThread'));
end;
/

;
begin
o(THREADS.ExecProc('error q',false));
end;
/


