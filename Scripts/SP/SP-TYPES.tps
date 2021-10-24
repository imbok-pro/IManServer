-- TYPES
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 17.08.2010 
-- update 06.09.2010 14.09.2010 16.09.2010 08.10.2010 13.10.2010 20.10.2010
--        28.10.2010 19.11.2010 24.11.2010 10.12.2010 17.12.2010 09.02.2011
--		    18.03.2011 11.05.2011 17.10.2011 10.11.2011 27.01.2012 11.04.2012 
--        04.04.2013 09.04.2013 04.06.2013 17.06.2013 22.08.2013 16.10.2013
--        22.06.2014 27.10.2014 
-- update 09.09.2014 by Evgeniy Piatakov
-- update by Nikolay Krasilnikov 27.10.2014 22.03.2015 25.05.2015 08.07.2015
--        23.12.2015 11.02.2016 29.02.2016 27.10.2016
-------------------------------------------------------------------------------
-- Обёртки в блоки нужны для совместимости с SQL Developer(только для массивов). 
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TSTRINGS 
/* Длинная строка.*/
/* SP-TYPES.tps*/
IS TABLE OF VARCHAR2(4000)
                   ');
END;
/
GRANT EXECUTE ON SP.TSTRINGS TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TSHORTSTRINGS 
/* Короткая строка.*/
/* SP-TYPES.tps*/
IS TABLE OF VARCHAR2(128) 
                   ');
END;
/
GRANT EXECUTE ON SP.TSHORTSTRINGS TO PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE SP.TS_VALUE_COMMENTS 
/* SP-TYPES.tps*/
/* Значение и комментарий к нему. 
Данный тип используют потоковые фунции, в запросах предоставляющих
возможные наборы значений для конкретного типа TValue.*/
AS OBJECT
(
/* Идентификатор значения.*/
ID NUMBER,
/* Значение.*/
S_VALUE VARCHAR2(4000),
/* Комментарий к значению.*/
COMMENTS VARCHAR2(4000)
);
/
GRANT EXECUTE ON SP.TS_VALUE_COMMENTS TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TS_VALUES_COMMENTS 
/*Набор значений с комментариями.
Данный тип возвращают потоковые фунции, в запросах предоставляющих
возможные наборы значений для конкретного типа TValue.*/
/* SP-TYPES.tps*/
IS TABLE OF SP.TS_VALUE_COMMENTS 
                    ');
END;
/
GRANT EXECUTE ON SP.TS_VALUES_COMMENTS TO PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE SP.TROLE_REC 
/* Запись, содержащая идентификатор, имя и описание роли.
Данный тип используют потоковые фунции.
   SP-TYPES.tps*/
AS OBJECT
(
/* Идентификатор роли.
Формат записи: идентификатор роли||'L'||уровень||D||кратность */             
NODE VARCHAR2(128),
/* Роль, получившая грант от этой роли. */
PNODE VARCHAR2(128),
/* Имя Роли.*/
NAME  VARCHAR2(128),
/* Признак листа.*/
LEAF NUMBER(1)
);
/
GRANT EXECUTE ON SP.TROLE_REC TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TROLE_RECORDS 
/* Набор из записей, содержащих идентификатор, имя и описание роли.
Данный тип возвращают потоковые фунции.
   SP-TYPES.tps*/
IS TABLE OF SP.TROLE_REC 
                    ');
END;
/
GRANT EXECUTE ON SP.TROLE_RECORDS TO PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE SP.TERROR_REC 
/* Запись, содержащая сведения об ошибках или предупреждениях при компиляции 
объектов базы.
   SP-TYPES.tps*/
AS OBJECT
(
/* Владелец объекта.*/
OWNER VARCHAR2(30),
/* Имя объекта.*/
NAME VARCHAR2(30),
/* Тип объекта.*/
TYPE VARCHAR2(12),
/* Указание на строку кода, содержащую ошибку.*/
LINE NUMBER,
/* Указатель на позицию в строке кода.*/
POSITION NUMBER,
/* Сообщение об ошибке.*/
TEXT VARCHAR2(4000),
/* Признак, является ли данная запись сообщением об ошибке или 
предупреждением. */
ATTRIBUTE VARCHAR2(9)
);
/
GRANT EXECUTE ON SP.TERROR_REC TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TERROR_RECORDS 
/*  Набо из записей, содержащих сообщения об ошибках или предупреждения
компилятора.
    SP-TYPES.tps*/
IS TABLE OF SP.TERROR_REC 
                    ');
END;
/
GRANT EXECUTE ON SP.TERROR_RECORDS TO PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE SP.TIMAN_PAR_REC 
/*  Данный тип используется при передаче значения параметров объекта модели или макрокоманды. При работе с пакетом SP.MACRO используется для передачи опорного объекта. Структура типа совпадает со структурой временной таблицы SP.WORK_OBJECTS_PAR_S  SP-TYPES.tps*/
AS OBJECT
(
/* Имя параметра. */
NAME VARCHAR2(255),
/* Тип параметра.*/
T NUMBER(9),
/* Имя значения для перечисляемых типов.*/
E VARCHAR2(128),
/* Поле значения.*/
N NUMBER,
/* Поле значения.*/
D DATE,
/* Поле значения.*/
S VARCHAR2(4000),
/* Поле значения.*/
X NUMBER,
/* Поле значения.*/
Y NUMBER,
/* Данное поле используется при организации диалога с пользователем в команде Get_User_Input. Если R_ONLY = 0, то значение параметра можно читать и записывать. Если R_ONLY = 1, то значение параметра можно только читать. Если R_ONLY = -1, то значение параметра должно быть обязательно обновлено пользователем. */
R_ONLY NUMBER(1),
/* Данное поле используется при передачи нескольких объектов в одном запросе. Причём значение данного поля может быть как просто индексом массива, так и уникальным идентификатором объекта.*/
OBJECT_INDEX NUMBER,
/* Конструктор пустой записи.*/
CONSTRUCTOR FUNCTION TIMAN_PAR_REC 
RETURN SELF AS RESULT,
/* Конструктор создаёт запись по имени параметра и его значению.*/
CONSTRUCTOR FUNCTION TIMAN_PAR_REC(pName IN VARCHAR2,pVal IN SP.TVALUE, oIndex IN NUMBER DEFAULT null)
RETURN SELF AS RESULT,
/* Процедура присваивает записи имя параметра и его значению.*/
MEMBER PROCEDURE Assign(self IN OUT SP.TIMAN_PAR_REC,
                        pName IN VARCHAR2,
                        pVal IN SP.TVALUE,
                        oIndex IN NUMBER DEFAULT null)
);
/
GRANT EXECUTE ON SP.TIMAN_PAR_REC TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TIMAN_PARS 
/* Набор из записей, содержащих имя и значение параметра.
Данный тип возвращают потоковые фунции.
SP-TYPES.tps*/
IS TABLE OF SP.TIMAN_PAR_REC
                    ');
END;
/
GRANT EXECUTE ON SP.TIMAN_PARS TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TNUMBERS 
/* Таблица из числовых полей.
    SP-TYPES.tps*/
IS TABLE OF NUMBER
                    ');
END;
/
GRANT EXECUTE ON SP.TNUMBERS TO PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE SP.TFORM_PARAM 
/*  Запись содержит сведения, необходимые для сохранения параметров приложений,
для каждого пользователя.
    SP-TYPES.tps*/
AS OBJECT
(
/* Имя приложения или его части(формы).*/
OBJ_NAME VARCHAR2(4000),
/* Имя параметра.*/
PROP_NAME VARCHAR2(128),
/* Значение параметра в виде строки.*/
PROP_VALUE VARCHAR2(4000),
/* Порядок обработки параметров.*/
ORD NUMBER(9)
);
/
GRANT EXECUTE ON SP.TFORM_PARAM TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TFORM_PARAMS 
/*  Таблица свойств параметров.
    SP-TYPES.tps*/
IS TABLE OF SP.TFORM_PARAM
                    ');
END;
/
GRANT EXECUTE ON SP.TFORM_PARAMS TO PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE SP.TSOURCE_LINE 
/* Запись, представляющая строку кода программы.
   SP-TYPES.tps*/
AS OBJECT
(
/* Номер строки.*/
LINE NUMBER(9),
/* Содержание строки.*/
TEXT VARCHAR2(4000)
);
/
GRANT EXECUTE ON SP.TSOURCE_LINE TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TSOURCE 
/* Таблица, представляющая листинг.
    SP-TYPES.tps*/
IS TABLE OF SP.TSOURCE_LINE
                    ');
END;
/
GRANT EXECUTE ON SP.TSOURCE TO PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE
TYPE SP.TREL
/* Запись, представляющая связь понятий.
   SP-TYPES.tps*/
as OBJECT
(
GR NUMBER,
INC NUMBER,
R_TYPE NUMBER,
ID NUMBER
);
/
GRANT EXECUTE ON SP.TREL to PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TRELS
/* Таблица связей.
   SP-TYPES.tps*/
IS TABLE OF SP.TREL;
                    ');
END;
/
GRANT EXECUTE ON SP.TRELS to PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE
TYPE SP.TGRAPH2TREE_NODE as OBJECT
/* Запись, представляющая связь понятий, после преобразования в дерево.
   SP-TYPES.tps*/
(
/*Идентификатор сущности.
Формат записи: идентификатор узла||'L'||уровень||D||кратность */             
NODE VARCHAR2(128),
/*Идентификатор родителя*/             
PNODE VARCHAR2(128),
/* Название сущности*/
TEXT VARCHAR2(128),
/* Признак листа дерева.*/
LEAF NUMBER(1),
/* Порядковый номер группы в ветке.*/
LINE NUMBER(9)
);
/
GRANT EXECUTE ON SP.TGRAPH2TREE_NODE to PUBLIC;
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TGRAPH2TREE_NODES
/* Таблица связей, преобразованная в дерево.
   SP-TYPES.tps*/
IS TABLE OF SP.TGRAPH2TREE_NODE;
                    ');
END;
/
GRANT EXECUTE ON SP.TGRAPH2TREE_NODES to PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE
TYPE SP.TMODEL_OBJECT_RECORD as OBJECT
/* Запись, представляющая объект модели, используется при формировании
   дерева объектов относительно текущего корня.
   SP-TYPES.tps*/
(
  ID NUMBER,
  MODEL_ID NUMBER,
  MOD_OBJ_NAME VARCHAR2(128),
  OID VARCHAR2(40),
  OBJ_ID NUMBER,
  PARENT_MOD_OBJ_ID NUMBER,
	COMPOSIT_ID NUMBER,
	START_COMPOSIT_ID NUMBER,
  MODIFIED NUMBER(1),
  M_DATE DATE,
  M_USER VARCHAR2(60),
  OBJ_LEVEL NUMBER,
  FULL_NAME VARCHAR2(4000)
);
/
GRANT EXECUTE ON SP.TMODEL_OBJECT_RECORD to PUBLIC;
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE SP.TMODEL_OBJECTS
/* Таблица, представляющая объекты модели.
   SP-TYPES.tps*/
IS TABLE OF SP.TMODEL_OBJECT_RECORD;
                    ');
END;
/
GRANT EXECUTE ON SP.TMODEL_OBJECTS to PUBLIC;


-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
create or replace TYPE SP.TPKFNote as Object(
        /* Тип - замечание ГИПа на первичную документацию  
        SP-TYPES.tps  */
        /* идентификатор документа в терминах ПКФ */
    Teg varchar2(128),
        /* суть замечания*/
    TegValue varchar2(4000),
        /* источник замечания*/
    fullfileName varchar2(4000),
        /* Входящий номер ПКФ для анализируемой документации */
    pkfInputNum varchar2(32),
    author varchar2(256) ,
    crDateTime date,
        /* номер загрузки  */
    LoadNum int,
     /* порядковый номер замечания в блоке замечаний для одного тега */
    Num int,
     /* сквоозной уник номер замечания, генерируется полседовательностью */
    SeqNum integer
);
                    ');
END;
/
GRANT EXECUTE ON SP.TPKFNote to PUBLIC;

BEGIN
    EXECUTE IMMEDIATE('
        /* Тип - таблица замечаний ГИПов, для pipeline функции   
        SP-TYPES.tps  */ 
    create or replace type SP.TPKFNoteTable as table of SP.TPKFNote;
    ');
END;
/
GRANT EXECUTE ON SP.TPKFNoteTable to PUBLIC;

-- end of file
