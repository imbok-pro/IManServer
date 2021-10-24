-- Threads for ORACLE
-- by Nikolai Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 11.11.2006
-- update 29.01.2016  
--
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE THREADS.TNUMBERs IS TABLE of NUMBER;
GRANT EXECUTE ON THREADS.TNUMBERs to public;
CREATE OR REPLACE PUBLIC SYNONYM TNUMBERS for THREADS.TNUMBERs;
/
