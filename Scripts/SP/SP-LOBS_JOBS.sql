-- SP LOBS_JOBS
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 29.07.2021
-- update 
------------------------------------------------------------------------------- 
-- 1440 - количество минут в дне
--(SP.LOBS_JOBS.sql)
--Очистка и нормализация LOB
------------------------------------------------------------------------------- 
declare
  tmpVar NUMBER;
begin
  for c1 in (
    select * from DBA_JOBS 
      where WHAT like '%SP.LOBS_JOBS%'
            )
  loop
    dbms_job.remove(c1.job);
  end loop;     
end;
/
--
DECLARE
  X NUMBER;
BEGIN
  SYS.DBMS_JOB.SUBMIT
    (
      job        => X
     ,what       =>
'BEGIN d(''begin'', ''SP.LOBS_JOBS''); SP.setSession(''PROG''); SP.LOBS_FREE_UNUSED; commit;d(''end'', ''SP.LOBS_JOBS''); exception when others then d(SQLERRM, ''ERROR in SP.LOBS_JOBS'');END;'
     ,next_date  => sysdate +1/1440
     ,interval   => 'SYSDATE+60/1440 '
     ,no_parse   => FALSE
    );
END;
/

