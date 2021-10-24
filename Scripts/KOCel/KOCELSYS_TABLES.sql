-- KOCELSYS  tables
-- create 14.05.2010
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 
CREATE TABLE KOCELSYS.SCRIPTS( 
  SCRIPT NUMBER not null,
	ScriptSession NUMBER not null,
	
	CONSTRAINT PK_SHEETS PRIMARY KEY (SCRIPT)
);

COMMENT ON TABLE KOCELSYS.SCRIPTS
  IS 'Перечень запущенных скриптов.';
  
COMMENT ON COLUMN KOCELSYS.SCRIPTS.SCRIPT
  IS 'Идентификатор скрипта.';  
COMMENT ON COLUMN KOCELSYS.SCRIPTS.ScriptSession
  IS 'Сессия скрипта.';  

