-- KOCEL Types
-- create 17.04.2009
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 11.02.2010 17.08.2011 28.08.2014 08.07.2015 05.07.2016
-- 
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TDATES 
/* ������� ���.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF DATE
                   ');
END;
/
GRANT execute on KOCEL.TDATES to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TNUMS 
/* ������� �����.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF NUMBER
                   ');
END;
/
GRANT execute on KOCEL.TNUMS to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TSTRINGS 
/* ������� �����.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF VARCHAR2(4000)
                   ');
END;
/
GRANT execute on KOCEL.TSTRINGS to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE KOCEL.TVALUE as OBJECT (
/* ������������� �������� ������ ������.*/
/* KOCEL.TYPES.sql*/
/* ����� ����.*/
R NUMBER(6),
/* ����� �������.*/
C NUMBER(3),
/* ���� ��� ��������� ��������.*/
N FLOAT(49),
/* ���� ��� �������� ���� ����.*/
D DATE,
/* ���� ��� �������� ���� ������.*/
S VARCHAR2(4000),
/* ���� ��� �������.*/
F VARCHAR2(4000),

MEMBER FUNCTION T return VARCHAR2,
MEMBER PROCEDURE ClearData(self in out KOCEL.TVALUE),
MEMBER FUNCTION as_Str return VARCHAR2,
CONSTRUCTOR FUNCTION TValue
return SELF AS RESULT,
CONSTRUCTOR FUNCTION TValue(CellValue in NUMBER)
return SELF AS RESULT,
CONSTRUCTOR FUNCTION TValue(CellValue in DATE)
return SELF AS RESULT,
CONSTRUCTOR FUNCTION TValue(CellValue in VARCHAR2)
return SELF AS RESULT,
CONSTRUCTOR FUNCTION TValue(N in NUMBER, D in DATE,S in VARCHAR2,
                            F in VARCHAR2 default null)
return SELF AS RESULT,
MAP MEMBER FUNCTION map_values(self in out KOCEL.TVALUE) return VARCHAR2
);
/
GRANT execute on KOCEL.TVALUE to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE KOCEL.TROW as OBJECT (
/* ��� ������. ������ ������ ������������ ��� ������ � ��������� ���������
   �� ����� ��� �� 25 �������.*/
/* KOCEL.TYPES.sql*/
A KOCEL.TVALUE,
B KOCEL.TVALUE,
C KOCEL.TVALUE,
D KOCEL.TVALUE,
E KOCEL.TVALUE,
F KOCEL.TVALUE,
G KOCEL.TVALUE,
H KOCEL.TVALUE,
I KOCEL.TVALUE,
J KOCEL.TVALUE,
K KOCEL.TVALUE,
L KOCEL.TVALUE,
M KOCEL.TVALUE,
N KOCEL.TVALUE,
O KOCEL.TVALUE,
P KOCEL.TVALUE,
Q KOCEL.TVALUE,
R KOCEL.TVALUE,
S KOCEL.TVALUE,
T KOCEL.TVALUE,
U KOCEL.TVALUE,
V KOCEL.TVALUE,
W KOCEL.TVALUE,
X KOCEL.TVALUE,
Y KOCEL.TVALUE,
Z KOCEL.TVALUE,
CONSTRUCTOR FUNCTION TRow
return SELF AS RESULT,
MEMBER PROCEDURE ClearData(self in out KOCEL.TROW)
);
/
GRANT execute on KOCEL.TROW to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE KOCEL.TSROW as OBJECT (
/* ��� �����. ������ ������ ������������ ��� ������ � ��������� ���������
   �� ����� ��� �� 25 �������.*/
/* KOCEL.TYPES.sql*/
A VARCHAR2(4000),
B VARCHAR2(4000),
C VARCHAR2(4000),
D VARCHAR2(4000),
E VARCHAR2(4000),
F VARCHAR2(4000),
G VARCHAR2(4000),
H VARCHAR2(4000),
I VARCHAR2(4000),
J VARCHAR2(4000),
K VARCHAR2(4000),
L VARCHAR2(4000),
M VARCHAR2(4000),
N VARCHAR2(4000),
O VARCHAR2(4000),
P VARCHAR2(4000),
Q VARCHAR2(4000),
R VARCHAR2(4000),
S VARCHAR2(4000),
T VARCHAR2(4000),
U VARCHAR2(4000),
V VARCHAR2(4000),
W VARCHAR2(4000),
X VARCHAR2(4000),
Y VARCHAR2(4000),
Z VARCHAR2(4000),
CONSTRUCTOR FUNCTION TSROW
return SELF AS RESULT,
MEMBER PROCEDURE ClearData(self in out KOCEL.TSROW)
);
/
GRANT execute on KOCEL.TSROW to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TCELLS 
/* ������� �����.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF KOCEL.TROW
                   ');
END;
/
GRANT execute on KOCEL.TCELLS to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TSCELLS 
/* ������� ����� �����.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF KOCEL.TSROW
                   ');
END;
/
GRANT execute on KOCEL.TSCELLS to public;

-------------------------------------------------------------------------------
CREATE or REPLACE TYPE KOCEL.TTableDef 
AS OBJECT (
/* ������, ����������� ���� ������� ���� ������.*/
/* KOCEL.TYPES.sql*/
/* ��� ����.*/
ColName VARCHAR2(40),
/* ��� ���� ������ ��� ������� ����.*/
ColTypeName VARCHAR2(30),
/* ���� ������ ��� ������� ����.*/
ColType NUMBER(9),
/* ������ ������ ��� ������� ����.*/
ColLength NUMBER(9),
/* ��������.*/
ColPrecision NUMBER(9),
/* �������.*/
ColScale NUMBER(9)
);
/
GRANT execute on KOCEL.TTableDef to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TTableDefs 
/* �������, ���������� ��������� ������� ���� ������.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF KOCEL.TTableDef
                   ');
END;
/
GRANT execute on KOCEL.TTableDefs to public;
 
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TFORMATS 
/* �������, ���������� �������� �������� �����.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF KOCEL.TFORMAT
                   ');
END;
/
GRANT execute on KOCEL.TFormats to public;

-------------------------------------------------------------------------------
CREATE or REPLACE TYPE KOCEL.TCELL_DATA 
AS OBJECT (
/* ������, ���������� ������ ������ ������ �����.*/
/* KOCEL.TYPES.sql*/
/* ROWID � ���� ������.*/
  RID VARCHAR2(36),
/* ��� ������. "N"-�����, "D"- ����, "S"- ������.*/
  T CHAR(1),
/* ����� ����.*/
  R NUMBER(6),
/* ����� ������.*/
	C NUMBER(3),
/* �������� ��������.*/
	N FLOAT(49),
/* �������� ���� ����.*/
  D DATE,
/* �������� ���� ������.*/
	S VARCHAR2(4000),
/* �������.*/
	F VARCHAR2(4000),
/* ���������� ����� �����.*/
  SHEET_NUM NUMBER(3),
/* ��� �����.*/
  SHEET VARCHAR2(255),
/* ��� �����.*/
  BOOK VARCHAR2(255),
/* ����� �������.*/
	Fmt NUMBER,
  CONSTRUCTOR FUNCTION TCELL_DATA return SELF AS RESULT
);
/
GRANT execute on KOCEL.TCELL_DATA to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TCELL_DATAS 
/* �������, ���������� ������ ������ ����� �����.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF KOCEL.TCELL_DATA
                   ');
END;
/
GRANT execute on KOCEL.TCELL_DATAS to public;

-------------------------------------------------------------------------------
CREATE or REPLACE TYPE KOCEL.TCOLUMN_DATA 
AS OBJECT (
/* ������, ���������� ������ �������� �������� ��� ����� �����.*/
/* KOCEL.TYPES.sql*/
/* ROWID � ���� ������.*/
  RID VARCHAR2(36),
/* ����� �������.*/
	C NUMBER(3),
/* ������ �������.*/
	W FLOAT(49),
/* ���������� ����� ����� � �����.*/
  SHEET_NUM NUMBER(3),
/* ��� �����.*/
  SHEET VARCHAR2(255),
/* ��� �����.*/
  BOOK VARCHAR2(255),
/* ����� �������.*/
	Fmt NUMBER,
  CONSTRUCTOR FUNCTION TCOLUMN_DATA return SELF AS RESULT
);
/
GRANT execute on KOCEL.TCOLUMN_DATA to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TCOLUMN_DATAS 
/* �������, ���������� ������ ������ �������� ������� ��� ����� �����.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF KOCEL.TCOLUMN_DATA
                   ');
END;
/
GRANT execute on KOCEL.TCOLUMN_DATAS to public;

-------------------------------------------------------------------------------
CREATE or REPLACE TYPE KOCEL.TROW_DATA 
AS OBJECT (
/* ������, ���������� ������ �������� ���� ��� ����� �����.*/
/* KOCEL.TYPES.sql*/
/* ROWID � ���� ������.*/
  RID VARCHAR2(36),
/* ����� ����.*/
  R NUMBER(6),
/* ������ ����.*/
	H FLOAT(49),
/* ���������� ����� ����� � �����.*/
  SHEET_NUM NUMBER(3),
/* ��� ����� � �����.*/
  SHEET VARCHAR2(255),
/* ��� �����.*/
  BOOK VARCHAR2(255),
/* ����� �������.*/
	Fmt NUMBER,
  CONSTRUCTOR FUNCTION TROW_DATA return SELF AS RESULT
);
/
GRANT execute on KOCEL.TROW_DATA to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TROW_DATAS 
/* �������, ���������� ������ ������ �������� ���� ��� ����� �����.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF KOCEL.TROW_DATA
                   ');
END;
/
GRANT execute on KOCEL.TROW_DATAS to public;

-------------------------------------------------------------------------------
CREATE or REPLACE TYPE KOCEL.TMCELL_DATA 
AS OBJECT (
/* ������, ���������� ������ �������� ����������� ������ �� ����� �����.*/
/* KOCEL.TYPES.sql*/
/* ����� �������, � ������� ���������� ����������� ������.*/
  L NUMBER(3),
/* ������� ���, � �������� ���������� ����������� ������.*/
  T NUMBER(6),
/* ������ �������, �� ������� ������������� ����������� ������.*/
  R NUMBER(3),
/* ������ ���, �� ������� ������������� ����������� ������.*/
  B NUMBER(6),
/* ���������� ����� ����� � �����.*/
  SHEET_NUM NUMBER(3),
/* ��� �����.*/
  SHEET VARCHAR2(255),
/* ��� �����.*/
  BOOK VARCHAR2(255),
  CONSTRUCTOR FUNCTION TMCELL_DATA return SELF AS RESULT
);
/
GRANT execute on KOCEL.TMCELL_DATA to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TMCELL_DATAS 
/* �������, ���������� ������ �������� ����������� ����� �� ����� �����.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF KOCEL.TMCELL_DATA
                   ');
END;
/
GRANT execute on KOCEL.TMCELL_DATAS to public;
--
-------------------------------------------------------------------------------
CREATE or REPLACE TYPE KOCEL.TSHEET_PAR 
AS OBJECT (
/* ������, ���������� ��������� ����� �����.*/
/* KOCEL.TYPES.sql*/
/* ��� ���������.*/
  PAR_NAME VARCHAR2(90),
/* ��� ������. "N"-�����, "D"- ����, "S"- ������.*/
  T CHAR(1),
/* �������� ��������.*/
	N FLOAT(49),
/* �������� ���� ����.*/
  D DATE,
/* �������� ���� ������.*/
	S VARCHAR2(4000),
/* ���������� ����� ����� � �����.*/
  SHEET_NUM NUMBER(3),
/* ��� �����.*/
  SHEET VARCHAR2(255),
/* ��� �����.*/
  BOOK VARCHAR2(255),
  CONSTRUCTOR FUNCTION TSHEET_PAR return SELF AS RESULT
);
/
GRANT execute on KOCEL.TSHEET_PAR to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TSHEET_PARS 
/* �������, ���������� ��������� ����� �����.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF KOCEL.TSHEET_PAR
                   ');
END;
/
GRANT execute on KOCEL.TSHEET_PARS to public;

-------------------------------------------------------------------------------
CREATE or REPLACE TYPE BODY KOCEL.TMCELL_DATA 
AS
CONSTRUCTOR FUNCTION TMCELL_DATA return SELF AS RESULT
is
begin 
  self.L:=null;
  self.T:=null;
	self.R:=null;
  self.B:=null;
  self.SHEET_NUM:=null;
  self.SHEET:=null;
  self.BOOK:=null;
  return;
end;  
END;
/

-------------------------------------------------------------------------------
CREATE or REPLACE TYPE BODY KOCEL.TSHEET_PAR 
AS
CONSTRUCTOR FUNCTION TSHEET_PAR return SELF AS RESULT
is
begin 
  self.PAR_NAME:=null;
  self.T:=null;
	self.N:=null;
  self.D:=null;
	self.S:=null;
  self.SHEET_NUM:=null;
  self.SHEET:=null;
  self.BOOK:=null;
  return;
end;  
END;
/

-------------------------------------------------------------------------------
CREATE or REPLACE TYPE BODY KOCEL.TCELL_DATA 
AS
CONSTRUCTOR FUNCTION TCELL_DATA return SELF AS RESULT
is
begin 
  self.RID:=null;
  self.T:=null;
  self.R:=null;
	self.C:=null;
	self.N:=null;
  self.D:=null;
	self.S:=null;
	self.F:=null;
  self.SHEET_NUM:=null;
  self.SHEET:=null;
  self.BOOK:=null;
	self.Fmt:=null;
  return;
end;  
END;
/

-------------------------------------------------------------------------------
CREATE or REPLACE TYPE BODY KOCEL.TCOLUMN_DATA 
AS
CONSTRUCTOR FUNCTION TCOLUMN_DATA return SELF AS RESULT
is
begin
  self.RID:=null;
	self.C:=null;
	self.W:=null;
  self.SHEET_NUM:=null;
  self.SHEET:=null;
  self.BOOK:=null;
	self.Fmt:=null;
  return;
end;  
END;
/

-------------------------------------------------------------------------------
CREATE or REPLACE TYPE BODY KOCEL.TROW_DATA 
AS
CONSTRUCTOR FUNCTION TROW_DATA return SELF AS RESULT
is
begin
  self.RID:=null;
	self.R:=null;
	self.H:=null;
  self.SHEET_NUM:=null;
  self.SHEET:=null;
  self.BOOK:=null;
	self.Fmt:=null;
  return;
end;  
END;
/

-------------------------------------------------------------------------------
CREATE or REPLACE TYPE KOCEL.TSHEET_NUM 
AS OBJECT (
/* ������, ���������� ���������� ����� ����� � �����.*/
/* KOCEL.TYPES.sql*/
/* ���������� ����� �����.*/
  SHEET_NUM NUMBER(3),
/* ��� �����.*/
  SHEET VARCHAR2(255),
  CONSTRUCTOR FUNCTION TSHEET_NUM return SELF AS RESULT
);
/
GRANT execute on KOCEL.TSHEET_NUM to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TSHEET_NUMS
/* �������, ���������� ������� ������ � �����.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF KOCEL.TSHEET_NUM
                   ');
END;
/
GRANT execute on KOCEL.TSHEET_NUMS to public;

-------------------------------------------------------------------------------
CREATE or REPLACE TYPE BODY KOCEL.TSHEET_NUM
AS
CONSTRUCTOR FUNCTION TSHEET_NUM return SELF AS RESULT
is
begin
  self.SHEET_NUM:=null;
  self.SHEET:=null;
  return;
end;  
END;
/

-- end of Types
