-- SP Model
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 05.08.2010
-- update 31.08.2010 22.09.2010 14.10.2010 17.11.2010 21.12.2010 05.04.2011
--        21.12.2011 21.08.2013 25.08.2013 29.08.2013 12.02.2014 14.06.2014
--        24.08.2014 26.08.2014 09.09.2014 11.11.2014 25.11.2014 30.03.2015
--        31.03.2015 06.07.2015-09.07.2015 16.07.2015 21.09.2015 06.11.2015
--        20.09.2016 12.10.2016 18.10.2016 22.11.2016 28.02.2017 08.03.2017
--        22.03.2017 06.04.2017 10.04.2017-12.04.2017 17.04.2017 11.05.2017
--        30.05.2017 22.11.2017 03.12.2017 08.04.2021 21.07.2021 08.09.2021
--*****************************************************************************

-- Таблица моделей.
-------------------------------------------------------------------------------
CREATE TABLE SP.MODELS
(
  ID NUMBER,
  NAME VARCHAR2(4000) NOT NULL,
  COMMENTS VARCHAR2(4000),
  CONSTRAINT PK_MODELS PRIMARY KEY (ID),
  PERSISTENT NUMBER(1) NOT NULL,
  LOCAL NUMBER(1) NOT NULL,
  USING_ROLE NUMBER DEFAULT NULL,
  M_DATE DATE NOT NULL,
  M_USER VARCHAR2(60) NOT NULL,
  CONSTRAINT REF_M_ROLES_to_USING_ROLES 
    FOREIGN KEY (USING_ROLE)
    REFERENCES SP.SP_ROLES (ID) ON DELETE SET NULL
);

CREATE UNIQUE INDEX SP.MODELS ON SP.MODELS (UPPER(NAME));

COMMENT ON TABLE SP.MODELS IS 'Перечень моделей.(SP-MODEL.sql)';

COMMENT ON COLUMN SP.MODELS.ID IS 'Идентификатор модели.';
COMMENT ON COLUMN SP.MODELS.NAME IS 'Имя модели.';
COMMENT ON COLUMN SP.MODELS.COMMENTS IS 'Описание модели.';
COMMENT ON COLUMN SP.MODELS.PERSISTENT IS 'Признак постоянного хранения модели. При установке этого признака модель не ощищается автоматически или при помощи команды очистки модели.';
COMMENT ON COLUMN SP.MODELS.LOCAL IS 'Признак, что данная модель сама является сервером модели, а не внутренним предчтавлением некоторого внешнего сервера (Intergraph, Tekla).';
COMMENT ON COLUMN SP.MODELS.M_DATE 
  IS 'Дата создания модели или изменения её своиств.';
COMMENT ON COLUMN SP.MODELS.M_USER 
  IS 'Пользователь создавший модель или изменивший её свойства.';
COMMENT ON COLUMN SP.MODEL_OBJECTS.USING_ROLE 
  IS 'Роль, которую должен иметь пользователь, чтобы изучать объекты данной модели. Пользователю, имеющему SP_ADMIN_ROLE доступена любая объект. Если поле нулл, то модель публичена.';

INSERT INTO SP.MODELS VALUES(1,'DEFAULT',
  'Модель используется по умолчанию при работе без соединения с SP3D.',
  1,1, null,
  to_date('05-01-2014','dd-mm-yyyy'), 'SP');
INSERT INTO SP.MODELS VALUES(2,'Buh||Example',
  'Модель используется по умолчанию как пример плана счетов бухгалтерии.',
  1,1, null,
  to_date('05-01-2014','dd-mm-yyyy'), 'SP');
  
-- Таблица объектов моделей.
-------------------------------------------------------------------------------
CREATE TABLE SP.MODEL_OBJECTS
(
  ID NUMBER,
  MODEL_ID NUMBER NOT NULL,
  MOD_OBJ_NAME VARCHAR2(128) NOT NULL,
  OID VARCHAR2(40),
  OBJ_ID NUMBER NOT NULL,
  PARENT_MOD_OBJ_ID NUMBER,
  USING_ROLE NUMBER,
  EDIT_ROLE NUMBER DEFAULT 1,
  M_DATE DATE NOT NULL,
  M_USER VARCHAR2(60) NOT NULL,
  TO_DEL NUMBER(1) DEFAULT 0 NOT NULL ,
  CONSTRAINT PK_M_OBJECTS PRIMARY KEY (ID),
  CONSTRAINT REF_M_OBJ_TO_MODELS
    FOREIGN KEY (MODEL_ID)
    REFERENCES SP.MODELS (ID) ON DELETE CASCADE,
  CONSTRAINT REF_M_OBJ_TO_OBJECTS
    FOREIGN KEY (OBJ_ID)
    REFERENCES SP.OBJECTS (ID),
  CONSTRAINT REF_M_OBJ_TO_M_OBJECTS
    FOREIGN KEY (PARENT_MOD_OBJ_ID)
    REFERENCES SP.MODEL_OBJECTS (ID) ON DELETE CASCADE,
  CONSTRAINT REF_M_OBJECTS_to_EDIT_ROLES 
    FOREIGN KEY (EDIT_ROLE)
    REFERENCES SP.SP_ROLES (ID) ON DELETE SET NULL,
  CONSTRAINT REF_M_OBJECTS_to_USING_ROLES 
    FOREIGN KEY (USING_ROLE)
    REFERENCES SP.SP_ROLES (ID) ON DELETE SET NULL
);

CREATE UNIQUE INDEX SP.M_OBJECTS_NAME 
  ON SP.MODEL_OBJECTS (MODEL_ID, PARENT_MOD_OBJ_ID, UPPER(MOD_OBJ_NAME));
CREATE INDEX SP.M_OBJECTS_NAM ON SP.MODEL_OBJECTS (MOD_OBJ_NAME);
-- OIDы могут повторяться в разных моделях. Возможно копирование моделей,
-- либо ретроспектива.  
CREATE UNIQUE INDEX SP.M_OBJECTS_OID 
  ON SP.MODEL_OBJECTS (MODEL_ID,nvl(OID,ID));
CREATE INDEX SP.M_OBJECTS_OIDs ON SP.MODEL_OBJECTS(OID);
  
CREATE INDEX SP.M_OBJECTS_MODEL_ID ON SP.MODEL_OBJECTS (MODEL_ID); 
CREATE INDEX SP.M_OBJECTS_OBJECTS ON SP.MODEL_OBJECTS (OBJ_ID);
CREATE INDEX SP.M_OBJECTS_PARENT_MOD_OBJ_ID 
  ON SP.MODEL_OBJECTS (PARENT_MOD_OBJ_ID); 
CREATE INDEX SP.M_OBJECTS_UROLES ON SP.MODEL_OBJECTS (USING_ROLE);
CREATE INDEX SP.M_OBJECTS_EROLES ON SP.MODEL_OBJECTS (EDIT_ROLE);
CREATE INDEX SP.M_OBJECTS_USER ON SP.MODEL_OBJECTS (M_USER);
CREATE INDEX SP.M_OBJECTS_DATE ON SP.MODEL_OBJECTS (M_DATE);
CREATE INDEX SP.M_OBJECTS_TO_DEL ON SP.MODEL_OBJECTS (TO_DEL);

COMMENT ON TABLE SP.MODEL_OBJECTS IS 'Объекты, созданные в модели.(SP-MODEL.sql)';

COMMENT ON COLUMN SP.MODEL_OBJECTS.ID 
  IS 'Идентификатор объекта. У объекта есть предопределённый параметр "ID". ';
COMMENT ON COLUMN SP.MODEL_OBJECTS.MODEL_ID 
  IS 'Ссылка на модель.';
COMMENT ON COLUMN SP.MODEL_OBJECTS.MOD_OBJ_NAME
  IS 'Имя объекта, данное генератором имён или присвоенное пользователем. У объекта есть предопределённый параметр "NAME".';
COMMENT ON COLUMN SP.MODEL_OBJECTS.OID 
  IS 'Идентификатор объекта во внешней модели. У объекта есть предопределённый параметр "OID". Для локальных моделей идентификатор присваиваится при добавлении объекта средствами базы.';
COMMENT ON COLUMN SP.MODEL_OBJECTS.OBJ_ID
  IS 'Ссылка на  объект каталога.';
COMMENT ON COLUMN SP.MODEL_OBJECTS.PARENT_MOD_OBJ_ID
  IS 'Ссылка на родительский объект. У объекта есть предопределённый параметр "PARENT"'; 
COMMENT ON COLUMN SP.MODEL_OBJECTS.USING_ROLE 
  IS 'Роль, которую должен иметь пользователь, чтобы изучать объект и его свойства. Пользователю, имеющему SP_ADMIN_ROLE доступен любой объект. Если поле нулл, то объект публичен. Любой пользователь может создать новый объект, но он может назначить ему роли, только которые имеет сам. Роль пользователя есть зарезервированный параметр объекта "USING_ROLE".';
COMMENT ON COLUMN SP.MODEL_OBJECTS.EDIT_ROLE 
  IS 'Роль, которую должен иметь пользователь, чтобы изменять объект, а также добавлять, удалять или изменять его параметры. Пользователь, имеющий SP_ADMIN_ROLE, может изменять любой объект. Если поле нулл, то, в отличие от каталога, любой пользователь может изменять объект. Роль пользователя есть зарезервированный параметр объекта "EDIT_ROLE".';
COMMENT ON COLUMN SP.MODEL_OBJECTS.M_DATE 
  IS 'Дата создания или изменения объекта модели.';
COMMENT ON COLUMN SP.MODEL_OBJECTS.M_USER 
  IS 'Пользователь создавший или изменивший объект модели.';
COMMENT ON COLUMN SP.MODEL_OBJECTS.TO_DEL 
  IS 'Признак недеёствительности объекта. Используется при синхронизации моделей';

CREATE GLOBAL TEMPORARY TABLE SP.INSERTED_MOD_OBJECTS
(
  NEW_ID NUMBER,
  NEW_MODEL_ID NUMBER,
  NEW_MOD_OBJ_NAME VARCHAR2(128),
  NEW_OID VARCHAR2(40),
  NEW_OBJ_ID NUMBER,
  NEW_PARENT_MOD_OBJ_ID NUMBER,
  NEW_USING_ROLE NUMBER,
  NEW_EDIT_ROLE NUMBER,
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60),
  NEW_TO_DEL NUMBER(1)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.INSERTED_MOD_OBJECTS
  IS 'Временная таблица, содержащая перечень добавленных записей.(SP-MODEL.sql)';

CREATE GLOBAL TEMPORARY TABLE SP.UPDATED_MOD_OBJECTS
(
  NEW_ID NUMBER,
  NEW_MODEL_ID NUMBER,
  NEW_MOD_OBJ_NAME VARCHAR2(128),
  NEW_OID VARCHAR2(40),
  NEW_OBJ_ID NUMBER,
  NEW_PARENT_MOD_OBJ_ID NUMBER,
  NEW_USING_ROLE NUMBER,
  NEW_EDIT_ROLE NUMBER,
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60),
  NEW_TO_DEL NUMBER(1),
  OLD_ID NUMBER,
  OLD_MODEL_ID NUMBER,
  OLD_MOD_OBJ_NAME VARCHAR2(128),
  OLD_OID VARCHAR2(40),
  OLD_OBJ_ID NUMBER,
  OLD_PARENT_MOD_OBJ_ID NUMBER,
  OLD_USING_ROLE NUMBER,
  OLD_EDIT_ROLE NUMBER,
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60),
  OLD_TO_DEL NUMBER(1)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.UPDATED_MOD_OBJECTS
  IS 'Временная таблица, содержащая перечень добавленных записей.(SP-MODEL.sql)';


CREATE GLOBAL TEMPORARY TABLE SP.DELETED_MOD_OBJECTS
(
  OLD_ID NUMBER,
  OLD_MODEL_ID NUMBER,
  OLD_MOD_OBJ_NAME VARCHAR2(128),
  OLD_OID VARCHAR2(40),
  OLD_OBJ_ID NUMBER,
  OLD_PARENT_MOD_OBJ_ID NUMBER,
  OLD_USING_ROLE NUMBER,
  OLD_EDIT_ROLE NUMBER,
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60),
  OLD_TO_DEL NUMBER(1)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.DELETED_MOD_OBJECTS
  IS 'Временная таблица, содержащая перечень удалённых записей.(SP-MODEL.sql)';

-- Таблица путей объектов моделей.
-------------------------------------------------------------------------------
CREATE TABLE SP.MODEL_OBJECT_PATHS
(
  ID NUMBER,
  MODEL_ID NUMBER NOT NULL,
  MOD_OBJ_PATH VARCHAR2(4000) NOT NULL,
  PARENT_MOD_OBJ_ID NUMBER,
  INVALID NUMBER(1) DEFAULT (0),
  CONSTRAINT PK_M_OBJECT_PATHS PRIMARY KEY (ID),
  CONSTRAINT REF_M_OBJP_TO_MODELS
    FOREIGN KEY (MODEL_ID)
    REFERENCES SP.MODELS (ID) ON DELETE CASCADE,
  CONSTRAINT REF_M_OBJP_TO_M_OBJP
    FOREIGN KEY (PARENT_MOD_OBJ_ID)
    REFERENCES SP.MODEL_OBJECT_PATHS (ID) ON DELETE CASCADE
);

CREATE UNIQUE INDEX SP.M_OBJECTS_PATH 
  ON SP.MODEL_OBJECT_PATHS (MODEL_ID, UPPER(MOD_OBJ_PATH));
CREATE INDEX SP.M_OBJECTS_PATH_VALID 
  ON SP.MODEL_OBJECT_PATHS (INVALID);

COMMENT ON TABLE SP.MODEL_OBJECT_PATHS IS 'Кэш путей (полных имён) объектов моделей. Таблица используется пакетом SP.MO.(SP-MODEL.sql)';

COMMENT ON COLUMN SP.MODEL_OBJECT_PATHS.ID 
  IS 'Идентификатор объекта. ';
COMMENT ON COLUMN SP.MODEL_OBJECT_PATHS.MODEL_ID 
  IS 'Ссылка на модель.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PATHS.MOD_OBJ_PATH
  IS 'Полное имя объекта.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PATHS.PARENT_MOD_OBJ_ID
  IS 'Ссылка на родительский объект.'; 
COMMENT ON COLUMN SP.MODEL_OBJECT_PATHS.INVALID
  IS 'Признак недействительности имени. Кэш имени устарел для данного идентификатора.'; 

CREATE OR REPLACE PROCEDURE SP.RENEW_MODEL_PATHS
-- Процедура обновления таблицы SP.MODEL_OBJECT_PATHS (SP.MODEL.sql)
is
absent number;
inv number;
begin
  d('begin ', 'SP.RENEW_MODEL_PATHS');
  select count(*) into absent from
  (
  select ID from SP.MODEL_OBJECTS
  minus
  select ID from SP.MODEL_OBJECT_PATHS where INVALID = 0
  )
  ;
  select count(*) into inv from SP.MODEL_OBJECT_PATHS pp 
    where PP.INVALID = 1;
  delete from SP.MODEL_OBJECT_PATHS pp where PP.INVALID = 1;
  insert into SP.MODEL_OBJECT_PATHS 
    select ID, MODEL_ID,
      SYS_CONNECT_BY_PATH(MOD_OBJ_NAME, '/') MOD_OBJ_PATH,
      PARENT_MOD_OBJ_ID,0 
      from SP.MODEL_OBJECTS
    where  
      ID in 
      (
        select ID from SP.MODEL_OBJECTS
        minus
        select ID from SP.MODEL_OBJECT_PATHS
      )
      start with PARENT_MOD_OBJ_ID is null
      connect by PARENT_MOD_OBJ_ID = prior ID
  ;
  commit;
  d('absent '||absent||' invalid '||inv, 'SP.RENEW_MODEL_PATHS');
end; 
/

-- Параметры созданных объектов
-------------------------------------------------------------------------------
CREATE TABLE SP.MODEL_OBJECT_PAR_S
(
  ID NUMBER,
  MOD_OBJ_ID NUMBER NOT NULL,
  NAME VARCHAR2(128),
  OBJ_PAR_ID NUMBER,
  R_ONLY NUMBER(1) NOT NULL,
  TYPE_ID NUMBER,
	E_VAL VARCHAR2(128),
  N NUMBER,
  D DATE,
  S VARCHAR2(4000),
	X NUMBER,
	Y NUMBER,
  M_DATE DATE NOT NULL,
  M_USER VARCHAR2(60) NOT NULL,
  CONSTRAINT PK_MOD_OBJECT_PAR_S PRIMARY KEY (ID),
  CONSTRAINT REF_MOD_OBJ_PAR_S_to_OBJ_PAR_S
    FOREIGN KEY (OBJ_PAR_ID) 
    REFERENCES SP.OBJECT_PAR_S (ID) ON DELETE CASCADE,
  CONSTRAINT REF_M_OBJ_PAR_S_to_M_OBJECTS
    FOREIGN KEY (MOD_OBJ_ID)
    REFERENCES SP.MODEL_OBJECTS (ID) ON DELETE CASCADE,
  CONSTRAINT CH_MODEL_OBJECT_PAR_S
    CHECK(
             (  ((OBJ_PAR_ID is null) and (NAME is not null))
              or((OBJ_PAR_ID is not null) and (NAME is null))
             )
          and (TYPE_ID != 100)
          ),
  CONSTRAINT REF_MOD_OBJ_PAR_S_to_TYPES_ID
  FOREIGN KEY (TYPE_ID) 
  REFERENCES SP.PAR_TYPES (ID) ON DELETE CASCADE
);

CREATE INDEX SP.MOD_OBJ_PAR_S_OBJ_PAR ON SP.MODEL_OBJECT_PAR_S (OBJ_PAR_ID);
CREATE INDEX SP.MOD_OBJ_PAR_S_MOD_OBJ ON SP.MODEL_OBJECT_PAR_S (MOD_OBJ_ID);
CREATE INDEX SP.MOD_OBJ_PAR_S_TYPE_ID ON SP.MODEL_OBJECT_PAR_S (TYPE_ID); 
CREATE INDEX SP.Object_PAR_S_S 
  ON SP.MODEL_OBJECT_PAR_S (S);
CREATE INDEX SP.Object_PAR_S_N
  ON SP.MODEL_OBJECT_PAR_S (N);
CREATE INDEX SP.Object_PAR_S_E
  ON SP.MODEL_OBJECT_PAR_S (E_VAL);
CREATE INDEX SP.Object_PAR_S_Enum_Value 
  ON SP.MODEL_OBJECT_PAR_S (TYPE_ID,E_VAL);
CREATE INDEX SP.Object_PAR_S_String_Value 
  ON SP.MODEL_OBJECT_PAR_S (TYPE_ID,S);
CREATE INDEX SP.Object_PAR_S_Number_Value 
  ON SP.MODEL_OBJECT_PAR_S (TYPE_ID,N);
CREATE INDEX SP.Object_PAR_S_3D_Value 
  ON SP.MODEL_OBJECT_PAR_S (TYPE_ID,N,X,Y);
CREATE INDEX SP.Object_PAR_S_2D_Value 
  ON SP.MODEL_OBJECT_PAR_S (TYPE_ID,X,Y);
CREATE INDEX SP.Object_PAR_S_Value 
  ON SP.MODEL_OBJECT_PAR_S (TYPE_ID,N,D,S,X,Y);
CREATE UNIQUE INDEX SP.OBJECT_PAR_S_UK_NAME
  ON SP.MODEL_OBJECT_PAR_S(MOD_OBJ_ID,
                           nvl(NAME, 'OBJ_PAR_ID_'||to_Char(OBJ_PAR_ID)));
CREATE INDEX SP.Object_PAR_S_USER
  ON SP.MODEL_OBJECT_PAR_S (M_USER);
CREATE INDEX SP.Object_PAR_S_DATE
  ON SP.MODEL_OBJECT_PAR_S (M_DATE);

  
COMMENT ON TABLE SP.MODEL_OBJECT_PAR_S 
  IS 'Перечень переопределённых параметров объектов, созданных в модели. Если значение параметра не отличается от каталога, то оно не заносится в данную таблицу. Если значение существует в данной таблице, а значение в каталоге изменилось и стало равным переопределённому значению, то значение НЕ УДАЛЯЕТСЯ.(SP-MODEL.sql) ';

COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.ID 
  IS 'Идентификатор параметра.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.MOD_OBJ_ID   
  IS 'Ссылка на объект.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.OBJ_PAR_ID
  IS 'Ссылка на параметр объекта каталога или нулл, если параметр определён в сторонней модели.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.NAME
  IS 'Имя параметра объекта модели не имеющего ссылки на соответсвующий параметр каталога (параметр определён в сторонней модели).';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.R_ONLY 
  IS 'это поле дублирует соответствующее поле каталога объектов для каталожных параметров. Если значение равно 1, то этот параметр только для чтения. Если значение равно -1, то этот параметр обязательно должен быть присвоен перед вызовом  команды. Eсли значение -2, то история изменения значений параметра не записывается. История так же не записывается для параметров только для чтения, поскольку они существуют только в каталоге.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.TYPE_ID 
  IS 'Тип значения. Данное поле дублирует соответствующее поле таблицы параметров объекта, для ускорения поиска по значению свойств, а также определяет типы сторонних параметров.';	 
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.E_VAL 
  IS 'Значение перечисляемого типа.';	 
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.N        
  IS 'Значение.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.D        
  IS 'Значение.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.S       
  IS 'Значение.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.X        
  IS 'Значение.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.Y        
  IS 'Значение.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.M_DATE 
  IS 'Дата создания или изменения параметра объекта модели.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.M_USER 
  IS 'Пользователь создавший или изменивший параметр объект модели.';


CREATE GLOBAL TEMPORARY TABLE SP.INSERTED_MOD_OBJ_PAR_S
(
  NEW_ID NUMBER,
  NEW_MOD_OBJ_ID NUMBER,
  NEW_NAME VARCHAR2(128),
  NEW_OBJ_PAR_ID NUMBER,
  NEW_R_ONLY NUMBER(1),
  NEW_TYPE_ID NUMBER,
	NEW_E_VAL VARCHAR2(128),
  NEW_N NUMBER,
  NEW_D DATE,
  NEW_S VARCHAR2(4000),
	NEW_X NUMBER,  
	NEW_Y NUMBER,  
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.INSERTED_MOD_OBJ_PAR_S
  IS 'Временная таблица, содержащая перечень добавленных записей.(SP-MODEL.sql)';
  
CREATE GLOBAL TEMPORARY TABLE SP.UPDATED_MOD_OBJ_PAR_S
(
  NEW_ID NUMBER,
  NEW_MOD_OBJ_ID NUMBER,
  NEW_NAME VARCHAR2(128),
  NEW_OBJ_PAR_ID NUMBER,
  NEW_R_ONLY NUMBER(1),
  NEW_TYPE_ID NUMBER,
	NEW_E_VAL VARCHAR2(128),
  NEW_N NUMBER,
  NEW_D DATE,
  NEW_S VARCHAR2(4000),
	NEW_X NUMBER,  
	NEW_Y NUMBER,  
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60),
  OLD_ID NUMBER,
  OLD_MOD_OBJ_ID NUMBER,
  OLD_NAME VARCHAR2(128),
  OLD_OBJ_PAR_ID NUMBER,
  OLD_R_ONLY NUMBER(1),
  OLD_TYPE_ID NUMBER,
	OLD_E_VAL VARCHAR2(128),
  OLD_N NUMBER,
  OLD_D DATE,
  OLD_S VARCHAR2(4000),
	OLD_X NUMBER,  
	OLD_Y NUMBER,  
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.UPDATED_MOD_OBJ_PAR_S
  IS 'Временная таблица, содержащая перечень изменённых записей.(SP-MODEL.sql)';
  
  
CREATE GLOBAL TEMPORARY TABLE SP.DELETED_MOD_OBJ_PAR_S
(
  OLD_ID NUMBER,
  OLD_MOD_OBJ_ID NUMBER,
  OLD_NAME VARCHAR2(128),
  OLD_OBJ_PAR_ID NUMBER,
  OLD_R_ONLY NUMBER(1),
  OLD_TYPE_ID NUMBER,
  OLD_E_VAL VARCHAR2(128),
  OLD_N NUMBER,
  OLD_D DATE,
  OLD_S VARCHAR2(4000),
  OLD_X NUMBER,  
  OLD_Y NUMBER,  
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;
 
COMMENT ON TABLE SP.DELETED_MOD_OBJ_PAR_S
  IS 'Временная таблица, содержащая перечень удалённых записей.(SP-MODEL.sql)';

-- Кэш параметров объекта
-------------------------------------------------------------------------------
CREATE GLOBAL TEMPORARY TABLE SP.MOD_OBJ_PARS_CACHE 
(
  ID NUMBER,
  MOD_OBJ_ID NUMBER NOT NULL,
  NAME VARCHAR2(128),
  OBJ_PAR_ID NUMBER,
  R_ONLY NUMBER(1) NOT NULL,
  TYPE_ID NUMBER,
  E_VAL VARCHAR2(128),
  N NUMBER,
  D DATE,
  S VARCHAR2(4000),
  X NUMBER,
  Y NUMBER,
  G_ID NUMBER,
  M_DATE DATE,
  M_USER VARCHAR2(60),
  set_key VARCHAR(60) NOT NULL
--  CONSTRAINT PK_MOD_OBJ_PARS_CACHE PRIMARY KEY (SET_KEY, NAME))
)ON COMMIT PRESERVE ROWS;

--CREATE INDEX SP.MOD_OBJ_PARS_CACHE_OBJ_PAR 
--  ON SP.MOD_OBJ_PARS_CACHE (OBJ_PAR_ID);
CREATE INDEX SP.MOD_OBJ_PARS_SET_KEY 
  ON SP.MOD_OBJ_PARS_CACHE (SET_KEY);
CREATE INDEX SP.MOD_OBJ_PARS_CACHE_NAME  
  ON SP.MOD_OBJ_PARS_CACHE (UPPER(NAME));

COMMENT ON TABLE SP.MOD_OBJ_PARS_CACHE
  IS 'Временная таблица, содержащая кэш для быстрого доступа к параметрам объекта модели. (SP-MODEL.sql)';

COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.ID 
  IS 'Идентификатор параметра объекта модели.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.MOD_OBJ_ID 
  IS 'Идентификатор объекта модели.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.NAME 
  IS 'Имя параметра.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.OBJ_PAR_ID 
  IS 'Идентификатор параметра объекта каталога.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.R_ONLY 
  IS 'Мордификатор записи параметра.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.TYPE_ID 
  IS 'Идентификатор типа параметра.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.E_VAL 
  IS 'Имя значения.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.N 
  IS 'Значение.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.D 
  IS 'Значение.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.S 
  IS 'Значение.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.X 
  IS 'Значение.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.Y 
  IS 'Значение.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.G_ID
  IS 'Идентификатор группы к которой принадлежит параметр.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.M_DATE 
  IS 'Последняя дата изменения значения.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.M_USER 
  IS 'Последний пользователь, изменивший значение.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.set_key 
  IS 'Идентификатор набора параметров. Используется при совместном использовании кэша различными модулями. Как правило содержит имя программного модуля в котором используется.';


-- История значения параметров.
-------------------------------------------------------------------------------
CREATE TABLE SP.MODEL_OBJECT_PAR_STORIES
(
  ID NUMBER,
  MOD_OBJ_ID NUMBER,
  OBJ_PAR_ID NUMBER,
  TYPE_ID NUMBER,
  E_VAL VARCHAR2(128),
  N NUMBER,
  D DATE,
  S VARCHAR2(4000),
  X NUMBER,
  Y NUMBER,
  M_DATE DATE NOT NULL,
  M_USER VARCHAR2(60) NOT NULL,
  CONSTRAINT PK_MOD_OBJECT_PAR_STORIES PRIMARY KEY (ID),
  CONSTRAINT REF_STORIES_to_MOD_OBJ_PAR
    FOREIGN KEY (OBJ_PAR_ID) 
    REFERENCES SP.OBJECT_PAR_S ON DELETE CASCADE,
  CONSTRAINT REF_STORIES_to_MOD_OBJ
    FOREIGN KEY (MOD_OBJ_ID) 
    REFERENCES SP.MODEL_OBJECTS ON DELETE CASCADE,
  CONSTRAINT REF_PAR_STORIES_to_TYPES_ID
  FOREIGN KEY (TYPE_ID) 
  REFERENCES SP.PAR_TYPES ON DELETE CASCADE
);

CREATE INDEX SP.PAR_STORIES_OBJ_PAR_ID 
  ON SP.MODEL_OBJECT_PAR_STORIES (OBJ_PAR_ID); 
CREATE INDEX SP.PAR_STORIES_MOD_OBJ_ID 
  ON SP.MODEL_OBJECT_PAR_STORIES (MOD_OBJ_ID);
CREATE INDEX SP.PAR_STORIES_TYPE_ID
  ON SP.MODEL_OBJECT_PAR_STORIES (TYPE_ID);
  
  
CREATE INDEX SP.PAR_STORIES_String_Value 
  ON SP.MODEL_OBJECT_PAR_STORIES (TYPE_ID,S);
CREATE INDEX SP.PAR_STORIES_Number_Value 
  ON SP.MODEL_OBJECT_PAR_STORIES (TYPE_ID,N);
CREATE INDEX SP.PAR_STORIES_3D_Value 
  ON SP.MODEL_OBJECT_PAR_STORIES (TYPE_ID,N,X,Y);
CREATE INDEX SP.PAR_STORIES_2D_Value 
  ON SP.MODEL_OBJECT_PAR_STORIES (TYPE_ID,X,Y);
CREATE INDEX SP.PAR_STORIES_Value 
  ON SP.MODEL_OBJECT_PAR_STORIES (TYPE_ID,N,D,S,X,Y);
CREATE INDEX SP.PAR_STORIES_MDATE 
  ON SP.MODEL_OBJECT_PAR_STORIES (M_DATE);
CREATE INDEX SP.PAR_STORIES_M_USER 
  ON SP.MODEL_OBJECT_PAR_STORIES (M_USER);
CREATE INDEX SP.PAR_STORIES_DATE_Value 
  ON SP.MODEL_OBJECT_PAR_STORIES (D);

  
COMMENT ON TABLE SP.MODEL_OBJECT_PAR_STORIES 
  IS 'История значений параметров. Для предопределённых параметров NAME, PARENT, USING_ROLE и EDIT_ROLE ведётся история изменения имени объекта. Удалять историю параметра можно, если установить его модификатор доступа равным StoryLess. Удалять историю псевдопараметров можно всегда.(SP-MODEL.sql)';

COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.ID 
  IS 'Идентификатор записи.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.MOD_OBJ_ID   
  IS 'Ссылка на объект модели.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.OBJ_PAR_ID   
  IS 'Ссылка на параметр каталога. История может сохраняться лишь для параметров каталога и для предопределённых параметров, при этом идентификаторы предопределённых параметров: NAME -1, PARENT -2, USING_ROLE -3, EDIT_ROLE -4. Для предопределённого параметра PARENT история сохраняется, используя значение типа Rel, а не STR4000, используемое для построения объекта.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.TYPE_ID 
  IS 'Тип значения. Данное поле дублирует соответствующее поле таблицы параметров объекта, для ускорения поиска по значению свойств.';   
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.E_VAL 
  IS 'Значение перечисляемого типа.';   
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.N        
  IS 'Значение.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.D        
  IS 'Значение.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.S       
  IS 'Значение.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.X        
  IS 'Значение.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.Y        
  IS 'Значение.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.M_DATE 
  IS 'Дата создания или изменения параметра объекта модели.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.M_USER 
  IS 'Пользователь создавший или изменивший параметр объект модели.';
  
CREATE GLOBAL TEMPORARY TABLE SP.DELETED_M_OBJ_PAR_STOPIES
(
  OLD_ID NUMBER,
  OLD_MOD_OBJ_ID NUMBER,
  OLD_OBJ_PAR_ID NUMBER,
  OLD_TYPE_ID NUMBER,
  OLD_E_VAL VARCHAR2(128),
  OLD_N NUMBER,
  OLD_D DATE,
  OLD_S VARCHAR2(4000),
  OLD_X NUMBER,
  OLD_Y NUMBER,
  OLD_M_DATE DATE NOT NULL,
  OLD_M_USER VARCHAR2(60) NOT NULL
)
ON COMMIT DELETE ROWS;
 
COMMENT ON TABLE SP.DELETED_M_OBJ_PAR_STOPIES
  IS 'Временная таблица, содержащая перечень удалённых записей.(SP-MODEL.sql)';
  
-- end of file
  