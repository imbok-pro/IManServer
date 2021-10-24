CREATE OR REPLACE TYPE BODY SP.TIMAN_PAR_REC
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 20.08.2010
-- update 03.11.2010 09.04.2013 27.10.2014
--****************************************************************************
as

CONSTRUCTOR FUNCTION TIMAN_PAR_REC 
return SELF AS RESULT
is
begin
  self.NAME := null;
  self.T := null;
  self.E := null;
  self.N := null;
  self.D := null;
  self.S := null;
  self.X := null;
  self.Y := null;
  self.R_ONLY := 0;
  self.OBJECT_INDEX := null;
  return;
end TIMAN_PAR_REC;
 
CONSTRUCTOR FUNCTION TIMAN_PAR_REC(pName in VARCHAR2,pVal in SP.TVALUE, 
                                   oIndex IN NUMBER DEFAULT null)
return SELF AS RESULT
is
begin
  self.NAME := pName;
  self.T := pVal.T;
  self.E := pVal.E;
  self.N := pVal.N;
  self.D := pVal.D;
  self.S := pVal.S;
  self.X := pVal.X;
  self.Y := pVal.Y;
  self.R_ONLY := pVal.R_ONLY;
  self.OBJECT_INDEX := oIndex;
  return;
end TIMAN_PAR_REC;

MEMBER PROCEDURE Assign(self in out SP.TIMAN_PAR_REC,
                        pName in VARCHAR2,
                        pVal in SP.TVALUE, 
                        oIndex IN NUMBER DEFAULT null)
is
begin
  self.NAME := pName;
  self.T := pVal.T;
  self.E := pVal.E;
  self.N := pVal.N;
  self.D := pVal.D;
  self.S := pVal.S;
  self.X := pVal.X;
  self.Y := pVal.Y;
  self.R_ONLY := pVal.R_ONLY;
  self.OBJECT_INDEX := oIndex;
end Assign;
end;
/
