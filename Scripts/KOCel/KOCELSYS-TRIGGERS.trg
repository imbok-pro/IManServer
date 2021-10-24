-- KOCELSYS triggers 
-- create 17.04.2009
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 14.05.2009
--*****************************************************************************
CREATE OR REPLACE TRIGGER KOCELSYS.ON_LOGOFF
BEFORE LOGOFF ON DATABASE
begin
  KOCELSYS.ClearScriptTable;
end;
/
