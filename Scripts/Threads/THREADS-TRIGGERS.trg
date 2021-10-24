-- KarTHREADS triggers 
-- by Nikolai Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 18.10.2006
-- update 20.07.2007 24.12.2015 29.01.2016

-- ON LOGOFF ------------------------------------------------------------------
CREATE OR REPLACE TRIGGER THREADS.ON_LOGOFF
BEFORE LOGOFF on DATABASE
-- Триггер закрываем все потоки пользователя, при закрытии его сессии.
-- (THREADS-TRIGGERS.trg)
Call Threads.KillAll
/

-- таблица сообщений об ошибках
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER THREADS.ERRORS_LOG_bir
BEFORE INSERT ON THREADS.ERRORS_LOG
FOR EACH ROW
-- (THREADS-TRIGGERS.trg)
DECLARE
tmpVar NUMBER;
BEGIN
   IF ReplSession THEN return; END IF;
   SELECT THREADS.SEQ.NEXTVAL INTO tmpVar FROM dual;
   :NEW.ID := tmpVar+REPLICATION.NODE_ID;
END;
/

-- таблица демонов
--BEFORE_INSERT----------------------------------------------------------------
CREATE OR REPLACE TRIGGER THREADS.JOBS_bir
BEFORE INSERT ON THREADS.JOBS
FOR EACH ROW
-- (THREADS-TRIGGERS.trg)
DECLARE
tmpVar NUMBER;
BEGIN
   IF ReplSession THEN return; END IF;
   SELECT THREADS.SEQ.NEXTVAL INTO tmpVar FROM dual;
   :NEW.ID := tmpVar+REPLICATION.NODE_ID;
END;
/

-- ON_STARTUP ----------------------------------------------------------------
--CREATE OR REPLACE TRIGGER THREADS.ON_STARTUP
--AFTER STARTUP on DATABASE
---- (THREADS-TRIGGERS.trg)
--DECLARE
--tmpVar NUMBER;
--begin
--tmpVar := dbms_pipe.create_pipe('STARTTHREAD');
--end;
--/