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

-- ������� �������.
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

COMMENT ON TABLE SP.MODELS IS '�������� �������.(SP-MODEL.sql)';

COMMENT ON COLUMN SP.MODELS.ID IS '������������� ������.';
COMMENT ON COLUMN SP.MODELS.NAME IS '��� ������.';
COMMENT ON COLUMN SP.MODELS.COMMENTS IS '�������� ������.';
COMMENT ON COLUMN SP.MODELS.PERSISTENT IS '������� ����������� �������� ������. ��� ��������� ����� �������� ������ �� ��������� ������������� ��� ��� ������ ������� ������� ������.';
COMMENT ON COLUMN SP.MODELS.LOCAL IS '�������, ��� ������ ������ ���� �������� �������� ������, � �� ���������� �������������� ���������� �������� ������� (Intergraph, Tekla).';
COMMENT ON COLUMN SP.MODELS.M_DATE 
  IS '���� �������� ������ ��� ��������� � �������.';
COMMENT ON COLUMN SP.MODELS.M_USER 
  IS '������������ ��������� ������ ��� ���������� � ��������.';
COMMENT ON COLUMN SP.MODEL_OBJECTS.USING_ROLE 
  IS '����, ������� ������ ����� ������������, ����� ������� ������� ������ ������. ������������, �������� SP_ADMIN_ROLE ��������� ����� ������. ���� ���� ����, �� ������ ���������.';

INSERT INTO SP.MODELS VALUES(1,'DEFAULT',
  '������ ������������ �� ��������� ��� ������ ��� ���������� � SP3D.',
  1,1, null,
  to_date('05-01-2014','dd-mm-yyyy'), 'SP');
INSERT INTO SP.MODELS VALUES(2,'Buh||Example',
  '������ ������������ �� ��������� ��� ������ ����� ������ �����������.',
  1,1, null,
  to_date('05-01-2014','dd-mm-yyyy'), 'SP');
  
-- ������� �������� �������.
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
-- OID� ����� ����������� � ������ �������. �������� ����������� �������,
-- ���� �������������.  
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

COMMENT ON TABLE SP.MODEL_OBJECTS IS '�������, ��������� � ������.(SP-MODEL.sql)';

COMMENT ON COLUMN SP.MODEL_OBJECTS.ID 
  IS '������������� �������. � ������� ���� ��������������� �������� "ID". ';
COMMENT ON COLUMN SP.MODEL_OBJECTS.MODEL_ID 
  IS '������ �� ������.';
COMMENT ON COLUMN SP.MODEL_OBJECTS.MOD_OBJ_NAME
  IS '��� �������, ������ ����������� ��� ��� ����������� �������������. � ������� ���� ��������������� �������� "NAME".';
COMMENT ON COLUMN SP.MODEL_OBJECTS.OID 
  IS '������������� ������� �� ������� ������. � ������� ���� ��������������� �������� "OID". ��� ��������� ������� ������������� ������������� ��� ���������� ������� ���������� ����.';
COMMENT ON COLUMN SP.MODEL_OBJECTS.OBJ_ID
  IS '������ ��  ������ ��������.';
COMMENT ON COLUMN SP.MODEL_OBJECTS.PARENT_MOD_OBJ_ID
  IS '������ �� ������������ ������. � ������� ���� ��������������� �������� "PARENT"'; 
COMMENT ON COLUMN SP.MODEL_OBJECTS.USING_ROLE 
  IS '����, ������� ������ ����� ������������, ����� ������� ������ � ��� ��������. ������������, �������� SP_ADMIN_ROLE �������� ����� ������. ���� ���� ����, �� ������ ��������. ����� ������������ ����� ������� ����� ������, �� �� ����� ��������� ��� ����, ������ ������� ����� ���. ���� ������������ ���� ����������������� �������� ������� "USING_ROLE".';
COMMENT ON COLUMN SP.MODEL_OBJECTS.EDIT_ROLE 
  IS '����, ������� ������ ����� ������������, ����� �������� ������, � ����� ���������, ������� ��� �������� ��� ���������. ������������, ������� SP_ADMIN_ROLE, ����� �������� ����� ������. ���� ���� ����, ��, � ������� �� ��������, ����� ������������ ����� �������� ������. ���� ������������ ���� ����������������� �������� ������� "EDIT_ROLE".';
COMMENT ON COLUMN SP.MODEL_OBJECTS.M_DATE 
  IS '���� �������� ��� ��������� ������� ������.';
COMMENT ON COLUMN SP.MODEL_OBJECTS.M_USER 
  IS '������������ ��������� ��� ���������� ������ ������.';
COMMENT ON COLUMN SP.MODEL_OBJECTS.TO_DEL 
  IS '������� ����������������� �������. ������������ ��� ������������� �������';

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
  IS '��������� �������, ���������� �������� ����������� �������.(SP-MODEL.sql)';

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
  IS '��������� �������, ���������� �������� ����������� �������.(SP-MODEL.sql)';


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
  IS '��������� �������, ���������� �������� �������� �������.(SP-MODEL.sql)';

-- ������� ����� �������� �������.
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

COMMENT ON TABLE SP.MODEL_OBJECT_PATHS IS '��� ����� (������ ���) �������� �������. ������� ������������ ������� SP.MO.(SP-MODEL.sql)';

COMMENT ON COLUMN SP.MODEL_OBJECT_PATHS.ID 
  IS '������������� �������. ';
COMMENT ON COLUMN SP.MODEL_OBJECT_PATHS.MODEL_ID 
  IS '������ �� ������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PATHS.MOD_OBJ_PATH
  IS '������ ��� �������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PATHS.PARENT_MOD_OBJ_ID
  IS '������ �� ������������ ������.'; 
COMMENT ON COLUMN SP.MODEL_OBJECT_PATHS.INVALID
  IS '������� ������������������ �����. ��� ����� ������� ��� ������� ��������������.'; 

CREATE OR REPLACE PROCEDURE SP.RENEW_MODEL_PATHS
-- ��������� ���������� ������� SP.MODEL_OBJECT_PATHS (SP.MODEL.sql)
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

-- ��������� ��������� ��������
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
  IS '�������� ��������������� ���������� ��������, ��������� � ������. ���� �������� ��������� �� ���������� �� ��������, �� ��� �� ��������� � ������ �������. ���� �������� ���������� � ������ �������, � �������� � �������� ���������� � ����� ������ ���������������� ��������, �� �������� �� ���������.(SP-MODEL.sql) ';

COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.ID 
  IS '������������� ���������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.MOD_OBJ_ID   
  IS '������ �� ������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.OBJ_PAR_ID
  IS '������ �� �������� ������� �������� ��� ����, ���� �������� �������� � ��������� ������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.NAME
  IS '��� ��������� ������� ������ �� �������� ������ �� �������������� �������� �������� (�������� �������� � ��������� ������).';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.R_ONLY 
  IS '��� ���� ��������� ��������������� ���� �������� �������� ��� ���������� ����������. ���� �������� ����� 1, �� ���� �������� ������ ��� ������. ���� �������� ����� -1, �� ���� �������� ����������� ������ ���� �������� ����� �������  �������. E��� �������� -2, �� ������� ��������� �������� ��������� �� ������������. ������� ��� �� �� ������������ ��� ���������� ������ ��� ������, ��������� ��� ���������� ������ � ��������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.TYPE_ID 
  IS '��� ��������. ������ ���� ��������� ��������������� ���� ������� ���������� �������, ��� ��������� ������ �� �������� �������, � ����� ���������� ���� ��������� ����������.';	 
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.E_VAL 
  IS '�������� �������������� ����.';	 
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.N        
  IS '��������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.D        
  IS '��������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.S       
  IS '��������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.X        
  IS '��������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.Y        
  IS '��������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.M_DATE 
  IS '���� �������� ��� ��������� ��������� ������� ������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_S.M_USER 
  IS '������������ ��������� ��� ���������� �������� ������ ������.';


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
  IS '��������� �������, ���������� �������� ����������� �������.(SP-MODEL.sql)';
  
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
  IS '��������� �������, ���������� �������� ��������� �������.(SP-MODEL.sql)';
  
  
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
  IS '��������� �������, ���������� �������� �������� �������.(SP-MODEL.sql)';

-- ��� ���������� �������
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
  IS '��������� �������, ���������� ��� ��� �������� ������� � ���������� ������� ������. (SP-MODEL.sql)';

COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.ID 
  IS '������������� ��������� ������� ������.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.MOD_OBJ_ID 
  IS '������������� ������� ������.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.NAME 
  IS '��� ���������.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.OBJ_PAR_ID 
  IS '������������� ��������� ������� ��������.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.R_ONLY 
  IS '������������ ������ ���������.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.TYPE_ID 
  IS '������������� ���� ���������.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.E_VAL 
  IS '��� ��������.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.N 
  IS '��������.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.D 
  IS '��������.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.S 
  IS '��������.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.X 
  IS '��������.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.Y 
  IS '��������.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.G_ID
  IS '������������� ������ � ������� ����������� ��������.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.M_DATE 
  IS '��������� ���� ��������� ��������.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.M_USER 
  IS '��������� ������������, ���������� ��������.';
COMMENT ON COLUMN SP.MOD_OBJ_PARS_CACHE.set_key 
  IS '������������� ������ ����������. ������������ ��� ���������� ������������� ���� ���������� ��������. ��� ������� �������� ��� ������������ ������ � ������� ������������.';


-- ������� �������� ����������.
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
  IS '������� �������� ����������. ��� ��������������� ���������� NAME, PARENT, USING_ROLE � EDIT_ROLE ������ ������� ��������� ����� �������. ������� ������� ��������� �����, ���� ���������� ��� ����������� ������� ������ StoryLess. ������� ������� ���������������� ����� ������.(SP-MODEL.sql)';

COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.ID 
  IS '������������� ������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.MOD_OBJ_ID   
  IS '������ �� ������ ������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.OBJ_PAR_ID   
  IS '������ �� �������� ��������. ������� ����� ����������� ���� ��� ���������� �������� � ��� ��������������� ����������, ��� ���� �������������� ��������������� ����������: NAME -1, PARENT -2, USING_ROLE -3, EDIT_ROLE -4. ��� ���������������� ��������� PARENT ������� �����������, ��������� �������� ���� Rel, � �� STR4000, ������������ ��� ���������� �������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.TYPE_ID 
  IS '��� ��������. ������ ���� ��������� ��������������� ���� ������� ���������� �������, ��� ��������� ������ �� �������� �������.';   
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.E_VAL 
  IS '�������� �������������� ����.';   
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.N        
  IS '��������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.D        
  IS '��������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.S       
  IS '��������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.X        
  IS '��������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.Y        
  IS '��������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.M_DATE 
  IS '���� �������� ��� ��������� ��������� ������� ������.';
COMMENT ON COLUMN SP.MODEL_OBJECT_PAR_STORIES.M_USER 
  IS '������������ ��������� ��� ���������� �������� ������ ������.';
  
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
  IS '��������� �������, ���������� �������� �������� �������.(SP-MODEL.sql)';
  
-- end of file
  