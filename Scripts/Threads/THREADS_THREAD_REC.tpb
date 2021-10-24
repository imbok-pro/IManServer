CREATE OR REPLACE TYPE BODY THREADS.THREAD_REC
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 29.01.2016
-- update 
--****************************************************************************
as

CONSTRUCTOR FUNCTION THREAD_REC 
return SELF AS RESULT
is
begin
  self.ID := null;
  self.JobID := null; 
  self.PipeName := null;
  self.BufSize := null;
  self.StateID := null;           
  self.State := null;          
  self.PrBar := null;						 
  self.Moment := null;           
  self.Mess := null;    
  self.ERR := null;     
  self.FlagDebug := null; 
  self.isImplicit := null;
  return;
end THREAD_REC;
end;
/
