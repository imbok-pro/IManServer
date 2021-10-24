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
/* Таблица дат.*/
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
/* Таблица чисел.*/
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
/* Таблица строк.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF VARCHAR2(4000)
                   ');
END;
/
GRANT execute on KOCEL.TSTRINGS to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE KOCEL.TVALUE as OBJECT (
/* Универсальное значение ячейки данных.*/
/* KOCEL.TYPES.sql*/
/* Номер ряда.*/
R NUMBER(6),
/* Номер колонки.*/
C NUMBER(3),
/* Поле для числового значения.*/
N FLOAT(49),
/* Поле для значения типа дата.*/
D DATE,
/* Поле для значения типа строка.*/
S VARCHAR2(4000),
/* Поле для формулы.*/
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
/* Ряд данных. Данный объект предназначен для работы с таблицами состоящих
   не более чем из 25 колонок.*/
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
/* Ряд строк. Данный объект предназначен для работы с таблицами состоящих
   не более чем из 25 колонок.*/
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
/* Таблица рядов.*/
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
/* Таблица рядов строк.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF KOCEL.TSROW
                   ');
END;
/
GRANT execute on KOCEL.TSCELLS to public;

-------------------------------------------------------------------------------
CREATE or REPLACE TYPE KOCEL.TTableDef 
AS OBJECT (
/* Объект, описывающий поле таблицы базы данных.*/
/* KOCEL.TYPES.sql*/
/* Имя поля.*/
ColName VARCHAR2(40),
/* Имя типа данных для данного поля.*/
ColTypeName VARCHAR2(30),
/* Типа данных для данного поля.*/
ColType NUMBER(9),
/* Размер данных для данного поля.*/
ColLength NUMBER(9),
/* Точность.*/
ColPrecision NUMBER(9),
/* Масштаб.*/
ColScale NUMBER(9)
);
/
GRANT execute on KOCEL.TTableDef to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TTableDefs 
/* Таблица, содержащая структуру таблицы базы данных.*/
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
/* Таблица, содержащая описания форматов ячеек.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF KOCEL.TFORMAT
                   ');
END;
/
GRANT execute on KOCEL.TFormats to public;

-------------------------------------------------------------------------------
CREATE or REPLACE TYPE KOCEL.TCELL_DATA 
AS OBJECT (
/* Объект, содержащий полные данные ячейки книги.*/
/* KOCEL.TYPES.sql*/
/* ROWID в виде строки.*/
  RID VARCHAR2(36),
/* Тип данных. "N"-число, "D"- дата, "S"- строка.*/
  T CHAR(1),
/* Номер ряда.*/
  R NUMBER(6),
/* Номер строки.*/
	C NUMBER(3),
/* Числовое значение.*/
	N FLOAT(49),
/* Значение типа дата.*/
  D DATE,
/* Значение типа строка.*/
	S VARCHAR2(4000),
/* Формула.*/
	F VARCHAR2(4000),
/* Порядковый номер листа.*/
  SHEET_NUM NUMBER(3),
/* Имя листа.*/
  SHEET VARCHAR2(255),
/* Имя книги.*/
  BOOK VARCHAR2(255),
/* Номер формата.*/
	Fmt NUMBER,
  CONSTRUCTOR FUNCTION TCELL_DATA return SELF AS RESULT
);
/
GRANT execute on KOCEL.TCELL_DATA to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TCELL_DATAS 
/* Таблица, содержащая полные данные ячеек книги.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF KOCEL.TCELL_DATA
                   ');
END;
/
GRANT execute on KOCEL.TCELL_DATAS to public;

-------------------------------------------------------------------------------
CREATE or REPLACE TYPE KOCEL.TCOLUMN_DATA 
AS OBJECT (
/* Объект, содержащий данные описания колоноки для листа книги.*/
/* KOCEL.TYPES.sql*/
/* ROWID в виде строки.*/
  RID VARCHAR2(36),
/* Номер колонки.*/
	C NUMBER(3),
/* Ширина колонки.*/
	W FLOAT(49),
/* Порядковый номер листа в книге.*/
  SHEET_NUM NUMBER(3),
/* Имя листа.*/
  SHEET VARCHAR2(255),
/* Имя книги.*/
  BOOK VARCHAR2(255),
/* Номер формата.*/
	Fmt NUMBER,
  CONSTRUCTOR FUNCTION TCOLUMN_DATA return SELF AS RESULT
);
/
GRANT execute on KOCEL.TCOLUMN_DATA to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TCOLUMN_DATAS 
/* Таблица, содержащая полные данные описания колонки для листа книги.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF KOCEL.TCOLUMN_DATA
                   ');
END;
/
GRANT execute on KOCEL.TCOLUMN_DATAS to public;

-------------------------------------------------------------------------------
CREATE or REPLACE TYPE KOCEL.TROW_DATA 
AS OBJECT (
/* Объект, содержащий данные описания ряда для листа книги.*/
/* KOCEL.TYPES.sql*/
/* ROWID в виде строки.*/
  RID VARCHAR2(36),
/* Номер ряда.*/
  R NUMBER(6),
/* Высота ряда.*/
	H FLOAT(49),
/* Порядковый номер листа в книге.*/
  SHEET_NUM NUMBER(3),
/* Имя листа в книге.*/
  SHEET VARCHAR2(255),
/* Имя книги.*/
  BOOK VARCHAR2(255),
/* Номер формата.*/
	Fmt NUMBER,
  CONSTRUCTOR FUNCTION TROW_DATA return SELF AS RESULT
);
/
GRANT execute on KOCEL.TROW_DATA to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TROW_DATAS 
/* Таблица, содержащая полные данные описания ряда для листа книги.*/
/* KOCEL.TYPES.sql*/
IS TABLE OF KOCEL.TROW_DATA
                   ');
END;
/
GRANT execute on KOCEL.TROW_DATAS to public;

-------------------------------------------------------------------------------
CREATE or REPLACE TYPE KOCEL.TMCELL_DATA 
AS OBJECT (
/* Объект, содержащий данные описания объеденённой ячееки на листе книги.*/
/* KOCEL.TYPES.sql*/
/* Левая колонка, с которой начинается объеденённая ячейка.*/
  L NUMBER(3),
/* Верхний ряд, с которого начинается объеденённая ячейка.*/
  T NUMBER(6),
/* Правая колонка, на которой заканчивается объеденённая ячейка.*/
  R NUMBER(3),
/* Нижний ряд, на котором заканчивается объеденённая ячейка.*/
  B NUMBER(6),
/* Порядковый номер листа в книге.*/
  SHEET_NUM NUMBER(3),
/* Имя листа.*/
  SHEET VARCHAR2(255),
/* Имя книги.*/
  BOOK VARCHAR2(255),
  CONSTRUCTOR FUNCTION TMCELL_DATA return SELF AS RESULT
);
/
GRANT execute on KOCEL.TMCELL_DATA to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TMCELL_DATAS 
/* Таблица, содержащая данные описания объединённых ячеек на листе книги.*/
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
/* Объект, содержащий параметры листа книги.*/
/* KOCEL.TYPES.sql*/
/* Имя параметра.*/
  PAR_NAME VARCHAR2(90),
/* Тип данных. "N"-число, "D"- дата, "S"- строка.*/
  T CHAR(1),
/* Числовое значение.*/
	N FLOAT(49),
/* Значение типа дата.*/
  D DATE,
/* Значение типа строка.*/
	S VARCHAR2(4000),
/* Порядковый номер листа в книге.*/
  SHEET_NUM NUMBER(3),
/* Имя листа.*/
  SHEET VARCHAR2(255),
/* Имя книги.*/
  BOOK VARCHAR2(255),
  CONSTRUCTOR FUNCTION TSHEET_PAR return SELF AS RESULT
);
/
GRANT execute on KOCEL.TSHEET_PAR to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TSHEET_PARS 
/* Таблица, содержащая параметры листа книги.*/
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
/* Объект, содержащий порядковый номер листа в книге.*/
/* KOCEL.TYPES.sql*/
/* Порядковый номер листа.*/
  SHEET_NUM NUMBER(3),
/* Имя листа.*/
  SHEET VARCHAR2(255),
  CONSTRUCTOR FUNCTION TSHEET_NUM return SELF AS RESULT
);
/
GRANT execute on KOCEL.TSHEET_NUM to public;

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE KOCEL.TSHEET_NUMS
/* Таблица, содержащая порядок листов в книге.*/
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
