-- Скрипт настройки имени базы для 12с
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 25.07.2017
-- update 27.07.2017 15.01.2019
--*****************************************************************************

ALTER SYSTEM SET SERVICE_NAMES = ora3  SCOPE=SPFILE;
ALTER DATABASE RENAME GLOBAL_NAME TO ora3;
ALTER SYSTEM SET db_domain='' SCOPE=SPFILE; 