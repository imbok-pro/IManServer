-- Скрипт настройки 12с
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 15.01.2019
-- update 16.01.2019 17.04.2021
--*****************************************************************************

create pfile from spfile;
ALTER SYSTEM SET open_cursors = 1000 SCOPE=SPFILE; 
ALTER SYSTEM SET optimizer_mode = "CHOOSE" SCOPE=SPFILE; 
ALTER SYSTEM SET os_authent_prefix = "OPS$" SCOPE=SPFILE; 
ALTER SYSTEM SET plsql_code_type = "NATIVE" SCOPE=SPFILE; 
ALTER SYSTEM SET remote_os_authent = FALSE SCOPE=SPFILE;
ALTER SYSTEM SET smtp_out_server = '' SCOPE=SPFILE; 
ALTER SYSTEM SET star_transformation_enabled = "TRUE" SCOPE=SPFILE; 
-- Перезапустите базу!!!
-- Добавить SQLNET.ALLOWED_LOGON_VERSION=8 в sqlnet.ora!!!!