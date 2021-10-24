-- SYS triggers 
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 20.08.2010
-- update 

-- on LOGON
-------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.ON_LOGON
AFTER LOGON ON DATABASE
-- SP-SYS.trg
Call SP.setSession
/

-- end of file
