CREATE OR REPLACE TYPE BODY KOCEL.TVALUE
-- KOCEL.TVALUE Type body
-- create 17.04.2009
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 11.02.2010 17.08.2011 05.07.2016
--*****************************************************************************
as

-------------------------------------------------------------------------------
MEMBER PROCEDURE ClearData(self in out KOCEL.TVALUE)
is
begin
	self.N:=null;
	self.D:=null;
	self.S:=null;
	self.F:=null;
	self.R:=null;
	self.C:=null;
  return;
end ClearData;

-------------------------------------------------------------------------------
MEMBER FUNCTION T return VARCHAR2
is
begin
  case
	  when self.D is not null then return 'D';
	  when (self.D is null) and (self.N is not null) then return'N';
	else
	  return 'S';
	end case;
end T;

-------------------------------------------------------------------------------
MEMBER FUNCTION as_Str return VARCHAR2
is
begin
  case T
	  when 'N' then return to_char(self.N);
	  when 'D' then return to_char(self.D);
	  when 'S' then return self.S;
  end case;
end as_Str;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TValue return SELF AS RESULT
is
begin
	self.N:=null;
	self.D:=null;
	self.S:=null;
	self.F:=null;
	self.R:=null;
	self.C:=null;
  return;
end TValue;


-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TValue(CellValue in NUMBER) return SELF AS RESULT
is
begin
	self.N:=CellValue;
	self.D:=null;
	self.S:=null;
	self.F:=null;
	self.R:=null;
	self.C:=null;
  return;
end TValue;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TValue(CellValue in DATE) return SELF AS RESULT
is
begin
	self.N:=null;
	self.D:=CellValue;
	self.S:=null;
	self.F:=null;
	self.R:=null;
	self.C:=null;
  return;
end TValue;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TValue(CellValue in VARCHAR2) return SELF AS RESULT
is
begin
	self.N:=null;
	self.D:=null;
	self.S:=CellValue;
	self.F:=null;
	self.R:=null;
	self.C:=null;
  return;
end TValue;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TValue(N in NUMBER, D in DATE,S in VARCHAR2,
                            F in VARCHAR2 default null)
return SELF AS RESULT
is
begin
  case
	  when D is not null then
    	self.N:=null;
	    self.D:=D;
	    self.S:=null;
	    self.F:=F;
	  when (D is null) and (N is not null) then
    	self.N:=N;
	    self.D:=null;
	    self.S:=null;
	    self.F:=F;
	else
    	self.N:=null;
	    self.D:=null;
	    self.S:=S;
	    self.F:=F;
  end case;
	self.R:=null;
	self.C:=null;
  return;
end TValue;

-------------------------------------------------------------------------------
MAP MEMBER FUNCTION map_values(self in out KOCEL.TVALUE) return VARCHAR2
is
begin
  return T||self.as_Str;
end map_values;

end;
/
