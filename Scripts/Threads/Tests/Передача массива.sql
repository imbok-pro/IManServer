select * from v$JOBS;
select * from SYS.V_$DB_Pipes;

begin
 Threads.Exec.FlagDebug:=false ;
 o(to_.Str(Threads.Exec.FlagDebug));
end;

call o(to_char(Threads.Exec.StartNewThread));
select * from table (THREADS.EXEC.GET_THREADS());

declare
IDs ThArrs.TNums;
begin 
IDs(100):=50;
IDs(50):=10;
o(to_char(Threads.Exec.SetARR(1,'t',IDs)));
end;

declare
s ThArrs.TVChars;
begin 
for i in 1..1000
loop
s(i):='array1'||i;
--s(i):='массив'||i;
end loop;
--s(50):='QQ';
o(to_char(Threads.Exec.SetARR(1,'l',s)));
end;

declare
s ThArrs.Tnums;
begin 
for i in 1..1000
loop
s(i):=i;
end loop;
o(to_char(Threads.Exec.SetARR(1,'l',s)));
end;

select (ThIDS.nam('t')(100)) from dual; -- сделать функцию 

call o(to_char(THreads.Exec.Proc(1,
'd(to_char(ThArrs.num(''t'')(100)));
 THREADS.SendState(50, ThArrs.num(''l'')(50));')));

call o(to_char(THreads.Exec.Proc(1,
'd(to_char(ThArrs.num(''t'')(100)));
 THREADS.SendState(50, ThArrs.Vchar(''l'')(50));')));


call o(to_char(THreads.Exec.Proc(1,
'd(to_char(ThArrs.num(''t'')(100)));
 THREADS.SendState(50, ''Кису Любишь!'');')));
 
 
call o(to_char(THreads.Exec.Proc(1,'d(to_char(ThArrs.num(''t'')(100)));'
         ||'THREADS.SendState(50,''привет'');')));

				 
call o(to_char(THreads.Exec.Proc(1,'o(to_char(ThArrs.num(''t'')(100)));'
         ||'THREADS.SendError(''привет'');')));

call o(Threads.Exec.Repair(1));
call o(Threads.Exec.StopThread(1));


				 




