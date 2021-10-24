CREATE OR REPLACE TYPE BODY KOCEL.TSROW
-- KOCEL TSROW
-- create 14.05.2009
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 15.08.2011
--*****************************************************************************
as

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TSRow return SELF AS RESULT
is
begin
	self.A:='';
	self.B:='';
	self.C:='';
	self.D:='';
	self.E:='';
	self.F:='';
	self.G:='';
	self.H:='';
	self.I:='';
	self.J:='';
	self.K:='';
	self.L:='';
	self.M:='';
	self.N:='';
	self.O:='';
	self.P:='';
	self.Q:='';
	self.R:='';
	self.S:='';
	self.U:='';
	self.V:='';
	self.W:='';
	self.X:='';
	self.Y:='';
	self.Z:='';
  return;
end TSRow;
-------------------------------------------------------------------------------
MEMBER PROCEDURE ClearData(self in out KOCEL.TSROW)
is
begin
	self.A:='';
	self.B:='';
	self.C:='';
	self.D:='';
	self.E:='';
	self.F:='';
	self.G:='';
	self.H:='';
	self.I:='';
	self.J:='';
	self.K:='';
	self.L:='';
	self.M:='';
	self.N:='';
	self.O:='';
	self.P:='';
	self.Q:='';
	self.R:='';
	self.S:='';
	self.U:='';
	self.V:='';
	self.W:='';
	self.X:='';
	self.Y:='';
	self.Z:='';
  return;
end ClearData;

end;
/
