CREATE OR REPLACE PACKAGE BODY KOCEL.BOOK
-- KOCEL BOOK package body
-- create 08.02.2010
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 15.02.2010 08.07.2015  26.09.2016
--*****************************************************************************

as

CBook VARCHAR2(255);
SCount NUMBER(3);

Fmts KOCEL.TNUMS;
type TFmtNum is table of NUMBER index by VARCHAR2(40);
FmtNum TFmtNum;
type TSheetNum is table of NUMBER index by VARCHAR2(255);
SheetNum TSheetNum;
type TSheetRec is record (SHEET_NUM NUMBER, SHEET VARCHAR2(255));
type TSheetRecs is table of TSheetRec index by PLS_INTEGER;
SheetRec TSheetRecs;

-------------------------------------------------------------------------------
-- Освобождение переменных пакета.
procedure ClearData
is
begin
  FmtNum.delete;
  SheetNum.delete;
  SheetRec.delete;
  Fmts:=null;
  CBook:=null;
  SCount:=null;
end ClearData;

-------------------------------------------------------------------------------
-- Загрузка и подготовка данных.
procedure PrepareData(UBOOK in VARCHAR2)
is
  tmpVar PLS_INTEGER;
begin
  ClearData;
  if UBook is null then return; end if;
  -- Находим количество листов в книге, их порядок следования слева направо и
  -- имена.
  tmpVar:=0;
  CBook:=UBook;
  for rec in (select NUM, SHEET from KOCEL.SHEETS_ORDER
                where upper(BOOK)=upper(CBook)
                order by NUM,SHEET)
  loop
    -- Упорядоченные номера листов в таблице могут пропускать значения.
    -- Мы используем в результате сплошную нумерацию.
    tmpVar:=tmpVar+1;
    SheetRec(tmpVar).SHEET_NUM:=tmpVar;
    SheetRec(tmpVar).SHEET:=rec.SHEET;
    SheetNum(upper(rec.SHEET)):=tmpVar;
  end loop;              
  for rec in (select distinct SHEET from KOCEL.SHEETS s
	              where upper(s.BOOK)=upper(CBook)
		              and upper(s.Sheet) not in (select upper(SHEET) 
                                               from KOCEL.SHEETS_ORDER
	                                             where upper(BOOK)=upper(CBook)
                                             )  
              order by SHEET)
  loop
    tmpVar:=tmpVar+1;
    SheetRec(tmpVar).SHEET_NUM:=tmpVar;
    SheetRec(tmpVar).SHEET:=rec.SHEET;
    SheetNum(upper(rec.SHEET)):=tmpVar;
  end loop;
  if tmpVar=0 then
    raise_application_Error(-20443,	'Book '||UBook||' is missing!');
  end if;
  SCount:=tmpVar;
  -- Заполняем массив индексов форматов, использованных в книге и
  -- массив соответствия индесов и номеров форматов. 
  FmtNum('0'):=0;
  -- Заполняем массив ссылок номеров форматов на индексы.
  select distinct Fmt bulk collect into Fmts from KOCEL.SHEETS
    where Fmt is not null
      and Fmt > 0
      and upper(BOOK)=upper(CBOOK);
  if Fmts.count=0 then return; end if;    
  for i in 1..Fmts.count    
  loop
    FmtNum(to_char(Fmts(i))):=i;
  end loop;
end PrepareData;

-------------------------------------------------------------------------------
-- Предоставляет для запроса параметры листов книги "UBOOK".
-- Если номер листа 0, а имя нулл, то это глобальный параметр книги.
function Pars return KOCEL.TSHEET_PARS pipelined
is
  orec KOCEL.TSHEET_PAR;
begin
  if CBook is null then return; end if;
  orec:=KOCEL.TSHEET_PAR;
  orec.BOOK:=CBOOK;
  for rec in(select PAR_NAME, T, N, D, S, SHEET, BOOK from KOCEL.V_SHEET_PARS
               where upper(BOOK)=upper(CBOOK)) 
  loop
    orec.PAR_NAME:=rec.PAR_NAME;
	  orec.T:=rec.T;
    orec.N:=rec.N;
	  orec.D:=rec.D;
	  orec.S:=rec.S;
    if rec.SHEET is null then
      orec.SHEET_NUM:=0;
    else  
      orec.SHEET_NUM:=SheetNum(upper(rec.SHEET));
    end if;
    orec.SHEET:=rec.SHEET;
    pipe row(orec);
  end loop
  return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.BOOK.Pars');
    raise;
end Pars;

-------------------------------------------------------------------------------
-- Предоставляет для запроса форматы, использующиеся в книге "UBOOK".
-- Поле "Fmt" содержит идентификатор формата, а поле "Tag" порядковый номер.
-- Первая запись содержит количество форматов в поле "Tag".
function Formats return KOCEL.TFORMATS pipelined
is
  orec KOCEL.TFORMAT;
begin
  if CBook is null then return; end if;
  orec:=KOCEL.TFORMAT(0);
  orec.Tag:=Fmts.Count;
  pipe row(orec);
  if Fmts.count=0 then return; end if;   
  for i in 1..Fmts.count    
  loop
    orec:=KOCEL.TFORMAT(Fmts(i));
    orec.Tag:=i;
    pipe row(orec);
  end loop;
  return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.BOOK.Formats');
    raise;
end Formats;

-------------------------------------------------------------------------------
-- Предоставляет для запроса номера листов книги "UBOOK".
-- Первая запись содержит не номер, а количество листов.
-- Информация о листах книги и их именах хранится в пакете.
function Sheets return KOCEL.TSHEET_NUMS pipelined
is
  orec KOCEL.TSHEET_NUM;
begin
  if CBook is null then return; end if;
  orec:=KOCEL.TSHEET_NUM(SCount,null);
  pipe row(orec);
  for i in SheetRec.first..SheetRec.last
  loop
    orec.SHEET_NUM:=SheetRec(i).SHEET_NUM;
    orec.SHEET:=SheetRec(i).SHEET;
    pipe row(orec);
  end loop;
  return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.BOOK.Sheets');
    raise;
end Sheets;

-------------------------------------------------------------------------------
-- Предоставляет для запроса форматы и высоты рядов листа  "USHEET" из книги
-- "UBOOK".
-- Поле "Fmt" содержит не идентификатор параметра, а номер,
-- соответствущий значению поля "Tag" в результате запросе к функции
-- "SHEET_FORMATS" для данной книги.
function Sheet_Row_s(USHEET in VARCHAR2) return KOCEL.TROW_DATAS pipelined
is
  orec KOCEL.TROW_DATA;
begin
  if CBook is null then return; end if;
  orec:=KOCEL.TROW_DATA;
  orec.SHEET_NUM:=SheetNum(upper(USHEET));
  orec.SHEET:=USHEET;
  orec.BOOK:=CBOOK;
  -- Отправляем ряд данных, заменяя идентификатор формата на его номер.
  for rec in(select RID,R,H, nvl(Fmt,0) Fmt 
               from KOCEL.V_ROWS
               where upper(BOOK)=upper(CBOOK)
                 and upper(SHEET)=upper(USHEET)) 
  loop
    orec.RID:=rec.RID;
    orec.R:=rec.R;
	  orec.H:=rec.H;
    begin
  	  orec.Fmt:=FmtNum(rec.Fmt);
    exception
      -- Если ячейка не имеет формата, то присваиваем 0
      when no_data_found then orec.Fmt:=0;  
    end;  
    pipe row(orec);
  end loop;
  return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.BOOK.Sheet_Row_s');
    raise;
end Sheet_Row_s;

-------------------------------------------------------------------------------
-- Предоставляет для запроса форматы и высоты рядов листов книги "UBOOK".
-- Поле "Fmt" содержит не идентификатор параметра, а номер,
-- соответствущий значению поля "Tag" в результате запросе к функции
-- "SHEET_FORMATS" для данной книги.
function Row_s return KOCEL.TROW_DATAS pipelined
is
  orec KOCEL.TROW_DATA;
begin
  if CBook is null then return; end if;
  orec:=KOCEL.TROW_DATA;
  orec.BOOK:=CBOOK;
  -- Отправляем ряд данных, заменяя идентификатор формата на его номер.
  for rec in(select RID, R, H, SHEET, nvl(Fmt,0) Fmt 
               from KOCEL.V_ROWS
               where upper(BOOK)=upper(CBOOK)) 
  loop
    orec.RID:=rec.RID;
    orec.R:=rec.R;
	  orec.H:=rec.H;
    orec.SHEET_NUM:=SheetNum(upper(rec.SHEET));
    orec.SHEET:=rec.SHEET;
    begin
  	  orec.Fmt:=FmtNum(rec.Fmt);
    exception
      -- Если ячейка не имеет формата, то присваиваем 0
      when no_data_found then orec.Fmt:=0;  
    end;  
    pipe row(orec);
  end loop
  return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.BOOK.Row_s');
    raise;
end Row_s;

-------------------------------------------------------------------------------
-- Предоставляет для запроса форматы и ширины колонок листа  "USHEET" из книги
-- "UBOOK".
-- Поле "Fmt" содержит не идентификатор параметра, а номер,
-- соответствущий значению поля "Tag" в результате запросе к функции
-- "SHEET_FORMATS" для данной книги.
function Sheet_Column_s(USHEET in VARCHAR2) return KOCEL.TCOLUMN_DATAS
pipelined
is
  orec KOCEL.TCOLUMN_DATA;
begin
  if CBook is null then return; end if;
  orec:=KOCEL.TCOLUMN_DATA;
  orec.BOOK:=CBOOK;
  orec.SHEET_NUM:=SheetNum(upper(USHEET));
  orec.SHEET:=USHEET;
  -- Отправляем ряд данных, заменяя идентификатор формата на его номер.
  for rec in(select RID, C, W, SHEET, nvl(Fmt,0) Fmt 
               from KOCEL.V_COLUMNS
               where upper(BOOK)=upper(CBOOK)
                 and upper(SHEET)=upper(USHEET)) 
  loop
    orec.RID:=rec.RID;
    orec.C:=rec.C;
	  orec.W:=rec.W;
    begin
  	  orec.Fmt:=FmtNum(rec.Fmt);
    exception
      -- Если ячейка не имеет формата, то присваиваем 0
      when no_data_found then orec.Fmt:=0;  
    end;  
    pipe row(orec);
  end loop
  return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.BOOK.Sheet_Column_s');
    raise;
end Sheet_Column_s;

-------------------------------------------------------------------------------
-- Предоставляет для запроса форматы и ширины колонок листов книги "UBOOK".
-- Поле "Fmt" содержит не идентификатор параметра, а номер,
-- соответствущий значению поля "Tag" в результате запросе к функции
-- "SHEET_FORMATS" для данной книги.
function Column_s return KOCEL.TCOLUMN_DATAS pipelined
is
  orec KOCEL.TCOLUMN_DATA;
begin
  if CBook is null then return; end if;
  orec:=KOCEL.TCOLUMN_DATA;
  orec.BOOK:=CBOOK;
  -- Отправляем ряд данных, заменяя идентификатор формата на его номер.
  for rec in(select RID, C, W, SHEET, nvl(Fmt,0) Fmt 
               from KOCEL.V_COLUMNS
               where upper(BOOK)=upper(CBOOK)) 
  loop
    orec.RID:=rec.RID;
    orec.C:=rec.C;
	  orec.W:=rec.W;
    orec.SHEET_NUM:=SheetNum(upper(rec.SHEET));
    orec.SHEET:=rec.SHEET;
    begin
  	  orec.Fmt:=FmtNum(rec.Fmt);
    exception
      -- Если ячейка не имеет формата, то присваиваем 0
      when no_data_found then orec.Fmt:=0;  
    end;  
    pipe row(orec);
  end loop
  return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.BOOK.Column_s');
    raise;
end Column_s;

-------------------------------------------------------------------------------
-- Предоставляет для запроса данные листа "USHEET" из книги "UBOOK".
-- Поле "Fmt" содержит не идентификатор параметра, а номер,
-- соответствущий значению поля "Tag" в результате запросе к функции
-- "SHEET_FORMATS" для данной книги.
function Sheet_Cells(USHEET in VARCHAR2) return KOCEL.TCELL_DATAS pipelined
is
  orec KOCEL.TCELL_DATA;
begin
  if CBook is null then return; end if;
  orec:=KOCEL.TCELL_DATA;
  orec.SHEET_NUM:=SheetNum(upper(USHEET));
  orec.SHEET:=USHEET;
  orec.BOOK:=CBOOK;
  -- Отправляем ряд данных, заменяя идентификатор формата на его номер.
  for rec in(select RID,T,R,C,N,D,S,F, nvl(Fmt,0) Fmt 
               from KOCEL.V_SHEETS
               where upper(BOOK)=upper(CBOOK)
                 and upper(SHEET)=upper(USHEET)) 
  loop
    orec.RID:=rec.RID;
    orec.T:=rec.T;
    orec.R:=rec.R;
	  orec.C:=rec.C;
	  orec.N:=rec.N;
    orec.D:=rec.D;
	  orec.S:=rec.S;
	  orec.F:=rec.F;
    begin
  	  orec.Fmt:=FmtNum(rec.Fmt);
    exception
      -- Если ячейка не имеет формата, то присваиваем 0
      when no_data_found then orec.Fmt:=0;  
    end;  
    pipe row(orec);
  end loop
  return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.BOOK.Sheet_Cells');
    raise;
end Sheet_Cells;

-------------------------------------------------------------------------------
-- Предоставляет для запроса данные книги "UBOOK".
-- Поле "Fmt" содержит не идентификатор параметра, а номер,
-- соответствущий значению поля "Tag" в результате запросе к функции
-- "SHEET_FORMATS" для данной книги.
function Cells return KOCEL.TCELL_DATAS pipelined
is
  orec KOCEL.TCELL_DATA;
begin
  if CBook is null then return; end if;
  orec:=KOCEL.TCELL_DATA;
  orec.BOOK:=CBOOK;
  -- Отправляем ряд данных, заменяя идентификатор формата на его номер.
  for rec in(select RID, T, R, C, N, D, S, F, SHEET, nvl(Fmt,0) Fmt 
               from KOCEL.V_SHEETS
               where upper(BOOK)=upper(CBOOK)
             order by SHEET) 
  loop
    orec.RID:=rec.RID;
    orec.T:=rec.T;
    orec.R:=rec.R;
	  orec.C:=rec.C;
	  orec.N:=rec.N;
    orec.D:=rec.D;
	  orec.S:=rec.S;
	  orec.F:=rec.F;
    orec.SHEET_NUM:=SheetNum(upper(rec.SHEET));
    orec.SHEET:=rec.SHEET;
    begin
  	  orec.Fmt:=FmtNum(rec.Fmt);
    exception
      -- Если ячейка не имеет формата, то присваиваем 0
      when no_data_found then orec.Fmt:=0;  
    end;  
    pipe row(orec);
  end loop
  return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.BOOK.Cells');
    raise;
end Cells;

-------------------------------------------------------------------------------
-- Предоставляет для запроса объединённые ячейки листa "USHEET" из книги
-- "UBOOK".
function Sheet_MCells(USHEET in VARCHAR2) return KOCEL.TMCELL_DATAS pipelined
is
  orec KOCEL.TMCELL_DATA;
begin
  if CBook is null then return; end if;
  orec:=KOCEL.TMCELL_DATA;
  orec.SHEET_NUM:=SheetNum(upper(USHEET));
  orec.SHEET:=USHEET;
  orec.BOOK:=CBOOK;
  -- Отправляем ряд данных.
  for rec in(select L,T,R,B,SHEET,BOOK from KOCEL.MERGED_CELLS
               where upper(BOOK)=upper(CBOOK)
                 and upper(SHEET)=upper(USHEET)) 
  loop
    orec.L:=rec.L;
	  orec.T:=rec.T;
    orec.R:=rec.R;
	  orec.B:=rec.B;
    pipe row(orec);
  end loop;
  return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.BOOK.Sheet_MCells');
    raise;
end Sheet_MCells;

-------------------------------------------------------------------------------
-- Предоставляет для запроса объединённые ячейки листов книги "UBOOK".
function MCells return KOCEL.TMCELL_DATAS pipelined
is
  orec KOCEL.TMCELL_DATA;
begin
  if CBook is null then return; end if;
  orec:=KOCEL.TMCELL_DATA;
  orec.BOOK:=CBOOK;
  -- Отправляем ряд данных.
  for rec in(select L,T,R,B,SHEET,BOOK from KOCEL.MERGED_CELLS
               where upper(BOOK)=upper(CBOOK)) 
  loop
    orec.L:=rec.L;
	  orec.T:=rec.T;
    orec.R:=rec.R;
	  orec.B:=rec.B;
    orec.SHEET_NUM:=SheetNum(upper(rec.SHEET));
    orec.SHEET:=rec.SHEET;
    pipe row(orec);
  end loop
  return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.BOOK.MCells');
    raise;
end MCells;

END;
/
