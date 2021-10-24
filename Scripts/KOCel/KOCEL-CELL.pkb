CREATE OR REPLACE PACKAGE BODY KOCEL.CELL
-- KOCEL CELL package body
-- create 17.04.2009
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 18.05.2009 15.12.2009 28.01.2010 01.02.2010 16.02.2010 03.03.2010
--        15.08.2011 13.08.2014 11.11.2014 26.09.2016
--*****************************************************************************

AS

A NUMBER(2);
Z NUMBER(2);

-------------------------------------------------------------------------------
FUNCTION CN(C in VARCHAR2)return NUMBER
is
begin
  return Col2Num(C);
end CN;

-- Создание новой книги и (или) листа.
-- Если лист уже существует, то ошибка.
-- Книга существует, если в ней хотябы один лист.
-- Лист книги существует, если в таблицу занесена хотябы одна ячейка.
-- в данном случае заносится нулевая ячейка в ячейку(R=0 и C=0).
-------------------------------------------------------------------------------
PROCEDURE New_SHEET(newSHEET in VARCHAR2,newBOOK in VARCHAR2)
is
  tmpVar NUMBER;
begin
  if isSHEET_exist(newSHEET,newBOOK) then
	  raise_application_Error(-20443,'Sheet already exists!');
	end if;
	insert into KOCEL.SHEETS values(0,0,null,null,null,null,newSHEET,newBOOK,0);
end New_SHEET;

-- Создание нового листа.
-------------------------------------------------------------------------------
PROCEDURE New_outSHEET
is
begin
  New_SHEET(outSHEET,outBOOK);
end New_outSHEET;

-- Создание нового листа и установка его как приёмник по умолчанию.
-------------------------------------------------------------------------------
PROCEDURE New_outSHEET(newSHEET in VARCHAR2)
is
begin
  New_SHEET(newSHEET,outBOOK);
	outSHEET:=newSHEET;
end New_outSHEET;

-------------------------------------------------------------------------------
PROCEDURE New_outSHEET(newSHEET in VARCHAR2,newBOOK in VARCHAR2)
is
begin
  New_SHEET(newSHEET,newBOOK);
	outSHEET:=newSHEET;
	outBOOK:=newBOOK;
end New_outSHEET;

-- Проверка что лист существует.
-------------------------------------------------------------------------------
FUNCTION is_inSHEET_exist return BOOLEAN
is
begin
  return isSHEET_exist(inSHEET,inBOOK);
end is_inSHEET_exist;

-------------------------------------------------------------------------------
FUNCTION is_outSHEET_exist return BOOLEAN
is
begin
  return isSHEET_exist(outSHEET,outBOOK);
end is_outSHEET_exist;

-------------------------------------------------------------------------------
FUNCTION is_inSHEET_exist(eSHEET in VARCHAR2)
return BOOLEAN
is
begin
  return isSHEET_exist(eSHEET,inBOOK);
end is_inSHEET_exist;

-------------------------------------------------------------------------------
FUNCTION is_outSHEET_exist(eSHEET in VARCHAR2)
return BOOLEAN
is
begin
  return isSHEET_exist(eSHEET,outBOOK);
end is_outSHEET_exist;

-------------------------------------------------------------------------------
FUNCTION isSHEET_exist(eSHEET in VARCHAR2,eBOOK in VARCHAR2)
return BOOLEAN
is
  tmpVar NUMBER;
begin
  select count(*) into tmpVar from dual
    where exists( select * from KOCEL.SHEETS
	                  where (SHEET=eSHEET) and (BOOK=eBOOK));
  if tmpVar =0 then
	  return false;
	end if;
	return true;
end isSHEET_exist;

-- Получение значения.
-------------------------------------------------------------------------------
FUNCTION Val(CellRow in NUMBER,CellColumn in NUMBER)
return TCellValue
is
begin
  return Val(inSHEET,inBOOK,CellRow,CellColumn);
end Val;

-------------------------------------------------------------------------------
FUNCTION Val(anySHEET in VARCHAR2,
             CellRow in NUMBER,CellColumn in NUMBER)
return TCellValue
is
begin
  return Val(anySHEET,inBOOK,CellRow,CellColumn);
end Val;

-------------------------------------------------------------------------------
FUNCTION Val(anySHEET in VARCHAR2,anyBook in VARCHAR2,
             CellRow in NUMBER,CellColumn in NUMBER)
return TCellValue
is
  tmpVar TCellValue;
begin
  select R,C,N,D,S,F into tmpVar from KOCEL.SHEETS 
	  where (SHEET=anySHEET) and (BOOK=anyBOOK)
		  and (R=CellRow) and (C=CellColumn);
	return tmpVar;
exception
  when no_data_found then
		if not isSHEET_exist(anySHEET,anyBOOK) then
		  raise_application_Error(-20443,
			  'Sheet: '||anySHEET||'  is missing in Book: '||anyBook||'!');
		end if;
    -- Если книга и лист существует, то возвращаем пустое значение.
    tmpVar.R:=CellRow;
    tmpVar.C:=CellColumn;
    return tmpVar;				    
end Val;

-------------------------------------------------------------------------------
FUNCTION Val(CellRow in NUMBER,CellColumn in VARCHAR2)
return TCellValue
is
begin
  return Val(inSHEET,inBOOK,CellRow,CN(CellColumn));
end Val;

-------------------------------------------------------------------------------
FUNCTION Val(anySHEET in VARCHAR2,
             CellRow in NUMBER,CellColumn in VARCHAR2)
return TCellValue
is
begin
  return Val(anySHEET,inBOOK,CellRow,CN(CellColumn));
end Val;

-------------------------------------------------------------------------------
FUNCTION Val(anySHEET in VARCHAR2,anyBook in VARCHAR2,
             CellRow in NUMBER,CellColumn in VARCHAR2)
return TCellValue
is
begin
  return Val(anySHEET,anyBOOK,CellRow,CN(CellColumn));
end Val;

-- Проверка, что значение дата.
-------------------------------------------------------------------------------
FUNCTION isDate(CellValue in TCellValue)
return BOOLEAN
is
begin
  if CellValue.D is not null then return true;end if;	
	return false;
end isDate;

-- Проверка, что значение null.
-------------------------------------------------------------------------------
FUNCTION isNull(CellValue in TCellValue)
return BOOLEAN
is
begin
  if    (CellValue.N is null) 
    and (CellValue.D is null)
    and (CellValue.S is null)
    and (CellValue.F is null)
  then
   return true;
  end if;	
	return false;
end isNull;

-- Проверка, что значение число.
-------------------------------------------------------------------------------
FUNCTION isNumber(CellValue in TCellValue)
return BOOLEAN
is
begin
  if (CellValue.N is not null)and(CellValue.D is null)then return true;end if;	
	return false;
end isNumber;

-- Проверка, что значение строка.
-------------------------------------------------------------------------------
FUNCTION isString(CellValue in TCellValue)
return BOOLEAN
is
begin
  if (CellValue.N is null)and(CellValue.D is null)then return true;end if;	
	return false;
end isString;

-- Проверка, что присутствует формула.
-------------------------------------------------------------------------------
FUNCTION hasFormula(CellValue in TCellValue)
return BOOLEAN
is
begin
  if (CellValue.F is not null) then return true;end if;	
	return false;
end hasFormula;

--Получение значения, как даты. Если это не дата, то нулл.
-------------------------------------------------------------------------------
FUNCTION asDate(CellRow in NUMBER,CellColumn in NUMBER)
return DATE
is
begin
  return asDate(inSHEET,inBook,CellRow,CellColumn);
end asDate;

-------------------------------------------------------------------------------
FUNCTION asDate(anySHEET in VARCHAR2,
                CellRow in NUMBER,CellColumn in NUMBER)
return DATE
is
begin
  return asDate(anySHEET,inBook,CellRow,CellColumn);
end asDate;

-------------------------------------------------------------------------------
FUNCTION asDate(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                CellRow in NUMBER,CellColumn in NUMBER)
return DATE
is
begin
  return Val(anySHEET,anyBook,CellRow,CellColumn).D;
end asDate;

-------------------------------------------------------------------------------
FUNCTION asDate(CellRow in NUMBER,CellColumn in VARCHAR2)
return DATE
is
begin
  return asDate(inSHEET,inBook,CellRow,CN(CellColumn));
end asDate;

-------------------------------------------------------------------------------
FUNCTION asDate(anySHEET in VARCHAR2,
                CellRow in NUMBER,CellColumn in VARCHAR2)
return DATE
is
begin
  return asDate(anySHEET,inBook,CellRow,CN(CellColumn));
end asDate;

-------------------------------------------------------------------------------
FUNCTION asDate(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                CellRow in NUMBER,CellColumn in VARCHAR2)
return DATE
is
begin
  return asDate(anySHEET,anyBook,CellRow,CN(CellColumn));
end asDate;

-- Получение значения, как числа. Если это не число, то нулл.
-------------------------------------------------------------------------------
FUNCTION asNumber(CellRow in NUMBER,CellColumn in NUMBER)
return NUMBER
is
begin
  return asNumber(inSHEET,inBook,CellRow,CellColumn);
end asNumber;

-------------------------------------------------------------------------------
FUNCTION asNumber(anySHEET in VARCHAR2,
                  CellRow in NUMBER,CellColumn in NUMBER)
return NUMBER
is
begin
  return asNumber(anySHEET,inBook,CellRow,CellColumn);
end asNumber;

-------------------------------------------------------------------------------
FUNCTION asNumber(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  CellRow in NUMBER,CellColumn in NUMBER)
return NUMBER
is
begin
  return Val(anySHEET,anyBook,CellRow,CellColumn).N;
end asNumber;

-------------------------------------------------------------------------------
FUNCTION asNumber(CellRow in NUMBER,CellColumn in VARCHAR2)
return NUMBER
is
begin
  return asNumber(inSHEET,inBook,CellRow,CN(CellColumn));
end asNumber;

-------------------------------------------------------------------------------
FUNCTION asNumber(anySHEET in VARCHAR2,
                  CellRow in NUMBER,CellColumn in VARCHAR2)
return NUMBER
is
begin
  return asNumber(anySHEET,inBook,CellRow,CN(CellColumn));
end asNumber;

-------------------------------------------------------------------------------
FUNCTION asNumber(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  CellRow in NUMBER,CellColumn in VARCHAR2)
return NUMBER
is
begin
  return asNumber(anySHEET,anyBook,CellRow,CN(CellColumn));
end asNumber;

-- Получение значения, как строки.
-------------------------------------------------------------------------------
FUNCTION asString(CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2
is
begin
  return asString(inSHEET,inBook,CellRow,CellColumn);
end asString;

-------------------------------------------------------------------------------
FUNCTION asString(anySHEET in VARCHAR2,
                  CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2
is
begin
  return asString(anySHEET,inBook,CellRow,CellColumn);
end asString;

-------------------------------------------------------------------------------
FUNCTION asString(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2
is
  V TCellValue;
  S VARCHAR2(4000);
begin
  V:=Val(anySHEET,anyBook,CellRow,CellColumn);
  S:=case
    when V.D is not null then to_char(V.D)
    when V.N is not null then to_char(V.N)
  else V.S
  end;
  return S;
end asString;

-------------------------------------------------------------------------------
FUNCTION asString(CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2
is
begin
  return asString(inSHEET,inBook,CellRow,CN(CellColumn));
end asString;

-------------------------------------------------------------------------------
FUNCTION asString(anySHEET in VARCHAR2,
                  CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2
is
begin
  return asString(anySHEET,inBook,CellRow,CN(CellColumn));
end asString;

-------------------------------------------------------------------------------
FUNCTION asString(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2
is
begin
  return asString(anySHEET,anyBook,CellRow,CN(CellColumn));
end asString;

-- Получение формулы.
-------------------------------------------------------------------------------
FUNCTION Formula(CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2
is
begin
  return Formula(inSHEET,inBook,CellRow,CellColumn);
end Formula;

-------------------------------------------------------------------------------
FUNCTION Formula(anySHEET in VARCHAR2,
                 CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2
is
begin
  return Formula(anySHEET,inBook,CellRow,CellColumn);
end Formula;

-------------------------------------------------------------------------------
FUNCTION Formula(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                 CellRow in NUMBER,CellColumn in NUMBER)
return VARCHAR2
is
begin
  return Val(anySHEET,anyBook,CellRow,CellColumn).F;
end Formula;

-------------------------------------------------------------------------------
FUNCTION Formula(CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2
is
begin
  return Formula(inSHEET,inBook,CellRow,CN(CellColumn));
end Formula;

-------------------------------------------------------------------------------
FUNCTION Formula(anySHEET in VARCHAR2,
                 CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2
is
begin
  return Formula(anySHEET,inBook,CellRow,CN(CellColumn));
end Formula;

-------------------------------------------------------------------------------
FUNCTION Formula(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                 CellRow in NUMBER,CellColumn in VARCHAR2)
return VARCHAR2
is
begin
  return Formula(anySHEET,anyBook,CellRow,CN(CellColumn));
end Formula;

-- Получение колонки.
-------------------------------------------------------------------------------
FUNCTION GetColumn(StartRow in NUMBER,StartColumn in NUMBER,
                   EndRow in NUMBER)
return TColumn
is
begin
  return GetColumn(inSHEET,inBook,StartRow,StartColumn,EndRow);
end GetColumn;

-------------------------------------------------------------------------------
FUNCTION GetColumn(entColumn in NUMBER)
return TColumn
is
begin
  return GetColumn(inSHEET,inBook,entColumn);
end GetColumn;

-------------------------------------------------------------------------------
FUNCTION GetColumn(anySHEET in VARCHAR2,
                   StartRow in NUMBER,StartColumn in NUMBER,
                   EndRow in NUMBER)
return TColumn
is
begin
  return GetColumn(anySHEET,inBook,StartRow,StartColumn,EndRow);
end GetColumn;

-------------------------------------------------------------------------------
FUNCTION GetColumn(anySHEET in VARCHAR2,
                   entColumn in NUMBER)
return TColumn
is
begin
  return GetColumn(anySHEET,inBook,entColumn);
end GetColumn;

-------------------------------------------------------------------------------
FUNCTION GetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   StartRow in NUMBER,StartColumn in NUMBER,
                   EndRow in NUMBER)
return TColumn
is
  tmpVar TColumn;
	i BINARY_INTEGER;
  v TCellValue;
begin
	if not isSHEET_exist(anySHEET,anyBOOK) then
	  raise_application_Error(-20443,
		  'Sheet: '||anySHEET||'  is missing in Book: '||anyBook||'!');
	end if;
  for rec in (
	select R,C,N,D,S,F from KOCEL.SHEETS 
	  where (C=StartColumn)
		  and (R between StartRow and EndRow)
		  and (SHEET=anySHEET)
		  and (Book=anyBook)
		order by R)
	loop
	  v.R:=rec.R;
	  v.C:=rec.C;
	  v.N:=rec.N;
	  v.D:=rec.D;
	  v.S:=rec.S;
	  v.F:=rec.F;
    -- Индекс массива равен номеру ряда.
		i:=rec.R;
	  tmpVar(i):=v;
	end loop;
	return tmpVar;
end GetColumn;

-------------------------------------------------------------------------------
FUNCTION GetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   entColumn in NUMBER)
return TColumn
is
  tmpVar TColumn;
  v TCellValue;
	i BINARY_INTEGER;
begin
	if not isSHEET_exist(anySHEET,anyBOOK) then
	  raise_application_Error(-20443,
		  'Sheet: '||anySHEET||'  is missing in Book: '||anyBook||'!');
	end if;
  for rec in (
	select R,C,N,D,S,F from KOCEL.SHEETS 
	  where (C=entColumn)
		  and (SHEET=anySHEET)
		  and (Book=anyBook)
		order by R)
	loop
	  v.R:=rec.R;
	  v.C:=rec.C;
	  v.N:=rec.N;
	  v.D:=rec.D;
	  v.S:=rec.S;
	  v.F:=rec.F;
    -- Индекс массива равен номеру ряда.
		i:=rec.R;
	  tmpVar(i):=v;
	end loop;
	return tmpVar;
end GetColumn;

-------------------------------------------------------------------------------
FUNCTION GetColumn(StartRow in NUMBER,StartColumn in VARCHAR2,
                   EndRow in NUMBER)
return TColumn
is
begin
  return GetColumn(inSHEET,inBook,StartRow,CN(StartColumn),EndRow);
end GetColumn;

-------------------------------------------------------------------------------
FUNCTION GetColumn(entColumn in VARCHAR2)
return TColumn
is
begin
  return GetColumn(inSHEET,inBook,CN(entColumn));
end GetColumn;

-------------------------------------------------------------------------------
FUNCTION GetColumn(anySHEET in VARCHAR2,
                   StartRow in NUMBER,StartColumn in VARCHAR2,
                   EndRow in NUMBER)
return TColumn
is
begin
  return GetColumn(anySHEET,inBook,StartRow,CN(StartColumn),EndRow);
end GetColumn;

-------------------------------------------------------------------------------
FUNCTION GetColumn(anySHEET in VARCHAR2,
                   entColumn in VARCHAR2)
return TColumn
is
begin
  return GetColumn(anySHEET,inBook,CN(entColumn));
end GetColumn;

-------------------------------------------------------------------------------
FUNCTION GetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   StartRow in NUMBER,StartColumn in VARCHAR2,
                   EndRow in NUMBER)
return TColumn
is
begin
  return GetColumn(anySHEET,anyBook,StartRow,CN(StartColumn),EndRow);
end GetColumn;

-------------------------------------------------------------------------------
FUNCTION GetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   entColumn in VARCHAR2)
return TColumn
is
begin
  return GetColumn(anySHEET,anyBook,CN(entColumn));
end GetColumn;


-- Получение ряда.
-------------------------------------------------------------------------------
FUNCTION GetRow(StartRow in NUMBER,StartColumn in NUMBER,
                EndColumn in NUMBER)
return TRow
is
begin
  return GetRow(inSHEET,inBOOK,StartRow,StartColumn,EndColumn);
end GetRow;

-------------------------------------------------------------------------------
FUNCTION GetRow(entRow in NUMBER)
return TRow
is
begin
  return GetRow(inSHEET,inBOOK,entRow);
end GetRow;

-------------------------------------------------------------------------------
FUNCTION GetRow(anySHEET in VARCHAR2,
                StartRow in NUMBER,StartColumn in NUMBER,
                EndColumn in NUMBER)
return TRow
is
begin
  return GetRow(anySHEET,inBOOK,StartRow,StartColumn,EndColumn);
end GetRow;

-------------------------------------------------------------------------------
FUNCTION GetRow(anySHEET in VARCHAR2,
                entRow in NUMBER)
return TRow
is
begin
  return GetRow(anySHEET,inBOOK,entRow);
end GetRow;

-------------------------------------------------------------------------------
FUNCTION GetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                StartRow in NUMBER,StartColumn in NUMBER,
                EndColumn in NUMBER)
return TRow
is
  tmpVar TRow;
	i BINARY_INTEGER;
  v TCellValue;
begin
	if not isSHEET_exist(anySHEET,anyBOOK) then
	  raise_application_Error(-20443,
		  'Sheet: '||anySHEET||'  is missing in Book: '||anyBook||'!');
	end if;
  for rec in (
	select R,C,N,D,S,F from KOCEL.SHEETS 
	  where (R=StartRow)
		  and (C between StartColumn and EndColumn)
		  and (SHEET=anySHEET)
		  and (Book=anyBook)
		order by C)
	loop
	  v.R:=rec.R;
	  v.C:=rec.C;
	  v.N:=rec.N;
	  v.D:=rec.D;
	  v.S:=rec.S;
	  v.F:=rec.F;
    -- Индекс массива равен колонке элемента.
    i:=rec.C;
	  tmpVar(i):=v;
	end loop;
	return tmpVar;
end GetRow;

-------------------------------------------------------------------------------
FUNCTION GetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                entRow in NUMBER)
return TRow
is
  tmpVar TRow;
	i BINARY_INTEGER;
  v TCellValue;
begin
	if not isSHEET_exist(anySHEET,anyBOOK) then
	  raise_application_Error(-20443,
		  'Sheet: '||anySHEET||'  is missing in Book: '||anyBook||'!');
	end if;
  for rec in (
	select R,C,N,D,S,F from KOCEL.SHEETS 
	  where (R=entRow)
		  and (SHEET=anySHEET)
		  and (Book=anyBook)
		order by C)
	loop
	  v.R:=rec.R;
	  v.C:=rec.C;
	  v.N:=rec.N;
	  v.D:=rec.D;
	  v.S:=rec.S;
	  v.F:=rec.F;
    -- Индекс массива равен колонке элемента.
    i:=rec.C;
	  tmpVar(i):=v;
	end loop;
	return tmpVar;
end GetRow;

-------------------------------------------------------------------------------
FUNCTION GetRow(StartRow in NUMBER,StartColumn in VARCHAR2,
                EndColumn in VARCHAR2)
return TRow
is
begin
  return GetRow(inSHEET,inBOOK,StartRow,CN(StartColumn),CN(EndColumn));
end GetRow;

-------------------------------------------------------------------------------
FUNCTION GetRow(anySHEET in VARCHAR2,
                StartRow in NUMBER,StartColumn in VARCHAR2,
                EndColumn in VARCHAR2)
return TRow
is
begin
  return GetRow(anySHEET,inBOOK,StartRow,CN(StartColumn),CN(EndColumn));
end GetRow;

-------------------------------------------------------------------------------
FUNCTION GetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                StartRow in NUMBER,StartColumn in VARCHAR2,
                EndColumn in VARCHAR2)
return TRow
is
begin
  return GetRow(inSHEET,anyBOOK,StartRow,CN(StartColumn),CN(EndColumn));
end GetRow;

-- Получение диапазона.
-------------------------------------------------------------------------------
FUNCTION GetRange(StartRow in NUMBER,StartColumn in NUMBER,
                  EndRow in NUMBER,EndColumn in NUMBER)
return TRange
is
begin
  return GetRange(inSHEET,inBook,StartRow,StartColumn,EndRow,EndColumn);
end GetRange;

-------------------------------------------------------------------------------
FUNCTION GetRange(anySHEET in VARCHAR2,
                  StartRow in NUMBER,StartColumn in NUMBER,
                  EndRow in NUMBER,EndColumn in NUMBER)
return TRange
is
begin
  return GetRange(anySHEET,inBook,StartRow,StartColumn,EndRow,EndColumn);
end GetRange;

-------------------------------------------------------------------------------
FUNCTION GetRange(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  StartRow in NUMBER,StartColumn in NUMBER,
                  EndRow in NUMBER,EndColumn in NUMBER)
return TRange
is
  tmpVar TRange;
	j BINARY_INTEGER;
  v TCellValue;
  tmpN NUMBER;
begin
	if not isSHEET_exist(anySHEET,anyBOOK) then
	  raise_application_Error(-20443,
		  'Sheet: '||anySHEET||'  is missing in Book: '||anyBook||'!');
	end if;	
	for i in StartRow..EndRow
	loop
    tmpN:=i;	
	  for rec in (
		select R,C,N,D,S,F from KOCEL.SHEETS 
		  where (R=tmpN)
			  and (C between StartColumn and EndColumn)
			  and (SHEET=anySHEET)
			  and (Book=anyBook)
			order by C)
		loop
		  v.R:=rec.R;
		  v.C:=rec.C;
		  v.N:=rec.N;
		  v.D:=rec.D;
		  v.S:=rec.S;
		  v.F:=rec.F;
		  tmpVar(rec.R)(rec.C):=v;
		end loop;
	end loop;
	return tmpVar;
end GetRange;

-------------------------------------------------------------------------------
FUNCTION GetRange(StartRow in NUMBER,StartColumn in VARCHAR2,
                  EndRow in NUMBER,EndColumn in VARCHAR2)
return TRange
is
begin
  return GetRange(inSHEET,inBook,
                  StartRow,CN(StartColumn),EndRow,CN(EndColumn));
end GetRange;

-------------------------------------------------------------------------------
FUNCTION GetRange(anySHEET in VARCHAR2,
                  StartRow in NUMBER,StartColumn in VARCHAR2,
                  EndRow in NUMBER,EndColumn in VARCHAR2)
return TRange
is
begin
  return GetRange(anySHEET,inBook,
                  StartRow,CN(StartColumn),EndRow,CN(EndColumn));
end GetRange;

-------------------------------------------------------------------------------
FUNCTION GetRange(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  StartRow in NUMBER,StartColumn in VARCHAR2,
                  EndRow in NUMBER,EndColumn in VARCHAR2)
return TRange
is
begin
  return GetRange(anySHEET,anyBook,
                  StartRow,CN(StartColumn),EndRow,CN(EndColumn));
end GetRange;

-- Сохранение значения.
-------------------------------------------------------------------------------
PROCEDURE SetVal(val in TCellValue)
is
begin
  SetVal(outSHEET,outBook,val);
end SetVal;

-------------------------------------------------------------------------------
PROCEDURE SetVal(anySHEET in VARCHAR2, val in TCellValue)
is
begin
  SetVal(anySHEET,outBook,val);
end SetVal;

-------------------------------------------------------------------------------
PROCEDURE SetVal(anySHEET in VARCHAR2,anyBook in VARCHAR2, val in TCellValue)
is
  i PLS_INTEGER;
begin
	if not isSHEET_exist(anySHEET,anyBOOK) then
	  raise_application_Error(-20443,
		  'Sheet: '||anySHEET||'  is missing in Book: '||anyBook||'!');
	end if;	
  -- Если поля определены неоднозначно, то ошибка.
  i:=0;
  if Val.N is not null then i:=i+1; end if;
  if Val.D is not null then i:=i+1; end if;
  if Val.S is not null then i:=i+1; end if;
  if i>1 then 
	  raise_application_Error(-20443,
		  'SetVal, Sheet: '||anySHEET||',  Book: '||anyBook||
		  ' R: '||Val.R||',  C: '||Val.C||
		  ' N: '||Val.N||',  D: '||Val.D||',  S: '||Val.S||'!');
  end if;
  KOCEL.UPDATE_CELL(Val.R,Val.C,Val.N,Val.D,Val.S,Val.F,anySHEET,anyBOOK);
end SetVal;

-- Сохранение значения, если аргумент KOCEL.TVALUE.
-------------------------------------------------------------------------------
PROCEDURE SetVal(val in KOCEL.TValue)
is
begin
  SetVal(outSHEET,outBook,val);
end SetVal;

-------------------------------------------------------------------------------
PROCEDURE SetVal(anySHEET in VARCHAR2,val in KOCEL.TValue)
is
begin
  SetVal(anySHEET,outBook,val);
end SetVal;


-------------------------------------------------------------------------------
PROCEDURE SetVal(anySHEET in VARCHAR2,anyBook in VARCHAR2,val in KOCEL.TValue)
is
begin
	if not isSHEET_exist(anySHEET,anyBOOK) then
	  raise_application_Error(-20443,
		  'Sheet: '||anySHEET||'  is missing in Book: '||anyBook||'!');
	end if;	
  KOCEL.UPDATE_CELL(Val.R,Val.C,Val.N,Val.D,Val.S,Val.F,anySHEET,anyBOOK);
end SetVal;

-- Сохранение значения, как даты.
-------------------------------------------------------------------------------
PROCEDURE SetValasDate(CellRow in NUMBER,CellColumn in NUMBER,
                       val in DATE)
is
begin
  SetValasDate(outSHEET,outBook,CellRow,CellColumn,val);
end SetValasDate;

-------------------------------------------------------------------------------
PROCEDURE SetValasDate(anySHEET in VARCHAR2,
                       CellRow in NUMBER,CellColumn in NUMBER,
											 val in DATE)
is
begin
  SetValasDate(anySHEET,outBook,CellRow,CellColumn,val);
end SetValasDate;

-------------------------------------------------------------------------------
PROCEDURE SetValasDate(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                       CellRow in NUMBER,CellColumn in NUMBER,
											 val in DATE)
is
  tmpVal TCellValue;
begin
  tmpVal.R:=CellRow;
  tmpVal.C:=CellColumn;
  tmpVal.D:=val;
  SetVal(anySHEET,anyBook,tmpVal);
end SetValasDate;

-------------------------------------------------------------------------------
PROCEDURE SetValasDate(CellRow in NUMBER,CellColumn in VARCHAR2,
                       val in DATE)
is
begin
  SetValasDate(outSHEET,outBook,CellRow,CN(CellColumn),val);
end SetValasDate;

-------------------------------------------------------------------------------
PROCEDURE SetValasDate(anySHEET in VARCHAR2,
                       CellRow in NUMBER,CellColumn in VARCHAR2,
											 val in DATE)
is
begin
  SetValasDate(anySHEET,outBook,CellRow,CN(CellColumn),val);
end SetValasDate;

-------------------------------------------------------------------------------
PROCEDURE SetValasDate(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                       CellRow in NUMBER,CellColumn in VARCHAR2,
											 val in DATE)
is
begin
  SetValasDate(anySHEET,anyBook,CellRow,CN(CellColumn),val);
end SetValasDate;

-- Сохранение значения, как числа.
-------------------------------------------------------------------------------
PROCEDURE SetValasNUMBER(CellRow in NUMBER,CellColumn in NUMBER,
                         val in NUMBER)
is
begin
  SetValasNUMBER(outSHEET,outBook,CellRow,CellColumn,val);
end SetValasNUMBER;

-------------------------------------------------------------------------------
PROCEDURE SetValasNUMBER(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in NUMBER)
is
begin
  SetValasNUMBER(anySHEET,outBook,CellRow,CellColumn,val);
end SetValasNUMBER;

-------------------------------------------------------------------------------
PROCEDURE SetValasNUMBER(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in NUMBER)
is
  tmpVal TCellValue;
begin
  tmpVal.R:=CellRow;
  tmpVal.C:=CellColumn;
  tmpVal.N:=val;
  SetVal(anySHEET,anyBook,tmpVal);
end SetValasNUMBER;

-------------------------------------------------------------------------------
PROCEDURE SetValasNUMBER(CellRow in NUMBER,CellColumn in VARCHAR2,
                         val in NUMBER)
is
begin
  SetValasNUMBER(outSHEET,outBook,CellRow,CN(CellColumn),val);
end SetValasNUMBER;

-------------------------------------------------------------------------------
PROCEDURE SetValasNUMBER(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in NUMBER)
is
begin
  SetValasNUMBER(anySHEET,outBook,CellRow,CN(CellColumn),val);
end SetValasNUMBER;

-------------------------------------------------------------------------------
PROCEDURE SetValasNUMBER(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in NUMBER)
is
begin
  SetValasNUMBER(anySHEET,anyBook,CellRow,CN(CellColumn),val);
end SetValasNUMBER;

-- Сохранение значения, как строки.
-------------------------------------------------------------------------------
PROCEDURE SetValasString(CellRow in NUMBER,CellColumn in NUMBER,
                         val in VARCHAR2)
is
begin
  SetValasString(outSHEET,outBook,CellRow,CellColumn,val);
end SetValasString;

-------------------------------------------------------------------------------
PROCEDURE SetValasString(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in VARCHAR2)
is
begin
  SetValasString(anySHEET,outBook,CellRow,CellColumn,val);
end;

-------------------------------------------------------------------------------
PROCEDURE SetValasString(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in VARCHAR2)
is
  tmpVal TCellValue;
begin
  tmpVal.R:=CellRow;
  tmpVal.C:=CellColumn;
  tmpVal.S:=val;
  SetVal(anySHEET,anyBook,tmpVal);
end SetValasString;

-------------------------------------------------------------------------------
PROCEDURE SetValasString(CellRow in NUMBER,CellColumn in VARCHAR2,
                         val in VARCHAR2)
is
begin
  SetValasString(inSHEET,outBook,CellRow,CN(CellColumn),val);
end SetValasString;

-------------------------------------------------------------------------------
PROCEDURE SetValasString(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in VARCHAR2)
is
begin
  SetValasString(anySHEET,outBook,CellRow,CN(CellColumn),val);
end SetValasString;

-------------------------------------------------------------------------------
PROCEDURE SetValasString(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in VARCHAR2)
is
begin
  SetValasString(anySHEET,anyBook,CellRow,CN(CellColumn),val);
end SetValasString;

-- Сохранение формулы.
-------------------------------------------------------------------------------
PROCEDURE SetFormula(CellRow in NUMBER,CellColumn in NUMBER,
                         val in VARCHAR2)
is
begin
  SetFormula(outSHEET,outBook,CellRow,CellColumn,val);
end SetFormula;

-------------------------------------------------------------------------------
PROCEDURE SetFormula(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in VARCHAR2)
is
begin
  SetFormula(anySHEET,outBook,CellRow,CellColumn,val);
end SetFormula;

-------------------------------------------------------------------------------
PROCEDURE SetFormula(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in NUMBER,
											   val in VARCHAR2)
is
  tmpVar NUMBER;
begin
	if not isSHEET_exist(anySHEET,anyBOOK) then
	  raise_application_Error(-20443,
		  'Sheet: '||anySHEET||'  is missing in Book: '||anyBook||'!');
	end if;	
	update KOCEL.SHEETS set F=val
		where (BOOK=anyBOOK) and (SHEET=anySHEET) 
      and (R=CellRow) and (C=CellColumn);
	if SQL%rowcount = 0 then
	  begin
	    select Fmt into tmpVar from KOCEL.SHEETS 
	      where (BOOK=anyBook) and (SHEET=anySHEET) and (R=0) and (C=CellColumn);
	  exception
	    when no_data_found then
	      tmpVar:=0;
	  end;
	  insert into KOCEL.SHEETS
	     values(CellRow,CellColumn,null,null,null,val,anySHEET,anyBook,tmpVar);
  end if;
end SetFormula;

-------------------------------------------------------------------------------
PROCEDURE SetFormula(CellRow in NUMBER,CellColumn in VARCHAR2,
                         val in VARCHAR2)
is
begin
  SetFormula(outSHEET,outBook,CellRow,CN(CellColumn),val);
end SetFormula;

-------------------------------------------------------------------------------
PROCEDURE SetFormula(anySHEET in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in VARCHAR2)
is
begin
  SetFormula(anySHEET,outBook,CellRow,CN(CellColumn),val);
end SetFormula;

-------------------------------------------------------------------------------
PROCEDURE SetFormula(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                         CellRow in NUMBER,CellColumn in VARCHAR2,
											   val in VARCHAR2)
is
begin
  SetFormula(anySHEET,anyBook,CellRow,CN(CellColumn),val);
end SetFormula;

-- Сохранение колонки.
-------------------------------------------------------------------------------
PROCEDURE SetColumn(StartRow in NUMBER,StartColumn in NUMBER,
                    ColumnVals in TColumn)
is
begin
  SetColumn(outSHEET,outBook,StartRow,StartColumn,ColumnVals);
end SetColumn;

-------------------------------------------------------------------------------
PROCEDURE SetColumn(asColumn in NUMBER,ColumnVals in TColumn)
is
begin
  SetColumn(outSHEET,outBook,asColumn,ColumnVals);
end SetColumn;

-------------------------------------------------------------------------------
PROCEDURE SetColumn(anySHEET in VARCHAR2,
                    StartRow in NUMBER,StartColumn in NUMBER,
                    ColumnVals in TColumn)
is
begin
  SetColumn(anySHEET,outBook,StartRow,StartColumn,ColumnVals);
end SetColumn;

-------------------------------------------------------------------------------
PROCEDURE SetColumn(anySHEET in VARCHAR2,
                    asColumn in NUMBER,ColumnVals in TColumn)
is
begin
  SetColumn(anySHEET,outBook,asColumn,ColumnVals);
end SetColumn;

-------------------------------------------------------------------------------
PROCEDURE SetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   StartRow in NUMBER,StartColumn in NUMBER,
                   ColumnVals in TColumn)
is
  i NUMBER;
  tmpVar NUMBER;
begin
	if not isSHEET_exist(anySHEET,anyBOOK) then
	  raise_application_Error(-20443,
		  'Sheet: '||anySHEET||'  is missing in Book: '||anyBook||'!');
	end if;
  delete from KOCEL.SHEETS 
    where (upper(SHEET)=upper(anySHEET))
      and (upper(BOOK)=upper(anyBOOK))
      and (R >= StartRow)
      and (C = StartColumn);
  if ColumnVals.count=0 then return; end if;   
  i:=ColumnVals.first;
  -- Находим формат колонки.
  begin
    select Fmt into tmpVar from KOCEL.SHEETS 
      where (BOOK=anyBook) and (SHEET=anySHEET) and (R=0) and (C=StartColumn);
  exception
    when no_data_found then
      tmpVar:=0;
  end;
	loop
		insert into KOCEL.SHEETS values( 
		  StartRow+i-1,
			StartColumn,
		  ColumnVals(i).N,
		  ColumnVals(i).D,
		  ColumnVals(i).S,
		  ColumnVals(i).F,
			anySHEET,
			anyBook,
      tmpVar);
    exit when i=ColumnVals.last;
    i:=ColumnVals.next(i);  
	end loop;
end SetColumn;

-------------------------------------------------------------------------------
PROCEDURE SetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                    asColumn in NUMBER,ColumnVals in TColumn)
is
  i NUMBER;
  tmpVar NUMBER;
begin
	if not isSHEET_exist(anySHEET,anyBOOK) then
	  raise_application_Error(-20443,
		  'Sheet: '||anySHEET||'  is missing in Book: '||anyBook||'!');
	end if;	
  delete from KOCEL.SHEETS 
    where (upper(SHEET)=upper(anySHEET))
      and (upper(BOOK)=upper(anyBOOK))
      and (C = asColumn);
  if ColumnVals.count=0 then return; end if;   
  i:=ColumnVals.first;
  begin
    select Fmt into tmpVar from KOCEL.SHEETS 
      where (BOOK=anyBOOK) and (SHEET=anySHEET) and (R=0) and (C=asColumn);
  exception
    when no_data_found then
      tmpVar:=0;
  end;
	loop
		insert into KOCEL.SHEETS values( 
		  i,
			asColumn,
		  ColumnVals(i).N,
		  ColumnVals(i).D,
		  ColumnVals(i).S,
		  ColumnVals(i).F,
			anySHEET,
			anyBook,
      tmpVar);
    exit when i=ColumnVals.last;
    i:=ColumnVals.next(i);  
	end loop;
end SetColumn;

-------------------------------------------------------------------------------
PROCEDURE SetColumn(StartRow in NUMBER,StartColumn in VARCHAR2,
                    ColumnVals in TColumn)
is
begin
  SetColumn(outSHEET,outBook,StartRow,CN(StartColumn),ColumnVals);
end SetColumn;

-------------------------------------------------------------------------------
PROCEDURE SetColumn(asColumn in VARCHAR2,ColumnVals in TColumn)
is
begin
  SetColumn(outSHEET,outBook,CN(asColumn),ColumnVals);
end SetColumn;

-------------------------------------------------------------------------------
PROCEDURE SetColumn(anySHEET in VARCHAR2,
                   StartRow in NUMBER,StartColumn in VARCHAR2,
                   ColumnVals in TColumn)
is
begin
  SetColumn(anySHEET,outBook,StartRow,CN(StartColumn),ColumnVals);
end SetColumn;

-------------------------------------------------------------------------------
PROCEDURE SetColumn(anySHEET in VARCHAR2,
                    asColumn in VARCHAR2,ColumnVals in TColumn)
is
begin
  SetColumn(anySHEET,outBook,CN(asColumn),ColumnVals);
end SetColumn;

-------------------------------------------------------------------------------
PROCEDURE SetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                   StartRow in NUMBER,StartColumn in VARCHAR2,
                   ColumnVals in TColumn)
is
begin
  SetColumn(anySHEET,anyBook,StartRow,CN(StartColumn),ColumnVals);
end SetColumn;

-------------------------------------------------------------------------------
PROCEDURE SetColumn(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                    asColumn in VARCHAR2,ColumnVals in TColumn)
is
begin
  SetColumn(anySHEET,anyBook,CN(asColumn),ColumnVals);
end SetColumn;

-- Сохранение ряда.
-------------------------------------------------------------------------------
PROCEDURE SetRow(StartRow in NUMBER,StartColumn in NUMBER,
                 RowVals in TRow)
is
begin
  SetRow(outSHEET,outBook,StartRow,StartColumn,RowVals);
end SetRow;

-------------------------------------------------------------------------------
PROCEDURE SetRow(asRow in NUMBER,RowVals in TRow)
is
begin
  SetRow(outSHEET,outBook,asRow,RowVals);
end;

-------------------------------------------------------------------------------
PROCEDURE SetRow(anySHEET in VARCHAR2,
                 StartRow in NUMBER,StartColumn in NUMBER,
                 RowVals in TRow)
is
begin
  SetRow(anySHEET,outBook,StartRow,StartColumn,RowVals);
end SetRow;

-------------------------------------------------------------------------------
PROCEDURE SetRow(anySHEET in VARCHAR2,
                 asRow in NUMBER,RowVals in TRow)
is
begin
  SetRow(anySHEET,outBook,asRow,RowVals);
end SetRow;

-------------------------------------------------------------------------------
PROCEDURE SetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                 StartRow in NUMBER,StartColumn in NUMBER,
                 RowVals in TRow)
is
  i NUMBER;
  tmpVar NUMBER;
begin
	if not isSHEET_exist(anySHEET,anyBOOK) then
	  raise_application_Error(-20443,
		  'Sheet: '||anySHEET||'  is missing in Book: '||anyBook||'!');
	end if;	
  delete from KOCEL.SHEETS 
    where (upper(SHEET)=upper(anySHEET))
      and (upper(BOOK)=upper(anyBOOK))
      and (R = StartRow)
      and (C >= StartColumn);
  if RowVals.count=0 then return; end if;   
  i:=RowVals.first;
  begin
    select Fmt into tmpVar from KOCEL.SHEETS 
      where (BOOK=anyBOOK) and (SHEET=anySHEET) and (R=StartRow) and (C=0);
  exception
    when no_data_found then
      tmpVar:=0;
  end;
	loop
		insert into KOCEL.SHEETS values( 
		  StartRow,
			StartColumn+i-1,
		  RowVals(i).N,
		  RowVals(i).D,
		  RowVals(i).S,
		  RowVals(i).F,
			anySHEET,
			anyBook,
      tmpVar);
    exit when i=RowVals.last;
    i:=RowVals.next(i);  
	end loop;
end SetRow;

-------------------------------------------------------------------------------
PROCEDURE SetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                 asRow in NUMBER,RowVals in TRow)
is
  i NUMBER;
  tmpVar NUMBER; 
begin
	if not isSHEET_exist(anySHEET,anyBOOK) then
	  raise_application_Error(-20443,
		  'Sheet: '||anySHEET||'  is missing in Book: '||anyBook||'!');
	end if;	
  delete from KOCEL.SHEETS 
    where (upper(SHEET)=upper(anySHEET))
      and (upper(BOOK)=upper(anyBOOK))
      and (R = asRow);
  if RowVals.count=0 then return; end if;   
  i:=RowVals.first;
  begin
    select Fmt into tmpVar from KOCEL.SHEETS 
      where (BOOK=anyBOOK) and (SHEET=anySHEET) and (R=asRow) and (C=0);
  exception
    when no_data_found then
      tmpVar:=0;
  end;
	loop
		insert into KOCEL.SHEETS values( 
		  asRow,
			i,
		  RowVals(i).N,
		  RowVals(i).D,
		  RowVals(i).S,
		  RowVals(i).F,
			anySHEET,
			anyBook,
      tmpVar);
    exit when i=RowVals.last;
    i:=RowVals.next(i);  
	end loop;
end SetRow;

-------------------------------------------------------------------------------
PROCEDURE SetRow(StartRow in NUMBER,StartColumn in VARCHAR2,
                 RowVals in TRow)
is
begin
  SetRow(outSHEET,outBook,StartRow,CN(StartColumn),RowVals);
end SetRow;

-------------------------------------------------------------------------------
PROCEDURE SetRow(anySHEET in VARCHAR2,
                 StartRow in NUMBER,StartColumn in VARCHAR2,
                 RowVals in TRow)
is
begin
  SetRow(anySHEET,outBook,StartRow,CN(StartColumn),RowVals);
end SetRow;

-------------------------------------------------------------------------------
PROCEDURE SetRow(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                 StartRow in NUMBER,StartColumn in VARCHAR2,
                 RowVals in TRow)
is
begin
  SetRow(anySHEET,anyBook,StartRow,CN(StartColumn),RowVals);
end SetRow;

-- Сохранение диапазона.
-------------------------------------------------------------------------------
PROCEDURE SetRange(StartRow in NUMBER,StartColumn in NUMBER,
									RangeVals in TRange)
is
begin
 SetRange(outSHEET,outBook,StartRow,StartColumn,RangeVals);
end SetRange;

-------------------------------------------------------------------------------
PROCEDURE SetRange(anySHEET in VARCHAR2,
                  StartRow in NUMBER,StartColumn in NUMBER,
									RangeVals in TRange)
is
begin
 SetRange(anySHEET,outBook,StartRow,StartColumn,RangeVals);
end SetRange;

-------------------------------------------------------------------------------
PROCEDURE SetRange(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  StartRow in NUMBER,StartColumn in NUMBER,
									RangeVals in TRange)
is
  maxCol NUMBER;
  maxRow NUMBER;
  i NUMBER;
  j NUMBER;
begin
	if not isSHEET_exist(anySHEET,anyBOOK) then
	  raise_application_Error(-20443,
		  'Sheet: '||anySHEET||'  is missing in Book: '||anyBook||'!');
	end if;
  if RangeVals.count=0 then return; end if;
  maxRow:=RangeVals.Last;
  -- находим максимальную колонку в диапазоне
  maxCol:=null;
  i:=RangeVals.first;
  loop
    if (maxCol is null) or (maxCol<RangeVals(i).Last) then
      maxCol:=RangeVals(i).Last;
    end if;  
    exit when i=maxRow; 
    i:=RangeVals.next(i);
  end loop;
  -- если диапазон пустой, то выход
  if maxCol is null then return; end if;
  d('StartRow =>'||StartRow||' MaxRow =>'||MaxRow||
    ' StartColumn =>'||StartColumn||' MaxColumn =>'||MaxCol
     ,'cell range');
  -- удаляем квадрат от точки (StartRow,StartColumn),
  -- до максимального (ряда,колонки) в диапазоне	
  delete from KOCEL.SHEETS 
    where (upper(SHEET)=upper(anySHEET))
      and (upper(BOOK)=upper(anyBOOK))
      and (R between StartRow and StartRow+MaxRow-1)
      and (C between StartColumn and StartColumn+maxCol-1);
  -- заполняем таблицу    
  i:=RangeVals.first;
	loop
	  j:=RangeVals(i).first;
    if j is not null then
			loop
        d('i,j '||i||','||j,'cell range');
				insert into KOCEL.SHEETS values( 
				  StartRow+i-1,
					StartColumn+j-1,
				  RangeVals(i)(j).N,
				  RangeVals(i)(j).D,
				  RangeVals(i)(j).S,
				  RangeVals(i)(j).F,
					anySHEET,
					anyBook,
          0);
        d('inserted '||to_char(StartRow+i-1)||','||to_char(StartColumn+j-1),
          'cell range');  
        exit when j=RangeVals(i).last;
        j:=RangeVals(i).next(j);
	  	end loop;
    end if;  
    exit when i=maxRow;
    i:=RangeVals.next(i);
	end loop;
end SetRange;

-------------------------------------------------------------------------------
PROCEDURE SetRange(StartRow in NUMBER,StartColumn in VARCHAR2,
									RangeVals in TRange)
is
begin
 SetRange(outSHEET,outBook,StartRow,CN(StartColumn),RangeVals);
end SetRange;

-------------------------------------------------------------------------------
PROCEDURE SetRange(anySHEET in VARCHAR2,
                  StartRow in NUMBER,StartColumn in VARCHAR2,
									RangeVals in TRange)
is
begin
 SetRange(anySHEET,outBook,StartRow,CN(StartColumn),RangeVals);
end SetRange;

-------------------------------------------------------------------------------
PROCEDURE SetRange(anySHEET in VARCHAR2,anyBook in VARCHAR2,
                  StartRow in NUMBER,StartColumn in VARCHAR2,
									RangeVals in TRange)
is
begin
 SetRange(anySHEET,anyBook,StartRow,CN(StartColumn),RangeVals);
end SetRange;

-- Копирование листа.
-------------------------------------------------------------------------------
PROCEDURE CopySHEET(fromSHEET in VARCHAR2,fromBook in VARCHAR2,
                    toSHEET in VARCHAR2,toBook in VARCHAR2,
										doOverwrire in BOOLEAN default false)
is
begin
	if not isSHEET_exist(fromSHEET,fromBook) then
	  raise_application_Error(-20443,
		  'Sheet: '||fromSHEET||'  is missing in Book: '||fromBook||'!');
	end if;	
	if isSHEET_exist(toSHEET,toBOOK) and (not doOverwrire) then
	  raise_application_Error(-20443,
		  'Sheet: '||toSHEET||' is already in Book: '||toBook||'!');
	end if;	
  for c in (select * from KOCEL.SHEETS 
	  where (SHEET=fromSHEET)
		  and (Book=fromBook))
	loop
    c.SHEET:=toSHEET;
		c.BOOK:=toBook;
		insert into KOCEL.SHEETS values c;	
	end loop;		
end CopySHEET;

-- Копирование книги.
-------------------------------------------------------------------------------
PROCEDURE CopyBook(fromBook in VARCHAR2,toBook in VARCHAR2,
									 doOverwrire in BOOLEAN default false)
is
  tmpVar NUMBER;
begin
  select count(*) into tmpVar from KOCEL.SHEETS 
	  where (BOOK=fromBook) and (rownum < 2);
  if tmpVar=0 then
	  raise_application_Error(-20443,
		  'Book: '||fromBook||' is missing!');
	end if;
  select count(*) into tmpVar from KOCEL.SHEETS 
	  where (BOOK=toBook) and (rownum < 2);
  if (tmpVar!=0) and (not doOverwrire) then
	  raise_application_Error(-20443,
		  'Book: '||fromBook||' already exists!');
	end if;
  for c in (select * from KOCEL.SHEETS where Book=fromBook)
  loop
    c.BOOK:=toBook;
    insert into KOCEL.SHEETS values c;  
  end loop;    
  for c in (select * from KOCEL.SHEETS_ORDER where Book=fromBook)
  loop
    c.BOOK:=toBook;
    insert into KOCEL.SHEETS_ORDER values c;  
  end loop;    
  for c in (select * from KOCEL.SHEET_PARS where Book=fromBook)
  loop
    c.BOOK:=toBook;
    insert into KOCEL.SHEET_PARS values c;  
  end loop;    
  for c in (select * from KOCEL.BOOKS_R1C1 where Book=fromBook)
  loop
    c.BOOK:=toBook;
    insert into KOCEL.BOOKS_R1C1 values c;  
  end loop;    
  for c in (select * from KOCEL.MERGED_CELLS where Book=fromBook)
  loop
    c.BOOK:=toBook;
    insert into KOCEL.MERGED_CELLS values c;  
  end loop;    
end CopyBook;

-- Переименование книги.
PROCEDURE RenameBook(fromBook in VARCHAR2,toBook in VARCHAR2)
is
  tmpVar NUMBER;
begin
  select count(*) into tmpVar from KOCEL.SHEETS 
    where (BOOK=fromBook) and (rownum < 2);
  if tmpVar=0 then
    raise_application_Error(-20443,
      'Book: '||fromBook||' is missing!');
  end if;
  select count(*) into tmpVar from KOCEL.SHEETS 
    where (BOOK=toBook) and (rownum < 2);
  if (tmpVar!=0) then
    raise_application_Error(-20443,
      'Book: '||fromBook||' already exists!');
  end if;
  update KOCEL.SHEETS set 
    BOOK = toBook
    where Book=fromBook;    
  update KOCEL.SHEETS_ORDER set 
    BOOK = toBook
    where Book=fromBook;    
  update KOCEL.SHEET_PARS set 
    BOOK = toBook
    where Book=fromBook;    
  update KOCEL.BOOKS_R1C1 set 
    BOOK = toBook
    where Book=fromBook;    
  update KOCEL.MERGED_CELLS set 
    BOOK = toBook
    where Book=fromBook;    
end RenameBook;

-- Удаление книги.
-------------------------------------------------------------------------------
PROCEDURE DeleteBook(DBook in VARCHAR2)
is
  tmpVar VARCHAR2(256);
begin
  tmpVar:= upper(DBook);
  delete from KOCEL.SHEETS where upper(BOOK)=tmpVar;
  delete from KOCEL.SHEETS_ORDER where upper(BOOK)=tmpVar;
  delete from KOCEL.SHEET_PARS where upper(BOOK)=tmpVar;
  delete from KOCEL.BOOKS_R1C1 where upper(BOOK)=tmpVar;
  delete from KOCEL.MERGED_CELLS where upper(BOOK)=tmpVar;
end DeleteBook;

-- Удаление листа.
-------------------------------------------------------------------------------
PROCEDURE DeleteSheet(DBook in VARCHAR2, DSheet in VARCHAR2)
is
  tmpS VARCHAR2(256);
  tmpB VARCHAR2(256);
begin
  tmpS:= upper(DSheet);
  tmpB:= upper(DBook);
  delete from KOCEL.SHEETS where upper(BOOK)=tmpB and upper(SHEET)=tmpS;
  delete from KOCEL.SHEETS_ORDER where upper(BOOK)=tmpB and upper(SHEET)=tmpS;
  delete from KOCEL.SHEET_PARS where upper(BOOK)=tmpB and upper(SHEET)=tmpS;
  delete from KOCEL.MERGED_CELLS where upper(BOOK)=tmpB and upper(SHEET)=tmpS;
end DeleteSheet;

-- Очистка данных всех листов книги.
-- Порядок листов и форматирование колонок остаётся.
-- Объединённые ячейки разъединяются.
-------------------------------------------------------------------------------
PROCEDURE ClearBook(DBook in VARCHAR2)
is
  tmpVar VARCHAR2(256);
begin
  tmpVar:= upper(DBook);
  delete from KOCEL.SHEETS where upper(BOOK)=tmpVar and R>0 and C>0;
  delete from KOCEL.MERGED_CELLS where upper(BOOK)=tmpVar;
end ClearBook;

-------------------------------------------------------------------------------
PROCEDURE ClearOutBook
is
begin
  ClearBook(outBook);
end ClearOutBook;

-- Очистка данных листа книги.
-- Порядок листов и форматирование колонок остаётся.
-- Объединённые ячейки разъединяются.
-------------------------------------------------------------------------------
PROCEDURE ClearSheet(DBook in VARCHAR2, DSheet in VARCHAR2)
is
  tmpS VARCHAR2(256);
  tmpB VARCHAR2(256);
begin
  tmpS:= upper(DSheet);
  tmpB:= upper(DBook);
  delete from KOCEL.SHEETS 
    where upper(BOOK)=tmpB and upper(SHEET)=tmpS and R>0 and C>0;
  delete from KOCEL.MERGED_CELLS 
    where upper(BOOK)=tmpB and upper(SHEET)=tmpS;
end ClearSheet;

-------------------------------------------------------------------------------
PROCEDURE ClearOutSheet(DSheet in VARCHAR2)
is
begin
  ClearSheet(outBook,DSheet);
end ClearOutSheet;

-------------------------------------------------------------------------------
PROCEDURE ClearOutSheet
is
begin
  ClearSheet(outBook,outSheet);
end ClearOutSheet;

-- Предоставление колонки или ряда, состоящих из дат, для запроса.
-------------------------------------------------------------------------------
FUNCTION Dates(RowVals in TRow)
return KOCEL.TDATES pipelined
is
  i PLS_INTEGER;
  l PLS_INTEGER;
begin
  i:=RowVals.first;
  l:=RowVals.last;
	loop
	  if RowVals(i).D is not null then
      pipe Row(RowVals(i).D);
    end if;
    exit when i=l;
    i:=RowVals.next(i);  
	end loop;
	return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.CELL.Dates');
    raise;
end Dates;

-------------------------------------------------------------------------------
FUNCTION Dates(ColumnVals in TColumn)
return KOCEL.TDATES pipelined
is
  i PLS_INTEGER;
  l PLS_INTEGER;
begin
  i:=ColumnVals.first;
  l:=ColumnVals.last;
	loop
	  if ColumnVals(i).D is not null then
	    pipe Row(ColumnVals(i).D);
    end if;
    exit when i=l;
    i:=ColumnVals.next(i);  
	end loop;
	return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.CELL.Dates');
    raise;
end Dates;

-- Предоставление колонки или ряда, состоящих из чисел, для запроса.
-------------------------------------------------------------------------------
FUNCTION Nums(RowVals in TRow)
return KOCEL.TNUMS pipelined
is
  i PLS_INTEGER;
  l PLS_INTEGER;
begin
  i:=RowVals.first;
  l:=RowVals.last;
	loop
	  if RowVals(i).N is not null then
      pipe Row(RowVals(i).N);
    end if;
    exit when i=l;
    i:=RowVals.next(i);  
	end loop;
	return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.CELL.Nums');
    raise;
end Nums;

-------------------------------------------------------------------------------
FUNCTION Nums(ColumnVals in TColumn)
return KOCEL.TNUMS pipelined
is
  i PLS_INTEGER;
  l PLS_INTEGER;
begin
  i:=ColumnVals.first;
  l:=ColumnVals.last;
	loop
	  if ColumnVals(i).N is not null then
	    pipe Row(ColumnVals(i).N);
    end if;
    exit when i=l;
    i:=ColumnVals.next(i);  
	end loop;
	return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.CELL.Nums');
    raise;
end Nums;

-- Предоставление колонки или ряда, состоящих из строк, для запроса.
-------------------------------------------------------------------------------
FUNCTION Strings(RowVals in TRow)
return KOCEL.TSTRINGS pipelined
is
  i PLS_INTEGER;
  l PLS_INTEGER;
begin
  i:=RowVals.first;
  l:=RowVals.last;
	loop
	  if RowVals(i).S is not null then
      pipe Row(RowVals(i).S);
    end if;
    exit when i=l;
    i:=RowVals.next(i);  
	end loop;
	return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.CELL.Strings');
    raise;
end Strings;

-------------------------------------------------------------------------------
FUNCTION Strings(ColumnVals in TColumn)
return KOCEL.TSTRINGS pipelined
is
  i PLS_INTEGER;
  l PLS_INTEGER;
begin
  i:=ColumnVals.first;
  l:=ColumnVals.last;
	loop
	  if ColumnVals(i).S is not null then
	    pipe Row(ColumnVals(i).S);
    end if;
    exit when i=l;
    i:=ColumnVals.next(i);  
	end loop;
	return;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.CELL.Strings');
    raise;
end Strings;

-- Преобразование буквы колонки в номер.
-------------------------------------------------------------------------------
FUNCTION Col2Num(columnChar in VARCHAR2) return NUMBER
is
  tmpVar VARCHAR2(10);
	tmpNum NUMBER;
	curChar NUMBER(2);
	
begin
  tmpVar:=trim(columnChar);
	tmpNum:=0;
	for i in 1..length(tmpVar)
	loop
	  if i>2 then 
		  raise_application_Error(-20443,'Column is greater then 256!');
		end if;
	  curChar:=ascii(upper(substr(tmpVar,i,1)));
		-- проверка что это буква английского алфавита
		if not (curChar between A and Z) then
		  raise_application_Error(-20443,
			  'Invalid letter: '||substr(tmpVar,i,1)||
				'In ColumnChar: '||tmpVar||' !');
		end if;
		case i
		  when 1 then tmpNum:=curChar-A+1;
			when 2 then
			  tmpNum:=tmpNum+(curChar-A+1)*(Z-A);
	  end case;
	end loop;
	return tmpNum;
end Col2Num;

-- Преобразование номера колонки в строку.
-------------------------------------------------------------------------------
FUNCTION Col2Char(columnNum in NUMBER) return VARCHAR2
is
  tmpVar NUMBER(3);
begin
  if ColumnNum between 1 and 256 then
    tmpVar:=floor(columnNum/(Z-A+1));
		if (tmpVar = 0) or (columnNum=(Z-A+1))then
		  return ' '||chr(columnNum+A-1);
		else
		  if mod(columnNum,Z-A+1)=0 then
		    return chr(tmpVar+A-2)||'Z';
			else
		    return chr(tmpVar+A-1)||chr(A+columnNum-tmpVar*(Z-A+1)-1);
			end if;
		end if;
  end if;
	raise_application_Error(-20443,'Column must be in 1..256!');
  return null;
end Col2Char;

-- Предоставление диапазона для запроса.
-------------------------------------------------------------------------------
FUNCTION RANGE(OutRange in TRange) 
return KOCEL.TCELLS pipelined
as 
  outRow KOCEL.TROW;
  tmpVar KOCEL.TVALUE;
  i PLS_INTEGER;
  j PLS_INTEGER;
  last_i PLS_INTEGER;
  last_j PLS_INTEGER;
begin
  tmpVar:=KOCEL.TVALUE;
  outRow:=KOCEL.TROW;
  i:=OutRange.first;
  last_i:=OutRange.last;
	loop
	  j:=OutRange(i).first;
	  last_j:=OutRange(i).last;
	  if last_j > 26 then 
	    raise_application_Error(-20443,
		  'Column must be in 1..26 to "Select from Range"!');
	  end if;	
		loop
		  tmpVar.N:=OutRange(i)(j).N;
		  tmpVar.D:=OutRange(i)(j).D;
		  tmpVar.S:=OutRange(i)(j).S;
		  tmpVar.F:=OutRange(i)(j).F;
		  tmpVar.R:=i;
		  tmpVar.C:=j;
      case j
		    when 1  then outRow.A:=tmpVar;
		    when 2  then outRow.B:=tmpVar;
		    when 3  then outRow.C:=tmpVar;
		    when 4  then outRow.D:=tmpVar;
		    when 5  then outRow.E:=tmpVar;
		    when 6  then outRow.F:=tmpVar;
		    when 7  then outRow.G:=tmpVar;
		    when 8  then outRow.H:=tmpVar;
		    when 9  then outRow.I:=tmpVar;
		    when 10	then outRow.J:=tmpVar;
		    when 11 then outRow.K:=tmpVar;
		    when 12 then outRow.L:=tmpVar;
		    when 13 then outRow.M:=tmpVar;
		    when 14 then outRow.N:=tmpVar;
		    when 15 then outRow.O:=tmpVar;
		    when 16 then outRow.P:=tmpVar;
		    when 17 then outRow.Q:=tmpVar;
		    when 18 then outRow.R:=tmpVar;
		    when 19 then outRow.S:=tmpVar;
		    when 20 then outRow.T:=tmpVar;
		    when 21 then outRow.U:=tmpVar;
		    when 22 then outRow.V:=tmpVar;
		    when 23 then outRow.W:=tmpVar;
		    when 24 then outRow.X:=tmpVar;
		    when 25 then outRow.Y:=tmpVar;
		    when 26 then outRow.Z:=tmpVar;
		  end case;
      exit when j=last_j;
      j:=OutRange(i).next(j);	
  	end loop;
	  pipe row(outRow);
    exit when i=last_i;
    outRow.ClearData;
    i:=OutRange.next(i);	
	end loop;
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.CELL.RANGE');
    raise;
end RANGE;

-- Предоставления листа для запроса.
-------------------------------------------------------------------------------
FUNCTION Vals(anySHEET in VARCHAR2,anyBOOK in VARCHAR2) 
return KOCEL.TCELLS pipelined
as 
  outRow KOCEL.TROW;
  tmpVar KOCEL.TVALUE;
  MCol NUMBER;
  curRow NUMBER;
begin
  tmpVar:=KOCEL.TVALUE;
  outRow:=KOCEL.TROW;
  curRow:=-1;
  select max(c) into MCol from KOCEL.SHEETS sh 
    where (sh.SHEET= anySHEET)
	    and (sh.BOOK= anyBOOK);
	if MCol > 26 then 
	  raise_application_Error(-20443,
		  'Column must be in 1..26 to "Select from Columns"!');
	end if;
  if MCol is null then		
	  raise_application_Error(-20443,
        'Sheet: '||anySHEET||' is missing in Book: '||anyBook||'!');
  end if;	  	
  for cells in (select R,C,N,D,S,F from KOCEL.SHEETS sh 
                  where (sh.SHEET=anySHEET)
	                  and (sh.BOOK=anyBOOK)
                    and (sh.R>0)
                    and (sh.C>0) 
                  order by R)
  loop
    if curRow = -1 then
      curRow:=cells.R;
    end if;  
  	if curRow < cells.R then
	    pipe row(outRow);
      outRow.ClearData;
      curRow:=cells.R;
    end if;
		tmpVar.N:=cells.N;
		tmpVar.D:=cells.D;
		tmpVar.S:=cells.S;
		tmpVar.F:=cells.F;
		tmpVar.R:=cells.R;
		tmpVar.C:=cells.C;
    case cells.c
	    when 1  then outRow.A:=tmpVar;
	    when 2  then outRow.B:=tmpVar;
	    when 3  then outRow.C:=tmpVar;
	    when 4  then outRow.D:=tmpVar;
	    when 5  then outRow.E:=tmpVar;
	    when 6  then outRow.F:=tmpVar;
	    when 7  then outRow.G:=tmpVar;
	    when 8  then outRow.H:=tmpVar;
	    when 9  then outRow.I:=tmpVar;
	    when 10	then outRow.J:=tmpVar;
	    when 11 then outRow.K:=tmpVar;
	    when 12 then outRow.L:=tmpVar;
	    when 13 then outRow.M:=tmpVar;
	    when 14 then outRow.N:=tmpVar;
	    when 15 then outRow.O:=tmpVar;
	    when 16 then outRow.P:=tmpVar;
	    when 17 then outRow.Q:=tmpVar;
	    when 18 then outRow.R:=tmpVar;
	    when 19 then outRow.S:=tmpVar;
	    when 20 then outRow.T:=tmpVar;
	    when 21 then outRow.U:=tmpVar;
	    when 22 then outRow.V:=tmpVar;
	    when 23 then outRow.W:=tmpVar;
	    when 24 then outRow.X:=tmpVar;
	    when 25 then outRow.Y:=tmpVar;
	    when 26 then outRow.Z:=tmpVar;
	  end case;	
	end loop;
  if curRow > 0 then
    pipe row(outRow);
  end if;
  return;  
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.CELL.Vals');
    raise;
end Vals;

-- Предоставления текущего листа для запроса. 
-------------------------------------------------------------------------------
FUNCTION inVals 
return KOCEL.TCELLS pipelined
is
  outRow KOCEL.TROW;
  tmpVar KOCEL.TVALUE;
  MCol NUMBER;
  curRow NUMBER;
begin
  tmpVar:=KOCEL.TVALUE;
  outRow:=KOCEL.TROW;
  curRow:=-1;
  select max(c) into MCol from KOCEL.SHEETS sh 
    where (sh.SHEET= inSHEET)
	    and (sh.BOOK= inBOOK);
	if MCol > 26 then 
	  raise_application_Error(-20443,
		  'Column must be in 1..26 to "Select from Columns"!');
	end if;
  if MCol is null then		
	  raise_application_Error(-20443,
      'Sheet: '||inSHEET||' is missing in Book: '||inBook||'!');
  end if;	  	
  for cells in (select R,C,N,D,S,F from KOCEL.SHEETS sh 
                  where (sh.SHEET=inSHEET)
	                  and (sh.BOOK=inBOOK)
                    and (R>0)
                    and (C>0) 
                  order by R)
  loop
    if curRow = -1 then
      curRow:=cells.R;
    end if;  
  	if curRow < cells.R then
	    pipe row(outRow);
      outRow.ClearData;
      curRow:=cells.R;
    end if;
		tmpVar.N:=cells.N;
		tmpVar.D:=cells.D;
		tmpVar.S:=cells.S;
		tmpVar.F:=cells.F;
		tmpVar.R:=cells.R;
		tmpVar.C:=cells.C;
    case cells.c
	    when 1  then outRow.A:=tmpVar;
	    when 2  then outRow.B:=tmpVar;
	    when 3  then outRow.C:=tmpVar;
	    when 4  then outRow.D:=tmpVar;
	    when 5  then outRow.E:=tmpVar;
	    when 6  then outRow.F:=tmpVar;
	    when 7  then outRow.G:=tmpVar;
	    when 8  then outRow.H:=tmpVar;
	    when 9  then outRow.I:=tmpVar;
	    when 10	then outRow.J:=tmpVar;
	    when 11 then outRow.K:=tmpVar;
	    when 12 then outRow.L:=tmpVar;
	    when 13 then outRow.M:=tmpVar;
	    when 14 then outRow.N:=tmpVar;
	    when 15 then outRow.O:=tmpVar;
	    when 16 then outRow.P:=tmpVar;
	    when 17 then outRow.Q:=tmpVar;
	    when 18 then outRow.R:=tmpVar;
	    when 19 then outRow.S:=tmpVar;
	    when 20 then outRow.T:=tmpVar;
	    when 21 then outRow.U:=tmpVar;
	    when 22 then outRow.V:=tmpVar;
	    when 23 then outRow.W:=tmpVar;
	    when 24 then outRow.X:=tmpVar;
	    when 25 then outRow.Y:=tmpVar;
	    when 26 then outRow.Z:=tmpVar;
	  end case;	
	end loop;
  if curRow > 0 then
    pipe row(outRow);
  end if;
  return;  
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.CELL.inVals');
    raise;
end inVals;

-- Предоставления листа для запроса в виде строковых значений.
-------------------------------------------------------------------------------
FUNCTION Vals_as_Str(anySHEET in VARCHAR2,anyBOOK in VARCHAR2) 
return KOCEL.TSCELLS pipelined
as 
  outRow KOCEL.TSROW;
  tmpVar VARCHAR2(4000);
  MCol NUMBER;
  curRow NUMBER;
begin
  outRow:=KOCEL.TSROW;
  curRow:=-1;
  select max(c) into MCol from KOCEL.SHEETS sh 
    where (sh.SHEET= anySHEET)
	    and (sh.BOOK= anyBOOK);
	if MCol > 26 then 
	  raise_application_Error(-20443,
		  'Column must be in 1..26 to "Select from Columns"!');
	end if;
  if MCol is null then	
	  raise_application_Error(-20443,
        'Sheet: '||anySHEET||' is missing in Book: '||anyBook||'!');
  end if;	  	
  for cells in (select R,C,N,D,S,F from KOCEL.SHEETS sh 
                  where (sh.SHEET=anySHEET)
	                  and (sh.BOOK=anyBOOK)
                    and (sh.R>0)
                    and (sh.C>0) 
                  order by R)
  loop
    if curRow = -1 then
      curRow:=cells.R;
    end if;  
  	if curRow < cells.R then
	    pipe row(outRow);
      outRow.ClearData;
      curRow:=cells.R;
    end if;
    tmpVar:=case
      when cells.D is not null then to_char(cells.D)
      when cells.N is not null then to_char(cells.N)
		  else cells.S
      end;
    case cells.c
	    when 1  then outRow.A:=tmpVar;
	    when 2  then outRow.B:=tmpVar;
	    when 3  then outRow.C:=tmpVar;
	    when 4  then outRow.D:=tmpVar;
	    when 5  then outRow.E:=tmpVar;
	    when 6  then outRow.F:=tmpVar;
	    when 7  then outRow.G:=tmpVar;
	    when 8  then outRow.H:=tmpVar;
	    when 9  then outRow.I:=tmpVar;
	    when 10	then outRow.J:=tmpVar;
	    when 11 then outRow.K:=tmpVar;
	    when 12 then outRow.L:=tmpVar;
	    when 13 then outRow.M:=tmpVar;
	    when 14 then outRow.N:=tmpVar;
	    when 15 then outRow.O:=tmpVar;
	    when 16 then outRow.P:=tmpVar;
	    when 17 then outRow.Q:=tmpVar;
	    when 18 then outRow.R:=tmpVar;
	    when 19 then outRow.S:=tmpVar;
	    when 20 then outRow.T:=tmpVar;
	    when 21 then outRow.U:=tmpVar;
	    when 22 then outRow.V:=tmpVar;
	    when 23 then outRow.W:=tmpVar;
	    when 24 then outRow.X:=tmpVar;
	    when 25 then outRow.Y:=tmpVar;
	    when 26 then outRow.Z:=tmpVar;
	  end case;	
	end loop;
  if curRow > 0 then
    pipe row(outRow);
  end if;
  return;  
exception
  when no_data_needed then 
    null;
  when others then
    d(SQLERRM, 'ERROR in KOCEL.CELL.Vals_as_Str');
    raise;
end Vals_as_Str;

-- INITIALIZATION
begin
  A:= ascii('A');
  Z:= ascii('Z');
end CELL;
/
