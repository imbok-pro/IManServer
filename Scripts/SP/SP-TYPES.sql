-- SP TYPES
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 05.08.2010
-- update 02.09.2010 22.09.2010 03.11.2010 08.11.2010 19.11.2010 09.12.2010
--        22.12.2010 18.01.2011 26.01.2011 10.02.2011 15.03.2011 17.03.2011
--				06.04.2011 04.05.2011 13.05.2011 19.05.2011 08.06.2011 06.10.2011
--        12.10.2011 14.10.2011 23.10.2011 25.10.2011 02.11.2011 09.11.2011
--        18.11.2011 25.11.2011 30.11.2011 05.12.2011 21.12.2011 16.03.2012
--        20.03.2012 04.06.2012 17.08.2012 24.12.2012 24.01.2013 04.02.2013
--        04.03.2013 22.03.2013 10.06.2013 25.06.2013 20.08.2013 25.08.2013
--        04.10.2013 30.04.2014 04.06.2014 11.06.2014 13.06.2014 15.06.2014
--        02.07.2014 22.07.2014 26.08.2014 30.08.2014-01.09.2014 23.10.2014
--        01.03.2015 26.03.2015 31.03.2015 01.04.2015 17.05.2015 25.05.2015
--        08.07.2015 10.06.2016 16.09.2016 22.11.2016 27.11.2016 12.01.2017
--        28.02.2017 10.03.2017 13.03.2017 16.03.2017 10.04.2017-12.04.2017
--        17.04.2017 03.05.2017 15.05.2017 11.01.2018 17.01.2018 01.02.2018
--        12.02.2018 26.01.2019 28.01.2019 19.11.2020 07.03.2021-08.03.2021
--        25.03.2021 06.04.2021 01.07.2021 11.09.2021
--*****************************************************************************

-- Дерево каталога.
-------------------------------------------------------------------------------
CREATE TABLE SP.CATALOG_TREE
(
  ID NUMBER,
  IM_ID NUMBER,
  NAME VARCHAR2(128)NOT NULL,
  COMMENTS VARCHAR2(4000) NOT NULL,
  PARENT_ID NUMBER,
  GROUP_ID NUMBER default 9 not null,
  M_DATE DATE NOT NULL,
  M_USER VARCHAR2(60) NOT NULL,
  CONSTRAINT PK_CATALOG_TREE PRIMARY KEY(ID),
  CONSTRAINT REF_CATALOG_TREE_internal
  FOREIGN KEY (PARENT_ID)
  REFERENCES SP.CATALOG_TREE (ID)ON DELETE SET NULL,
  CONSTRAINT REF_CATALOG_TREE_TO_GROUPS
  FOREIGN KEY (GROUP_ID)
  REFERENCES SP.GROUPS (ID)
);

CREATE UNIQUE INDEX SP.CATALOG_TREE 
  ON SP.CATALOG_TREE (upper("NAME"),nvl("PARENT_ID",0));
CREATE INDEX SP.CATALOG_TREE_PARENT_ID ON SP.CATALOG_TREE (PARENT_ID);
CREATE INDEX SP.CATALOG_TREE_GROUP_ID ON SP.CATALOG_TREE (GROUP_ID);

COMMENT ON TABLE SP.CATALOG_TREE IS 'Дерево каталога.(SP-TYPES.sql)';

COMMENT ON COLUMN SP.CATALOG_TREE.ID       
  IS 'Идентификатор узла.';
COMMENT ON COLUMN SP.CATALOG_TREE.IM_ID       
  IS 'Идентификатор изображения узла.';
COMMENT ON COLUMN SP.CATALOG_TREE.NAME     
  IS 'Имя узла.';
COMMENT ON COLUMN SP.CATALOG_TREE.COMMENTS 
  IS 'Описание узла.';
COMMENT ON COLUMN SP.CATALOG_TREE.PARENT_ID
  IS 'Ссылка на узел родитель.';
COMMENT ON COLUMN SP.CATALOG_TREE.GROUP_ID
  IS 'Ссылка на группу.';
COMMENT ON COLUMN SP.CATALOG_TREE.M_DATE 
  IS 'Дата создания или изменения узла.';
COMMENT ON COLUMN SP.CATALOG_TREE.M_USER 
  IS 'Пользователь создавший или изменивший узел.';
  
-------------------------------------------------------------------------------
CREATE GLOBAL TEMPORARY TABLE SP.UPDATED_CATALOG_TREE
(
  NEW_ID NUMBER,
  NEW_IM_ID NUMBER,
  NEW_NAME VARCHAR2(128),
  NEW_COMMENTS VARCHAR2(4000),
  NEW_PARENT_ID NUMBER,
  NEW_GROUP_ID NUMBER,
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60),
  OLD_ID NUMBER,
  OLD_IM_ID NUMBER,
  OLD_NAME VARCHAR2(128)NOT NULL,
  OLD_COMMENTS VARCHAR2(4000) NOT NULL,
  OLD_PARENT_ID NUMBER,
  OLD_GROUP_ID NUMBER,
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.UPDATED_CATALOG_TREE
  IS 'Временная таблица, содержащая перечень изменённых записей.';
  
  
-- Типы данных.
-------------------------------------------------------------------------------
CREATE TABLE SP.PAR_TYPES
(
  ID NUMBER(9),
  IM_ID NUMBER,
  NAME VARCHAR2(128)NOT NULL,
  COMMENTS VARCHAR2(4000) NOT NULL,
  CHECK_VAL VARCHAR2(4000),
	STRING_TO_VAL VARCHAR2(4000),
	VAL_TO_STRING VARCHAR2(4000),
	SET_OF_VALUES VARCHAR2(4000),
  GROUP_ID NUMBER default 9 not null,
  M_DATE DATE NOT NULL,
  M_USER VARCHAR2(60) NOT NULL,
  CONSTRAINT PK_PAR_TYPES PRIMARY KEY(ID),  
  CONSTRAINT REF_PAR_TYPES_TO_GROUPS
  FOREIGN KEY (GROUP_ID)
  REFERENCES SP.GROUPS (ID)
);

CREATE UNIQUE INDEX SP.PAR_TYPES_NAME ON SP.PAR_TYPES(upper(NAME));
CREATE INDEX SP.PAR_TYPES_GROUP_ID ON SP.PAR_TYPES(GROUP_ID);

COMMENT ON TABLE SP.PAR_TYPES IS 'Типы параметров.';

COMMENT ON COLUMN SP.PAR_TYPES.ID       
  IS 'Идентификатор типа параметра. 1..999 - встроенные типы. Такие типы может добавлять и редактировать только PROG.';
COMMENT ON COLUMN SP.PAR_TYPES.IM_ID       
  IS 'Идентификатор изображения.';
COMMENT ON COLUMN SP.PAR_TYPES.GROUP_ID
  IS 'Ссылка на группу.';
COMMENT ON COLUMN SP.PAR_TYPES.NAME     
  IS 'Имя типа параметра.';
COMMENT ON COLUMN SP.PAR_TYPES.COMMENTS 
  IS 'Описание типа параметра.';
COMMENT ON COLUMN SP.PAR_TYPES.CHECK_VAL 
  IS 'Если тип имеет именованные значения, то значение должено быть нулл (отсутствовать). Это является признаком именованного значения. Блок pl/sql для проверки значения параметра, V - переменная блока типа TVALUE, содержащая  значение проверяемого параметра. Если значение не допустимо, то ошибка. Если блок проверки не определён, то последующие три поля несущественны';  
COMMENT ON COLUMN SP.PAR_TYPES.STRING_TO_VAL 
  IS 'Если тип имеет именованные значения, то поле не используется. Блок pl/sql для получения значения параметра по его строковому представлению, S - строка, V - возвращаемое значение типа TVALUE (причем тип уже установлен).';  
COMMENT ON COLUMN SP.PAR_TYPES.VAL_TO_STRING 
  IS 'Если тип имеет именованные значения, то поле не используется. Блок pl/sql для преобразования значения параметра в уникальную для типа параметра строку, V - значение типа TVALUE, S - возвращаемое значение типа VARCHAR2.';  
COMMENT ON COLUMN SP.PAR_TYPES.SET_OF_VALUES 
  IS 'Если тип имеет именованные значения, то поле не используется. Курсор для получения набора из двух полей для данного типа. Первое поле S_VALUE - уникальное символьных значение, второе - COMMENTS - комментарии к значению.';  
COMMENT ON COLUMN SP.PAR_TYPES.M_DATE 
  IS 'Дата создания или изменения типа.';
COMMENT ON COLUMN SP.PAR_TYPES.M_USER 
  IS 'Пользователь создавший или изменивший тип.';
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.TO_StrType(T in NUMBER) return VARCHAR2
-- предоставляем имя типа параметра
-- (SP_TYPES.sql)
is
TypeName SP.PAR_TYPES.NAME%type;
begin
	select NAME into TypeName	
	  from SP.PAR_TYPES where ID=T;
	return TypeName;
exception
  when no_data_found then 
	  raise_application_error(-20033,
      'SP.TO_StrType, Неверный идентификатор типа '||
                      nvl(to_char(T),'"NULL!"')||'! ');	 				 
end;
/
GRANT EXECUTE ON SP.TO_StrType to public;	
   
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.TO_Type(T in VARCHAR2) return NUMBER
-- предоставляем идентификатор типа параметра по имени
-- (SP_TYPES.sql)
is
SType NUMBER;
begin
	select ID into SType	
	  from SP.PAR_TYPES where upper(NAME)=upper(T);
	return SType;
exception
  when no_data_found then 
	  raise_application_error(-20033,
		  'SP.TO_Type, Неверный тип: '||nvl(T,'"NULL!"')||'!');	 			 
end;
/
	   
GRANT EXECUTE ON SP.TO_Type to public;	

--*****************************************************************************
-- идентификаторы (ID) для встроенных типов присваиваются в пакете SP.TG
declare
tmp SP.COMMANDS.COMMENTS%type;
Ch_V SP.COMMANDS.COMMENTS%type;
S_to_V SP.COMMANDS.COMMENTS%type;
V_to_S SP.COMMANDS.COMMENTS%type;
Vset SP.COMMANDS.COMMENTS%type;
-------------------------------------------------------------------------------
procedure InsType(Num in NUMBER,TypeName in VARCHAR2)
is
begin
  insert into SP.PAR_TYPES VALUES (
		Num, null, TypeName, tmp, Ch_V, S_to_V, V_to_S, Vset, G.OTHER_GROUP,
    to_date('05-01-2014','dd-mm-yyyy'), 'SP');
  -- Если блок не определён, то значение именованное
  Ch_V:='begin null; end;';
  S_to_V:=null;
  V_to_S:=null;
  Vset:=null;
end;
-------------------------------------------------------------------------------
procedure UpdType(Num in NUMBER,TypeName in VARCHAR2)
is
begin
  update SP.PAR_TYPES set
    NAME = TypeName,
    COMMENTS = tmp,
    CHECK_VAL = Ch_V,     
    STRING_TO_VAL = S_to_V,
    VAL_TO_STRING = V_to_S,
    SET_OF_VALUES = Vset,
    GROUP_ID = G.OTHER_GROUP,
    M_DATE = null, 
    M_USER = 'SP'
    where ID = Num;
end;
begin
-------------------------------------------------------------------------------

-- ClientCommands.
tmp:='Перечень команд, которые может выполнить программный клиент серверов моделей.';
Ch_V:=Null;
-- S_to_V:=
-- V_to_S:=
-- Vset:=
Instype(SP.G.TClientCommand,'ClientCommand');
-------------------------------------------------------------------------------

-- Clob.
tmp:='Текстовый файл.';
Ch_V:='SP.Lobs.testLob(V);';
-- S_to_V:=
S_to_V:='SP.Lobs.S2CLob(S, V);';
-- V_to_S:=
V_to_S:= 'S:= SP.Lobs.CL2Str(V);';
-- Vset:=
Instype(SP.G.TClob,'Clob');
-------------------------------------------------------------------------------

-- Blob.
tmp:='Файл с данными.';
Ch_V:='SP.Lobs.testLob(V);';
-- S_to_V:=
S_to_V:='SP.Lobs.S2BLob(S, V);';
-- V_to_S:=
V_to_S:= 'S:= SP.Lobs.BL2Str(V);';
-- Vset:=
Instype(SP.G.TBlob,'Blob');
-------------------------------------------------------------------------------

-- FileType.
tmp:='Тип Файла.';
Ch_V:= null;
-- S_to_V:=
S_to_V:= null;
-- V_to_S:=
V_to_S:= null;
-- Vset:=
Instype(SP.G.TFileType,'FileType');
-------------------------------------------------------------------------------

-- DATA.
tmp:='Двоичные данные в виде HEX-строки.';
Ch_V:='if (V.N is not null) or (V.E is not null) or (V.X is not null) or (V.Y is not null) then raise_application_error(-20030,''Wrong DATA'');end if;';
--? V.D
S_to_V:=' V.S:=S;';
V_to_S:=' S:=V.S;';
-- Vset:=
Instype(SP.G.TData,'Data');
-------------------------------------------------------------------------------

-- Login.
tmp:='Ссылка на логин пользователя в системе.';
Ch_V:='if (V.N is not null) or (V.E is not null) or (V.X is not null) or (V.Y is not null) then raise_application_error(-20030,''Wrong Login''); end if; select count(*) into V.Y from SP.V_USERS where SP_USER = V.S; if V.Y = 0 then raise_application_error(-20030,''Wrong Login''); end if;';
--? V.D
S_to_V:=' select SP_USER into V.S from SP.V_USERS where SP_USER=S;';
V_to_S:=' S:=V.S;';
Vset:=' select rownum id, SP_USER S_VALUE, COMMENTS from SP.V_USERS';
Instype(SP.G.TLogin,'Login');
-------------------------------------------------------------------------------

-- Used_Object.
tmp:='Used_Object. Данный объект есть символьная ссылка на объект каталога. Поле S этого типа содержит: либо GUID объекта каталого, либо его полное имя. Объекты  каталога или Модели не могут содержать параметры данного типа. Параметр данного типа передаётся серверам приложений для привязки объекта на серверах приложений к объекту каталога базы. Допускается единственный параметр объекта данного типа, полученного от сервера приложения. Он может иметь имя "Used_Object". Если сервер приложений не передал параметр с именем "Used_Object", база ищет любой другой параметр данного типа. Если ни какой параметр не найден или он равен нулл, то используется универсальный объект для построения объекта в модели.';
-- Ch_V:=
Ch_V:= 'if (V.E is not null) or (V.N is not null) or (V.X is not null) or (V.Y is not null) then raise_application_error(-20030, ''Wrong Used_Object''); end if; if (V.S is not null) and (SP.MO.GET_CATALOG_OBJECT(V.S) is null) then raise_application_error(-20030,''Wrong Used_Object, ''||V.S||''!'');end if;';
-- S_to_V:=
S_to_V:=' V.S:=S;';
-- V_to_S:=
V_to_S:= 'S:=V.S;';
-- Vset:=
Instype(SP.G.TUsed_Object,'Used_Object');
-------------------------------------------------------------------------------

-- Array.
tmp:='Array. Данный объект есть ссылка на массив как на единое целое. Поле S этого типа содержит имя массива. Принадлежность к пространству имён данного масива определяется полем N (ссылка на группу), поле D может определять временной срез массива (использовать ли только данные на дату) или нет, если D - null. Для хранения данных всех массивов фреймворка используется таблица SP.ARRAYS и пакет SP.A. При переводе в строку значение данного типа есть полное имя массива, состоящее из <имя группы>.<S> и даты серии, написанной после имени массива через пробел в формате "YYYY-MM-DD_hh:mi:ss". Если поле D - null, то пробел и дата не добавляется.';
-- Ch_V:=
Ch_V:= 'if (V.E is not null) or (V.X is not null) or (V.Y is not null) then raise_application_error(-20030, ''Wrong Array''); end if; select count(*) into V.Y from SP.V_PRIM_GROUPS where G_ID = V.N; if (V.Y = 0) and (V.N is not null) then raise_application_error(-20030,''Wrong Array GROUP_ID ''||to_char(V.N)); end if;';
-- S_to_V:=
S_to_V:='SP.A.S2ARR(S, V);';
-- V_to_S:=
V_to_S:= 'S:= SP.A.ARR2S(V);';
-- Vset:=
Instype(SP.G.TArr,'Array');
-------------------------------------------------------------------------------

-- Number.
tmp:='Number. Поле "D" может быть произвольным. Иногда оно используется для отражения времени последнего изменения значения.';
-- Ch_V:=
Ch_V:= 'if (V.E is not null) or (V.S is not null) or (V.X is not null) or (V.Y is not null) then raise_application_error(-20030,''Wrong NUMBER'');end if;';
-- S_to_V:=
S_to_V:='if upper(S)=''NULL'' then V.N := null; else V.N:=to_number(S); end if;';
-- V_to_S:=
V_to_S:= 'S:=to_.STR(V.N);';
-- Vset:=
Instype(SP.G.TNumber,'Number');
-------------------------------------------------------------------------------

-- Date.
tmp:='Date. Дата и время.';			 
Ch_V:= 'if (V.N is not null) or (V.E is not null) or (V.S is not null) or (V.X is not null) or (V.Y is not null) then raise_application_error(-20030,''Wrong DATE'');end if;';
-- строковое значение вместе с форматом и языком
S_to_V:=' V.D:=to_date(S);';
-- строковое значение вместе с форматом и языком по умолчанию
V_to_S:=' S:=to_char(V.D);';
-- Vset:=
Instype(SP.G.TDate,'Date');
-------------------------------------------------------------------------------

-- Str4000. VARCHAR2(4000).
tmp:='Строка.';		
Ch_V:='if (V.N is not null) or (V.E is not null) or (V.X is not null) or (V.Y is not null) then raise_application_error(-20030,''Wrong Str4000'');end if;';
--? V.D
S_to_V:=' V.S:=S;';
V_to_S:=' S:=V.S;';
-- Vset:=
Instype(SP.G.TStr4000,'Str4000');
-------------------------------------------------------------------------------

-- NullBoolean.
tmp:='NullBoolean. Значения "null", "false" или "true".';
Ch_V:=Null;
-- S_to_V:=
-- V_to_S:=
-- Vset:=
Instype(SP.G.TNullBoolean,'NullBoolean');
-------------------------------------------------------------------------------
-- Boolean.
tmp:='Boolean. Значения "false" или "true".';
Ch_V:=Null;
-- S_to_V:=
-- V_to_S:=
-- Vset:=
Instype(SP.G.TBoolean,'Boolean');
-------------------------------------------------------------------------------

-- Ms Integer.
tmp:='Ms Integer - эквивалент PLS_INTEGER. Поле "D" может быть произвольным. Иногда оно используется для отражения времени последнего изменения значения.';
-- проверка на диапазон
Ch_V:=
'if (V.E is not null) or (V.S is not null) or (V.X is not null) or (V.Y is not null) then raise_application_error(-20030,''Wrong Integer'');end if;'||
'declare I number(9); begin I:=V.N; end;';
S_to_V:= ' V.N:=to_number(S);';
V_to_S:= ' S:=to_.STR(V.N);';
-- Vset:=
Instype(SP.G.TInteger,'Integer');
---------------------------------------------------------------------------

-- Ms NullShort.
tmp:='NullShort. Поле "D" может быть произвольным. Иногда оно используется для отражения времени последнего изменения значения.';
-- проверка на диапазон
Ch_V:=
'if (V.E is not null) or (V.S is not null) or (V.X is not null) or (V.Y is not null) then raise_application_error(-20003,''Wrong NullShort'');end if;'||
'declare I number(5); begin I:=V.N; if i < -32768 and i > 32767 then raise_application_error(-20030,''Wrong Value'');end if; end;';   
S_to_V:='if upper(S)=''NULL'' then V.N := null; else V.N:=to_number(S); end if;';
V_to_S:= ' S:=to_.STR(V.N);';
-- Vset:=
Instype(SP.G.TNullShort,'NullShort');

-------------------------------------------------------------------------------

-- Ms NullInteger.
tmp:='NullInteger. Поле "D" может быть произвольным. Иногда оно используется для отражения времени последнего изменения значения.';
-- проверка на диапазон
Ch_V:=
'if (V.E is not null) or (V.S is not null) or (V.X is not null) or (V.Y is not null) then raise_application_error(-20003,''Wrong NullInteger'');end if;'||
'declare I number(9); begin I:=V.N; end;';   
S_to_V:='if upper(S)=''NULL'' then V.N := null; else V.N:=to_number(S); end if;';
V_to_S:= ' S:=to_.STR(V.N);';
-- Vset:=
Instype(SP.G.TNullInteger,'NullInteger');

-------------------------------------------------------------------------------

-- CodeList.
tmp:='CodeList. Неотрицательное целое используется в интерграфе для обозначения различных типов данных.  См. AllCodeList.xls. Значения 10 001 .. 40 000 зарезервированы за пользователем, остальные - за Интерграфом. Поле "S" может быть произвольным. Oно может присваиваться моделью и сохраняется в базе, но пока никак не используется. При преобразовании значения в строку и обратно поле S  будет потереною.';
-- проверка на диапазон
Ch_V:=
'if (V.E is not null) or (V.X is not null) or (V.Y is not null) '||
'then raise_application_error(-20003,''Wrong CodeList'');end if;'||
'declare I number(5); begin I:=V.N; if i < -1 or i > 40000 then '||
' raise_application_error(-20030,''Wrong Value'');end if; end;';   
S_to_V:= ' V.N:=to_number(S);';
V_to_S:= ' S:=to_.STR(V.N);';
-- Vset:=
Instype(SP.G.TCodeList,'CodeList');
-------------------------------------------------------------------------------

-- NullDouble.
tmp:='Double - эквивалент BINARY_DOUBLE. Поле "D" может быть произвольным. Иногда оно используется для отражения времени последнего изменения значения.';
Ch_V:=
'if (V.E is not null) or (V.S is not null) or (V.X is not null) or (V.Y is not null) then raise_application_error(-20030,''Wrong Double'');end if;'||
'declare R FLOAT(49); begin R:=V.N; end;';
S_to_V:='if upper(S)=''NULL'' then V.N := null; else V.N:=to_number(S); end if;';
V_to_S:= ' S:=to_.STR(V.N);';
-- Vset:=
Instype(SP.G.TNullDouble,'NullDouble');
-------------------------------------------------------------------------------

-- NullFloat.
tmp:='NullFloat - эквивалент BINARY_DOUBLE. Поле "D" может быть произвольным. Иногда оно используется для отражения времени последнего изменения значения.';
Ch_V:=
'if (V.E is not null) or (V.S is not null) or (V.X is not null) or (V.Y is not null) then raise_application_error(-20030,''Wrong Float'');end if;'||
'declare R FLOAT(49); begin R:=V.N; if r > 34E37 then raise_application_error(-20030,''Wrong Value'');end if; end;';
S_to_V:='if upper(S)=''NULL'' then V.N := null; else V.N:=to_number(S); end if;';
V_to_S:= ' S:=to_.STR(V.N);';
-- Vset:=
Instype(SP.G.TNullFloat,'NullFloat');
-------------------------------------------------------------------------------

-- Double.
tmp:='Double - эквивалент BINARY_DOUBLE. Поле "D" может быть произвольным. Иногда оно используется для отражения времени последнего изменения значения.';
Ch_V:=
'if (V.E is not null) or (V.S is not null) or (V.X is not null) or (V.Y is not null) then raise_application_error(-20030,''Wrong Double'');end if;'||
'declare R FLOAT(49); begin R:=V.N; end;';
S_to_V:= ' V.N:=to_number(S);';
V_to_S:= ' S:=to_.STR(V.N);';
-- Vset:=
Instype(SP.G.TDouble,'Double');
-------------------------------------------------------------------------------

-- NLS_Language. Язык сессии пользователя.
tmp:='Язык сессии пользователя. После выполнения соединения с сервером устанавливается язык сессии в соответствии с этим параметром. Может меняться в процессе работы приложения.';
-- проверка на возможные значения из E_VAL 
Ch_V:=null;
-- S_to_V:= '';
-- V_to_S:=
-- Vset:=
Instype(SP.G.TNLang,'NLS_Language');
-------------------------------------------------------------------------------

-- NLS_Territory. Настройки территории для сессии.
tmp:='Настройки территории для сессии. После выполнения соединения с сервером устанавливается территория сессии в соответствии с этим параметром. Может меняться в процессе работы приложения. Изменение территории не меняет настройку параметра сессии "NLS_Numeric_Characters".';
-- проверка на возможные значения из E_VAL
Ch_V:=null;
-- S_to_V:=
-- V_to_S:=
-- Vset:=
Instype(SP.G.TNTerritory,'NLS_Territory');
-------------------------------------------------------------------------------

-- NLS_Numeric_Characters. Настройка символов десятичного разделителя и разделителя тысяч.
tmp:='Настройка символов десятичного разделителя и разделителя тысяч. После выполнения соединения с сервером устанавливается значение сессии в соответствии с этим параметром. Может меняться в процессе работы приложения.';
-- проверка на возможные значения из E_VAL
Ch_V:=null;
-- S_to_V:=
-- V_to_S:=
-- Vset:=
Instype(SP.G.TNNumChars ,'NLS_Numeric_Characters ');
-------------------------------------------------------------------------------

-- NLS_SORT. Локализация сортировки.
tmp:='Локализация сортировки. После выполнения соединения с сервером устанавливается значение типа сортировки сессии. Может меняться в процессе работы приложения. Изменение территории изменяет настройку сортировки сессии. При этом значение параметра сортировки будет не совпадать с типом сортировки сессии.';
-- проверка на возможные значения из E_VAL
Ch_V:=null;
-- S_to_V:=
-- V_to_S:=
-- Vset:=
Instype(SP.G.TNSort,'NLS_SORT');
-------------------------------------------------------------------------------

-- NoValue.
tmp:='Значение не используется.';
Ch_V:= 'if (V.E is not null) or (V.N is not null) or (V.D is not null)  or (V.S is not null) or (V.X is not null) or (V.Y is not null) then raise_application_error(-20030,''Wrong NoValue'');end if;';
S_to_V:=null;
V_to_S:=null;
-- Vset:=
Instype(SP.G.TNoValue,'NoValue');
-------------------------------------------------------------------------------

-- XY. Координаты точки
tmp:='Координаты точки. В поле "X" содержится координата "X", в поле "Y" - "Y". Представление в виде строки это координаты точки, разделённые символом "." или ",". Все символы, кроме цифр, или повторение разделителя - это ошибка.';
Ch_V:= 'if (V.E is not null) or (V.N is not null) or (V.D is not null)  or (V.S is not null) then raise_application_error(-20030,''Wrong XY'');end if;';
S_to_V:=' SP.S2XY(S,V);';
V_to_S:=' S:=to_.STR(V.X)||'':''||to_.STR(V.Y);';
-- Vset:=
Instype(SP.G.TXY,'XY');
-------------------------------------------------------------------------------

-- XYZ. Координаты точки
tmp:='Координаты точки. В поле "X" содержится координата "X", в поле "Y" - "Y", в поле "Z" - "Z". Представление в виде строки это координаты точки, разделённые символом "." или ",". Все символы, кроме цифр, или повторение разделителя - это ошибка.';
Ch_V:= 'if (V.E is not null) or (V.D is not null)  or (V.S is not null) then raise_application_error(-20030,''Wrong XYZ'');end if;';
S_to_V:=' SP.S3XYZ(S,V);';
V_to_S:=' S:=to_.STR(V.X)||'':''||to_.STR(V.Y)||'':''||to_.STR(V.N);';
-- Vset:=
Instype(SP.G.TXYZ,'XYZ');
-------------------------------------------------------------------------------

-- NLS_Date_Format. Формат даты сессии пользователя.
tmp:='Формат даты сессии. После выполнения соединения с сервером устанавливается формат даты сессии в соответствии с этим параметром. Может меняться в процессе работы приложения.';
-- проверка записью текущей даты в строку
Ch_V:='declare DS varchar2(100);begin DS:=to_char(sysdate,V.S); end;';
S_to_V:=' V.S:=S;';
V_to_S:=' S:=V.S;';
-- Vset:=
Instype(SP.G.TNDFormat,'NLS_DateFormat');
-------------------------------------------------------------------------------

-- NullDate. Тип введён для возможности отличать в MS Studio тип даты 
-- позволяющий использовать значение нулл. 
tmp:='NullDate. Дата и время. Тип введён для возможности отличать в MS Studio тип даты позволяющий использовать значение нулл. ';			 
Ch_V:= 'if (V.N is not null) or (V.E is not null) or (V.S is not null) or (V.X is not null) or (V.Y is not null) then raise_application_error(-20030,''Wrong NullDate'');end if;';
-- строковое значение вместе с форматом и языком
S_to_V:='if upper(S)=''NULL'' then V.D := null; else V.D:=to_date(S); end if;';
-- строковое значение вместе с форматом и языком по умолчанию
V_to_S:=' S:=to_char(V.D);';
-- Vset:=
Instype(SP.G.TNullDate,'NullDate');
-------------------------------------------------------------------------------

-- IType. Общий тип (класс) объекта в SP3D.
tmp:='Общий тип (класс) объекта в SP3D.';
Ch_V:=null;
Instype(SP.G.TIType,'IType');
-------------------------------------------------------------------------------

-- TreeNode. Ссылка на узел дерева каталога SP3D.
tmp:='Ссылка на узел дерева каталога SP3D. Поле N содержит ссылку на узел дерева. Если объект лист, то поле Y =1, иначе 0. Тип допускает неопределённое значение. При этом поле N равно нулл, а поле Y может быть любым. Полный путь к объекту представляет из себя его строковое значение. Набор значений показывает множестро детей узла, если он не лист, или множество соседей, если узел лист. Функция Tree.NodeName предоставляет имя узла, расположенного на i-м уровне от листа. Функция Tree.LastNodeNames обрезает строковое значение от корня до некоторого узла.';
-- Проверяем, что ссылка определяет узел в таблице SP.CATALOG_TREE,
-- а поле Y - правильно указывает признак листа.  
Ch_V:='SP.TREE.CHECK_VALUE(V);';
-- Преобразовываем полный путь объекта в идентификатор.
S_to_V:='SP.TREE.S2V(S,V);';
-- Преобразовываем идентификатор дерева в полный путь.
V_to_S:='S:=SP.TREE.FullNodeName(V.N,V.S);';
-- Предоставляем множестро детей узла, если он не лист, или множество соседей,
-- если узел лист.
Vset:='select * from table(SP.TREE.NODES)';
Instype(SP.G.TTreeNode,'TreeNode');
-------------------------------------------------------------------------------

-- TGroup. Ссылка на узел графа Групп.
tmp:='Ссылка на узел графа групп. Поле N содержит ссылку на узел. Равенство V.N нулл означает отсутствие фильтрации. (В фильтр, основанный на значении нулл войдут все объекты) Строковое значение типа это Имя группы.  Набор значений показывает состав имен, включённых в группу, а также состав родителей группы и корень.';
-- Проверяем, что ссылка определяет узел в таблице SP.GROUPS.  
Ch_V:='if V.Y is not null or V.X is not null or V.S is not null then raise_application_error(-20030,''Wrong GROUP''); end if;select count(*) into V.Y from SP.V_PRIM_GROUPS where G_ID = V.N; if (V.Y = 0) and (V.N is not null) then raise_application_error(-20030,''Wrong GROUP_ID ''||to_char(V.N)); end if;';
-- Преобразовываем имя группы в идентификатор.
S_to_V:='if (S is null) or (S = ''/'') or ( Upper(S) = ''ROOT'' ) then V.N:=null; else select G_ID into V.N from SP.V_PRIM_GROUPS where upper(NAME) = upper(S);end if;';
-- Преобразовываем идентификатор группы в имя.
V_to_S:='if V.N is null then S:= ''ROOT''; else select NAME into S from SP.V_PRIM_GROUPS where G_ID = V.N;end if;';
-- Предоставляем множество групп.
Vset:='select * from table(SP.GRAPH2TREE.GROUP_NODES)';
Instype(SP.G.TGROUP,'Group');
-------------------------------------------------------------------------------

-- TTrans. Ссылка на проводку бухгалтерии.
tmp:='Ссылка на проводку бухгалтерии. Поле N содержит ссылку на транзакцию (проводку). Символное значение - это символьное значение N.';
-- Проверяем, что ссылка определяет узел в таблице SP.BUH.  
Ch_V:='if V.Y is not null or V.X is not null or V.S is not null then raise_application_error(-20030,''Wrong TRANS''); end if;select count(*) into V.Y from SP.TRANS where ID = V.N; if (V.Y = 0) and (V.N is not null) then raise_application_error(-20030,''Wrong TRANS_ID ''||to_char(V.N)); end if;';
-- Преобразовываем строку в идентификатор.
S_to_V:='V.N:= to_number(S);';
-- Преобразовываем идентификатор транзакции в строку.
V_to_S:='S:= to_char(V.N);';
-- Предоставляем множество групп.
Vset:=null;
Instype(SP.G.TTRANS,'Trans');
-------------------------------------------------------------------------------

-- CardinalPoint. Точка привязки.
tmp:='Точка привязки.';
Ch_V:=null;
Instype(SP.G.TCardinalPoint,'CardinalPoint');
-------------------------------------------------------------------------------

-- CSType. Вид координатной системы.
tmp:='Вид координатной системы.';
Ch_V:=null;
Instype(SP.G.TCSType,'CSType');
-------------------------------------------------------------------------------

-- CSHand. Правило рук для координатной системы.
tmp:='Правило рук для координатной системы.';
Ch_V:=null;
Instype(SP.G.TCSHand,'CSHand');
-------------------------------------------------------------------------------

-- AxisType. Тип осей координатной системы.
tmp:='Тип осей координатной системы.';
Ch_V:=null;
Instype(SP.G.TAxisType,'AxisType');
-------------------------------------------------------------------------------

-- Note. Тип привязки бизнес-объекта.
tmp:='Тип Note - структурированный комментарий для объекта SP3D. Тип определяет текст и параметры комментария для объекта SP3D. Имя примечания в SP3D соответствует имени параметра, имеющего данный тип. Содержание примечания соответствует полю S параметра, а параметры примечания закодированы в полях N,X,Y. Поле N содержит номер "KeyPoint" - (0,1,2,3..N). Поле X содержит признак "Dimension" - (0 - false, 1- true). Поле Y содержит признак "Purpose" ( -1=null, 1=General, 2=Design, 3=Fabrication, 4=Instalation, 5=Operation and Maintenance, 6=Inspection, 7=Remark, 8=Material of Construction, 9=Design Review, 10=Piping Specification note, 11=Justification, 12=Procurement, 13=Standard note). Преобразование данного типа в строку и обратно производится при помощи следующего формата: !!<KeyPoint>!<Dimension>!<Purpose>!Text или  просто текст <Text> в том случае когда параметры примечания имеют следующие значения: KeyPoint => 0, Dimension => false, Purpose => General';
Ch_V:= 'if (V.N is null) or (V.N < 0) or (V.X not in (0,1)) or (V.Y not in 		(-1,1,2,3,4,5,6,7,8,9,10,11,12,13)) then raise_application_error(-20030,''Wrong Note N=''||to_char(V.N)||'' X=''||to_char(V.X)||'' Y=''||to_char(V.Y));end if;';
S_to_V:='SP.Str_Note_ToVal(S,V);';
V_to_S:='S:=SP.Val_Note_ToStr(V);';
Instype(SP.G.TNote,'Note');
-------------------------------------------------------------------------------

-- NotePurpose. Расшифровка Purpose для типа Note.
tmp:='Расшифровка Purpose для типа Note.';
Ch_V:=null;
Instype(SP.G.TNotePurpose,'NotePurpose');

-------------------------------------------------------------------------------

-- ObjectKind. Типы объектов для Note.
tmp:='Типы объектов для Note.';
Ch_V:=null;
Instype(SP.G.TObjectKind,'OBJECT_KIND');
-------------------------------------------------------------------------------

-- CurveType. Тип линии для рисования кривых MemberSystem.
tmp:='Тип линии для рисования кривых MemberSystem.';
Ch_V:=null;
Instype(SP.G.TCurveType,'CurveType');
-------------------------------------------------------------------------------

-- TFacePosition. Положение опорной плоскости для горизонатьной плиты (Slab).
tmp:='Положение опорной плоскости для горизонатьной плиты (Slab).';
Ch_V:=null;
Instype(SP.G.TFacePosition,'FacePosition');
-------------------------------------------------------------------------------

-- THandrailOrientation. Положение столбиков для перил (Handrail).
tmp:='Положение столбиков для перил (Handrail).';
Ch_V:=null;
Instype(SP.G.THandrailOrientation,'HandrailOrientation');
-------------------------------------------------------------------------------

-- THandrailEndTreatment. Вид окончаний перил (Handrail).
tmp:='Вид окончаний перил (Handrail).';
Ch_V:=null;
Instype(SP.G.THandrailEndTreatment,'HandrailEndTreatment');
-------------------------------------------------------------------------------

-- TPostConnType. Способ крепления столбиков для перил (Handrail).
tmp:='Способ крепления столбиков для перил (Handrail).';
Ch_V:=null;
Instype(SP.G.TPostConnType,'PostConnType');
-------------------------------------------------------------------------------

-- TGraphicPrimitive. Графические примитивы(TGraphicPrimitive).
tmp:='Графические примитивы (GraphicPrimitive).';
Ch_V:=null;
Instype(SP.G.TGraphicPrimitive,'GraphicPrimitive');
-------------------------------------------------------------------------------

-- TSection. Графические примитивы(TSection).
tmp:='Сечения (Section).';
Ch_V:=null;
Instype(SP.G.TSection,'Section');
-------------------------------------------------------------------------------

-- Beep. Звук, издаваемый IMan по команде Beep.
tmp:='Звук, издаваемый IMan по команде Beep.';
Ch_V:=null;
Instype(SP.G.TBeep,'Beep');
-------------------------------------------------------------------------------

-- Flags. Именованный набор флагов.
tmp:='Именованный набор флагов. Поле N содержит набор из 32 флагов(битов). Поле S содержит имя типа в котором заданы константа и имя каждого флага. При преобразовании в строку и обратно используется следующий формат: <имя_набора>:<перечень флагов, входящих в набор через запятую в произвольном порядке>. "none" в перечне флагов означает, что ни один флаг не выбран и поле N равно "0". "all" - устанавлавет поле N равным 2**31-1.';
Ch_V:= 'if (V.N is null) or (V.N >= power(2,31)) or (V.N < 0) or (V.S is null) then raise_application_error(-20030,''Wrong Flags S='' ||nvl(V.S, ''null'')||'' N=''||to_char(V.N,''XXX'')); end if;';
S_to_V:='SP.Str_Flags_ToVal(S,V);';
V_to_S:='S:=SP.Val_Flags_ToStr(V);';
Instype(SP.G.TFlags,'Flags');
-------------------------------------------------------------------------------

-- AspectCode. Тег фильтра просмотра SP3D.
tmp:='Тег фильтра просмотра SP3D.Specifies the aspect associated with the 3D Model Data document(s). An aspect is a geometric area or space related to an object. The aspect represents information about the object, such as its physical shape or the space required around the object. Aspects are associated parameters for an object, representing additional information needed for placement. Aspects can represent clearances for safety or maintenance, additional space required during operation, or simple and detailed representations of the object. ';
Ch_V:=null;
Instype(SP.G.TAspectCode,'AspectCode');
-------------------------------------------------------------------------------

-- CPType. Тип объекта "Контрольная точка".
tmp:='Тип объекта "Контрольная точка".';
Ch_V:=null;
Instype(SP.G.TCPType,'CPType');
-------------------------------------------------------------------------------

-- CPSubType. Подтип объекта "Контрольная точка".
tmp:='Подтип объекта "Контрольная точка".';
Ch_V:=null;
Instype(SP.G.TCPSubType,'CPSubType');
-------------------------------------------------------------------------------

-- CableTrayShape. Форма сечения кабельного лотка.
tmp:='Форма сечения кабельного лотка.';
Ch_V:=null;
Instype(SP.G.TCableTrayShape,'CableTrayShape');
-------------------------------------------------------------------------------

-- OID. Уникальный строковый идентификатор объекта модели.
tmp:='Уникальный строковый идентификатор объекта модели.';		
Ch_V:='if (V.N is not null) or (V.E is not null) or (V.X is not null) or (V.Y is not null) then raise_application_error(-20030,''Wrong OID'');end if;';
--? V.D
S_to_V:=' V.S:=S;';
V_to_S:=' S:=V.S;';
-- Vset:=
Instype(SP.G.TOID,'OID');
-------------------------------------------------------------------------------

-- ID. Уникальный идентификатор объекта в модели IMan.
tmp:='Уникальный идентификатор объекта в модели IMan.';
-- Ch_V:=
Ch_V:= 'if (V.E is not null) or (V.S is not null) or (V.X is not null) or (V.Y is not null) then raise_application_error(-20030,''Wrong ID'');end if;';
-- S_to_V:=
S_to_V:=' V.N:=to_number(S);';
-- V_to_S:=
V_to_S:= 'S:=to_.STR(V.N);';
-- Vset:=
Instype(SP.G.TID,'ID');

-------------------------------------------------------------------------------

-- ComponentInput_1. Первый элемент входной коллекции при построении Tekla компонента.
tmp:='Первый элемент входной коллекции при построении Tekla компонента. Если поле S не нулл, то это ссылка на объект Tekla, иначе это точка. Может быть несколько параметров точек или ссылок в одном уровне входного потока компонента, очерёдность при этом определяется именами параметров компонентов.';
-- Ch_V:=
Ch_V:= 'if not ( ((V.N is not null) and (V.X is not null) and (V.Y is not null) and (V.S is null)) or  ((V.N is null) and (V.X is null) and (V.Y is null) and (V.S is not null)) ) then raise_application_error(-20030,''Wrong ComponentInput'');end if;';
-- S_to_V:=
S_to_V:='if instr(S,'':'',1,2)>0 then  SP.S3XYZ(S,V); else V.S := S;end if;';
-- V_to_S:=
V_to_S:= 'if V.S is not null then S:=V.S; else S:=to_.STR(V.X)||'':''||to_.STR(V.Y)||'':''||to_.STR(V.N); end if;';
-- Vset:=
Instype(SP.G.TComponentInput_1,'ComponentInput_1');

-------------------------------------------------------------------------------

-- ComponentInput_2. Второй элемент входной коллекции при построении Tekla компонента.
tmp:='Второй элемент входной коллекции при построении Tekla компонента. Если поле S не нулл, то это ссылка на объект Tekla, иначе это точка. Может быть несколько параметров точек или ссылок в одном уровне входного потока компонента, очерёдность при этом определяется именами параметров компонентов.';
-- Ch_V:=
Ch_V:= 'if not ( ((V.N is not null) and (V.X is not null) and (V.Y is not null) and (V.S is null)) or  ((V.N is null) and (V.X is null) and (V.Y is null) and (V.S is not null)) ) then raise_application_error(-20030,''Wrong ComponentInput'');end if;';
-- S_to_V:=
S_to_V:='if instr(S,'':'',1,2)>0 then  SP.S3XYZ(S,V); else V.S := S;end if;';
-- V_to_S:=
V_to_S:= 'if V.S is not null then S:=V.S; else S:=to_.STR(V.X)||'':''||to_.STR(V.Y)||'':''||to_.STR(V.N); end if;';
-- Vset:=
Instype(SP.G.TComponentInput_2,'ComponentInput_2');

-------------------------------------------------------------------------------

-- ComponentInput_3. Третий элемент входной коллекции при построении Tekla компонента.
tmp:='Третий элемент входной коллекции при построении Tekla компонента. Если поле S не нулл, то это ссылка на объект Tekla, иначе это точка. Может быть несколько параметров точек или ссылок в одном уровне входного потока компонента, очерёдность при этом определяется именами параметров компонентов.';
-- Ch_V:=
Ch_V:= 'if not ( ((V.N is not null) and (V.X is not null) and (V.Y is not null) and (V.S is null)) or  ((V.N is null) and (V.X is null) and (V.Y is null) and (V.S is not null)) ) then raise_application_error(-20030,''Wrong ComponentInput'');end if;';
-- S_to_V:=
S_to_V:='if instr(S,'':'',1,2)>0 then  SP.S3XYZ(S,V); else V.S := S;end if;';
-- V_to_S:=
V_to_S:= 'if V.S is not null then S:=V.S; else S:=to_.STR(V.X)||'':''||to_.STR(V.Y)||'':''||to_.STR(V.N); end if;';
-- Vset:=
Instype(SP.G.TComponentInput_3,'ComponentInput_3');

-------------------------------------------------------------------------------

-- ComponentInput_4. Четвёртый элемент входной коллекции при построении Tekla компонента.
tmp:='Четвёртый элемент входной коллекции при построении Tekla компонента. Если поле S не нулл, то это ссылка на объект Tekla, иначе это точка. Может быть несколько параметров точек или ссылок в одном уровне входного потока компонента, очерёдность при этом определяется именами параметров компонентов.';
-- Ch_V:=
Ch_V:= 'if not ( ((V.N is not null) and (V.X is not null) and (V.Y is not null) and (V.S is null)) or  ((V.N is null) and (V.X is null) and (V.Y is null) and (V.S is not null)) ) then raise_application_error(-20030,''Wrong ComponentInput'');end if;';
-- S_to_V:=
S_to_V:='if instr(S,'':'',1,2)>0 then  SP.S3XYZ(S,V); else V.S := S;end if;';
-- V_to_S:=
V_to_S:= 'if V.S is not null then S:=V.S; else S:=to_.STR(V.X)||'':''||to_.STR(V.Y)||'':''||to_.STR(V.N); end if;';
-- Vset:=
Instype(SP.G.TComponentInput_4,'ComponentInput_4');

-------------------------------------------------------------------------------

-- ComponentInput_5. Пятый элемент входной коллекции при построении Tekla компонента.
tmp:='Пятый элемент входной коллекции при построении Tekla компонента. Если поле S не нулл, то это ссылка на объект Tekla, иначе это точка. Может быть несколько параметров точек или ссылок в одном уровне входного потока компонента, очерёдность при этом определяется именами параметров компонентов.';
-- Ch_V:=
Ch_V:= 'if not ( ((V.N is not null) and (V.X is not null) and (V.Y is not null) and (V.S is null)) or  ((V.N is null) and (V.X is null) and (V.Y is null) and (V.S is not null)) ) then raise_application_error(-20030,''Wrong ComponentInput'');end if;';
-- S_to_V:=
S_to_V:='if instr(S,'':'',1,2)>0 then  SP.S3XYZ(S,V); else V.S := S;end if;';
-- V_to_S:=
V_to_S:= 'if V.S is not null then S:=V.S; else S:=to_.STR(V.X)||'':''||to_.STR(V.Y)||'':''||to_.STR(V.N); end if;';
-- Vset:=
Instype(SP.G.TComponentInput_5,'ComponentInput_5');

-------------------------------------------------------------------------------

-- PositionDepth. Tekla Position Depth Enum (отределение точки профиля,
-- за которую он сдвигается вперед назад)
tmp:='Tekla Position Depth Enum (отределение точки профиля, за которую он сдвигается вперед назад)';
Ch_V:= null; 
Instype(SP.G.TPositionDepth,'PositionDepth');

-------------------------------------------------------------------------------

-- PositionPlane. Tekla Position Plane Enum (отределение точки профиля,
-- за которую он сдвигается вправо влево)
tmp:='Tekla Position Plane Enum (отределение точки профиля, за которую он сдвигается вправо влево)';
Ch_V:= null; 
Instype(SP.G.TPositionPlane,'PositionPlane');

-------------------------------------------------------------------------------

-- PositionRotation. Tekla Position Rotation Enum (отределение точки профиля,
-- которая берётся за ноль при определении вращения профиля)
tmp:='Tekla Position Rotation Enum (отределение точки профиля, которая берётся за ноль при определении вращения профиля)';
Ch_V:= null; 
Instype(SP.G.TPositionRotation,'PositionRotation');

-------------------------------------------------------------------------------

-- ServerType. Тип сервера модели.
tmp:='Тип сервера модели.';
-- проверка на возможные значения из E_VAL 
Ch_V:=null;
-- S_to_V:= '';
-- V_to_S:=
-- Vset:=
Instype(SP.G.TServerType,'ServerType');

-------------------------------------------------------------------------------

-- Rel. Ссылка на объект модели.
tmp:='Ссылка на объект модели. Поле N содержит идентификатор объекта. Строковое значение есть: "<имя модели>=><Полное имя объекта>"(при преобразовании в строку), если нет разделителя "=>", то используется текущая модель, или "<имя модели>=OID><OID объекта>", если нет имени модели, то используется текущая модель. Ссылка на корневой объект модели: поле N - отрицательное значение идентификатора модели, обозначение "<имя модели>=>/". Набор значений показывает детей (для листа соседей), а также родителя и корень. Если N нулл, то список значений состоит из списка моделей. Значение N нулл допустимо и означает отсутствие ссылки. При создании значения в конструкторе SP.TVALUE, с использованием всех полей, допустимо определить только поле S OIDом. При создании значения поле N получит значение ID объета текущей модели.';
-- проверка на возможные значения
Ch_V:='if V.Y is not null or V.X is not null or V.S is not null then raise_application_error(-20030,''Wrong REL'');end if;if V.N > 0 then select count(*) into V.Y from SP.V_MODEL_OBJECTS where ID = V.N; if (V.Y = 0) and (V.N is not null) then raise_application_error(-20030,''Wrong REL! OBJECT_ID '' ||V.N||'' not found!''); end if; else select count(*) into V.Y from SP.V_MODELS where ID = -V.N; if (V.Y = 0) and (V.N is not null) then raise_application_error(-20030,''Wrong REL! MODEL_ID '' ||-V.N||'' not found!'');end if;end if;';
S_to_V:= 'SP.MO.S2R(S,V);';
V_to_S:='S:=SP.MO.Rel_Name(V.N);';
Vset:= 'select * from table(SP.MO.REL_S)';
Instype(SP.G.TRel,'Rel');

-------------------------------------------------------------------------------

-- SymRel. Символьная ссылка на объект модели.
tmp:='Символьная ссылка на объект модели. Данный тип предназначен для предварительного определения ссылок на объекты, которые возможно будут созданы позже самого объекта. Поле S может содержать: "=OID><OID>", "<имя модели>=OID><OID>", "<Полное имя объекта>", "<имя модели>=><Полное имя объекта>". Отсутствие имени модели указывает на ссылку исключительно в пределах текущей модели. Если объект будет перемещён в другую модель, то предполагается, что ссылка переместиться вместе с объектом. Все остальные поля должны быть нулл. Значение нулл допустимо и означает отсутствие ссылки. Символьную ссылку можно использовать при создании объекта модели, вместо параметра типа REL. Можно так же заменить тип REL на SYMREL при редактировании значения параметра.';
-- проверка на возможные значения
Ch_V:='if V.Y is not null or V.X is not null or V.N is not null then raise_application_error(-20030,''Wrong SymREL'');end if;';
S_to_V:=' V.S:=S;';
V_to_S:=' S:=V.S;';
Vset:= null;
Instype(SP.G.TSymRel,'SymRel');

-------------------------------------------------------------------------------
-- DrawingType. Тип операции черчения Tekla.
tmp:='Тип операции черчения Tekla.';
-- проверка на возможные значения из E_VAL 
Ch_V:=null;
-- S_to_V:= '';
-- V_to_S:=
-- Vset:=
Instype(SP.G.TDrawingType,'DrawingType');

-------------------------------------------------------------------------------
-- Modified. Тип изменения объекта.
tmp:='Тип изменения объекта.';
-- проверка на возможные значения из E_VAL 
Ch_V:=null;
-- S_to_V:= '';
-- V_to_S:=
-- Vset:=
Instype(SP.G.TModified,'Modified');

-------------------------------------------------------------------------------
-- Role. Ссылка на роль базы данных, входящую в перечень ролей IMan.
tmp:='Ссылка на роль базы данных, входящую в перечень ролей IMan.';
-- проверка на возможные значения
Ch_V:='if V.Y is not null or V.X is not null or V.S is not null then raise_application_error(-20030,''Wrong Role'');end if; select count(*) into V.Y from SP.V_PRIM_ROLES where ID = V.N; if (V.Y = 0) and (V.N is not null) then raise_application_error(-20030,''Wrong Role! ROLE_ID '' ||V.N||'' not found!''); end if;';
S_to_V:= 'if S is null or Upper(S)=''NULL'' then V.N:= null; else begin select ID into V.N from SP.V_PRIM_ROLES where upper(NAME)=upper(S); exception when no_data_Found then raise_application_error(-20030,''Wrong Role! Role Name '' ||S||'' not found!''); end;end if;';
V_to_S:='if V.N is not null then begin select NAME into S from SP.V_PRIM_ROLES where ID=V.N; exception when no_data_Found then raise_application_error(-20030,''Wrong Role! Role ID '' ||V.N||'' not found!''); end;else S:= null; end if;';
Vset:='select null ID, null S_VALUE, ''null'' COMMENTS from dual union all SELECT ID, NAME S_VALUE, COMMENTS COMMENTS FROM SP.V_PRIM_ROLES';
Instype(SP.G.TRole,'Role');

-------------------------------------------------------------------------------
-- Single. Ссылка на объект каталога.
tmp:='Ссылка на объект каталога.';
-- проверка на возможные значения
Ch_V:='if V.Y is not null or V.X is not null or V.S is not null then raise_application_error(-20030,''Wrong Single'');end if; select count(*) into V.Y from SP.V_OBJECTS where ID = V.N and Kind_ID = 0; if (V.Y = 0) and (V.N is not null) then raise_application_error(-20030,''Wrong Single! Id '' ||V.N||'' not found!''); end if;';
S_to_V:= 'if S is null or Upper(S)=''NULL'' then V.N:= null; else begin select ID into V.N from SP.V_OBJECTS where upper(FULL_NAME)=upper(S) and Kind_ID = 0; exception when no_data_Found then raise_application_error(-20030,''Wrong Single! Single with full name '' ||S||'' not found!''); end;end if;';
V_to_S:='if V.N is not null then begin select FULL_NAME into S from SP.V_OBJECTS where ID=V.N; exception when no_data_Found then raise_application_error(-20030,''Wrong Single! Single with ID '' ||V.N||'' not found!''); end;else S:= null; end if;';
Vset:='select null ID, null S_VALUE, ''null'' COMMENTS from dual union all SELECT ID, FULL_NAME S_VALUE, COMMENTS COMMENTS FROM SP.V_OBJECTS where Kind_ID = 0 order by S_VALUE asc nulls first';
Instype(SP.G.TSingle,'Single');

-------------------------------------------------------------------------------
-- E3_Type. Типы объектов Pointcad.E3Series.
tmp:='Тип объекта Pointcad.E3Series.';
-- проверка на возможные значения из E_VAL 
Ch_V:=null;

Instype(SP.G.TE3Type,'E3_Type');

--------------------------------------------------------------------------------
tmp:='Перечисление Pointcad.E3Series.Wrapper.Enums.TextAlignments.';
-- проверка на возможные значения из E_VAL
Ch_V:=null;

Instype(SP.G.TTextAlignments,'TextAlignments');
--------------------------------------------------------------------------------
tmp:='Перечисление Pointcad.E3Series.Wrapper.Enums.TextBalloonings.';
-- проверка на возможные значения из E_VAL
Ch_V:=null;

Instype(SP.G.TTextBalloonings,'TextBalloonings');
--------------------------------------------------------------------------------
tmp:='Перечисление Pointcad.E3Series.Wrapper.Enums.TextModes.';
-- проверка на возможные значения из E_VAL
Ch_V:=null;

Instype(SP.G.TTextModes,'TextModes');
--------------------------------------------------------------------------------
tmp:='Перечисление Pointcad.E3Series.Wrapper.Enums.TextStyles.';
-- проверка на возможные значения из E_VAL
Ch_V:=null;

Instype(SP.G.TTextStyles,'TextStyles');

--------------------------------------------------------------------------------
tmp:='Перечисление'
  || 'Pointcad.E3Series.Wrapper.Enums.Pin.PinPhysicalConnectionDirection.';
-- проверка на возможные значения из E_VAL
Ch_V:=null;

Instype(SP.G.TE3PinPhyslConnDirection,
    'Pointcad.E3Series.Wrapper.Enums.Pin.PinPhysicalConnectionDirection');

--------------------------------------------------------------------------------
tmp:='Перечисление Pointcad.E3Series.Wrapper.Enums.Pin.PinTypeId.';
-- проверка на возможные значения из E_VAL
Ch_V:=null;

Instype(SP.G.TE3PinTypeId,'Pointcad.E3Series.Wrapper.Enums.Pin.PinTypeId');

--------------------------------------------------------------------------------
tmp:='Перечисление Pointcad.E3Series.Wrapper.Database.Enums.AttributeOwner2.';
-- проверка на возможные значения из E_VAL
Ch_V:=null;

Instype(SP.G.TE3AttributeOwner2,
          'Pointcad.E3Series.Wrapper.Database.Enums.AttributeOwner2');

--------------------------------------------------------------------------------
tmp:='Перечисление Pln.IMan.e3.Enums.AttributeOwner.';
-- проверка на возможные значения из E_VAL
Ch_V:=null;

Instype(SP.G.TE3AttributeOwner,'Pln.IMan.e3.Enums.AttributeOwner');

--------------------------------------------------------------------------------
tmp:='Перечисление Pointcad.E3Series.Wrapper.Enums.SymbolCodes.';
-- проверка на возможные значения из E_VAL
Ch_V:=null;

Instype(SP.G.TE3SymbolCodes,'Pointcad.E3Series.Wrapper.Enums.SymbolCodes');

-------------------------------------------------------------------------------
-- Polar. Координаты точки (R, Phi)
tmp:='Координаты точки. В поле "X" содержится координата "R", в поле "Y" - "Phi". Представление в виде строки это координаты точки, разделённые символом "." или ",". Все символы, кроме цифр, или повторение разделителя - это ошибка.';
Ch_V:= 'if (V.X <= 0.0) or (V.E is not null) or (V.N is not null) or (V.D is not null)  or (V.S is not null) then raise_application_error(-20030,''Wrong Polar'');end if;';
S_to_V:=' SP.S2XY(S,V);';
V_to_S:=' S:=to_.STR(V.X)||'':''||to_.STR(V.Y);';
-- Vset:=
Instype(SP.G.TPolar,'Polar');
-------------------------------------------------------------------------------

-- Cylindr. Координаты точки (R, Phi, Z)
tmp:='Координаты точки. В поле "X" содержится координата "R", в поле "Y" - "Phi", в поле "N" - "Z". Представление в виде строки это координаты точки, разделённые символом "." или ",". Все символы, кроме цифр, или повторение разделителя - это ошибка.';
Ch_V:= 'if (V.X <= 0.0) or (V.E is not null) or (V.D is not null)  or (V.S is not null) then raise_application_error(-20030,''Wrong Cylindr'');end if;';
S_to_V:=' SP.S3XYZ(S,V);';
V_to_S:=' S:=to_.STR(V.X)||'':''||to_.STR(V.Y)||'':''||to_.STR(V.N);';
-- Vset:=
Instype(SP.G.TCylindr,'Cylindr');

end;
/

-------------------------------------------------------------------------------
-- Типы или значения с идентификаторами более 1000 являются пользовательскими.				 			 			 			 
-- Именованные значения. 
CREATE TABLE SP.ENUM_VAL_S
(
  ID NUMBER,
  IM_ID NUMBER,
  TYPE_ID NUMBER(9) not NULL, 
  E_VAL VARCHAR2(128) not NULL,
	COMMENTS VARCHAR2(4000) not NULL,
  N NUMBER,
  D DATE,
  S VARCHAR2(4000),
	X NUMBER,
  Y NUMBER,
  GROUP_ID NUMBER default 9 not null,
  M_DATE DATE NOT NULL,
  M_USER VARCHAR2(60)NOT NULL,
  CONSTRAINT PK_ENUM_PAR_VAL_S  PRIMARY KEY (ID),
  CONSTRAINT REF_ENUM_PAR_to_TYPE_ID
  FOREIGN KEY (TYPE_ID)
  REFERENCES SP.PAR_TYPES (ID) ON DELETE CASCADE,
  CONSTRAINT REF_ENUM_VAL_S_to_GROUPS_ID
  FOREIGN KEY (GROUP_ID) 
  REFERENCES SP.GROUPS (ID)
);

CREATE INDEX SP.ENUM_VAL_S_TYPE_ID ON SP.ENUM_VAL_S (TYPE_ID);
CREATE INDEX SP.ENUM_VAL_S_GROUP_ID ON SP.ENUM_VAL_S (GROUP_ID);
CREATE UNIQUE INDEX SP.ENUM_VAL_S_E_VAL 
  ON SP.ENUM_VAL_S(TYPE_ID,upper(E_VAL));

COMMENT ON TABLE SP.ENUM_VAL_S 
  IS 'Именованные значение типов (состоящих из наборов значений, причем каждое значение имеет своё имя).';
COMMENT ON COLUMN SP.ENUM_VAL_S.ID       IS 'Идентификатор записи.';
COMMENT ON COLUMN SP.ENUM_VAL_S.IM_ID       IS 'Идентификатор изображения для значения.';
COMMENT ON COLUMN SP.ENUM_VAL_S.TYPE_ID  IS 'Ссылка на тип параметра.';
COMMENT ON COLUMN SP.ENUM_VAL_S.E_VAL 
  IS 'Имя значения, замена имени значения запрещена.';
COMMENT ON COLUMN SP.ENUM_VAL_S.COMMENTS IS 'Комментарии использования.';
COMMENT ON COLUMN SP.ENUM_VAL_S.N        IS 'Значение параметра.';
COMMENT ON COLUMN SP.ENUM_VAL_S.D        IS 'Значение параметра.';
COMMENT ON COLUMN SP.ENUM_VAL_S.S        IS 'Значение параметра.';
COMMENT ON COLUMN SP.ENUM_VAL_S.X        IS 'Значение параметра.';
COMMENT ON COLUMN SP.ENUM_VAL_S.Y        IS 'Значение параметра.';
COMMENT ON COLUMN SP.ENUM_VAL_S.GROUP_ID  IS 'Ссылка на группу, которой принадлежит данное именованное значение.';
COMMENT ON COLUMN SP.ENUM_VAL_S.M_DATE 
  IS 'Дата создания или изменения значения типа.';
COMMENT ON COLUMN SP.ENUM_VAL_S.M_USER 
  IS 'Пользователь создавший или изменивший значение типа.';
			
GRANT SELECT on SP.ENUM_VAL_S to public;

-------------------------------------------------------------------------------
CREATE GLOBAL TEMPORARY TABLE SP.INSERTED_ENUM_VAL_S( 
  NEW_ID NUMBER,
  NEW_IM_ID NUMBER,
  NEW_TYPE_ID NUMBER(9),
  NEW_E_VAL VARCHAR2(128),
	NEW_COMMENTS VARCHAR2(4000),
  NEW_N NUMBER,
  NEW_D DATE,
  NEW_S VARCHAR2(4000),
	NEW_X NUMBER,
  NEW_Y NUMBER,
  NEW_GROUP_ID NUMBER,
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60))
ON COMMIT DELETE ROWS;
COMMENT ON TABLE SP.INSERTED_ENUM_VAL_S
  IS 'Временная таблица, содержащая перечень добавленных записей.';
  
CREATE GLOBAL TEMPORARY TABLE SP.UPDATED_ENUM_VAL_S( 
  NEW_ID NUMBER,
  NEW_IM_ID NUMBER,
  NEW_TYPE_ID NUMBER(9),
  NEW_E_VAL VARCHAR2(128),
	NEW_COMMENTS VARCHAR2(4000),
  NEW_N NUMBER,
  NEW_D DATE,
  NEW_S VARCHAR2(4000),
	NEW_X NUMBER,
  NEW_Y NUMBER,
  NEW_GROUP_ID NUMBER,
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60),
  OLD_ID NUMBER,
  OLD_IM_ID NUMBER,
  OLD_TYPE_ID NUMBER(9),
  OLD_E_VAL VARCHAR2(128),
	OLD_COMMENTS VARCHAR2(4000),
  OLD_N NUMBER,
  OLD_D DATE,
  OLD_S VARCHAR2(4000),
	OLD_X NUMBER,
  OLD_Y NUMBER,
  OLD_GROUP_ID NUMBER,
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60))
ON COMMIT DELETE ROWS;
COMMENT ON TABLE SP.UPDATED_ENUM_VAL_S
  IS 'Временная таблица, содержащая перечень изменённых записей.';
  
CREATE GLOBAL TEMPORARY TABLE SP.DELETED_ENUM_VAL_S( 
  OLD_ID NUMBER,
  OLD_IM_ID NUMBER,
  OLD_TYPE_ID NUMBER(9),
  OLD_E_VAL VARCHAR2(128),
	OLD_COMMENTS VARCHAR2(4000),
  OLD_N NUMBER,
  OLD_D DATE,
  OLD_S VARCHAR2(4000),
	OLD_X NUMBER,
  OLD_Y NUMBER,
  OLD_GROUP_ID NUMBER,
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60))
ON COMMIT DELETE ROWS;
COMMENT ON TABLE SP.DELETED_ENUM_VAL_S
  IS 'Временная таблица, содержащая перечень удалённых записей.';
  
-- end of file
