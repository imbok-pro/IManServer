-- SP Catalog Objects
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 05.08.2010  
-- update 22.09.2010 12.10.2010 15.10.2010 24.11.2010 06.12.2010 13.05.2011
--        23.10.2011 10.11.2011 21.12.2011 02.02.2012 15.03.2012 11.04.2012
--        03.04.2013 10.06.2013 04.10.2013 31.10.2013 12.06.2014 13.06.2014
--        24.06.2014 02.07.2014 26.08.2014 30.08.2014 21.11.2014 06.01.2015
--        05.07.2015 08.07.2015 20.09.2016 22.11.2016 22.03.2017 12.04.2017
--        13.04.2017 10.05.2017 14.02.2018 23.07.2021
--*****************************************************************************


-- Таблица объектов и в том числе процедур.
-------------------------------------------------------------------------------
CREATE TABLE SP.OBJECTS
(
  ID NUMBER,
  OID VARCHAR2(40),
  IM_ID NUMBER,
  NAME VARCHAR2(128) NOT NULL,
  COMMENTS VARCHAR2(4000) NOT NULL,
  OBJECT_KIND NUMBER(1) NOT NULL,
	GROUP_ID NUMBER default 2 not null,
	USING_ROLE NUMBER,
	EDIT_ROLE NUMBER DEFAULT 1,
  MODIFIED DATE NOT NULL,
  M_USER VARCHAR2(60)NOT NULL,
  CONSTRAINT PK_OBJECTS PRIMARY KEY (ID),
  CONSTRAINT REF_OBJECTS_to_EDIT_ROLES 
  FOREIGN KEY (EDIT_ROLE)
  REFERENCES SP.SP_ROLES (ID) ON DELETE SET NULL,
  CONSTRAINT REF_OBJECTS_to_USING_ROLES 
  FOREIGN KEY (USING_ROLE)
  REFERENCES SP.SP_ROLES (ID) ON DELETE SET NULL,
  CONSTRAINT REF_OBJECTS_TO_GROUPS
  FOREIGN KEY (GROUP_ID)
  REFERENCES SP.GROUPS (ID)
);

CREATE UNIQUE INDEX SP.OBJECTS_NAME ON SP.ObjectS (UPPER(NAME), GROUP_ID);
CREATE UNIQUE INDEX SP.OBJECTS_UOID ON SP.ObjectS (nvl(OID, ID));
CREATE UNIQUE INDEX SP.OBJECTS_OID ON SP.ObjectS (OID);
CREATE INDEX SP.OBJECTS_NAME_G ON SP.ObjectS (NAME, GROUP_ID);
CREATE INDEX SP.OBJECTS_NAM ON SP.ObjectS (NAME);
CREATE INDEX SP.OBJECTS_GROUP_ID ON SP.ObjectS (GROUP_ID);
CREATE INDEX SP.OBJECTS_EDIT_ROLE ON SP.ObjectS (EDIT_ROLE);
CREATE INDEX SP.OBJECTS_USING_ROLE ON SP.ObjectS (USING_ROLE);

GRANT SELECT ON SP.OBJECTS TO PUBLIC;   

COMMENT ON TABLE SP.OBJECTS 
  IS 'Объекты. Прототипы объектов модели, примитивные операции моделей, а также типовые процедуры.(SP-CATALOG.sql)';

COMMENT ON COLUMN SP.OBJECTS.ID        IS 'Идентификатор объекта.';
COMMENT ON COLUMN SP.OBJECTS.OID 
  IS 'Глобальный идентификатор объекта постоянен между каталогами.';
COMMENT ON COLUMN SP.OBJECTS.IM_ID     IS 'Идентификатор изображения.';
COMMENT ON COLUMN SP.OBJECTS.NAME      IS 'Имя объекта. Имя должно быть уникально в пределах своего пространства имён. Имя объекта не должно содержать ".", поскольку последний символ "." в полном имени объекта, является разделителем между пространством имён и именем объекта.';
COMMENT ON COLUMN SP.OBJECTS.COMMENTS  IS 'Описание объекта.';
COMMENT ON COLUMN SP.OBJECTS.OBJECT_KIND
  IS 'Вид объекта. (0 - одиночный объект каталога, 1 - композитный объект каталога, 2 - макропроцедура, 3 - одиночная операция(выполняемая сервером модели))'; 
COMMENT ON COLUMN SP.OBJECTS.GROUP_ID  IS 'Пространство имён объекта.(Ссылка на группу.) Может содержать любые символы в том числе и ".".';
COMMENT ON COLUMN SP.OBJECTS.USING_ROLE 
  IS 'Роль, которую должен иметь пользователь, чтобы иcпользовать объект в элементах своих объектов. Пользователь, имеющий SP_ADMIN_ROLE, может использовать любой объект. Если поле нулл, то объект публичен.';
COMMENT ON COLUMN SP.OBJECTS.EDIT_ROLE 
  IS 'Роль, которую должен иметь пользователь дополнительно к SP_DEVELOPING_ROLE, чтобы изменять объект, а также добавлять удалять или изменять его параметры. Пользователь, имеющий SP_ADMIN_ROLE, может изменять любой объект. Если поле нулл, то только администратор может изменять объект.';
COMMENT ON COLUMN SP.OBJECTS.MODIFIED 
  IS 'Дата изменения объекта. Поле заполняется вызовом процедуры SetObjModified, а не триггером при операциях DML.';
COMMENT ON COLUMN SP.OBJECTS.M_USER 
  IS 'Пользователь изменивший объект. Поле заполняется вызовом процедуры SetObjModified, а не триггером при операциях DML.';


-- Добавляем объект "#Composit Origin". Все элементы композитных объектов 
-- создаются как дочерние элементы данного объекта.
INSERT INTO SP.OBJECTS (ID, OID, NAME, COMMENTS, OBJECT_KIND, MODIFIED, M_USER,
                        GROUP_ID)
  VALUES(0, 0,
  '#Composit Origin', 
  'Все элементы композитных объектов создаются как дочерние элементы данного объекта.',
   0,
   TO_DATE('01-01-2011','dd-mm-yyyy'),
   'SP',
   6);
-- Добавляем универсальный объект для построения дерева.  
INSERT INTO SP.OBJECTS (ID, OID, NAME, COMMENTS, OBJECT_KIND, MODIFIED, M_USER,
                        GROUP_ID)
  VALUES(1, 1,
  '#Native Object',
  'Объект построенный в сторонней модели не средствами IMan. Все объекты, не имеющие прообраза в каталоге и имеющие возможность содержать дочерние объекты имеют этот объект как свой каталожный прототип.',
  0,
  TO_DATE('01-01-2011','dd-mm-yyyy'),
  'SP',
  6);
  
-- Добавляем универсальный корневой объект модели.   
INSERT INTO SP.OBJECTS (ID, OID, NAME, COMMENTS, OBJECT_KIND, MODIFIED, M_USER,
                        GROUP_ID)
  VALUES(2, 2,
  '#HierarchiesRoot',
  'Корневой объект иерархии модели, всегда присутствует виртуально в модели.',
  0,
  TO_DATE('01-01-2011','dd-mm-yyyy'),
  'SP',
  6);
-- Объект прообраз объекта-владельца виртуальных параметров.
INSERT INTO SP.OBJECTS (ID, OID, NAME, COMMENTS, OBJECT_KIND, MODIFIED, M_USER,
                        GROUP_ID)
  VALUES(3, 3,
  '#VirtualObject',
  'Объект - прообраз объекта модели, который владеет виртуальными параметрами (NAME, PARENT ... ).',
  0,
  TO_DATE('01-06-2015','dd-mm-yyyy'),
  'SP',
  6);
-- Добавляем универсальный объект для построения листа.  
INSERT INTO SP.OBJECTS (ID, OID, NAME, COMMENTS, OBJECT_KIND, MODIFIED, M_USER,
                        GROUP_ID)
  VALUES(4, 4,
  '#Native Leaf',
  'Объект построенный в сторонней модели не средствами IMan. Все объекты, не имеющие прообраза в каталоге и являющиеся листьями в дереве модели имеют этот объект как свой каталожный прототип.',
  0,
  TO_DATE('10-05-2017','dd-mm-yyyy'),
  'SP',
  6);

CREATE GLOBAL TEMPORARY TABLE SP.DELETED_OBJECTS
(
  OLD_ID NUMBER,
  OLD_OID VARCHAR2(40),
  OLD_IM_ID NUMBER,
  OLD_NAME VARCHAR2(128),
  OLD_COMMENTS VARCHAR2(4000),
  OLD_OBJECT_KIND NUMBER(1),
  OLD_GROUP_ID NUMBER,
	OLD_USING_ROLE NUMBER,
	OLD_EDIT_ROLE NUMBER,
  OLD_MODIFIED DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.DELETED_OBJECTS
  IS 'Временная таблица, содержащая перечень удалённых записей.(SP-CATALOG.sql)';

-------------------------------------------------------------------------------	
CREATE OR REPLACE PROCEDURE SP.SetObjModified(ObjID IN NUMBER)
-- Установка текущей даты в качестве даты обновления для объекта каталога.
-- (SP-CATALOG.sql)
AS
BEGIN
  UPDATE SP.OBJECTS 
    SET MODIFIED = SYSDATE, M_USER = TG.UserName 
    WHERE ID=ObjID;
EXCEPTION  
	WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20033,
		  'SP.SetObjModified, Объект с ID: '||TO_CHAR(ObjID)||' не найден!');
END;
/

-------------------------------------------------------------------------------	
CREATE OR REPLACE FUNCTION SP.to_str_Obj_KIND(Kind IN NUMBER)
RETURN VARCHAR2
-- преобразование в строковое значение вида объекта
-- (SP-CATALOG.sql)
AS
BEGIN
  IF Kind IS NULL THEN RETURN NULL; END IF;
  CASE Kind
	  WHEN NULL  THEN RETURN NULL;
	  WHEN 0  THEN RETURN 'SINGLE';
		WHEN 1  THEN RETURN 'COMPOSIT';
		WHEN 2  THEN RETURN 'MACRO';
		WHEN 3  THEN RETURN 'OPERATION';
  ELSE
	  RAISE_APPLICATION_ERROR(-20033,
		  'SP.to_str_Obj_KIND, Неверное значение KIND: '||TO_CHAR(Kind)||'!');
	END CASE;
END;
/

GRANT EXECUTE ON SP.to_str_Obj_KIND TO PUBLIC;

-------------------------------------------------------------------------------	
CREATE OR REPLACE FUNCTION SP.to_Obj_KIND(KIND IN VARCHAR2)
RETURN NUMBER
-- преобразование строкового значения вида объекта в значение
-- по умолчанию устанавливаем "SINGLE"
-- (SP-CATALOG.sql)
AS
BEGIN
  IF KIND IS NULL THEN RETURN 0; END IF;
  CASE UPPER(KIND)
	  WHEN 'SINGLE'  THEN RETURN 0;
		WHEN 'COMPOSIT'  THEN RETURN 1;
	  WHEN 'MACRO'  THEN RETURN 2;
		WHEN 'OPERATION'  THEN RETURN 3;
  ELSE
	  RAISE_APPLICATION_ERROR(-20033,
		  'SP.to_Obj_KIND, Неверное значение KIND: '||KIND||'!');
	END CASE;
END;
/

GRANT EXECUTE ON SP.to_Obj_KIND TO PUBLIC;

-------------------------------------------------------------------------------	
CREATE OR REPLACE FUNCTION SP.OBJ_KIND_VAL_S
RETURN REPLICATION.TIDENTIFIERS pipelined
-- перечень возможных значений вида объекта
-- (SP-CATALOG.sql)
AS
BEGIN
  pipe ROW('SINGLE');
	pipe ROW('COMPOSIT');
	pipe ROW('MACRO');
  pipe ROW('OPERATION'); 
  RETURN;
END;
/

GRANT EXECUTE ON SP.OBJ_KIND_VAL_S TO PUBLIC;



-------------------------------------------------------------------------------	
-- Параметры объектов
CREATE TABLE SP.OBJECT_PAR_S
(
  ID NUMBER,
  NAME VARCHAR2(128) NOT NULL,
  COMMENTS VARCHAR2(4000),
  TYPE_ID NUMBER(9) NOT NULL,
	E_VAL VARCHAR2(128),
  N NUMBER,
  D DATE,
  S VARCHAR2(4000),
	X NUMBER,
	Y NUMBER,
  R_ONLY NUMBER(1) DEFAULT 0 NOT NULL,
  OBJ_ID NUMBER NOT NULL,
  GROUP_ID NUMBER DEFAULT 9 NOT NULL,
  M_DATE DATE NOT NULL,
  M_USER VARCHAR2(60) NOT NULL,
  CONSTRAINT PK_OBJECT_PAR_S PRIMARY KEY (ID),
  CONSTRAINT CH_OBJECT_PAR_S
    CHECK(TYPE_ID != 100),
  CONSTRAINT REF_OBJECT_PAR_S_to_TYPES_ID
  FOREIGN KEY (TYPE_ID) 
  REFERENCES SP.PAR_TYPES (ID) ON DELETE CASCADE,
  CONSTRAINT REF_OBJECT_PAR_S_to_GROUPS_ID
  FOREIGN KEY (GROUP_ID) 
  REFERENCES SP.GROUPS (ID),
  CONSTRAINT REF_OBJECT_PAR_S_to_OBJECTS
  FOREIGN KEY (OBJ_ID)
  REFERENCES SP.OBJECTS (ID) ON DELETE CASCADE
);

CREATE INDEX SP.OBJECT_PAR_S_GROUP_ID ON SP.OBJECT_PAR_S (GROUP_ID);
CREATE INDEX SP.OBJECT_TYPE_ID ON SP.OBJECT_PAR_S (TYPE_ID);
CREATE INDEX SP.OBJECT_PAR_OBJ ON SP.OBJECT_PAR_S (OBJ_ID);
CREATE UNIQUE INDEX SP.OBJECT_PAR_S_NAME 
  ON SP.OBJECT_PAR_S(OBJ_ID,UPPER(NAME));
CREATE INDEX SP.OBJECT_PAR_S_NAM ON SP.OBJECT_PAR_S(OBJ_ID,NAME);
CREATE INDEX SP.OBJECT_PAR_S_UNAM ON SP.OBJECT_PAR_S(NAME);
CREATE INDEX SP.OBJECT_PAR_E_VAL ON SP.OBJECT_PAR_S (E_VAL);

  
-- может быть только один параметр с типом ....
--CREATE UNIQUE INDEX SP.Object_PAR_S_EPrivate 
--  on SP.Object_PAR_S(case when TYPE_ID=19 then Object else null end);
GRANT SELECT ON SP.OBJECT_PAR_S TO PUBLIC;   

COMMENT ON TABLE SP.OBJECT_PAR_S 
  IS 'Перечень параметров  объектов. (SP-CATALOG.sql)';
COMMENT ON COLUMN SP.OBJECT_PAR_S.ID        
  IS 'Идентификатор параметра. Если идентификатор параметра отрицательный, то это псевдопараметр(поле заиси из таблицы объектов). Такой псевдопараметр существует у всех объектов. Все псевдопараметры хранят историю изменений.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.NAME      IS 'Имя параметра.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.COMMENTS  IS 'Описание параметра';
COMMENT ON COLUMN SP.OBJECT_PAR_S.TYPE_ID    IS 'Тип параметра.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.E_VAL 
  IS 'Значение перечисляемого типа.';	 
COMMENT ON COLUMN SP.OBJECT_PAR_S.N         IS 'Значение по умолчанию.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.D         IS 'Значение по умолчанию.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.S         IS 'Значение по умолчанию.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.X         IS 'Значение по умолчанию.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.Y         IS 'Значение по умолчанию.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.R_ONLY 
  IS 'Если значение равно 1, то этот параметр только для чтения. Если значение равно -1, то этот параметр обязательно должен быть присвоен перед вызовом  команды. Значение по умолчанию из каталога можно использовать только для справки. Eсли значение -2, то история изменения значений параметра не записывается.История так же не записывается для параметров только для чтения.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.OBJ_ID     IS 'Ссылка на объект.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.GROUP_ID   IS 'Ссылка на группу, которой принадлежит параметр.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.M_DATE 
  IS 'Дата изменения или добавления параметра объекта.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.M_USER 
  IS 'Пользователь изменивший или добавивший параметр объекта.';


--
-- Процедуры преобразования значения поля "R_Only" в строку и обратно
-- в SP.GLOBALS.	
-----				 
-- Добавляем параметры встроенных объектов.
--
-- Добавляем параметры объекта "Composit Origin".
BEGIN
--
-- Имя объекта - обязательный параметр типа строка.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (0, 'NAME',
         'Имя Композитного объекта - обязательный параметр типа строка.',
         SP.G.TStr4000, -1, 0, 
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- Имя родителя - обязательный параметр типа строка.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID,	R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (1, 'PARENT',
         'Имя родителя - обязательный параметр типа строка.',
         SP.G.TStr4000, -1, 0,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- Тип объекта - "GenericSystem" - только для чтения.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID,	E_VAL, N, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (2, 'SP3DTYPE',
         'Тип объекта - "GenericSystem" - только для чтения',                        
				 SP.G.TIType, 'GenericSystem', 1, 1, 0,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- Вид объекта - "Composit" - только для чтения.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID, N, S, X, Y, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (3, 'OBJECT_KIND',
         'Вид объекта - "Composit"  - только для чтения',                        
				 SP.G.TNote, 0, 'COMPOSIT', 0, 1, 1, 0,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
         
-- Объект есть система - только для чтения.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID, E_VAL, N, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (4, 'IS_SYSTEM',
         'Объект есть система  - только для чтения',                        
				 SP.G.TBoolean, 'true', 1, 1, 0,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
END;
/
--
-- Добавляем параметры объекта "Native Object".
--
BEGIN
-- Имя объекта - обязательный параметр типа строка.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (5, 'NAME',
         'Имя объекта - обязательный параметр типа строка.',
         SP.G.TStr4000, -1, 1, 
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- Имя родителя - обязательный параметр типа строка.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID,  R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (6, 'PARENT',
         'Имя родителя - обязательный параметр типа строка.',
         SP.G.TStr4000, -1, 1,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- Вид объекта - "Single" - только для чтения.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID, N, S, X, Y, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (8, 'OBJECT_KIND',
         'Вид объекта - "Single"  - только для чтения',                        
         SP.G.TNote, 0, 'SINGLE', 0, 1, 1, 1,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');

-- Объект есть система - только для чтения.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID, E_VAL, N, R_ONLY, OBJ_ID,
         M_DATE, M_USER)
  VALUES
        (9, 'IS_SYSTEM',
         'Объект есть система  - только для чтения',                        
         SP.G.TBoolean, 'true', 1, 1, 1,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
--
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID,  E_VAL, N, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (20, 'SP3DTYPE',
         'Тип объекта неизвестен.',                        
         SP.G.TIType, 'notDef', 0, 1, 1,
         to_date('14-02-2018','dd-mm-yyyy'), 'SP');
END;
/ 
--        
-- Добавляем параметры объекта "HierarchiesRoot".
--
BEGIN
-- Имя объекта - только для чтения.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID, S, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (10, 'NAME',
         'Имя Корневогоо объекта - всегда "/".',
         SP.G.TStr4000, '/', 1, 2, 
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- Имя родителя -  только для чтения.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID,  R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (11, 'PARENT',
         'Имя родителя - всегда нулл.',
         SP.G.TStr4000, 1, 2,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
         
-- Тип объекта - "HierarchiesRoot" - только для чтения.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID,  E_VAL, N, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (12, 'SP3DTYPE',
         'Тип объекта - "HierarchiesRoot" - только для чтения',                        
         SP.G.TIType, 'HierarchiesRoot', 42, 1, 2,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- OID -  только для чтения.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID,  R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (13, 'OID',
         'Уникальный идентификатор корневого объекта, присвоенный сервером модели.',
         SP.G.TStr4000, 1, 2,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- Реальное имя корневого объкта -  только для чтения.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID,  R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (14, 'HIERARCHY_ROOT_NAME',
         'Реальное имя корневого объекта, присвоенное сервером модели. Для локальных моделей всегда нулл.',
         SP.G.TStr4000, 1, 2,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
END;    
/ 
--
-- Добавляем параметры объекта "Native Leaf".
--
BEGIN
-- Имя объекта - обязательный параметр типа строка.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (15, 'NAME',
         'Имя объекта - обязательный параметр типа строка.',
         SP.G.TStr4000, -1, 4, 
         to_date('10-05-2017','dd-mm-yyyy'), 'SP');
-- Имя родителя - обязательный параметр типа строка.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID,  R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (16, 'PARENT',
         'Имя родителя - обязательный параметр типа строка.',
         SP.G.TStr4000, -1, 4,
         to_date('10-05-2017','dd-mm-yyyy'), 'SP');
-- Вид объекта - "Single" - только для чтения.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID, N, S, X, Y, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (18, 'OBJECT_KIND',
         'Вид объекта - "Single"  - только для чтения',                        
         SP.G.TNote, 0, 'SINGLE', 0, 1, 1, 4,
         to_date('10-05-2017','dd-mm-yyyy'), 'SP');

-- Объект не система - только для чтения.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID, E_VAL, N, R_ONLY, OBJ_ID,
         M_DATE, M_USER)
  VALUES
        (19, 'IS_SYSTEM',
         'Объект есть система  - только для чтения',                        
         SP.G.TBoolean, 'false', 0, 1, 4,
         to_date('10-05-2017','dd-mm-yyyy'), 'SP');
--
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID,  E_VAL, N, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (21, 'SP3DTYPE',
         'Тип объекта неизвестен.',                        
         SP.G.TIType, 'notDef', 0, 1, 4,
         to_date('14-02-2018','dd-mm-yyyy'), 'SP');
END;
/         
--    
-- Добавляем параметры объекта "VirtualObject".
--
BEGIN
-- Имя объекта
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID, S, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (-1, 'NAME',
         'Прообраз виртуального имени объектов.',
         SP.G.TStr4000, '', 1, 3, 
         to_date('05-07-2015','dd-mm-yyyy'), 'SP');
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID,  R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (-2, 'PARENT',
         'Прообраз виртуального родителя.',
         SP.G.TRel, 1, 3,
         to_date('05-07-2015','dd-mm-yyyy'), 'SP');
         
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID,  E_VAL, N, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (-3, 'USING_ROLE',
         'Прообраз виртуально объекта роль использования.',                        
         SP.G.TRole, '', null, 1,3,
         to_date('05-07-2015','dd-mm-yyyy'), 'SP');
         
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID,  E_VAL, N, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (-4, 'EDIT_ROLE',
         'Прообраз виртуально объекта роль использования.',                        
         SP.G.TRole, '', null, 1,3,
         to_date('05-07-2015','dd-mm-yyyy'), 'SP');
END;    
/     
   
CREATE GLOBAL TEMPORARY TABLE SP.INSERTED_OBJECT_PAR_S
(
  NEW_ID NUMBER,
  NEW_NAME VARCHAR2(128),
  NEW_COMMENTS VARCHAR2(4000),
  NEW_TYPE_ID NUMBER(9),
	NEW_E_VAL VARCHAR2(128),
  NEW_N NUMBER,
  NEW_D DATE,
  NEW_S VARCHAR2(4000),
	NEW_X NUMBER,
	NEW_Y NUMBER,
  NEW_R_ONLY NUMBER(1),
  NEW_OBJ_ID NUMBER,
  NEW_GROUP_ID NUMBER,
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.INSERTED_OBJECT_PAR_S
  IS 'Временная таблица, содержащая перечень вставленных записей. (SP-CATALOG.sql)';
  
  
CREATE GLOBAL TEMPORARY TABLE SP.UPDATED_OBJECT_PAR_S
(
  NEW_ID NUMBER,
  NEW_NAME VARCHAR2(128),
  NEW_COMMENTS VARCHAR2(4000),
  NEW_TYPE_ID NUMBER(9),
	NEW_E_VAL VARCHAR2(128),
  NEW_N NUMBER,
  NEW_D DATE,
  NEW_S VARCHAR2(4000),
	NEW_X NUMBER,
	NEW_Y NUMBER,
  NEW_R_ONLY NUMBER(1),
  NEW_OBJ_ID NUMBER,
  NEW_GROUP_ID NUMBER,
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60),
  OLD_ID NUMBER,
  OLD_NAME VARCHAR2(60),
  OLD_COMMENTS VARCHAR2(4000),
  OLD_TYPE_ID NUMBER(9),
	OLD_E_VAL VARCHAR2(128),
  OLD_N NUMBER,
  OLD_D DATE,
  OLD_S VARCHAR2(4000),
	OLD_X NUMBER,
	OLD_Y NUMBER,
  OLD_R_ONLY NUMBER(1),
  OLD_OBJ_ID NUMBER,
  OLD_GROUP_ID NUMBER,
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.UPDATED_OBJECT_PAR_S
  IS 'Временная таблица, содержащая перечень изменённых записей. (SP-CATALOG.sql)';
  
CREATE GLOBAL TEMPORARY TABLE SP.DELETED_OBJECT_PAR_S
(
  OLD_ID NUMBER,
  OLD_NAME VARCHAR2(128),
  OLD_COMMENTS VARCHAR2(4000),
  OLD_TYPE_ID NUMBER(9),
	OLD_E_VAL VARCHAR2(128),
  OLD_N NUMBER,
  OLD_D DATE,
  OLD_S VARCHAR2(4000),
	OLD_X NUMBER,
	OLD_Y NUMBER,
  OLD_R_ONLY NUMBER(1),
  OLD_OBJ_ID NUMBER,
  OLD_GROUP_ID NUMBER,
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.DELETED_OBJECT_PAR_S
  IS 'Временная таблица, содержащая перечень удалённых записей. (SP-CATALOG.sql)';
  
  
-- end of file
  
