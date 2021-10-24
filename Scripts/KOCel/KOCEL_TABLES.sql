-- KOCEL tables
-- create 17.04.2009
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 27.04.2009 06.02.2010 15.02.2010 19.01.2015 08.07.2015 02.03.2020
--*****************************************************************************

-- Данные.
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

-- В дальнейшем эта таблица превратиться в представление, а ячейки будут ссылаться на идентификаторы ряда и колонки. При этом ряд и колонка превратяться в уровни иерархии. Изменятся процедуры добавления рядов и колонок. При удалении колонки или ряда необходимо вести историю ссылок для поддержки репликации.
-- Добавить группы для книг.

COMMENT ON TABLE KOCEL.SHEETS
  IS 'Данные листов и книг. Ячейка R=0 и C=0 присутствует всегда.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.SHEETS.R
  IS 'Ряд данных. Если ряд равен "0", а поле колонка больше "0", то остальные поля содержат ширину колонки и её формат.';  
COMMENT ON COLUMN KOCEL.SHEETS.C
  IS 'Колонка данных. Если колонка равена "0", а поле ряд больше "0", то остальные поля содержат ширину ряда и его формат.';  
COMMENT ON COLUMN KOCEL.SHEETS.N
  IS 'Если тип ячейки числовой, то число, иначе нулл.';  
COMMENT ON COLUMN KOCEL.SHEETS.D
  IS 'Если тип дата, то дата, иначе нулл.';  
COMMENT ON COLUMN KOCEL.SHEETS.S
  IS 'Если тип ячейки строка, то строка, иначе нулл.';  
COMMENT ON COLUMN KOCEL.SHEETS.F
  IS 'Строка формулы, если формулы нет, то null.';  
COMMENT ON COLUMN KOCEL.SHEETS.SHEET
  IS 'Имя листа.';  
COMMENT ON COLUMN KOCEL.SHEETS.BOOK
  IS 'Имя книги.';  
COMMENT ON COLUMN KOCEL.SHEETS.Fmt
  IS 'Идентификатор формата в талице форматов.';  

-- В сетевой версии добавить роли.
GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.SHEETS to public;

-- Временная таблица данных, в которую происходит импорт.
-- После завершения импорта, данные переписывается в постоянную таблицу.
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
  IS 'Данные импортируемой книги.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.R
  IS 'Ряд данных. Если ряд равен "0", а поле колонка больше "0", то остальные поля содержат ширину колонки и её формат.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.C
  IS 'Колонка данных. Если ряд равен "0", а поле колонка больше "0", то остальные поля содержат ширину колонки и её формат.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.N
  IS 'Если тип ячейки числовой, то число, иначе нулл.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.D
  IS 'Если тип дата, то дата, иначе нулл.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.S
  IS 'Если тип ячейки строка, то строка, иначе нулл.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.F
  IS 'Строка формулы, если формулы нет, то null.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.SHEET
  IS 'Имя листа. Если поле лист нулл, то это параметр книги. Имя параметра в поле "F".';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.NUM
  IS 'Порядковый номер позиции листа слева направо.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.BOOK
  IS 'Имя книги.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET.Fmt_Num
  IS 'Номер формата в книге на клиенте.';  
    
GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.TEMP_SHEET to public;

-- Временная таблица форматов, в которую при импорте записывается соответствие
-- номеров форматов и их идентификаторов в постоянной таблице.
-------------------------------------------------------------------------------
CREATE GLOBAL TEMPORARY TABLE KOCEL.TEMP_SHEET_FORMATS( 
  Fmt_NUM NUMBER(9),
  Fmt NUMBER
) on commit delete rows;

COMMENT ON TABLE KOCEL.TEMP_SHEET_FORMATS
  IS 'Форматы импортируемой книги.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.TEMP_SHEET_FORMATS.Fmt_Num
  IS 'Номер формата в книге на клиенте.';  
COMMENT ON COLUMN KOCEL.TEMP_SHEET_FORMATS.Fmt
  IS 'Идентификатор формата в талице форматов.';
    
GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.TEMP_SHEET_FORMATS to public;

-- Таблица содержит тип адресации для каждой книги.
-------------------------------------------------------------------------------
CREATE TABLE KOCEL.BOOKS_R1C1( 
  R1C1 VARCHAR2(10) DEFAULT 'A1' NOT NULL ,
	BOOK VARCHAR2(255),
	CONSTRAINT PK_BOOKS_R1C1 PRIMARY KEY (BOOK),
  CONSTRAINT CK_BOOKS_R1C1 CHECK ((R1C1='R1C1')or(R1C1='A1'))
);

CREATE UNIQUE INDEX KOCEL.BOOKS_R1C1 ON KOCEL.BOOKS_R1C1(upper(BOOK));

COMMENT ON TABLE KOCEL.BOOKS_R1C1
  IS 'Если книга имеет тип адресации R1C1, то поле R1C1=''R1C1'', иначе ''A1''.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.BOOKS_R1C1.R1C1
  IS 'Если книга имеет тип адресации R1C1, то ''R1C1'', иначе ''A1''.';  
COMMENT ON COLUMN KOCEL.BOOKS_R1C1.BOOK
  IS 'Имя книги данных.';  

GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.BOOKS_R1C1 to public;


-- Порядок расположения листов в книге.
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
  IS 'Данные о порядке расположения листов в книгах.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.SHEETS_ORDER.NUM
  IS 'Порядковый номер слева направо.';  
COMMENT ON COLUMN KOCEL.SHEETS_ORDER.SHEET IS 'Имя листа.';  
COMMENT ON COLUMN KOCEL.SHEETS_ORDER.BOOK  IS 'Имя книги.';  

-- В сетевой версии добавить роли.
GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.SHEETS_ORDER to public;

-- Представление порядка листов в книгах.
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW KOCEL.V_BOOKS (BOOK, SHEET, SHEET_NUM)
as
select * from (select b.BOOK,b.SHEET,b.NUM SHEET_NUM from KOCEL.SHEETS_ORDER b 
order  by book, sheet_num)
WITH READ ONLY;

COMMENT ON TABLE KOCEL.V_BOOKS
  IS 'Упорядоченные данные о порядке расположения листов в книгах.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.V_BOOKS.SHEET_NUM
  IS 'Порядковый номер слева направо.';  
COMMENT ON COLUMN KOCEL.V_BOOKS.SHEET  IS 'Имя листа.';  
COMMENT ON COLUMN KOCEL.V_BOOKS.BOOK IS 'Имя книги.';  

GRANT SELECT ON KOCEL.V_BOOKS TO public;


-- Представление данных.
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
  IS 'Данные листов книги.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.V_SHEETS.RID
  IS 'ROWID записи в виде строки.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.T
  IS 'Тип данных: ''N''-число, ''D''-дата, ''S''- строка.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.R
  IS 'Ряд данных.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.C
  IS 'Колонка данных.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.N
  IS 'Если тип ячейки числовой, то число, иначе нулл.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.D
  IS 'Если тип дата, то дата, иначе нулл.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.S
  IS 'Если тип ячейки строка, то строка, иначе нулл.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.F
  IS 'Строка формулы, если формулы нет, то null.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.SHEET_NUM
  IS 'Порядковый номер листа в книге.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.SHEET
  IS 'Имя листа.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.BOOK
  IS 'Имя книги.';  
COMMENT ON COLUMN KOCEL.V_SHEETS.Fmt
  IS 'Идентификатор формата.';  
	
GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.V_SHEETS to public; 
 
-- Представление колонок.
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
  IS 'Ширины и форматы колонок листов книг.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.V_COLUMNS.RID
  IS 'ROWID записи в виде строки.';  
COMMENT ON COLUMN KOCEL.V_COLUMNS.C
  IS 'Номер колонки.';  
COMMENT ON COLUMN KOCEL.V_COLUMNS.W
  IS 'Ширина колонки.';  
COMMENT ON COLUMN KOCEL.V_COLUMNS.SHEET
  IS 'Имя листа.';  
COMMENT ON COLUMN KOCEL.V_COLUMNS.BOOK
  IS 'Имя книги.';  
COMMENT ON COLUMN KOCEL.V_COLUMNS.Fmt
  IS 'Идентификатор формата.';  
   
GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.V_COLUMNS to public; 

-- Представление рядов.
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
  IS 'Ширины и форматы колонок листов книг.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.V_ROWS.RID
  IS 'ROWID записи в виде строки.';  
COMMENT ON COLUMN KOCEL.V_ROWS.R
  IS 'Номер ряда.';  
COMMENT ON COLUMN KOCEL.V_ROWS.H
  IS 'Высота ряда.';  
COMMENT ON COLUMN KOCEL.V_ROWS.SHEET
  IS 'Имя листа.';  
COMMENT ON COLUMN KOCEL.V_ROWS.BOOK
  IS 'Имя книги.';  
COMMENT ON COLUMN KOCEL.V_ROWS.Fmt
  IS 'Идентификатор формата.';  
	
GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.V_ROWS to public;
 
-- Таблица объединённых ячеек.
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
  IS 'Перечень объединённых ячеек в листе книги. При редактировании необходимо использовать представление, для объединения возможных вложенных диапазонов.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.MERGED_CELLS.L
  IS 'Левая колонка ячейки.';  
COMMENT ON COLUMN KOCEL.MERGED_CELLS.T
  IS 'Верхний ряд ячейки.';  
COMMENT ON COLUMN KOCEL.MERGED_CELLS.R
  IS 'Правая колонка ячейки.';  
COMMENT ON COLUMN KOCEL.MERGED_CELLS.B
  IS 'Нижний ряд ячейки.';  
COMMENT ON COLUMN KOCEL.MERGED_CELLS.SHEET
  IS 'Имя листа.';  
COMMENT ON COLUMN KOCEL.MERGED_CELLS.BOOK
  IS 'Имя книги.';  

--GRANT SELECT on KOCEL.MERGED_CELLS to public;

-- Представление объединённых ячеек.
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW KOCEL.V_MERGED_CELLS( 
  L,T,R,B,SHEET,BOOK)
as
  select * from KOCEL.MERGED_CELLS;

COMMENT ON TABLE KOCEL.V_MERGED_CELLS
  IS 'Перечень объединённых ячеек в листе книги.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.V_MERGED_CELLS.L
  IS 'Левая колонка ячейки.';  
COMMENT ON COLUMN KOCEL.V_MERGED_CELLS.T
  IS 'Верхний ряд ячейки.';  
COMMENT ON COLUMN KOCEL.V_MERGED_CELLS.R
  IS 'Правая колонка ячейки.';  
COMMENT ON COLUMN KOCEL.V_MERGED_CELLS.B
  IS 'Нижний ряд ячейки.';  
COMMENT ON COLUMN KOCEL.V_MERGED_CELLS.SHEET
  IS 'Имя листа.';  
COMMENT ON COLUMN KOCEL.V_MERGED_CELLS.BOOK
  IS 'Имя книги.';  

GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.V_MERGED_CELLS to public;


-- Параметры скриптов.
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
  IS 'Параметры которые могут использовать блоки, работающие в разных сессиях.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.Pars.BatName  IS 'Имя пакетного задания.';  
COMMENT ON COLUMN KOCEL.Pars.ParName  IS 'Имя параметра.';  
COMMENT ON COLUMN KOCEL.Pars.ParValue  IS 'Значение.';  

-- В сетевой версии добавить роли.
GRANT SELECT,UPDATE,DELETE,INSERT on KOCEL.Pars to public;


-- Параметры листов и книг.
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
  IS 'Параметры печати и прочие данные листов и книг.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.SHEET_PARS.PAR_NAME  IS 'Имя параметра.';  
COMMENT ON COLUMN KOCEL.SHEET_PARS.N  
  IS 'Если тип ячейки числовой, то число, иначе нулл.';  
COMMENT ON COLUMN KOCEL.SHEET_PARS.D  
  IS 'Если тип ячейки дата, то дата, иначе нулл.';  
COMMENT ON COLUMN KOCEL.SHEET_PARS.S  
  IS 'Если тип ячейки строка, то строка, иначе нулл.';  
COMMENT ON COLUMN KOCEL.SHEET_PARS.SHEET 
  IS 'Имя листа. Если "*", то это параметры для всей книги.';  
COMMENT ON COLUMN KOCEL.SHEET_PARS.BOOK  IS 'Имя книги.';  

-- В сетевой версии добавить роли.
--GRANT SELECT on KOCEL.SHEET_PARS to public;

-- Представление параметров листов и книг.
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
  IS 'Параметры печати и прочие данные листов и книг.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.V_SHEET_PARS.PAR_NAME  IS 'Имя параметра.';  
COMMENT ON COLUMN KOCEL.V_SHEET_PARS.T  
  IS 'Тип данных: ''N''-число, ''D''-дата, ''S''- строка.';  
COMMENT ON COLUMN KOCEL.V_SHEET_PARS.N  
  IS 'Если тип ячейки числовой, то число, иначе нулл.';  
COMMENT ON COLUMN KOCEL.V_SHEET_PARS.D  
  IS 'Если тип ячейки дата, то дата, иначе нулл.';  
COMMENT ON COLUMN KOCEL.V_SHEET_PARS.S  
  IS 'Если тип ячейки строка, то строка, иначе нулл.';  
COMMENT ON COLUMN KOCEL.V_SHEET_PARS.SHEET 
  IS 'Имя листа. Если имя нулл, то это параметры для всей книги.';  
COMMENT ON COLUMN KOCEL.V_SHEET_PARS.BOOK  IS 'Имя книги.';  

-- В сетевой версии добавить роли.
GRANT SELECT,INSERT,UPDATE on KOCEL.V_SHEET_PARS to public;
  
-- Таблица форматов.
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
  IS 'Единая таблица для форматов всех книг.(KOCEL_TABLES.sql)';
  
COMMENT ON COLUMN KOCEL.FORMATS.Fmt  IS 'Идентификатор формата. Если идентификатор равен "0", то это формат по умолчанию.';  
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

