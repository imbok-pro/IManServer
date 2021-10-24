-- Скрипт настройки автоматического управления памятью для 12с
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 04.07.2017
-- update 16.01.2019
--*****************************************************************************

create pfile from spfile;
ALTER SYSTEM SET MEMORY_MAX_TARGET=14G SCOPE=SPFILE;
ALTER SYSTEM SET MEMORY_TARGET=11G SCOPE=SPFILE;
ALTER SYSTEM SET PGA_AGGREGATE_TARGET=0 SCOPE=SPFILE;
ALTER SYSTEM SET SGA_TARGET=0 SCOPE=SPFILE;
ALTER SYSTEM SET SGA_MAX_SIZE = 11g SCOPE = SPFILE;
ALTER SYSTEM SET PGA_Aggregate_LIMIT = 11g SCOPE = SPFILE;
-- Перезапустите базу!!!