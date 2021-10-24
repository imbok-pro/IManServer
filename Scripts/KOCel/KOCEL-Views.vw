-- KOCEL views
-- create 01.09.2009
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 13.02.2009
--*****************************************************************************

CREATE OR REPLACE Package KOCEL.CC
-- Пакет копирования комментариев полей таблиц в комментарии полей
-- представленийю
as
fT VARCHAR2(30);
tT VARCHAR2(30);
procedure C(fromColumn in VARCHAR2, toCol in VARCHAR2);
procedure all_av;
end;
/

CREATE or REPLACE Package Body KOCEL.CC
as
--
procedure C(fromColumn in VARCHAR2, toCol in VARCHAR2)
is
  tmp VARCHAR2(4000);
begin 
	select comments into tmp from ALL_COL_COMMENTS 
	  where (OWNER='KOCEL')
		  and (TABLE_NAME=fT)
			and (COLUMN_NAME=FromColumn);
  tmp:='COMMENT ON COLUMN BDR.'||tT||'.'||toCol||' IS '''||tmp||'''';		
  execute immediate (tmp);
end C;
--
procedure all_av 
is
 tmp VARCHAR2(4000);
begin
  for c in(
	select COLUMN_NAME,COMMENTS from ALL_COL_COMMENTS 
	  where (OWNER='KOCEL')
		  and (TABLE_NAME=fT))
	loop		
		tmp:='COMMENT ON COLUMN BDR.'||tT||'.'||C.COLUMN_NAME||
		' IS '''||C.COMMENTS||'''';
		begin		
      execute immediate (tmp);
		exception
		  when others then null;	
		end;	
  end loop;
end all_av; 
end CC;
/ 

CREATE OR REPLACE PUBLIC SYNONYM kcc for KOCEL.CC;

-------------------------------------------------------------------------------
declare
S VARCHAR2(32000);
begin
  s:='CREATE OR REPLACE VIEW KOCEL.V_in_VALS(';
  for i in 1..26
  loop
    S:=S||' '||chr(ascii('A')+i-1);
    if i!=26 then S:=S||','; end if;
  end loop;
  S:=S||')AS select * from table (KOCEL.CELL.inVals)';
--  O(S);
  EXECUTE IMMEDIATE(S);
end;
/
COMMENT ON TABLE KOCEL.V_in_VALS 
  is 'Представление входного листа книги для пакета BDR.CELL. Поля это колонки от "A" до "Z"".';
GRANT SELECT ON KOCEL.V_in_VALS to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW KOCEL.V_BOOK_SHEETS
(SHEET_NUM, SHEET)
AS 
select cast(SHEET_NUM as NUMBER(3)),SHEET from table(KOCEL.BOOK.Sheets);

COMMENT ON TABLE KOCEL.V_BOOK_SHEETS 
  is 'Обёртка для результата табличной функции KOCEL.BOOK.Sheets. Перед запросом к этому представлению необходимо установить активную книгу через вызов KOCEL.BOOK.PrepareData(<book Name>.)';
COMMENT ON COLUMN KOCEL.V_BOOK_SHEETS.SHEET_NUM 
is 'Порядковый номер листа в книге слева направо.';
COMMENT ON COLUMN KOCEL.V_BOOK_SHEETS.SHEET is 'Имя листа книги.';
GRANT SELECT ON KOCEL.V_BOOK_SHEETS to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW KOCEL.V_BOOK_ROWS
(RID, R, H, SHEET_NUM, SHEET, BOOK,	Fmt)
AS 
select RID, cast( R as NUMBER(6))R, cast(H as FLOAT(49))H,
  cast(SHEET_NUM as NUMBER(3)), SHEET, BOOK, cast(Fmt as NUMBER(6))
  from table(KOCEL.BOOK.Row_s);

COMMENT ON TABLE KOCEL.V_BOOK_ROWS 
  is 'Обёртка для результата табличной функции KOCEL.BOOK.Row_s. Перед запросом к этому представлению необходимо установить активную книгу через вызов KOCEL.BOOK.PrepareData(<book Name>). Это представление не содержит ряды, у которых формат задан по умолчанию и высота подбирается автоматически.';
COMMENT ON COLUMN KOCEL.V_BOOK_ROWS.RID 
is 'Символьное представление ROWID записи в таблице KOCEL.SHEETS.';
COMMENT ON COLUMN KOCEL.V_BOOK_ROWS.R is 'Номер ряда.';
COMMENT ON COLUMN KOCEL.V_BOOK_ROWS.H is 'Высота ряда. Если значение равно "0", то автоподбор высоты.';
COMMENT ON COLUMN KOCEL.V_BOOK_ROWS.SHEET_NUM 
is 'Порядковый номер листа в книге слева направо.';
COMMENT ON COLUMN KOCEL.V_BOOK_ROWS.SHEET is 'Имя листа книги.';
COMMENT ON COLUMN KOCEL.V_BOOK_ROWS.BOOK is 'Имя книги.';
COMMENT ON COLUMN KOCEL.V_BOOK_ROWS.Fmt is 'Номер формата в книге. Соответствует полю "Fmt" в представлении V_BOOK_FORMATS. Если номер формата равен "0", то используется формат по умолчанию.';
GRANT SELECT ON KOCEL.V_BOOK_ROWS to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW KOCEL.V_BOOK_COLUMNS
(RID, C, W, SHEET_NUM, SHEET, BOOK,	Fmt)
AS 
select RID, cast( C as NUMBER(3))C, cast(W as FLOAT(49))W,
  cast(SHEET_NUM as NUMBER(3)), SHEET, BOOK, cast(Fmt as NUMBER(6))Fmt
  from table(KOCEL.BOOK.Column_s);

COMMENT ON TABLE KOCEL.V_BOOK_COLUMNS
  is 'Обёртка для результата табличной функции KOCEL.BOOK.Columns_s. Перед запросом к этому представлению необходимо установить активную книгу через вызов KOCEL.BOOK.PrepareData(<book Name>).';
COMMENT ON COLUMN KOCEL.V_BOOK_COLUMNS.RID 
is 'Символьное представление ROWID записи в таблице KOCEL.SHEETS.';
COMMENT ON COLUMN KOCEL.V_BOOK_COLUMNS.C is 'Номер колонки.';
COMMENT ON COLUMN KOCEL.V_BOOK_COLUMNS.W is 'Ширина колонки колонки.';
COMMENT ON COLUMN KOCEL.V_BOOK_COLUMNS.SHEET_NUM 
is 'Порядковый номер листа в книге слева направо.';
COMMENT ON COLUMN KOCEL.V_BOOK_COLUMNS.SHEET is 'Имя листа книги.';
COMMENT ON COLUMN KOCEL.V_BOOK_COLUMNS.BOOK is 'Имя книги.';
COMMENT ON COLUMN KOCEL.V_BOOK_COLUMNS.Fmt is 'Номер формата в книге. Соответствует полю "Fmt" в представлении V_BOOK_FORMATS.';
GRANT SELECT ON KOCEL.V_BOOK_COLUMNS to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW KOCEL.V_BOOK_CELLS
(RID, T, R, C, N, D, S, F, SHEET_NUM, SHEET, BOOK,	Fmt)
AS 
select RID, T, cast( R as NUMBER(6)), cast( C as NUMBER(3)),
  cast(N as FLOAT(49)), D, S, F,
  cast(SHEET_NUM as NUMBER(3)), SHEET, BOOK, cast(Fmt as NUMBER(6))Fmt
  from table(KOCEL.BOOK.CELLS);

COMMENT ON TABLE KOCEL.V_BOOK_CELLS
  is 'Обёртка для результата табличной функции KOCEL.BOOK.Cells. Перед запросом к этому представлению необходимо установить активную книгу через вызов KOCEL.BOOK.PrepareData(<book Name>).';
COMMENT ON COLUMN KOCEL.V_BOOK_CELLS.RID 
is 'Символьное представление ROWID записи в таблице KOCEL.SHEETS.';
COMMENT ON COLUMN KOCEL.V_BOOK_CELLS.T is 'Тип значения.';
COMMENT ON COLUMN KOCEL.V_BOOK_CELLS.R is 'Номер ряда.';
COMMENT ON COLUMN KOCEL.V_BOOK_CELLS.C is 'Номер колонки.';
COMMENT ON COLUMN KOCEL.V_BOOK_CELLS.N is 'Значение.';
COMMENT ON COLUMN KOCEL.V_BOOK_CELLS.D is 'Значение.';
COMMENT ON COLUMN KOCEL.V_BOOK_CELLS.S is 'Значение.';
COMMENT ON COLUMN KOCEL.V_BOOK_CELLS.F is 'Формула.';
COMMENT ON COLUMN KOCEL.V_BOOK_CELLS.SHEET_NUM 
is 'Порядковый номер листа в книге слева направо.';
COMMENT ON COLUMN KOCEL.V_BOOK_CELLS.SHEET is 'Имя листа книги.';
COMMENT ON COLUMN KOCEL.V_BOOK_CELLS.BOOK is 'Имя книги.';
COMMENT ON COLUMN KOCEL.V_BOOK_CELLS.Fmt is 'Номер формата в книге. Соответствует полю "Fmt" в представлении V_BOOK_FORMATS.';
GRANT SELECT ON KOCEL.V_BOOK_CELLS to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW KOCEL.V_BOOK_MCELLS
(L, T, R, B, SHEET_NUM, SHEET, BOOK)
AS 
select cast( L as NUMBER(3)), cast( T as NUMBER(6)),
  cast( R as NUMBER(3)), cast( B as NUMBER(6)),
  cast(SHEET_NUM as NUMBER(3)), SHEET, BOOK
  from table(KOCEL.BOOK.MCELLS);

COMMENT ON TABLE KOCEL.V_BOOK_MCELLS
  is 'Обёртка для результата табличной функции KOCEL.BOOK.MCells. Перед запросом к этому представлению необходимо установить активную книгу через вызов KOCEL.BOOK.PrepareData(<book Name>).';
COMMENT ON COLUMN KOCEL.V_BOOK_MCELLS.L 
  is 'Левая коолонка объединённой ячейки.';
COMMENT ON COLUMN KOCEL.V_BOOK_MCELLS.T 
  is 'Верхний ряд объединённой ячейки.';
COMMENT ON COLUMN KOCEL.V_BOOK_MCELLS.R 
  is 'Правая колонка объединённой ячейки.';
COMMENT ON COLUMN KOCEL.V_BOOK_MCELLS.B 
  is 'Нижний ряд объединённой ячейки.';
COMMENT ON COLUMN KOCEL.V_BOOK_MCELLS.SHEET is 'Имя листа книги.';
COMMENT ON COLUMN KOCEL.V_BOOK_MCELLS.SHEET_NUM is 'Номер листа книги.';
COMMENT ON COLUMN KOCEL.V_BOOK_MCELLS.BOOK is 'Имя книги.';
GRANT SELECT ON KOCEL.V_BOOK_MCELLS to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW KOCEL.V_BOOK_PARS
(PAR_NAME, T, N, D, S, SHEET_NUM, SHEET, BOOK)
AS 
select PAR_NAME, T, cast(N as FLOAT(49)), D, S,
  cast(SHEET_NUM as NUMBER(3)), SHEET, BOOK
  from table(KOCEL.BOOK.PARS);

COMMENT ON TABLE KOCEL.V_BOOK_PARS
  is 'Обёртка для результата табличной функции KOCEL.BOOK.Pars. Перед запросом к этому представлению необходимо установить активную книгу через вызов KOCEL.BOOK.PrepareData(<book Name>).';
COMMENT ON COLUMN KOCEL.V_BOOK_PARS.PAR_NAME is 'Имя параметра.';
COMMENT ON COLUMN KOCEL.V_BOOK_PARS.T is 'Тип значения.';
COMMENT ON COLUMN KOCEL.V_BOOK_PARS.N is 'Значение.';
COMMENT ON COLUMN KOCEL.V_BOOK_PARS.D is 'Значение.';
COMMENT ON COLUMN KOCEL.V_BOOK_PARS.S is 'Значение.';
COMMENT ON COLUMN KOCEL.V_BOOK_PARS.SHEET_NUM 
is 'Порядковый номер листа в книге слева направо.';
COMMENT ON COLUMN KOCEL.V_BOOK_PARS.SHEET is 'Имя листа книги.';
COMMENT ON COLUMN KOCEL.V_BOOK_PARS.BOOK is 'Имя книги.';
GRANT SELECT ON KOCEL.V_BOOK_PARS to public;

-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW KOCEL.V_BOOK_FORMATS
(Fmt, Font_Name, Font_Size20, Font_Color, Font_Style, Font_Underline,
Font_Family, Font_CharSet, Left_Style, Left_Color, Right_Style,
Right_Color,Top_Style, Top_Color, Bottom_Style, Bottom_Color, Diagonal,
Diagonal_Style, Diagonal_Color, Format_String, Fill_Pattern, Fill_FgColor,
Fill_BgColor, H_Alignment, V_Alignment, E_Locked, E_Hidden, Parent_Fmt,
Wrap_Text, Shrink_To_Fit, Text_Rotation,Text_Indent)
as
select cast(Tag as NUMBER(9)) Fmt, Font_Name, cast(Font_Size20 as NUMBER(9)),
cast(Font_Color as NUMBER(9)), cast(Font_Style as NUMBER(9)),
cast(Font_Underline as NUMBER(1)), cast(Font_Family as NUMBER(3)),
cast(Font_CharSet as NUMBER(3)), cast(Left_Style as NUMBER(2)),
cast(Left_Color as NUMBER(9)), cast(Right_Style as NUMBER(2)),
cast(Right_Color as NUMBER(9)), cast(Top_Style as NUMBER(2)),
cast(Top_Color as NUMBER(9)), cast(Bottom_Style as NUMBER(2)),
cast(Bottom_Color as NUMBER(9)), cast(Diagonal as NUMBER(1)),
cast(Diagonal_Style as NUMBER(2)), cast(Diagonal_Color as NUMBER(9)),
Format_String, cast(Fill_Pattern as NUMBER(2)), 
cast(Fill_FgColor as NUMBER(9)), cast(Fill_BgColor as NUMBER(9)),
cast(H_Alignment as NUMBER(1)), cast(V_Alignment as NUMBER(1)),
cast(E_Locked as NUMBER(1)), cast(E_Hidden as NUMBER(1)),
cast(Parent_Fmt as NUMBER(9)), cast(Wrap_Text  as NUMBER(1)),
cast(Shrink_To_Fit as NUMBER(1)), cast(Text_Rotation as NUMBER(3)),
cast(Text_Indent as NUMBER(3))
  from table(KOCEL.BOOK.FORMATS);

COMMENT ON TABLE KOCEL.V_BOOK_FORMATS
  is 'Обёртка для результата табличной функции KOCEL.BOOK.Formats. Перед запросом к этому представлению необходимо установить активную книгу через вызов KOCEL.BOOK.PrepareData(<book Name>).';
begin
kcc.ft:='FORMATS';
kcc.tt:='V_BOOK_FORMATS';
kcc.all_av;
end;
/
COMMENT ON COLUMN KOCEL.V_BOOK_FORMATS.Fmt
  is 'Порядковый номер формата в книге.';
GRANT SELECT ON KOCEL.V_BOOK_FORMATS to public;


