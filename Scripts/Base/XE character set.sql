-- Преобразование базы к однобайтовым символам русского языка.
conn / as sysdba
col parameter format a30
col value format a30

SELECT view_name FROM dba_views WHERE view_name LIKE '%NLS%';
SELECT * FROM v$nls_parameters;
SELECT * FROM NLS_DATABASE_PARAMETERS;

SHUTDOWN IMMEDIATE;
STARTUP RESTRICT;
ALTER SYSTEM SET JOB_QUEUE_PROCESSES=0;
ALTER SYSTEM SET AQ_TM_PROCESSES=0;

-- для английского
ALTER DATABASE CHARACTER SET WE8MSWIN1252;
-- для русского 
ALTER DATABASE CHARACTER SET CL8MSWIN1251;
-- если не сработает изменение параметров:
-- для английского
ALTER DATABASE CHARACTER SET INTERNAL_USE WE8MSWIN1252;
-- для русского 
ALTER DATABASE CHARACTER SET INTERNAL_USE CL8MSWIN1251;
SHUTDOWN IMMEDIATE;
STARTUP; 
SELECT * FROM v$nls_parameters;

