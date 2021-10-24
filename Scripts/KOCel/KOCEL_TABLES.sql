-- KOCEL tables
-- create 17.04.2009
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 27.04.2009 06.02.2010 15.02.2010 19.01.2015 08.07.2015 02.03.2020
--*****************************************************************************

-- ������.
-------------------------------------------------------------------------------
CREATE TABLE KOCEL.SHEETS( 
  R NUMBER(6) not null,
	C NUMBER(3) not null,
	N FLOAT(49),
  D DATE,
	S VARCHAR2(4000),
	F VARCHAR2(4000),
	SHEET VARCHAR2(255)not null,
	BOOK VARCHAR2(255)not null,
  Fmt NUMBER default 0 not null,
	
	CONSTRAINT PK_SHEETS PRIMARY KEY (R,C,SHEET,BOOK),
	CONSTRAINT CK_SHEETS CHECK ((R>=0)and(C between 0 and 256))
);

CREATE UNIQUE INDEX KOCEL.SHEETS ON KOCEL.SHEETS(R,C,upper(SHEET),upper(BOOK));
CREATE INDEX KOCEL.SHEETS_S 
  ON KOCEL.SHEETS(upper(BOOK), upper(SHEET), C, TRIM(S));

-- � ���������� ��� ������� ������������ � �������������, � ������ ����� ��������� �� �������������� ���� � �������. ��� ���� ��� � ������� ������������ � ������ ��������. ��������� ��������� ���������� ����� � �������. ��� �������� ������� ��� ���� ���������� ����� ������� ������ ��� ��������� ����������.
-- �������� ������ ��� ����.

COMMENT ON TABLE KOCEL.SHEETS
  IS '������ ������ � ����. ������ R=0 � C=0 ������������ ������.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.SHEETS.R
  IS '��� ������. ���� ��� ����� "0", � ���� ������� ������ "0", �� ��������� ���� �������� ������ ������� � � ������.';  
COMMENT ON COLUMN KOCEL.SHEETS.C
  IS '������� ������. ���� ������� ������ "0", � ���� ��� ������ "0", �� ��������� ���� �������� ������ ���� � ��� ������.';  
COMMENT ON COLUMN KOCEL.SHEETS.N
  IS '���� ��� ������ ��������, �� �����, ����� ����.';  
COMMENT ON COLUMN KOCEL.SHEETS.D
  IS '���� ��� ����, �� ����, ����� ����.';  
COMMENT ON COLUMN KOCEL.SHEETS.S
  IS '���� ��� ������ ������, �� ������, ����� ����.';  
COMMENT ON COLUMN KOCEL.SHEETS.F
  IS '������ �������, ���� ������� ���, �� null.';  
COMMENT ON COLUMN KOCEL.SHEETS.SHEET
  IS '��� �����.';  
COMMENT ON COLUMN KOCEL.SHEETS.BOOK
  IS '��� �����.';  
COMMENT ON COLUMN KOCEL.SHEETS.Fmt
  IS '������������� ������� � ������ ��������.';  

-- � ������� ������ �������� ����.
GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.SHEETS to public;

-- ��������� ������� ������, � ������� ���������� ������.
-- ����� ���������� �������, ������ �������������� � ���������� �������.
-------------------------------------------------------------------------------
CREATE GLOBAL TEMPORARY TABLE KOCEL.TEMP_SHEET( 
  R NUMBER(6),
	C NUMBER(3),
	N FLOAT(49),
  D DATE,
	S VARCHAR2(4000),
	F VARCHAR2(4000),
	SHEET VARCHAR2(255),
	NUM NUMBER(3),
	BOOK VARCHAR2(255),
  Fmt_NUM NUMBER(9)
) on commit delete rows;

COMMENT ON TABLE KOCEL.TEMP_SHEET
  IS '������ ������������� �����.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.R
  IS '��� ������. ���� ��� ����� "0", � ���� ������� ������ "0", �� ��������� ���� �������� ������ ������� � � ������.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.C
  IS '������� ������. ���� ��� ����� "0", � ���� ������� ������ "0", �� ��������� ���� �������� ������ ������� � � ������.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.N
  IS '���� ��� ������ ��������, �� �����, ����� ����.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.D
  IS '���� ��� ����, �� ����, ����� ����.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.S
  IS '���� ��� ������ ������, �� ������, ����� ����.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.F
  IS '������ �������, ���� ������� ���, �� null.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.SHEET
  IS '��� �����. ���� ���� ���� ����, �� ��� �������� �����. ��� ��������� � ���� "F".';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.NUM
  IS '���������� ����� ������� ����� ����� �������.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.BOOK
  IS '��� �����.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.Fmt_Num
  IS '����� ������� � ����� �� �������.';  
    
GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.TEMP_SHEET to public;

-- ��������� ������� ��������, � ������� ��� ������� ������������ ������������
-- ������� �������� � �� ��������������� � ���������� �������.
-------------------------------------------------------------------------------
CREATE GLOBAL TEMPORARY TABLE KOCEL.TEMP_SHEET_FORMATS( 
  Fmt_NUM NUMBER(9),
  Fmt NUMBER
) on commit delete rows;

COMMENT ON TABLE KOCEL.TEMP_SHEET_FORMATS
  IS '������� ������������� �����.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.TEMP_SHEET_FORMATS.Fmt_Num
  IS '����� ������� � ����� �� �������.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET_FORMATS.Fmt
  IS '������������� ������� � ������ ��������.';
    
GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.TEMP_SHEET_FORMATS to public;

-- ������� �������� ��� ��������� ��� ������ �����.
-------------------------------------------------------------------------------
CREATE TABLE KOCEL.BOOKS_R1C1( 
  R1C1 VARCHAR2(10) DEFAULT 'A1' NOT NULL ,
	BOOK VARCHAR2(255),
	CONSTRAINT PK_BOOKS_R1C1 PRIMARY KEY (BOOK),
  CONSTRAINT CK_BOOKS_R1C1 CHECK ((R1C1='R1C1')or(R1C1='A1'))
);

CREATE UNIQUE INDEX KOCEL.BOOKS_R1C1 ON KOCEL.BOOKS_R1C1(upper(BOOK));

COMMENT ON TABLE KOCEL.BOOKS_R1C1
  IS '���� ����� ����� ��� ��������� R1C1, �� ���� R1C1=''R1C1'', ����� ''A1''.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.BOOKS_R1C1.R1C1
  IS '���� ����� ����� ��� ��������� R1C1, �� ''R1C1'', ����� ''A1''.';  
COMMENT ON COLUMN KOCEL.BOOKS_R1C1.BOOK
  IS '��� ����� ������.';  

GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.BOOKS_R1C1 to public;


-- ������� ������������ ������ � �����.
-------------------------------------------------------------------------------
CREATE TABLE KOCEL.SHEETS_ORDER( 
  NUM NUMBER(3) not null,
	SHEET VARCHAR2(255)not null,
	BOOK VARCHAR2(255)not null,
	
	CONSTRAINT PK_SHEETS_ORDER PRIMARY KEY (NUM,SHEET,BOOK),
	CONSTRAINT CK_SHEETS_ORDER CHECK (NUM between 1 and 256)
);

CREATE UNIQUE INDEX KOCEL.SHEETS_ORDER 
  ON KOCEL.SHEETS_ORDER(NUM,upper(SHEET),upper(BOOK));

COMMENT ON TABLE KOCEL.SHEETS_ORDER
  IS '������ � ������� ������������ ������ � ������.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.SHEETS_ORDER.NUM
  IS '���������� ����� ����� �������.';  
COMMENT ON COLUMN KOCEL.SHEETS_ORDER.SHEET IS '��� �����.';  
COMMENT ON COLUMN KOCEL.SHEETS_ORDER.BOOK  IS '��� �����.';  

-- � ������� ������ �������� ����.
GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.SHEETS_ORDER to public;

-- ������������� ������� ������ � ������.
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW KOCEL.V_BOOKS (BOOK, SHEET, SHEET_NUM)
as
select * from (select b.BOOK,b.SHEET,b.NUM SHEET_NUM from KOCEL.SHEETS_ORDER b 
order  by book, sheet_num)
WITH READ ONLY;

COMMENT ON TABLE KOCEL.V_BOOKS
  IS '������������� ������ � ������� ������������ ������ � ������.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.V_BOOKS.SHEET_NUM
  IS '���������� ����� ����� �������.';  
COMMENT ON COLUMN KOCEL.V_BOOKS.SHEET  IS '��� �����.';  
COMMENT ON COLUMN KOCEL.V_BOOKS.BOOK IS '��� �����.';  

GRANT SELECT ON KOCEL.V_BOOKS TO public;


-- ������������� ������.
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW KOCEL.V_SHEETS
(RID, T, R, C, N, D, S, F, SHEET_NUM, SHEET, BOOK, Fmt) 
as
select rowidtochar(s.rowid) RID,
  case 
	  when s.D is not null then 'D'
	  when (s.D is null) and (s.N is not null) then 'N'
	else 'S'
	end T,
  s.R,s.C,s.N,s.D,s.S,s.F,
  nvl((select distinct NUM from KOCEL.SHEETS_ORDER
         where upper(s.SHEET)=upper(SHEET)
           and upper(s.BOOK)=upper(BOOK)),1000) SHEET_NUM,
  s.SHEET,s.BOOK,s.Fmt 
  from KOCEL.SHEETS s
  where s.R > 0
    and s.C > 0
    and s.SHEET is not null
  order by BOOK, SHEET_NUM, SHEET; 
    
COMMENT ON TABLE KOCEL.V_SHEETS
  IS '������ ������ �����.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.V_SHEETS.RID
  IS 'ROWID ������ � ���� ������.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.T
  IS '��� ������: ''N''-�����, ''D''-����, ''S''- ������.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.R
  IS '��� ������.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.C
  IS '������� ������.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.N
  IS '���� ��� ������ ��������, �� �����, ����� ����.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.D
  IS '���� ��� ����, �� ����, ����� ����.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.S
  IS '���� ��� ������ ������, �� ������, ����� ����.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.F
  IS '������ �������, ���� ������� ���, �� null.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.SHEET_NUM
  IS '���������� ����� ����� � �����.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.SHEET
  IS '��� �����.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.BOOK
  IS '��� �����.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.Fmt
  IS '������������� �������.';  
	
GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.V_SHEETS to public; 
 
-- ������������� �������.
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW KOCEL.V_COLUMNS
(RID,C,W,SHEET,BOOK,Fmt) 
as
select rowidtochar(rowid) RID,C,N W,SHEET,BOOK,Fmt 
  from KOCEL.SHEETS
  where R = 0
    and C > 0
    and SHEET is not null;
    
COMMENT ON TABLE KOCEL.V_COLUMNS
  IS '������ � ������� ������� ������ ����.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.V_COLUMNS.RID
  IS 'ROWID ������ � ���� ������.';  
COMMENT ON COLUMN KOCEL.V_COLUMNS.C
  IS '����� �������.';  
COMMENT ON COLUMN KOCEL.V_COLUMNS.W
  IS '������ �������.';  
COMMENT ON COLUMN KOCEL.V_COLUMNS.SHEET
  IS '��� �����.';  
COMMENT ON COLUMN KOCEL.V_COLUMNS.BOOK
  IS '��� �����.';  
COMMENT ON COLUMN KOCEL.V_COLUMNS.Fmt
  IS '������������� �������.';  
   
GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.V_COLUMNS to public; 

-- ������������� �����.
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW KOCEL.V_ROWS
(RID,R,H,SHEET,BOOK,Fmt) 
as
select rowidtochar(rowid) RID,R,N H,SHEET,BOOK,Fmt 
  from KOCEL.SHEETS
  where R > 0
    and C = 0
    and SHEET is not null;    
    
COMMENT ON TABLE KOCEL.V_ROWS
  IS '������ � ������� ������� ������ ����.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.V_ROWS.RID
  IS 'ROWID ������ � ���� ������.';  
COMMENT ON COLUMN KOCEL.V_ROWS.R
  IS '����� ����.';  
COMMENT ON COLUMN KOCEL.V_ROWS.H
  IS '������ ����.';  
COMMENT ON COLUMN KOCEL.V_ROWS.SHEET
  IS '��� �����.';  
COMMENT ON COLUMN KOCEL.V_ROWS.BOOK
  IS '��� �����.';  
COMMENT ON COLUMN KOCEL.V_ROWS.Fmt
  IS '������������� �������.';  
	
GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.V_ROWS to public;
 
-- ������� ����������� �����.
-------------------------------------------------------------------------------
CREATE TABLE KOCEL.MERGED_CELLS( 
  L NUMBER(3) not null,
  T NUMBER(6) not null,
  R NUMBER(3) not null,
  B NUMBER(6) not null,
	SHEET VARCHAR2(255)not null,
	BOOK VARCHAR2(255)not null,
	
	CONSTRAINT PK_MERGED_CELLS PRIMARY KEY (L,T,SHEET,BOOK),
	CONSTRAINT CK_MERGED_CELLS CHECK (   (L between 1 and 256)
                                    and(T > 0)
                                    and(R between 1 and 256)
                                    and(B > 0))
);

CREATE UNIQUE INDEX KOCEL.MERGED_CELLS 
  ON KOCEL.MERGED_CELLS(L,T,upper(SHEET),upper(BOOK));

COMMENT ON TABLE KOCEL.MERGED_CELLS
  IS '�������� ����������� ����� � ����� �����. ��� �������������� ���������� ������������ �������������, ��� ����������� ��������� ��������� ����������.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.MERGED_CELLS.L
  IS '����� ������� ������.';  
COMMENT ON COLUMN KOCEL.MERGED_CELLS.T
  IS '������� ��� ������.';  
COMMENT ON COLUMN KOCEL.MERGED_CELLS.R
  IS '������ ������� ������.';  
COMMENT ON COLUMN KOCEL.MERGED_CELLS.B
  IS '������ ��� ������.';  
COMMENT ON COLUMN KOCEL.MERGED_CELLS.SHEET
  IS '��� �����.';  
COMMENT ON COLUMN KOCEL.MERGED_CELLS.BOOK
  IS '��� �����.';  

--GRANT SELECT on KOCEL.MERGED_CELLS to public;

-- ������������� ����������� �����.
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW KOCEL.V_MERGED_CELLS( 
  L,T,R,B,SHEET,BOOK)
as
  select * from KOCEL.MERGED_CELLS;

COMMENT ON TABLE KOCEL.V_MERGED_CELLS
  IS '�������� ����������� ����� � ����� �����.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.V_MERGED_CELLS.L
  IS '����� ������� ������.';  
COMMENT ON COLUMN KOCEL.V_MERGED_CELLS.T
  IS '������� ��� ������.';  
COMMENT ON COLUMN KOCEL.V_MERGED_CELLS.R
  IS '������ ������� ������.';  
COMMENT ON COLUMN KOCEL.V_MERGED_CELLS.B
  IS '������ ��� ������.';  
COMMENT ON COLUMN KOCEL.V_MERGED_CELLS.SHEET
  IS '��� �����.';  
COMMENT ON COLUMN KOCEL.V_MERGED_CELLS.BOOK
  IS '��� �����.';  

GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.V_MERGED_CELLS to public;


-- ��������� ��������.
-------------------------------------------------------------------------------
CREATE TABLE KOCEL.Pars( 
  BatName VARCHAR2(255) not null,
	ParName VARCHAR2(255)not null,
	ParValue VARCHAR2(255),
  CONSTRAINT PK_PARS PRIMARY KEY (BatName,ParName)
);

CREATE UNIQUE INDEX KOCEL.Pars
  ON KOCEL.Pars(upper(BatName),upper(ParName));

COMMENT ON TABLE KOCEL.Pars
  IS '��������� ������� ����� ������������ �����, ���������� � ������ �������.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.Pars.BatName  IS '��� ��������� �������.';  
COMMENT ON COLUMN KOCEL.Pars.ParName  IS '��� ���������.';  
COMMENT ON COLUMN KOCEL.Pars.ParValue  IS '��������.';  

-- � ������� ������ �������� ����.
GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.Pars to public;


-- ��������� ������ � ����.
-------------------------------------------------------------------------------
CREATE TABLE KOCEL.SHEET_PARS( 
	PAR_NAME VARCHAR2(90)not null,
  N FLOAT(49),
  D DATE,
	S VARCHAR2(4000),
	SHEET VARCHAR2(255),
	BOOK VARCHAR2(255)not null,
	
	CONSTRAINT PK_SHEET_PARS PRIMARY KEY (PAR_NAME,SHEET,BOOK)
);

CREATE UNIQUE INDEX KOCEL.SHEET_PARS
  ON KOCEL.SHEET_PARS(upper(PAR_NAME),upper(SHEET),upper(BOOK));

COMMENT ON TABLE KOCEL.SHEET_PARS
  IS '��������� ������ � ������ ������ ������ � ����.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.SHEET_PARS.PAR_NAME  IS '��� ���������.';  
COMMENT ON COLUMN KOCEL.SHEET_PARS.N  
  IS '���� ��� ������ ��������, �� �����, ����� ����.';  
COMMENT ON COLUMN KOCEL.SHEET_PARS.D  
  IS '���� ��� ������ ����, �� ����, ����� ����.';  
COMMENT ON COLUMN KOCEL.SHEET_PARS.S  
  IS '���� ��� ������ ������, �� ������, ����� ����.';  
COMMENT ON COLUMN KOCEL.SHEET_PARS.SHEET 
  IS '��� �����. ���� "*", �� ��� ��������� ��� ���� �����.';  
COMMENT ON COLUMN KOCEL.SHEET_PARS.BOOK  IS '��� �����.';  

-- � ������� ������ �������� ����.
--GRANT SELECT on KOCEL.SHEET_PARS to public;

-- ������������� ���������� ������ � ����.
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW KOCEL.V_SHEET_PARS( 
	PAR_NAME,
  T, N, D, S,
	SHEET, BOOK)
as
	select PAR_NAME,
  case 
	  when D is not null then 'D'
	  when (D is null) and (N is not null) then 'N'
	else 'S'
	end T,
  N,D,S,
  case SHEET when '*' then null else SHEET end SHEET,
  BOOK 
  from KOCEL.SHEET_PARS
  order by BOOK,SHEET,PAR_NAME; 

COMMENT ON TABLE KOCEL.V_SHEET_PARS
  IS '��������� ������ � ������ ������ ������ � ����.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.V_SHEET_PARS.PAR_NAME  IS '��� ���������.';  
COMMENT ON COLUMN KOCEL.V_SHEET_PARS.T  
  IS '��� ������: ''N''-�����, ''D''-����, ''S''- ������.';  
COMMENT ON COLUMN KOCEL.V_SHEET_PARS.N  
  IS '���� ��� ������ ��������, �� �����, ����� ����.';  
COMMENT ON COLUMN KOCEL.V_SHEET_PARS.D  
  IS '���� ��� ������ ����, �� ����, ����� ����.';  
COMMENT ON COLUMN KOCEL.V_SHEET_PARS.S  
  IS '���� ��� ������ ������, �� ������, ����� ����.';  
COMMENT ON COLUMN KOCEL.V_SHEET_PARS.SHEET 
  IS '��� �����. ���� ��� ����, �� ��� ��������� ��� ���� �����.';  
COMMENT ON COLUMN KOCEL.V_SHEET_PARS.BOOK  IS '��� �����.';  

-- � ������� ������ �������� ����.
GRANT SELECT,INSERT,UPDATE on KOCEL.V_SHEET_PARS to public;
  
-- ������� ��������.
-------------------------------------------------------------------------------
CREATE TABLE KOCEL.FORMATS( 
  Fmt NUMBER,
  Font_Name VARCHAR2(90),
  Font_Size20 NUMBER(9),
  Font_Color NUMBER(9),
  Font_Style NUMBER(2),
  Font_Underline NUMBER(1),
  Font_Family NUMBER(3),
  Font_CharSet NUMBER(3),
  Left_Style NUMBER(2),
  Left_Color NUMBER(9),
  Right_Style NUMBER(2),
  Right_Color NUMBER(9),
  Top_Style NUMBER(2),
  Top_Color NUMBER(9),
  Bottom_Style NUMBER(2),
  Bottom_Color NUMBER(9),
  Diagonal NUMBER(1),
  Diagonal_Style NUMBER(2),
  Diagonal_Color NUMBER(9),
  Format_String VARCHAR2(128),
  Fill_Pattern NUMBER(2),
  Fill_FgColor NUMBER(9),
  Fill_BgColor NUMBER(9),
  H_Alignment NUMBER(1),
  V_Alignment NUMBER(1),
  E_Locked NUMBER(1),
  E_Hidden NUMBER(1),
  Parent_Fmt NUMBER(9),
  Wrap_Text  NUMBER(1),
  Shrink_To_Fit NUMBER(1),
  Text_Rotation NUMBER(3),
  Text_Indent NUMBER(3),
	CONSTRAINT PK_FOPMATS PRIMARY KEY (Fmt)
);

CREATE UNIQUE INDEX KOCEL.FORMATS ON KOCEL.FORMATS(
  upper(Font_Name), Font_Size20, Font_Color, Font_Style,
  Font_Underline, Font_Family, Font_CharSet, Left_Style, Left_Color,
  Right_Style, Right_Color, Top_Style, Top_Color, Bottom_Style,
  Bottom_Color, Diagonal, Diagonal_Style, Diagonal_Color, Format_String,
  Fill_Pattern, Fill_FgColor, Fill_BgColor, H_Alignment, V_Alignment,
  E_Locked, E_Hidden, Parent_Fmt, Wrap_Text, Shrink_To_Fit,
  Text_Rotation,Text_Indent);

COMMENT ON TABLE KOCEL.FORMATS
  IS '������ ������� ��� �������� ���� ����.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.FORMATS.Fmt  IS '������������� �������. ���� ������������� ����� "0", �� ��� ������ �� ���������.';  
COMMENT ON COLUMN KOCEL.FORMATS.Font_Name IS 'Name of the font, like Arial or Times New Roman.';
COMMENT ON COLUMN KOCEL.FORMATS.Font_Size20 IS 'Height of the font (in units of 1/20th of a point). A Font_Size20=200 means 10 points';
COMMENT ON COLUMN KOCEL.FORMATS.Font_Color IS 'Index on the color palett'; 
COMMENT ON COLUMN KOCEL.FORMATS.Font_Style IS 'Style of the font, such as bold or italics.';
COMMENT ON COLUMN KOCEL.FORMATS.Font_Underline IS 'Underline type'; 
COMMENT ON COLUMN KOCEL.FORMATS.Font_Family IS 'Font family, (see Windows API LOGFONT structure)'; 
COMMENT ON COLUMN KOCEL.FORMATS.Font_CharSet IS 'Character set. (see Windows API LOGFONT structure)';
COMMENT ON COLUMN KOCEL.FORMATS.Left_Style IS 'Cell borders, Left_Style.';
COMMENT ON COLUMN KOCEL.FORMATS.Left_Color IS 'Cell borders, Left_Color.';
COMMENT ON COLUMN KOCEL.FORMATS.Right_Style IS 'Cell borders, Right_Style.';
COMMENT ON COLUMN KOCEL.FORMATS.Right_Color IS 'Cell borders, Right_Color.';
COMMENT ON COLUMN KOCEL.FORMATS.Top_Style IS 'Cell borders, Top_Style.';
COMMENT ON COLUMN KOCEL.FORMATS.Top_Color IS 'Cell borders, Top_Color.';
COMMENT ON COLUMN KOCEL.FORMATS.Bottom_Style IS 'Cell borders, Bottom_Style.';
COMMENT ON COLUMN KOCEL.FORMATS.Bottom_Color IS 'Cell borders, Bottom_Color.';
COMMENT ON COLUMN KOCEL.FORMATS.Diagonal IS 'Cell borders, Diagonal.';
COMMENT ON COLUMN KOCEL.FORMATS.Diagonal_Style IS 'Cell borders, Diagonal_Style.';
COMMENT ON COLUMN KOCEL.FORMATS.Diagonal_Color IS 'Cell borders, Diagonal_Color.';
COMMENT ON COLUMN KOCEL.FORMATS.Format_String IS ' Format string. (For example, "yyyy-mm-dd" for a DATE format, or "#.00" for a NUMERIC 2 DECIMAL format) This format string is the same you use in Excel unde "Custom" format when formatting a cell, and it is documented in Excel documentation.';
COMMENT ON COLUMN KOCEL.FORMATS.Fill_Pattern IS 'Fill pattern  for the background of a cell';
COMMENT ON COLUMN KOCEL.FORMATS.Fill_FgColor IS 'Color for the foreground of the pattern. It is used when the pattern is solid, but not when it is automatic'; 
COMMENT ON COLUMN KOCEL.FORMATS.Fill_BgColor IS 'Color for the background of the pattern.  If the pattern is solid it has no effect, but it is used when pattern is automatic.';
COMMENT ON COLUMN KOCEL.FORMATS.H_Alignment IS 'Horizontal alignment on the cell.';
COMMENT ON COLUMN KOCEL.FORMATS.V_Alignment IS 'Vertical alignment on the cell.';
COMMENT ON COLUMN KOCEL.FORMATS.E_Locked IS 'Cell or Row or Column is locked.'; 
COMMENT ON COLUMN KOCEL.FORMATS.E_Hidden IS 'Cell or Row or Column is hidden.'; 
COMMENT ON COLUMN KOCEL.FORMATS.Parent_Fmt IS 'Parent style. Not currently supported.';
COMMENT ON COLUMN KOCEL.FORMATS.Wrap_Text IS 'Wrap cell text.';  
COMMENT ON COLUMN KOCEL.FORMATS.Shrink_To_Fit IS 'Shrink text to fit the cell.';
COMMENT ON COLUMN KOCEL.FORMATS.Text_Rotation IS 'Text Rotation in degrees. 0 -  90 is up, 91 - 180 is down,  255 is vertical.';
COMMENT ON COLUMN KOCEL.FORMATS.Text_Indent IS 'Indent value.(in characters).'; 

GRANT SELECT on KOCEL.FORMATS to public;

