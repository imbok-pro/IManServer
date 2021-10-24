CREATE OR REPLACE TYPE BODY KOCEL.TROW
-- KOCEL TROW
-- create 14.05.2009
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 15.08.2011
--*****************************************************************************
as

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TRow return SELF AS RESULT
is
begin
	self.A:=KOCEL.TVALUE;
	self.B:=KOCEL.TVALUE;
	self.C:=KOCEL.TVALUE;
	self.D:=KOCEL.TVALUE;
	self.E:=KOCEL.TVALUE;
	self.F:=KOCEL.TVALUE;
	self.G:=KOCEL.TVALUE;
	self.H:=KOCEL.TVALUE;
	self.I:=KOCEL.TVALUE;
	self.J:=KOCEL.TVALUE;
	self.K:=KOCEL.TVALUE;
	self.L:=KOCEL.TVALUE;
	self.M:=KOCEL.TVALUE;
	self.N:=KOCEL.TVALUE;
	self.O:=KOCEL.TVALUE;
	self.P:=KOCEL.TVALUE;
	self.Q:=KOCEL.TVALUE;
	self.R:=KOCEL.TVALUE;
	self.S:=KOCEL.TVALUE;
	self.U:=KOCEL.TVALUE;
	self.V:=KOCEL.TVALUE;
	self.W:=KOCEL.TVALUE;
	self.X:=KOCEL.TVALUE;
	self.Y:=KOCEL.TVALUE;
	self.Z:=KOCEL.TVALUE;
  return;
end TRow;
-------------------------------------------------------------------------------
MEMBER PROCEDURE ClearData(self in out KOCEL.TROW)
is
begin
	self.A.ClearData;
	self.B.ClearData;
	self.C.ClearData;
	self.D.ClearData;
	self.E.ClearData;
	self.F.ClearData;
	self.G.ClearData;
	self.H.ClearData;
	self.I.ClearData;
	self.J.ClearData;
	self.K.ClearData;
	self.L.ClearData;
	self.M.ClearData;
	self.N.ClearData;
	self.O.ClearData;
	self.P.ClearData;
	self.Q.ClearData;
	self.R.ClearData;
	self.S.ClearData;
	self.U.ClearData;
	self.V.ClearData;
	self.W.ClearData;
	self.X.ClearData;
	self.Y.ClearData;
	self.Z.ClearData;
  return;
end ClearData;

end;
/
