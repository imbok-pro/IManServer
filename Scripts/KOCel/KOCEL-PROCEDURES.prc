-- KOCEL procedures
-- create 17.04.2009
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- update 17.05.2009 15.12.2009 27.12.2009 06.01.2010 28.01.2010 16.02.2010
--        26.03.2006 19.01.2015 18.03.2015 19.03.2015 09.02.2018 11.04.2019
--        19.12.2020
--*****************************************************************************


-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCEL.UPDATE_CELL(
  -- Номер ряда ячейки листа. 
  -- Ячейка с индксом 0 определяет параметры по умолчанию для всего ряда.
  UR in NUMBER,
  -- Номер колонки ячейки листа. 
  -- Ячейка с индксом 0 определяет параметры по умолчанию для всей колонки.
  UC in NUMBER,
  -- Значение ячейки. Лишь один параметр из (UN, UD, US)может быть не нулл.
  UN in FLOAT default null,
  UD in DATE default null,
  US in VARCHAR2 default null,
  -- Формула.
  UF in VARCHAR2 default null,
  -- Имя листа.
	USHEET in VARCHAR2,
  -- Имя книги.
  UBOOK in VARCHAR2,
  -- Номер формата, если не определён, то используется формат по умолчанию.
  UFmt in NUMBER default null)
-- Процедура изменения ячейки в листе книги. 
-- Можно использовать и для добавления ячеек к уже существующей книге.
-- Смотри описание типа KOSEL.TFOMAT и пример построения листа.
-- (KOCEL_PROCEDURES.prc)  
is
  tmpVar NUMBER;
begin
  -- Если формат нулл, то используем старый.
  if UFmt is null then
	  update KOCEL.SHEETS set
		  N=UN,D=UD,S=US,F=UF
			where (BOOK=UBOOK) and (SHEET=USHEET) and (R=UR) and (C=UC);
  else  
	  update KOCEL.SHEETS set
		  N=UN,D=UD,S=US,F=UF,Fmt=UFmt
			where (BOOK=UBOOK) and (SHEET=USHEET) and (R=UR) and (C=UC);
  end if;  
	if SQL%rowcount = 0 then
    -- Если формат нулл, то используем формат колонки.
    begin
      select Fmt into tmpVar from KOCEL.SHEETS 
        where (BOOK=UBOOK) and (SHEET=USHEET) and (R=0) and (C=UC);
    exception
      -- Если нет описания колонки, то используем формат по умолчанию.
      when no_data_found then
        tmpVar:=0;
    end;
	  insert into KOCEL.SHEETS values(UR,UC,UN,UD,US,UF,USHEET,UBOOK,tmpVar);
	end if;
end;
/
grant EXECUTE on KOCEL.UPDATE_CELL to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCEL.INSERT_CELL(
  -- Номер ряда ячейки листа. 
  -- Ячейка с индксом 0 определяет параметры по умолчанию для всего ряда.
  UR in NUMBER,
  -- Номер колонки ячейки листа. 
  -- Ячейка с индксом 0 определяет параметры по умолчанию для всей колонки.
  UC in NUMBER,
  -- Значение ячейки. Лишь один параметр из (UN, UD, US)может быть не нулл.
  UN in FLOAT default null,
  UD in DATE default null,
  US in VARCHAR2 default null,
  -- Формула.
  UF in VARCHAR2 default null,
  -- Имя листа.
	USHEET in VARCHAR2,
  -- Порядковый номер листа в книге.
	UNUM in VARCHAR2,
  -- Имя книги.
  UBOOK in VARCHAR2,
  -- Номер формата, если не определён, то используется формат по умолчанию.
  UFmt in NUMBER default null)
-- Процедура вставляет ячейку во временную таблицу.
-- Процедура может использоваться при импорте файла.
-- После добавления всех ячеек необходимо вызвать процедуру
-- KOCEL.COMMIT_INSERTS
-- Смотри описание типа KOSEL.TFOMAT и пример построения листа.
-- (KOCEL_PROCEDURES.prc)  
is
begin
  insert into KOCEL.TEMP_SHEET
    values(UR,UC,UN,UD,US,UF,USHEET,UNUM,UBOOK,UFmt);
end;
/
grant EXECUTE on KOCEL.INSERT_CELL to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCEL.INSERT_5CELLS(
  -- Число ячеек, которые реально нужно вставить в базу.
  UCOUNT in NUMBER,
  UR1 in NUMBER,UC1 in NUMBER, 
  UN1 in FLOAT,UD1 in DATE,US1 in VARCHAR2,UF1 in VARCHAR2,
  UFmt1 in NUMBER,
  UR2 in NUMBER,UC2 in NUMBER, 
  UN2 in FLOAT,UD2 in DATE,US2 in VARCHAR2,UF2 in VARCHAR2,
  UFmt2 in NUMBER,
  UR3 in NUMBER,UC3 in NUMBER, 
  UN3 in FLOAT,UD3 in DATE,US3 in VARCHAR2,UF3 in VARCHAR2,
  UFmt3 in NUMBER,
  UR4 in NUMBER,UC4 in NUMBER, 
  UN4 in FLOAT,UD4 in DATE,US4 in VARCHAR2,UF4 in VARCHAR2,
  UFmt4 in NUMBER,
  UR5 in NUMBER,UC5 in NUMBER, 
  UN5 in FLOAT,UD5 in DATE,US5 in VARCHAR2,UF5 in VARCHAR2,
  UFmt5 in NUMBER,
  -- Имя листа.
	USHEET in VARCHAR2,
  -- Порядковый номер листа в книге.
	UNUM in VARCHAR2,
  -- Имя книги.
  UBOOK in VARCHAR2,
  -- Номер формата, если не определён, то используется формат по умолчанию.
  UFmt in NUMBER default null
  )
-- Процедура вставляет ячейки во временную таблицу.
-- Процедура, используется при ускоренном импорте файла.
-- После добавления всех ячеек необходимо вызвать процедуру
-- KOCEL.COMMIT_INSERTS
-- Смотри описание типа KOSEL.TFORMAT и пример построения листа.
-- (KOCEL_PROCEDURES.prc)  
is
begin
  if UCOUNT<1 then return; end if;  
  insert into KOCEL.TEMP_SHEET
    values(UR1,UC1,UN1,UD1,US1,UF1,USHEET,UNUM,UBOOK,UFmt1);
  if UCOUNT=1 then return; end if;  
  insert into KOCEL.TEMP_SHEET
    values(UR2,UC2,UN2,UD2,US2,UF2,USHEET,UNUM,UBOOK,UFmt2);
  if UCOUNT=2 then return; end if;  
  insert into KOCEL.TEMP_SHEET
    values(UR3,UC3,UN3,UD3,US3,UF3,USHEET,UNUM,UBOOK,UFmt3);
  if UCOUNT=3 then return; end if;  
  insert into KOCEL.TEMP_SHEET
    values(UR4,UC4,UN4,UD4,US4,UF4,USHEET,UNUM,UBOOK,UFmt4);
  if UCOUNT=4 then return; end if;  
  insert into KOCEL.TEMP_SHEET
    values(UR5,UC5,UN5,UD5,US5,UF5,USHEET,UNUM,UBOOK,UFmt5);
end;
/
grant EXECUTE on KOCEL.INSERT_5CELLS to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCEL.INSERT_COLUMN(
  -- Номер колонки, начиная с 1 (колонка "A").
  UC in NUMBER, 
  -- Ширина колонки.
  UW in FLOAT,
  -- Имя листа.	
  USHEET in VARCHAR2, 
  -- Порядковый номер листа в книге.
  USHEET_NUM in NUMBER, 
  -- Имя книги.
  UBOOK in VARCHAR2,
  -- Номер формата, если не определён, то используется формат по умолчанию.
  UFmt in NUMBER default 0)
-- Процедура вставляет данные во временную таблицу.
-- Процедура определяет ширину и формат по умолчанию для ячеек колонки
-- листа книги.  
-- Процедура используется при импорте файла.
-- Смотри описание типа KOSEL.TFORMAT и пример построения листа.
-- (KOCEL_PROCEDURES.prc)  
is
begin
  insert into KOCEL.TEMP_SHEET (R,C,N,D,S,F,SHEET,NUM,BOOK,Fmt_Num)
    values(0,UC,UW,null,null,null,USHEET,USHEET_NUM,UBOOK,UFmt);
end;
/
grant EXECUTE on KOCEL.INSERT_COLUMN to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCEL.INSERT_ROW(
  -- Номер ряда, начиная с 1.
  UR in NUMBER, 
  -- Высота ряда.
  UH in FLOAT,
  -- Имя листа.	
  USHEET in VARCHAR2, 
  -- Порядковый номер листа в книге.
  USHEET_NUM in NUMBER, 
  -- Имя книги.
  UBOOK in VARCHAR2,
  -- Номер формата, если не определён, то используется формат по умолчанию.
  UFmt in NUMBER default 0)
-- Процедура вставляет данные во временную таблицу.
-- Процедура определяет ширину и формат по умолчанию для ячеек ряда
-- листа книги.  
-- Процедура используется при импорте файла.
-- Смотри описание типа KOSEL.TFORMAT и пример построения листа.
-- (KOCEL_PROCEDURES.prc)  
is
begin
  insert into KOCEL.TEMP_SHEET (R,C,N,D,S,F,SHEET,NUM,BOOK,Fmt_Num)
    values(UR,0,UH,null,null,null,USHEET,USHEET_NUM,UBOOK,UFmt);
end;
/
grant EXECUTE on KOCEL.INSERT_ROW to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCEL.INSERT_FORMAT(
  UFmtNum in NUMBER,
  UFont_Name in VARCHAR2,
  UFont_Size20 in NUMBER,
  UFont_Color in NUMBER,
  UFont_Style in NUMBER,
  UFont_Underline in NUMBER,
  UFont_Family in NUMBER,
  UFont_CharSet in NUMBER,
  ULeft_Style in NUMBER,
  ULeft_Color in NUMBER,
  URight_Style in NUMBER,
  URight_Color in NUMBER,
  UTop_Style in NUMBER,
  UTop_Color in NUMBER,
  UBottom_Style in NUMBER,
  UBottom_Color in NUMBER,
  UDiagonal in NUMBER,
  UDiagonal_Style in NUMBER,
  UDiagonal_Color in NUMBER,
  UFormat_String in VARCHAR2,
  UFill_Pattern in NUMBER,
  UFill_FgColor in NUMBER,
  UFill_BgColor in NUMBER,
  UH_Alignment in NUMBER,
  UV_Alignment in NUMBER,
  UE_Locked in NUMBER,
  UE_Hidden in NUMBER,
  UParent_Fmt in NUMBER,
  UWrap_Text  in NUMBER,
  UShrink_To_Fit in NUMBER,
  UText_Rotation in NUMBER,
  UText_Indent in NUMBER)
-- Процедура используется при импорте файла.
-- Процедура вставляет данные во временную таблицу.
-- Смотри описание типа KOSEL.TFORMAT и пример построения листа.
-- (KOCEL_PROCEDURES.prc)  
is
  NewFormat KOCEL.TFORMAT;
  tmpVar NUMBER;
begin
  -- Игнорируем занесение формата по умолчанию.
  if UFmtNum=0 then return; end if;
  NewFormat:=KOCEL.TFORMAT;
  NewFormat.Font_Name:=UFont_Name; 
  NewFormat.Font_Size20:=UFont_Size20; 
  NewFormat.Font_Color:=UFont_Color;
  NewFormat.Font_Style:=UFont_Style; 
  NewFormat.Font_Underline:=UFont_Underline; 
  NewFormat.Font_Family:=UFont_Family; 
  NewFormat.Font_CharSet:=UFont_CharSet; 
  NewFormat.Left_Style:=ULeft_Style;
  NewFormat.Left_Color:=ULeft_Color; 
  NewFormat.Right_Style:=URight_Style; 
  NewFormat.Right_Color:=URight_Color; 
  NewFormat.Top_Style:=UTop_Style; 
  NewFormat.Top_Color:=UTop_Color; 
  NewFormat.Bottom_Style:=UBottom_Style; 
  NewFormat.Bottom_Color:=UBottom_Color;
  NewFormat.Diagonal:=UDiagonal; 
  NewFormat.Diagonal_Style:=UDiagonal_Style; 
  NewFormat.Diagonal_Color:=UDiagonal_Color; 
  NewFormat.Format_String:=UFormat_String;
  NewFormat.Fill_Pattern:=UFill_Pattern;
  NewFormat.Fill_FgColor:=UFill_FgColor; 
  NewFormat.Fill_BgColor:=UFill_BgColor; 
  NewFormat.H_Alignment:=UH_Alignment;
  NewFormat.V_Alignment:=UV_Alignment; 
  NewFormat.E_Locked:=UE_Locked; 
  NewFormat.E_Hidden:=UE_Hidden; 
  NewFormat.Parent_Fmt:=UParent_Fmt;
  NewFormat.Wrap_Text:=UWrap_Text; 
  NewFormat.Shrink_To_Fit:=UShrink_To_Fit; 
  NewFormat.Text_Rotation:=UText_Rotation;
  NewFormat.Text_Indent:=UText_Indent;
  tmpVar:=NewFormat.Save;
  insert into KOCEL.TEMP_SHEET_FORMATS
    values(UFmtNum,tmpVar);
end;
/
grant EXECUTE on KOCEL.INSERT_FORMAT to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCEL.COMMIT_INSERTS
-- Завершение импорта файла.
-- (KOCEL_PROCEDURES.prc)  
is
begin
  d('1','KOCEL.COMMIT_INSERTS');
  KOCEL.TABLE2SHEET('KOCEL.TEMP_SHEET', '1', 'UBOOK');
  d('2','KOCEL.COMMIT_INSERTS');
  insert into KOCEL.SHEETS 
	  select R,C,N,D,S,F,SHEET,BOOK,Fmt 
      from KOCEL.TEMP_SHEET s, KOCEL.TEMP_SHEET_FORMATS f
      where s.FMT_NUM=f.FMT_NUM(+);
  insert into KOCEL.SHEETS_ORDER 
	  select distinct NUM,SHEET,BOOK from KOCEL.TEMP_SHEET;
	commit;
end;
/

grant EXECUTE on KOCEL.COMMIT_INSERTS to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCEL.SET_R1C1(
	UR1C1 in VARCHAR2,UBOOK in VARCHAR2)
-- Процедура установливает тип адресации в формулах книги (A1 или 1.1).
-- (KOCEL_PROCEDURES.prc)  
is
begin
  update KOCEL.BOOKS_R1C1 set R1C1=UR1C1
		where (upper(BOOK)=upper(UBOOK));
	if SQL%rowcount = 0 then
	  insert into KOCEL.BOOKS_R1C1 values(UR1C1,UBOOK);
	end if;
end;
/
grant EXECUTE on KOCEL.SET_R1C1 to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION KOCEL.GET_R1C1(UBOOK in VARCHAR2)
return VARCHAR2
-- Получение типа адресации в формулах книги (A1 или 1.1).
-- (KOCEL_PROCEDURES.prc)  
is
tmpVar VARCHAR2(10);
begin
  select R1C1 into tmpVar from KOCEL.BOOKS_R1C1 
	  where (upper(BOOK)=upper(UBOOK));
	return tmpVar;	
exception
  when no_data_found then return 'A1';	
end;
/
grant EXECUTE on KOCEL.GET_R1C1 to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION KOCEL.TFUN return VARCHAR2
-- Тестовая функция.
-- (KOCEL_PROCEDURES.prc)  
is
begin
  return 'Hello!';
end;
/
grant EXECUTE on KOCEL.TFUN to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION KOCEL.BatPar(UBatName in VARCHAR2,
                                        UParName in VARCHAR2)
return VARCHAR2
-- Получение значения параметра пакетного задания.
-- (KOCEL_PROCEDURES.prc)  
is
tmpVar VARCHAR2(255);
begin
  select ParValue into tmpVar from KOCEL.Pars 
    where (upper(BatName)=upper(UBatName))
      and (upper(ParName)=upper(UParName));
  return tmpVar;
end;
/
grant EXECUTE on KOCEL.BatPar to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCEL.SetBatPar(UBatName in VARCHAR2,
                                            UParName in VARCHAR2,
                                            UParValue in VARCHAR2)
-- Сохранение параметра пакетного задания.
-- (KOCEL_PROCEDURES.prc)  
is
begin
  update KOCEL.Pars set ParValue=UParValue
    where (upper(BatName)=upper(UBatName))
      and (upper(ParName)=upper(UParName));
	if SQL%rowcount = 0 then
	  insert into KOCEL.Pars values(UBatName,UParName,UParValue);
	end if;
end;
/
grant EXECUTE on KOCEL.SetBatPar to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCEL.AutoClearSHEET(USHEET in VARCHAR2,
                                                 UBOOK in VARCHAR2)
-- Очищение данных листа, выполняемое в автономной транзакции.
-- (KOCEL_PROCEDURES.prc)  
is
pragma autonomous_transaction;
  tmpS VARCHAR2(256);
  tmpB VARCHAR2(256);
begin
  tmpS:= upper(USHEET);
  tmpB:= upper(UBOOK);
  delete from KOCEL.SHEETS 
    where upper(BOOK)=tmpB and upper(SHEET)=tmpS and R>0 and C>0;
  delete from KOCEL.MERGED_CELLS 
    where upper(BOOK)=tmpB and upper(SHEET)=tmpS;
  commit;    
end;
/
grant EXECUTE on KOCEL.AutoClearSHEET to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCEL.AutoClearBOOK(UBOOK in VARCHAR2)
-- Очищение данных книги, выполняемое в автономной транзакции.
-- (KOCEL_PROCEDURES.prc)  
is
pragma autonomous_transaction;
  tmpVar VARCHAR2(256);
begin
  tmpVar:= upper(UBOOK);
  delete from KOCEL.SHEETS where upper(BOOK)=tmpVar and R>0 and C>0;
  delete from KOCEL.MERGED_CELLS where upper(BOOK)=tmpVar;
  commit;    
end;
/
grant EXECUTE on KOCEL.AutoClearBOOK to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCEL.AutoRANGE2SHEET(URANGE in KOCEL.CELL.TRange,
                                                  USHEET in VARCHAR2,
                                                  UBOOK in VARCHAR2)
-- Добавление диапазона к книге, как новый лист.
-- Выполняется как автономная транзакция. 
-- (KOCEL_PROCEDURES.prc)  
is
pragma autonomous_transaction;
begin
  if not KOCEL.CELL.isSHEET_exist(USHEET,UBOOK) then
    KOCEL.CELL.New_SHEET(USHEET,UBOOK);
  end if;  
  KOCEL.CELL.SetRange(USHEET,UBOOK,1,1,URANGE);
  commit;    
end;
/
grant EXECUTE on KOCEL.AutoRANGE2SHEET to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION KOCEL.Describe(TableName IN VARCHAR2)
 return KOCEL.TTableDefs
 authid current_user
 pipelined
-- Описывает выходные столбцы таблиц и табличных функций. 
-- (KOCEL_PROCEDURES.prc)  
AS
rec KOCEL.TTableDef:=KOCEL.TTableDef('Q','Q',1,1,1,1);
Res KOCEL.TTableDefs;
ColCount NUMBER;
DTable DBMS_SQL.DESC_TAB2;
SqlStr VARCHAR2(4000);
DCursor NUMBER;
SubString VARCHAR2(60);

begin
  -- Если не нашли значение равное входному параметру среди таблиц или
  -- представлений, то это функция.
  SubString:=substr(upper(TableName),instr(TableName,'.')+1);
  select count(*) into DCursor from ALL_ALL_TABLES aat
	  where SubString = aat.TABLE_NAME;
--        and (substr(upper(TableName),1,instr(TableName,'.')-1) = aat.OWNER;
  if DCursor=0 then 
    SubString:=substr(upper(TableName),instr(TableName,'.')+1);   
	  select count(*) into DCursor from ALL_VIEWS av
		  where SubString = av.VIEW_NAME;
  end if;    
  SqlStr :=case DCursor
	  when 0 then 'select * from TABLE('||TableName||')'
	  else 'select * from '||TableName
		end;
  DCursor :=dbms_sql.open_cursor;
  dbms_sql.parse(DCursor,SqlStr,1);
  dbms_sql.describe_columns2(DCursor,ColCount,DTable);
	
	Rec.ColName := DTable(1).col_name;
Rec.ColTypeName:= case DTable(1).col_type
	                    when 1  then 'VARCHAR2'
										  when 2  then 'NUMBER'
                      when 8  then 'LONG'
                      when 11 then 'ROWID'
										  when 12 then 'DATE'
										  when 23 then 'RAW'
										  when 24 then 'LONG_RAW'
                      when 96 then 'CHAR'
                      when 108 then 'User'
                      when 112  then 'REF'
                      when 113  then 'CLOB'
                      when 114 then 'BFILE'
                      when 208 then 'UROWID'
										else 'Other'
										end;
	Rec.ColType:= DTable(1).col_type;
	Rec.ColLength:= DTable(1).col_max_len;
	Rec.ColPrecision:= DTable(1).col_precision;
	Rec.Colscale:= DTable(1).col_Scale;
	pipe row(rec);
  for i in 2..ColCount
  loop
	  Rec.ColName := DTable(i).col_name;
	  Rec.ColTypeName:= case DTable(i).col_type
	                    when 1  then 'VARCHAR2'
										  when 2  then 'NUMBER'
                      when 8  then 'LONG'
                      when 11 then 'ROWID'
										  when 12 then 'DATE'
										  when 23 then 'RAW'
										  when 24 then 'LONG_RAW'
                      when 96 then 'CHAR'
                      when 108 then 'User'
                      when 112  then 'REF'
                      when 113  then 'CLOB'
                      when 114 then 'BFILE'
                      when 208 then 'UROWID'
											else 'Other'
											end;
		Rec.ColType:= DTable(i).col_type;
		Rec.ColLength:= DTable(i).col_max_len;
	  Rec.ColPrecision:= DTable(i).col_precision;
	  Rec.Colscale:= DTable(i).col_Scale;
		pipe row(rec);
	end loop;
	dbms_sql.close_cursor(DCursor);
	return ;
exception
  when others	then
	dbms_sql.close_cursor(DCursor);
	raise;		
end;
/
grant EXECUTE on KOCEL.Describe to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCEL.TABLE2SHEET(TableName in VARCHAR2,
	USHEET in VARCHAR2,UBOOK in VARCHAR2, isPipeFunction in BOOLEAN default false)
 authid current_user
-- Процедура добавляет или обновляет лист книги, записывая в него данные
-- таблицы "TableName". 
-- (KOCEL_PROCEDURES.prc)  
is
  SHEET KOCEL.CELL.TRange;
  V KOCEL.CELL.TCellValue;
  sql_S VARCHAR2(128);
  C sys_refcursor;
  RowN PLS_INTEGER;
  isVChar constant PLS_INTEGER :=1;
  isNum   constant PLS_INTEGER :=2;
  isLong  constant PLS_INTEGER := 8;
  isROWID constant PLS_INTEGER :=11;
  isDat   constant PLS_INTEGER :=12;
  isRAW   constant PLS_INTEGER :=23;
	isLONG_RAW	constant PLS_INTEGER := 24;
  isCHAR constant PLS_INTEGER := 96;
  isCLOB constant PLS_INTEGER := 113;
  isUROWID constant PLS_INTEGER := 208;
  tmpROWID ROWID;
  tmpRAW RAW(2000);
begin
  if (TableName is null) or (USHEET is null) or (UBOOK is null) then 
    return; 
  end if;
  -- очищаем лист
  KOCEL.AutoClearSHEET(USHEET,UBOOK);
  -- создаём лист
  for i in (select rownum ColNum,COLNAME,COLTYPE 
            from TABLE(KOCEL.DESCRIBE(TableName)))
  loop
    -- записываем имя колонки
    V.N:=null;V.D:=null;V.S:=null;
    V.S:=i.COLNAME;
--    V.F:=to_char(1)||'  '||to_char(i.ColNum);
    SHEET(1)(i.ColNum):=V;
    V.S:=null;
--    d(to_char(1)||'  '||to_char(i.ColNum)||'  '||V.S,'Table2Sheet');
    -- Если тип не поддерживается то записываем диагностику и переходим к
    -- следующей колонке.
    if i.COLTYPE not in (isVChar,isChar,isClob,isRAW,isROWID,isNum,isDat) 
    then
	    V.S:='Unsupported type '||to_char(i.COLTYPE);
	    SHEET(2)(i.ColNum):=V;
	    V.S:=null;
      goto NEXT_i;
    end if;
    if isPipeFunction then
      sql_S:= 'select rownum,"'||i.COLNAME||'" from TABLE('||TableName||')';
    else   
      sql_S:= 'select rownum,"'||i.COLNAME||'" from '||TableName; 
    end if;  
    open C for sql_S;
    loop
	    case i.COLTYPE
	      when isRAW then
          fetch C into RowN,tmpRAW;
          V.S:=UTL_I18N.RAW_TO_CHAR(tmpRAW);
	      when isROWID then
          fetch C into RowN,tmpROWID;
          V.S:=rowidtochar(tmpROWID);
	      when isNum then 
          fetch C into RowN,V.N;
	      when isDat then 
          fetch C into RowN,V.D;
	    else 
        fetch C into RowN,V.S;
	    end case;
	    exit when C%notfound;
--      V.F:=to_char(RowN+1)||'  '||to_char(i.ColNum);
      SHEET(RowN+1)(i.ColNum):=V;
--      d(to_char(RowN+1)||'  '||to_char(i.ColNum),'Table2Sheet');
      V.N:=null;V.D:=null;V.S:=null;
    end loop;
    close C;
  <<NEXT_i>>null;   
  end loop;
  --записываем лист
  KOCEL.AutoRANGE2SHEET(SHEET, USHEET, UBOOK);
exception
  when others then if C%isOpen then Close C; end if; raise;  
end;
/
grant EXECUTE on KOCEL.TABLE2SHEET to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION KOCEL.BITOR(a NUMBER, b NUMBER) return NUMBER
-- Функция выполняет побитную операцию "или".
-- (KOCEL_PROCEDURES.prc)  
is
begin
  return a+b-bitand(a,b);
end;
/
grant EXECUTE on KOCEL.BITOR to PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM BITOR for KOCEL.BITOR; 

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION KOCEL.BITXOR(a NUMBER, b NUMBER) return NUMBER
-- Функция выполняет побитную операцию "исключающее или".
-- (KOCEL_PROCEDURES.prc)  
is
begin
  return a+b-2*bitand(a,b);
end;
/
grant EXECUTE on KOCEL.BITXOR to PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM BITXOR for KOCEL.BITXOR; 

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION KOCEL.BITNOT(a NUMBER, width NUMBER) return NUMBER
-- Функция выполняет побитную операцию инверсии параметра "a". 
-- Параметр "width" определяет число разрядов, участвующих в операции.
-- (KOCEL_PROCEDURES.prc)  
is
begin
  return bitand(-1-a,power(2,width)-1);
end;
/
grant EXECUTE on KOCEL.BITNOT to PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM BITNOT for KOCEL.BITNOT; 
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCEL.ADD_SHEET
(
  pi_num   NUMBER,
  pi_sheet VARCHAR2,
  pi_book  VARCHAR2
) IS
BEGIN
  -- add new sheet
  KOCEL.CELL.NEW_SHEET (pi_sheet, pi_book);
  -- add new sheet order
  INSERT INTO KOCEL.SHEETS_ORDER VALUES (pi_num, pi_sheet, pi_book);
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    raise_application_error(-20001,
                            'Таблица KOCEL.SHEETS_ORDER уже сожержит запись: num="' ||
                            pi_num || '"; sheet="' || pi_sheet ||
                            '"; book="' || pi_book || '"');
  
END;
/
GRANT EXECUTE ON KOCEL.ADD_SHEET TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ADD_SHEET FOR KOCEL.ADD_SHEET;
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCEL.SAVE_CELL(
  -- Номер ряда ячейки листа.
  -- Ячейка с индксом 0 определяет параметры по умолчанию для всего ряда.
  UR in NUMBER,
  -- Номер колонки ячейки листа.
  -- Ячейка с индксом 0 определяет параметры по умолчанию для всей колонки.
  UC in NUMBER,
  -- Значение ячейки. Лишь один параметр из (UN, UD, US)может быть не нулл.
  UN in NUMBER default null,
  UD in DATE default null,
  US in VARCHAR2 default null,
  -- Формула.
  UF in VARCHAR2 default null,
  -- Имя листа.
	USHEET in VARCHAR2,
  -- Имя книги.
  UBOOK in VARCHAR2,
  -- Номер формата, если не определён, то используется формат по умолчанию.
  UFmt in NUMBER default null)
-- Процедура изменения ячейки в листе книги.
-- Можно использовать и для добавления ячеек к уже существующей книге.
-- Смотри описание типа KOSEL.TFOMAT и пример построения листа.
-- (KOCEL_PROCEDURES.prc)
is
  tmpVar NUMBER;
  vUD DATE := UD; --to_date(UD, 'dd.mm.yyyy');
  vUN FLOAT;
begin
  IF (US IS NOT NULL OR UD IS NOT NULL OR UF IS NOT NULL) AND UN = -1 THEN
     vUN := NULL;
  ELSE
     vUN := UN;   
  END IF;
  
  -- Если формат нулл, то используем старый.
  if UFmt is null then
	  update KOCEL.SHEETS set
		  N=vUN,D=vUD,S=US,F=UF
			where (BOOK=UBOOK) and (SHEET=USHEET) and (R=UR) and (C=UC);
  else
	  update KOCEL.SHEETS set
		  N=vUN,D=vUD,S=US,F=UF,Fmt=UFmt
			where (BOOK=UBOOK) and (SHEET=USHEET) and (R=UR) and (C=UC);
  end if;
	if SQL%rowcount = 0 then
    -- Если формат нулл, то используем формат колонки.
    if UFmt is null then
      begin
        select Fmt into tmpVar from KOCEL.SHEETS
          where (BOOK=UBOOK) and (SHEET=USHEET) and (R=0) and (C=UC);
      exception
        -- Если нет описания колонки, то используем формат по умолчанию.
        when no_data_found then
          tmpVar:=0;
      end;
    else 
      tmpVar := UFmt;
    end if;
    
	  insert into KOCEL.SHEETS values(UR,UC,vUN,vUD,US,UF,USHEET,UBOOK,tmpVar);
    
	end if;
end;
/
GRANT EXECUTE ON KOCEL.SAVE_CELL TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM SAVE_CELL FOR KOCEL.SAVE_CELL;
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCEL.SAVE_FORMAT(
  UFmtNum in NUMBER,
  UFont_Name in VARCHAR2,
  UFont_Size20 in NUMBER,
  UFont_Color in NUMBER,
  UFont_Style in NUMBER,
  UFont_Underline in NUMBER,
  UFont_Family in NUMBER,
  UFont_CharSet in NUMBER,
  ULeft_Style in NUMBER,
  ULeft_Color in NUMBER,
  URight_Style in NUMBER,
  URight_Color in NUMBER,
  UTop_Style in NUMBER,
  UTop_Color in NUMBER,
  UBottom_Style in NUMBER,
  UBottom_Color in NUMBER,
  UDiagonal in NUMBER,
  UDiagonal_Style in NUMBER,
  UDiagonal_Color in NUMBER,
  UFormat_String in VARCHAR2,
  UFill_Pattern in NUMBER,
  UFill_FgColor in NUMBER,
  UFill_BgColor in NUMBER,
  UH_Alignment in NUMBER,
  UV_Alignment in NUMBER,
  UE_Locked in NUMBER,
  UE_Hidden in NUMBER,
  UParent_Fmt in NUMBER,
  UWrap_Text  in NUMBER,
  UShrink_To_Fit in NUMBER,
  UText_Rotation in NUMBER,
  UText_Indent in NUMBER,
  OutFmt OUT NUMBER
  )
-- Процедура используется при импорте файла.
-- Процедура вставляет данные во временную таблицу.
-- Смотри описание типа KOSEL.TFORMAT и пример построения листа.
-- (KOCEL_PROCEDURES.prc)
is
  -- NewFormat KOCEL.FORMATS_TEST%ROWTYPE;--KOCEL.TFORMAT;
  NewFormat KOCEL.TFORMAT;
  tmpVar NUMBER;
--  pragma autonomous_transaction;
begin
--  raise_application_error(-20001, 'UFont_Name: '||UFont_Name||'; UFmtNum:'||UFmtNum);
  -- Игнорируем занесение формата по умолчанию.
  if UFmtNum=0 then return; end if;
  NewFormat:=KOCEL.TFORMAT;
  NewFormat.Font_Name:=UFont_Name;
  NewFormat.Font_Size20:=UFont_Size20;
  NewFormat.Font_Color:=UFont_Color;
  NewFormat.Font_Style:=UFont_Style;
  NewFormat.Font_Underline:=UFont_Underline;
  NewFormat.Font_Family:=UFont_Family;
  NewFormat.Font_CharSet:=UFont_CharSet;
  NewFormat.Left_Style:=ULeft_Style;
  NewFormat.Left_Color:=ULeft_Color;
  NewFormat.Right_Style:=URight_Style;
  NewFormat.Right_Color:=URight_Color;
  NewFormat.Top_Style:=UTop_Style;
  NewFormat.Top_Color:=UTop_Color;
  NewFormat.Bottom_Style:=UBottom_Style;
  NewFormat.Bottom_Color:=UBottom_Color;
  NewFormat.Diagonal:=UDiagonal;
  NewFormat.Diagonal_Style:=UDiagonal_Style;
  NewFormat.Diagonal_Color:=UDiagonal_Color;
  NewFormat.Format_String:=UFormat_String;
  NewFormat.Fill_Pattern:=UFill_Pattern;
  NewFormat.Fill_FgColor:=UFill_FgColor;
  NewFormat.Fill_BgColor:=UFill_BgColor;
  NewFormat.H_Alignment:=UH_Alignment;
  NewFormat.V_Alignment:=UV_Alignment;
  NewFormat.E_Locked:=UE_Locked;
  NewFormat.E_Hidden:=UE_Hidden;
  NewFormat.Parent_Fmt:=UParent_Fmt;
  NewFormat.Wrap_Text:=UWrap_Text;
  NewFormat.Shrink_To_Fit:=UShrink_To_Fit;
  NewFormat.Text_Rotation:=UText_Rotation;
  NewFormat.Text_Indent:=UText_Indent;
  tmpVar:=NewFormat.Save;
  OutFmt := tmpVar;
--  commit;
end;
/
GRANT EXECUTE ON KOCEL.SAVE_FORMAT TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM SAVE_FORMAT FOR KOCEL.SAVE_FORMAT;
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE KOCEL.INSERT_MERGED_REGION(
   -- Имя листа.
   USHEET IN VARCHAR2,
   -- Имя книги.
   UBOOK IN VARCHAR2,
   -- Номер первой колонки объединения (номер ячейки).
   fCol IN NUMBER,
   -- Номер первого ряда объединения (номер строки).
   fRow IN NUMBER,
   -- Номер последней колонки объединения (номер ячейки).
   lCol IN NUMBER,
   -- Номер последнего ряда объединения (номер строки).
   lRow IN NUMBER) IS
BEGIN
  INSERT INTO KOCEL.Merged_Cells
  VALUES
    (fCol, fRow, lCol, lRow, usheet, ubook);
EXCEPTION
  WHEN dup_val_on_index THEN
    raise_application_error(-20001,
                            'Объединение ячеек: fCol="' || fCol ||
                            '"; fRow:"' || fRow ||
                            '" - уже существует для книги: "' || UBOOK ||
                            '", и листа: "' || USHEET || '"');
END;
/
GRANT EXECUTE ON KOCEL.INSERT_MERGED_REGION TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM INSERT_MERGED_REGION FOR KOCEL.INSERT_MERGED_REGION;