-- SP procedures
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 10.10.2010
-- update 14.10.2010 27.10.2010 17.12.2010 01.03.2011 20.05.2011 09.08.2011
--        23.06.2011 28.06.2011 06.07.2011 10.11.2011 18.11.2011 25.11.2011
--        09.12.2011 19.12.2011 16.01.2012 18.01.2012 25.01.2012 08.02.2012
--        27.03.2012 19.07.2013 25.08.2013 24.10.2013 02.07.2014 09.07.2014
--        10.07.2014 16.07.2014
-- updated by Evgeniy Piatakov  09.09.2014 01.10.2014 07.10.2014 28.10.2014
--        05.11.2014
-- updated by Nikolay Krasilnikov 
--        06.01.2015 10.06.2015 19.09.2016 27.10.2016 22.02.2017 25.04.2017
--        15.05.2017 22.05.2017 17.01.2019
-- updated by Azarov 22.07.2019
-- updated by Nikolay Krasilnikov
--        14.12.2019 16.12.2019 18.12.2019 25.12.2019 18.01.2021 31.01.2021
--        06.02.2019 01.07.2021 08.07.2021 21.07.2021 
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.SET_FROM_STRING(
   -- Cтрока.
   S in VARCHAR2,
   -- Разделитель (регулярное выражение).
   Delim in VARCHAR2 default '[,|;|:]',
   CaseSens in BOOLEAN default false,
   delEmpStr in BOOLEAN default true)
return SP.TSTRINGS pipelined
-- Преобразование строки с разделителями в набор строк. 
-- Пробеллы справа и слева в каждой подстроке урезаются.
-- Пустые подстроки между повторяющимися разделителями удаляются
-- если стоит флаг delEmpStr 
--(SP-PROCEDURES.fnc)
as
  str SP.COMMANDS.COMMENTS%type;
  B_pos PLS_INTEGER;
  E_pos PLS_INTEGER;
  match VARCHAR2(1):='i';
begin
  if CaseSens then match:='c'; end if;
  if S is null then return; end if;
  B_pos:=1;
  loop
    -- Ищем вхождение. 
    E_pos:=regexp_instr(S,Delim,B_pos,1/*occurrence*/,1/*next*/,match);
    exit when E_Pos=0;
    -- Выдаём строку между вхождениями.
    str:=substr(s,B_pos,E_pos-B_pos);
    --d(str);
    str:=trim(regexp_replace(str,Delim,'',1,1,match));
    -- без пустых рядов
    if delEmpStr and (str is not null) then pipe row(str); end if;
    B_pos:=E_pos;
  end loop;
  -- Если не нашли вхождение, то, если остаток не пуст, выдаём его и выход.
  str:=trim(substr(S,B_pos));
  if str is null then return; end if;
  pipe row(str);
  return;
end;  
/
--
grant EXECUTE on SP.SET_FROM_STRING to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.STRINGS_FROM_STRING(
   -- Cтрока.
   S in VARCHAR2,
   -- Разделитель (регулярное выражение).
   Delim in VARCHAR2 default '[,|;|:]',
   -- Чувствительность к регистру, по умолчанию нечувствительно.
   CaseSens in BOOLEAN default false,
   -- Обрезание правых пробелов.
   R in BOOLEAN default true,
   -- Обрезание левых пробелов.
   L in BOOLEAN default true,
   -- Удаление пустых строк.
   delEmpStr in BOOLEAN default true)
return SP.TSTRINGS
-- Преобразование строки с разделителями в Массив строк.
-- Пробеллы в каждой подстроке урезаются по умолчанию.
-- Пустые подстроки между повторяющимися разделителями удаляются
-- если стоит флаг delEmpStr 
-- (SP-PROCEDURES.fnc)
as
  str SP.COMMANDS.COMMENTS%type;
  B_pos PLS_INTEGER;
  E_pos PLS_INTEGER;
  match VARCHAR2(1):='i';
  result SP.TSTRINGS;
  i BINARY_INTEGER;
begin
  if CaseSens then match:='c'; end if;
  if S is null then return SP.TSTRINGS(); end if;
  result := SP.TSTRINGS();
  i:=0;
  B_pos:=1;
  loop
    -- Ищем вхождение. 
    E_pos:=regexp_instr(S,Delim,B_pos,1/*occurrence*/,1/*next*/,match);
    exit when E_Pos=0;
    -- Выдаём строку между вхождениями.
    str:=substr(s,B_pos,E_pos-B_pos);
    --d(str,'SP.STRINGS_FROM_STRING');
    case
      when R and (not L) then
        str:=rtrim(regexp_replace(str,Delim,'',1,1,match));
      when (not R) and L then
        str:=ltrim(regexp_replace(str,Delim,'',1,1,match));
      when R and L then
        str:=trim(regexp_replace(str,Delim,'',1,1,match));
      when (not R) and (not L) then
        str:=regexp_replace(str,Delim,'',1,1,match);
    end case;    
    if delEmpStr and (str is not null) then
      i:=i+1; 
      result.extend(1);
      result(i):=str;
    end if;   
    B_pos:=E_pos;
  end loop;
  -- Если не нашли вхождение, то, если остаток не пуст, выдаём его и выход.
  str:=trim(substr(S,B_pos));
  if str is null then return result; end if;
  i:=i+1; 
  result.extend(1);
  result(i):=str; 
  return result;
end;  
/
--
grant EXECUTE on SP.STRINGS_FROM_STRING to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.NAMES_FROM_STRING(
   -- Cтрока.
   S in VARCHAR2,
   -- Разделитель (регулярное выражение).
   Delim in VARCHAR2 default '[,|;|:]',
   -- Чувствительность к регистру, по умолчанию нечувствительно.
   CaseSens in BOOLEAN default false)
return SP.G.TNAMES
-- Преобразование строки с разделителями в Массив имён.
-- Пробеллы справа и слева в каждой подстроке урезаются.
-- Пустые подстроки между повторяющимися разделителями удаляются.
--(SP-PROCEDURES.fnc)
as
  str SP.COMMANDS.COMMENTS%type;
  B_pos PLS_INTEGER;
  E_pos PLS_INTEGER;
  match VARCHAR2(1):='i';
  result SP.G.TNAMES;
  i BINARY_INTEGER;
begin
  if CaseSens then match:='c'; end if;
  if S is null then return result; end if;
  i:=0;
  B_pos:=1;
  --d('begin'||S,'SP.NAMES_FROM_STRING');
  loop
    -- Ищем вхождение.
    E_pos:=regexp_instr(S,Delim,B_pos,1/*occurrence*/,1/*next*/,match);
    exit when E_Pos=0;
    -- Выдаём строку между вхождениями.
    str:=substr(s,B_pos,E_pos-B_pos);
    --d(str,'SP.NAMES_FROM_STRING');
    str:=trim(regexp_replace(str,Delim,'',1,1,match));
    if str is not null then
      i:=i+1;
      --d(i,'SP.NAMES_FROM_STRING');
      result(i):=str;
      --d('loop','SP.NAMES_FROM_STRING');
   end if;
    B_pos:=E_pos;
  end loop;
  --d('end B_pos'||B_pos,'SP.NAMES_FROM_STRING');
  -- Если не нашли вхождение, то, если остаток не пуст, выдаём его и выход.
  str:=trim(substr(S,B_pos));
  --d('end'||str,'SP.NAMES_FROM_STRING');
  if str is null then return result; end if;
  i:=i+1;
  --d('str not null'||i,'SP.NAMES_FROM_STRING');
  result(i):=str;
  --d('end','SP.NAMES_FROM_STRING');
  return result;
end;
/
--
grant EXECUTE on SP.NAMES_FROM_STRING to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.UTRIM(S in VARCHAR2)
return VARCHAR2
-- Подготовка строки, полученной от управляющих элементов Windows, для
-- использования её как исполняемого блока в базе.
-- (SP-PROCEDURES.fnc)
as
  tmpVar SP.COMMANDS.COMMENTS%type; 
begin
  -- Если строка не содержит алфавитно-цифровых символов, то она пуста.
  if regexp_instr(S,'[[:alnum:]]')=0 then return null; end if;
  -- Убираем последние пробелы, и прочие ненужные символы в конце строки.
  tmpVar:=RTRIM(S,' '||chr(13)||chr(10));
  -- Убираем пробелы, и прочие ненужные символы в начале строки.
  tmpVar:=LTRIM(tmpVar,' '||chr(13)||chr(10));
  -- Преобразуем переводы строк. 
  tmpVar:= regexp_replace(tmpVar,
                          chr(13)||chr(10)||'|'||chr(10)||chr(13),
                          chr(10));
  return tmpVar; 
end;  
/
--
grant EXECUTE on SP.UTRIM to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.S_(S in VARCHAR2)
return SP.TVALUE
-- Функция возвращает универсальное значение (TVALUE)
-- с типом строка и значением S.
-- (SP-PROCEDURES.fnc)
as
begin
  return SP.TVALUE(Sp.G.TStr4000,S); 
end;  
/
--
grant EXECUTE on SP.S_ to PUBLIC;
create or replace public synonym S_ for SP.S_;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.N_(N in NUMBER)
return SP.TVALUE
-- Функция возвращает универсальное значение (TVALUE)
-- с типом Number и значением N.
-- (SP-PROCEDURES.fnc)
as
begin
  return SP.TVALUE(Sp.G.TNumber,N); 
end;  
/
--
grant EXECUTE on SP.N_ to PUBLIC;
create or replace public synonym N_ for SP.N_;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.ID_(N in NUMBER)
return SP.TVALUE
-- Функция возвращает универсальное значение (TVALUE)
-- с типом "ID" и значением N.
-- (SP-PROCEDURES.fnc)
as
begin
  return SP.TVALUE(Sp.G.TID,N); 
end;  
/
--
grant EXECUTE on SP.ID_ to PUBLIC;
create or replace public synonym ID_ for SP.ID_;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.B_(B in BOOLEAN)
return SP.TVALUE
-- Функция возвращает универсальное значение (TVALUE)
-- с типом Boolean и значением B.
-- (SP-PROCEDURES.fnc)
as
begin
  return SP.TVALUE(Sp.G.TBoolean,trim(to_.STR(B))); 
end;  
/
--
grant EXECUTE on SP.B_ to PUBLIC;
create or replace public synonym B_ for SP.B_;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.I2B_(I in NUMBER)
return SP.TVALUE
-- Функция возвращает универсальное значение (TVALUE)
-- с типом Boolean и true, если параметр "I" > 0.
-- (SP-PROCEDURES.fnc)
as
begin
  if I > 0 then
    return SP.TVALUE(Sp.G.TBoolean,'true');
  else
    return SP.TVALUE(Sp.G.TBoolean,'false');
  end if; 
end;  
/
--
grant EXECUTE on SP.I2B_ to PUBLIC;
create or replace public synonym I2B_ for SP.I2B_;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.I_(I in NUMBER)
return SP.TVALUE
-- Функция возвращает универсальное значение (TVALUE)
-- с типом Integer и значением I.
-- (SP-PROCEDURES.fnc)
as
begin
  return SP.TVALUE(Sp.G.TInteger,to_.STR(I)); 
end;  
/
--
grant EXECUTE on SP.I_ to PUBLIC;
create or replace public synonym I_ for SP.I_;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.NI_(I in NUMBER)
return SP.TVALUE
-- Функция возвращает универсальное значение (TVALUE)
-- с типом NullInteger и значением I.
-- (SP-PROCEDURES.fnc)
as
begin
  return SP.TVALUE(Sp.G.TNullInteger,to_.STR(I)); 
end;  
/
--
grant EXECUTE on SP.NI_ to PUBLIC;
create or replace public synonym NI_ for SP.NI_;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.REL_(ID in NUMBER DEFAULT null,
                                   OID in VARCHAR2 DEFAULT null)
return SP.TVALUE
-- Функция возвращает универсальное значение (TVALUE)
-- с типом Rel и ссылкой на ID или OID.
-- Если оба параметра равны нулл, то возвращается нулевая ссылка. 
-- Если указан ID, а OID нулл, то ссылка назначается по ID.
-- Примеры обращения REL_(234567), REL(ID=>12345),
-- Если ID - null, а OID содержит "=>" то ищем объект по его полному имени.
-- REL_(null, 'модель=>объект'), если не написать нулл,
-- то возникнет ошибка.
-- REL_(OID=>'модель=>объект')
-- REL_(OID=>'129-29-122-39-0393333')
-- Поиск по "OID" происходит ТОЛЬКО в ТЕКУЩЕЙ модели! 
-- (SP-PROCEDURES.fnc)
as
begin
  if ID is null and OID is null then
    return SP.TVALUE(ValueType => Sp.G.TRel,
                     N => null, S=> null, X=> null, Y => null);
  elsif ID is not null then
    return SP.TVALUE(ValueType => Sp.G.TRel,
                     N => ID, S=> null, X=> null, Y => null);
  else 
    return SP.TVALUE(Sp.G.TRel, OID);
  end if;                    
end;  
/
--
grant EXECUTE on SP.REL_ to PUBLIC;
create or replace public synonym REL_ for SP.REL_;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.D_(D in DATE)
return SP.TVALUE
-- Функция возвращает универсальное значение (TVALUE)
-- с типом DATE. 
-- (SP-PROCEDURES.fnc)
as
begin
  return SP.TVALUE(G.TDATE,null,0,null,null,D,null,null,null);
end;  
/
--
grant EXECUTE on SP.D_ to PUBLIC;
create or replace public synonym D_ for SP.D_;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.ND_(D in DATE)
return SP.TVALUE
-- Функция возвращает универсальное значение (TVALUE)
-- с типом DATE. 
-- (SP-PROCEDURES.fnc)
as
begin
  return SP.TVALUE(G.TNullDATE,null,0,null,null,D,null,null,null);
end;  
/
--
grant EXECUTE on SP.ND_ to PUBLIC;
create or replace public synonym ND_ for SP.ND_;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.R_(R in NUMBER)
return SP.TVALUE
-- Функция возвращает универсальное значение (TVALUE)
-- с типом Double и значением R.
-- (SP-PROCEDURES.fnc)
as
begin
  return SP.TVALUE(Sp.G.TDouble,to_.STR(R)); 
end;  
/
--
grant EXECUTE on SP.R_ to PUBLIC;
create or replace public synonym R_ for SP.R_;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.NR_(R in NUMBER)
return SP.TVALUE
-- Функция возвращает универсальное значение (TVALUE)
-- с типом NullDouble и значением R.
-- (SP-PROCEDURES.fnc)
as
begin
  return SP.TVALUE(Sp.G.TNullDouble,to_.STR(R)); 
end;  
/
--
grant EXECUTE on SP.NR_ to PUBLIC;
create or replace public synonym NR_ for SP.NR_;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.P_(P in VARCHAR2)
return SP.TVALUE
-- Функция возвращает универсальное значение (TVALUE)
-- с типом TXYZ или TXY (Point) и значением P.
-- (SP-PROCEDURES.fnc)
as
tmpVar SP.TSTRINGS;
begin
  tmpVar:= SP.Strings_From_String(P);
  case   
    when tmpVar.count = 2 then return SP.TVALUE(Sp.G.TXY,P);
    when tmpVar.count = 3 then return SP.TVALUE(Sp.G.TXYZ,P);
    when trim(P) = '::'  then return SP.TVALUE(Sp.G.TXY);
    when trim(P) = ':::' then return SP.TVALUE(Sp.G.TXYZ);
  else 
    raise_application_error(-20033,
      'SP.P_. Неверное определение точки '||P||'!');
  end case;    
end;  
/
--
grant EXECUTE on SP.P_ to PUBLIC;
create or replace public synonym P_ for SP.P_;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.M_(K in VARCHAR2)
return VARCHAR2
-- Функция возвращает значение по ключу.
-- Функция обеспечивает сокращенный вызов SP.MAP.V(K).
-- (SP-PROCEDURES.fnc)
as
begin
  return SP.MAP.V(K);  
end;  
/
--
grant EXECUTE on SP.M_ to PUBLIC;
create or replace public synonym M_ for SP.M_;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.P2_(X in NUMBER, Y in NUMBER)
return SP.TVALUE
-- Функция возвращает универсальное значение (TVALUE)
-- с типом TXY (Point) и значением X:Y.
-- (SP-PROCEDURES.fnc)
as
P SP.TVALUE;
begin
  P := SP.TVALUE(Sp.G.TXY);
  P.X :=X;
  P.Y :=Y;
  return P; 
end;  
/
--
grant EXECUTE on SP.P2_ to PUBLIC;
create or replace public synonym P2_ for SP.P2_;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.P3_(X in NUMBER, Y in NUMBER, Z in NUMBER)
return SP.TVALUE
-- Функция возвращает универсальное значение (TVALUE)
-- с типом TXYZ (Point) и значением X:Y:Z.
-- (SP-PROCEDURES.fnc)
as
P SP.TVALUE;
begin
  P := SP.TVALUE(Sp.G.TXYZ);
  P.X :=X;
  P.Y :=Y;
  P.N :=Z;
  return P; 
end;  
/
--
grant EXECUTE on SP.P3_ to PUBLIC;
create or replace public synonym P3_ for SP.P3_;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.AddCompositParam(
               MacroName in VARCHAR2, 
               ParamName in VARCHAR2,
               ParamValue in VARCHAR2,
               MacroTXT in out VARCHAR2)
-- Процедура добавляет текст добавления параметров 
-- при формировании листинга макры 
-- (SP-PROCEDURES.fnc)
is
TmpParamName SP.OBJECT_PAR_S.NAME%TYPE;
TmpParam SP.V_OBJECT_PAR_S%ROWTYPE;
cnt NUMBER;
begin
	select count(*) into cnt 
	           from table(SP.SET_FROM_STRING(ParamName,'P_'));
	if cnt = 1 then
	   return;
	end if;
	if nvl(length(trim(MacroTXT)),0) > 0  then
	  MacroTXT :=MacroTXT ||to_.STR;
	else
	  MacroTXT := '';
	end if;
	begin
	  select p.* into TmpParam 
      from (select column_value 
              from table(SP.SET_FROM_STRING(ParamName,'P_')) ) t,
	         SP.V_OBJECT_PAR_S p, SP.V_OBJECTS o 
	    where p.NAME = t.COLUMN_VALUE
        and p.OBJECT_ID = o.ID   
	      and o.FULL_NAME = MacroName;
	  MacroTXT := MacroTXT ||'IP('''||TmpParam.NAME||'''):=SP.TVALUE('''||
	              TmpParam.VALUE_TYPE||''','||to_.STR||''''||ParamValue||''');';
  exception when others then
    d( 'ERRROR Не найден параметр '||ParamName ||' для макропроцедуры '||
       MacroName||'!',' ERRROR sp.AddMacroParam');
  --  raise_application_error(-20033, 'Не найден параметр '||ParamName ||
  --   ' для макропроцедуры '||MacroName||'sp.AddMacroParam!');
  end;
end;
/
--
grant EXECUTE on SP.AddCompositParam to PUBLIC;
create or replace public synonym AddCompositParam for SP.AddCompositParam;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.DegreeToRad(aDegree in NUMBER)
return NUMBER
-- Перевод градусов в радианы.
-- (SP-PROCEDURES.fnc)
as
  tmpVar NUMBER;
begin
  tmpVar := aDegree * acos(0) / 90;
  return tmpVar; 
end;  
/
--
grant EXECUTE on SP.DegreeToRad to PUBLIC;
create or replace public synonym DegreeToRad for SP.DegreeToRad;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.RadToDegree(aRad in NUMBER)
return NUMBER
-- Перевод градусов в радианы
-- (SP-PROCEDURES.fnc)
as
  tmpVar NUMBER;
begin
  tmpVar := aRad * 90 / acos(0);
  return tmpVar; 
end;  
/
--
grant EXECUTE on SP.RadToDegree to PUBLIC;
create or replace public synonym RadToDegree for SP.RadToDegree;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.PercentToRad(aPer in NUMBER)
return NUMBER
-- Перевод процентов в радианы
-- (SP-PROCEDURES.fnc)
as
  tmpVar NUMBER;
begin
  tmpVar := atan(aPer/100);
  return tmpVar;
end;
/
grant EXECUTE on SP.PercentToRad to PUBLIC;
create or replace public synonym PercentToRad for SP.PercentToRad;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.PercentToDegree(aPer in NUMBER)
return NUMBER
-- Перевод процентов в градусы
-- (SP-PROCEDURES.fnc)
as
  tmpVar NUMBER;
begin
  tmpVar := atan(aPer/100);
  tmpVar := tmpVar * 90 / acos(0);
  return tmpVar;
end;
/

grant EXECUTE on SP.PercentToDegree to PUBLIC;
create or replace public synonym PercentToDegree for SP.PercentToDegree;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.PRINT(Message in VARCHAR2)
-- Вывод сообщения на консоль IManClient.
-- (SP-PROCEDURES.fnc)
as
tmpVar BINARY_INTEGER;
begin
  tmpVar := SP.IM.MESSAGES.last;
  if tmpVar is null then tmpVar:=0; end if;
  SP.IM.MESSAGES(tmpVar+1):=Message; 
end;  
/
--
grant EXECUTE on SP.PRINT to PUBLIC;
create or replace public synonym PRINT for SP.PRINT;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.CallingMacro return VARCHAR2
-- Имя макропроцедуры, запустившей данную.
-- (SP-PROCEDURES.fnc)
as
begin
  return SP.M.MacroName(SP.M.CALLING_PACKAGE); 
end;  
/
--
grant EXECUTE on SP.CallingMacro to PUBLIC;
create or replace public synonym CallingMacro for SP.CallingMacro;
--

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.Get_ObjParTypeID(Obj IN VARCHAR2,
                                               Par IN VARCHAR2) 
RETURN NUMBER
-- Функция возвращает ID типа по полному имени объекта и параметра.
-- (SP-PROCEDURES.fnc)
is
TmpID NUMBER;
begin
  select Type_id into TmpID from SP.V_OBJECT_PAR_S p, SP.V_OBJECTS o 
    where p.OBJECT_ID = o.ID
      and upper(o.FULL_NAME) = upper(Obj) 
      and upper(p.NAME) = upper(Par);
  return TmpID;
exception when no_data_found then
  return -1; 
end;
/
--
grant EXECUTE on SP.Get_ObjParTypeID to PUBLIC;
create or replace public synonym Get_ObjParTypeID for SP.Get_ObjParTypeID;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.Get_ObjParID(ObjID IN NUMBER,
                                           Par IN VARCHAR2) 
RETURN NUMBER
-- Функция возвращает ID параметра объекта по ID объекта и имени параметра.
-- (SP-PROCEDURES.fnc)
is
tmpID NUMBER;
begin
  select ID into tmpID from SP.OBJECT_PAR_S p 
    where p.OBJ_ID = ObjID
      and upper(p.NAME) = upper(Par);
  return tmpID;
exception 
  when no_data_found then
    return -1; 
  when others then
    d( 'Ошибка нахождения идентификатора параметра '||Par ||
      ' для объекта '||ObjID||' '||SQLERRM, ' ERRROR in SP.Get_ObjParID');
    raise_application_error(-20033,
      'Ошибка нахождения идентификатора параметра '||Par ||
      ' для объекта '||ObjID||' '||SQLERRM);
  
end;
/
--
grant EXECUTE on SP.Get_ObjParID to PUBLIC;
create or replace public synonym Get_ObjParID for SP.Get_ObjParID;
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.Get_ObjParGroupName(ParID IN NUMBER,
                                                  GroupID OUT NUMBER) 
RETURN VARCHAR2
-- Функция возвращает имя группы, к которой принадлежит параметр объекта,
-- по ID параметра в каталоге.
-- Идентификатор группы, возвращается в вторым параметром функции.
-- (SP-PROCEDURES.fnc)
is
tmpNAME SP.GROUPS.NAME%type;
begin
  if ParID is null then 
    GroupId := 11;
    return 'NoCatalogue';
  end if;
  select g.NAME, g.ID into tmpNAME, GroupID from SP.OBJECT_PAR_S p, SP.GROUPS g 
    where p.ID = ParID
      and g.ID = p.Group_ID;
  return tmpNAME;
exception 
  when no_data_found then
    return -1; 
  when others then
    d( 'Ошибка нахождения идентификатора параметра '||ParID ||SQLERRM,
       ' ERRROR in SP.Get_ObjParGroupName');
    raise_application_error(-20033,
      'Ошибка нахождения идентификатора параметра '||ParID || SQLERRM);
  
end;
/
--
grant EXECUTE on SP.Get_ObjParGroupName to PUBLIC;
create or replace public synonym Get_ObjParGroupName for SP.Get_ObjParGroupName;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.S2B(S IN VARCHAR2) 
RETURN BOOLEAN
-- Функция возвращает true, если входной параметр равен true без учёта регистра,
-- false - если параметр равен false без учёта регистра, иначе нулл.
-- (SP-PROCEDURES.fnc)
is
begin
return
  case upper(S)
    when 'FALSE' then false 
    when 'TRUE' then true
  else null
  end;
end;
/
--
grant EXECUTE on SP.S2B to PUBLIC;
create or replace public synonym S2B for SP.S2B;

--------------------------------------------------------------------------------
CREATE OR REPLACE function SP.Cyr2Lat(str varchar2) return varchar2
-- замена избранных кириллических букв на визуально похожие латинские буквы
-- (SP-PROCEDURES.fnc)
is      
begin                                            
return translate(str,
      -- кириллическиe буквы, которые выглядят как латинские
      'АВСЕНКМОРТХасеоху', 
      -- латинскиe буквы, которые выглядят как кириллическиe
      'ABCEHKMOPTXaceoxy'  
     );        
end;  
/
--
grant EXECUTE on SP.Cyr2Lat to PUBLIC;

--------------------------------------------------------------------------------
CREATE OR REPLACE function SP.E3Repo(guid varchar2, 
                                     operationtype varchar2,
                                     modelname varchar2) return varchar2
-- отработка команды на репликацию элемента с идентификатором guid 
-- проекта projguid 
-- тип операции operationtype (i, e, d)
-- имя модели определяет реплицируемую модель
-- (SP-PROCEDURES.fnc)
is 
p SP.TMPAR;
ModelID NUMBER;     
begin      
d('guid='||guid ||
  ' operationtype=' || operationtype ||
  ' modelname=' || modelname,
  'call function SP.E3Repo');
begin
  select ID into ModelID from SP.MODELS where NAME = modelname;
exception
  when others then 
    d(modelname || ' не найдено!!!', 'ERROR in SP.E3Repo');
    return 'OK';
end;  
p := SP.TMPAR(SP.MO.MOD_OBJ_ID_BY_FULL_NAME(ModelID, '/Репликация'),
              operationtype);
insert into SP.ARRAYS(TYPE_ID, NAME, GROUP_ID, S)
  values (g.TStr4000, p.VAL.S, p.VAL.N, guid);
commit;           
return 'OK';
exception
  when others then
    d(SQLERRM, 'ERROR in SP.E3Repo');
    return 'OK';          
end;  
/
--
grant EXECUTE on SP.E3Repo to PUBLIC;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.UPDATE_LOBS_TAG(LOB IN OUT nocopy SP.TVALUE,
                                               TAG in NUMBER)
-- Обновление поля X у значения LOB на значение параметра TAG
-- и изменение поля TAG в таблице SP.LOB_S по ссылке LOB.
-- (SP-PROCEDURES.fnc)
as
begin
  SP.Lobs.updateTAG(Lob, TAG);
end;
/

grant EXECUTE on SP.UPDATE_LOBS_TAG to PUBLIC;
create or replace public synonym UPDATE_LOBS_TAG for SP.UPDATE_LOBS_TAG;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.Fill_Object(P IN OUT nocopy SP.G.TMACRO_PARS,
                                          GroupName in VARCHAR2)
-- Заполнение входного массива параметрами объекта,
-- определённого набором параметров на входе, с фильтрацией по группе,
-- определённой вторым параметром.
-- (SP-PROCEDURES.fnc)
as
tmpVar NUMBER;
tmpS VARCHAR2(100);
begin
  tmpVar := SP.MO.MOD_OBJ_ID(P, tmpS);
  if tmpVar is null then
    RAISE_APPLICATION_ERROR(-20033,
      'ERROR in SP.Fill_Object. Объект '||to_.str(P)||' не найден!'); 
  end if;
  P.delete;
  for op in
  (
    select * from TABLE (SP.MO.GET_V_MODEL_OBJECT_PARS(tmpVar))p
      where p.Group_ID in (select * from TABLE(SP.GRoupsofGroup(GroupName)))
      order by PARAM_NAME
  )
 loop
  P(op.PARAM_NAME) := SP.TVALUE( op.TYPE_ID,null,0, op.E_VAL,
                                 op.N, op.D, op.S, op.X, op.Y);
  end loop;
end;
/

grant EXECUTE on SP.Fill_Object to PUBLIC;
create or replace public synonym Fill_Object for SP.Fill_Object;

-- end of file
