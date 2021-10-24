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


-- ������� �������� � � ��� ����� ��������.
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
  IS '�������. ��������� �������� ������, ����������� �������� �������, � ����� ������� ���������.(SP-CATALOG.sql)';

COMMENT ON COLUMN SP.OBJECTS.ID        IS '������������� �������.';
COMMENT ON COLUMN SP.OBJECTS.OID 
  IS '���������� ������������� ������� ��������� ����� ����������.';
COMMENT ON COLUMN SP.OBJECTS.IM_ID     IS '������������� �����������.';
COMMENT ON COLUMN SP.OBJECTS.NAME      IS '��� �������. ��� ������ ���� ��������� � �������� ������ ������������ ���. ��� ������� �� ������ ��������� ".", ��������� ��������� ������ "." � ������ ����� �������, �������� ������������ ����� ������������� ��� � ������ �������.';
COMMENT ON COLUMN SP.OBJECTS.COMMENTS  IS '�������� �������.';
COMMENT ON COLUMN SP.OBJECTS.OBJECT_KIND
  IS '��� �������. (0 - ��������� ������ ��������, 1 - ����������� ������ ��������, 2 - ��������������, 3 - ��������� ��������(����������� �������� ������))'; 
COMMENT ON COLUMN SP.OBJECTS.GROUP_ID  IS '������������ ��� �������.(������ �� ������.) ����� ��������� ����� ������� � ��� ����� � ".".';
COMMENT ON COLUMN SP.OBJECTS.USING_ROLE 
  IS '����, ������� ������ ����� ������������, ����� �c���������� ������ � ��������� ����� ��������. ������������, ������� SP_ADMIN_ROLE, ����� ������������ ����� ������. ���� ���� ����, �� ������ ��������.';
COMMENT ON COLUMN SP.OBJECTS.EDIT_ROLE 
  IS '����, ������� ������ ����� ������������ ������������� � SP_DEVELOPING_ROLE, ����� �������� ������, � ����� ��������� ������� ��� �������� ��� ���������. ������������, ������� SP_ADMIN_ROLE, ����� �������� ����� ������. ���� ���� ����, �� ������ ������������� ����� �������� ������.';
COMMENT ON COLUMN SP.OBJECTS.MODIFIED 
  IS '���� ��������� �������. ���� ����������� ������� ��������� SetObjModified, � �� ��������� ��� ��������� DML.';
COMMENT ON COLUMN SP.OBJECTS.M_USER 
  IS '������������ ���������� ������. ���� ����������� ������� ��������� SetObjModified, � �� ��������� ��� ��������� DML.';


-- ��������� ������ "#Composit Origin". ��� �������� ����������� �������� 
-- ��������� ��� �������� �������� ������� �������.
INSERT INTO SP.OBJECTS (ID, OID, NAME, COMMENTS, OBJECT_KIND, MODIFIED, M_USER,
                        GROUP_ID)
  VALUES(0, 0,
  '#Composit Origin', 
  '��� �������� ����������� �������� ��������� ��� �������� �������� ������� �������.',
   0,
   TO_DATE('01-01-2011','dd-mm-yyyy'),
   'SP',
   6);
-- ��������� ������������� ������ ��� ���������� ������.  
INSERT INTO SP.OBJECTS (ID, OID, NAME, COMMENTS, OBJECT_KIND, MODIFIED, M_USER,
                        GROUP_ID)
  VALUES(1, 1,
  '#Native Object',
  '������ ����������� � ��������� ������ �� ���������� IMan. ��� �������, �� ������� ��������� � �������� � ������� ����������� ��������� �������� ������� ����� ���� ������ ��� ���� ���������� ��������.',
  0,
  TO_DATE('01-01-2011','dd-mm-yyyy'),
  'SP',
  6);
  
-- ��������� ������������� �������� ������ ������.   
INSERT INTO SP.OBJECTS (ID, OID, NAME, COMMENTS, OBJECT_KIND, MODIFIED, M_USER,
                        GROUP_ID)
  VALUES(2, 2,
  '#HierarchiesRoot',
  '�������� ������ �������� ������, ������ ������������ ���������� � ������.',
  0,
  TO_DATE('01-01-2011','dd-mm-yyyy'),
  'SP',
  6);
-- ������ �������� �������-��������� ����������� ����������.
INSERT INTO SP.OBJECTS (ID, OID, NAME, COMMENTS, OBJECT_KIND, MODIFIED, M_USER,
                        GROUP_ID)
  VALUES(3, 3,
  '#VirtualObject',
  '������ - �������� ������� ������, ������� ������� ������������ ����������� (NAME, PARENT ... ).',
  0,
  TO_DATE('01-06-2015','dd-mm-yyyy'),
  'SP',
  6);
-- ��������� ������������� ������ ��� ���������� �����.  
INSERT INTO SP.OBJECTS (ID, OID, NAME, COMMENTS, OBJECT_KIND, MODIFIED, M_USER,
                        GROUP_ID)
  VALUES(4, 4,
  '#Native Leaf',
  '������ ����������� � ��������� ������ �� ���������� IMan. ��� �������, �� ������� ��������� � �������� � ���������� �������� � ������ ������ ����� ���� ������ ��� ���� ���������� ��������.',
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
  IS '��������� �������, ���������� �������� �������� �������.(SP-CATALOG.sql)';

-------------------------------------------------------------------------------	
CREATE OR REPLACE PROCEDURE SP.SetObjModified(ObjID IN NUMBER)
-- ��������� ������� ���� � �������� ���� ���������� ��� ������� ��������.
-- (SP-CATALOG.sql)
AS
BEGIN
  UPDATE SP.OBJECTS 
    SET MODIFIED = SYSDATE, M_USER = TG.UserName 
    WHERE ID=ObjID;
EXCEPTION  
	WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20033,
		  'SP.SetObjModified, ������ � ID: '||TO_CHAR(ObjID)||' �� ������!');
END;
/

-------------------------------------------------------------------------------	
CREATE OR REPLACE FUNCTION SP.to_str_Obj_KIND(Kind IN NUMBER)
RETURN VARCHAR2
-- �������������� � ��������� �������� ���� �������
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
		  'SP.to_str_Obj_KIND, �������� �������� KIND: '||TO_CHAR(Kind)||'!');
	END CASE;
END;
/

GRANT EXECUTE ON SP.to_str_Obj_KIND TO PUBLIC;

-------------------------------------------------------------------------------	
CREATE OR REPLACE FUNCTION SP.to_Obj_KIND(KIND IN VARCHAR2)
RETURN NUMBER
-- �������������� ���������� �������� ���� ������� � ��������
-- �� ��������� ������������� "SINGLE"
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
		  'SP.to_Obj_KIND, �������� �������� KIND: '||KIND||'!');
	END CASE;
END;
/

GRANT EXECUTE ON SP.to_Obj_KIND TO PUBLIC;

-------------------------------------------------------------------------------	
CREATE OR REPLACE FUNCTION SP.OBJ_KIND_VAL_S
RETURN REPLICATION.TIDENTIFIERS pipelined
-- �������� ��������� �������� ���� �������
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
-- ��������� ��������
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

  
-- ����� ���� ������ ���� �������� � ����� ....
--CREATE UNIQUE INDEX SP.Object_PAR_S_EPrivate 
--  on SP.Object_PAR_S(case when TYPE_ID=19 then Object else null end);
GRANT SELECT ON SP.OBJECT_PAR_S TO PUBLIC;   

COMMENT ON TABLE SP.OBJECT_PAR_S 
  IS '�������� ����������  ��������. (SP-CATALOG.sql)';
COMMENT ON COLUMN SP.OBJECT_PAR_S.ID        
  IS '������������� ���������. ���� ������������� ��������� �������������, �� ��� ��������������(���� ����� �� ������� ��������). ����� �������������� ���������� � ���� ��������. ��� ��������������� ������ ������� ���������.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.NAME      IS '��� ���������.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.COMMENTS  IS '�������� ���������';
COMMENT ON COLUMN SP.OBJECT_PAR_S.TYPE_ID    IS '��� ���������.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.E_VAL 
  IS '�������� �������������� ����.';	 
COMMENT ON COLUMN SP.OBJECT_PAR_S.N         IS '�������� �� ���������.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.D         IS '�������� �� ���������.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.S         IS '�������� �� ���������.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.X         IS '�������� �� ���������.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.Y         IS '�������� �� ���������.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.R_ONLY 
  IS '���� �������� ����� 1, �� ���� �������� ������ ��� ������. ���� �������� ����� -1, �� ���� �������� ����������� ������ ���� �������� ����� �������  �������. �������� �� ��������� �� �������� ����� ������������ ������ ��� �������. E��� �������� -2, �� ������� ��������� �������� ��������� �� ������������.������� ��� �� �� ������������ ��� ���������� ������ ��� ������.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.OBJ_ID     IS '������ �� ������.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.GROUP_ID   IS '������ �� ������, ������� ����������� ��������.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.M_DATE 
  IS '���� ��������� ��� ���������� ��������� �������.';
COMMENT ON COLUMN SP.OBJECT_PAR_S.M_USER 
  IS '������������ ���������� ��� ���������� �������� �������.';


--
-- ��������� �������������� �������� ���� "R_Only" � ������ � �������
-- � SP.GLOBALS.	
-----				 
-- ��������� ��������� ���������� ��������.
--
-- ��������� ��������� ������� "Composit Origin".
BEGIN
--
-- ��� ������� - ������������ �������� ���� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (0, 'NAME',
         '��� ������������ ������� - ������������ �������� ���� ������.',
         SP.G.TStr4000, -1, 0, 
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- ��� �������� - ������������ �������� ���� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID,	R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (1, 'PARENT',
         '��� �������� - ������������ �������� ���� ������.',
         SP.G.TStr4000, -1, 0,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- ��� ������� - "GenericSystem" - ������ ��� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID,	E_VAL, N, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (2, 'SP3DTYPE',
         '��� ������� - "GenericSystem" - ������ ��� ������',                        
				 SP.G.TIType, 'GenericSystem', 1, 1, 0,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- ��� ������� - "Composit" - ������ ��� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID, N, S, X, Y, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (3, 'OBJECT_KIND',
         '��� ������� - "Composit"  - ������ ��� ������',                        
				 SP.G.TNote, 0, 'COMPOSIT', 0, 1, 1, 0,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
         
-- ������ ���� ������� - ������ ��� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID, E_VAL, N, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (4, 'IS_SYSTEM',
         '������ ���� �������  - ������ ��� ������',                        
				 SP.G.TBoolean, 'true', 1, 1, 0,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
END;
/
--
-- ��������� ��������� ������� "Native Object".
--
BEGIN
-- ��� ������� - ������������ �������� ���� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (5, 'NAME',
         '��� ������� - ������������ �������� ���� ������.',
         SP.G.TStr4000, -1, 1, 
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- ��� �������� - ������������ �������� ���� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID,  R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (6, 'PARENT',
         '��� �������� - ������������ �������� ���� ������.',
         SP.G.TStr4000, -1, 1,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- ��� ������� - "Single" - ������ ��� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID, N, S, X, Y, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (8, 'OBJECT_KIND',
         '��� ������� - "Single"  - ������ ��� ������',                        
         SP.G.TNote, 0, 'SINGLE', 0, 1, 1, 1,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');

-- ������ ���� ������� - ������ ��� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID, E_VAL, N, R_ONLY, OBJ_ID,
         M_DATE, M_USER)
  VALUES
        (9, 'IS_SYSTEM',
         '������ ���� �������  - ������ ��� ������',                        
         SP.G.TBoolean, 'true', 1, 1, 1,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
--
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID,  E_VAL, N, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (20, 'SP3DTYPE',
         '��� ������� ����������.',                        
         SP.G.TIType, 'notDef', 0, 1, 1,
         to_date('14-02-2018','dd-mm-yyyy'), 'SP');
END;
/ 
--        
-- ��������� ��������� ������� "HierarchiesRoot".
--
BEGIN
-- ��� ������� - ������ ��� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID, S, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (10, 'NAME',
         '��� ���������� ������� - ������ "/".',
         SP.G.TStr4000, '/', 1, 2, 
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- ��� �������� -  ������ ��� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID,  R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (11, 'PARENT',
         '��� �������� - ������ ����.',
         SP.G.TStr4000, 1, 2,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
         
-- ��� ������� - "HierarchiesRoot" - ������ ��� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID,  E_VAL, N, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (12, 'SP3DTYPE',
         '��� ������� - "HierarchiesRoot" - ������ ��� ������',                        
         SP.G.TIType, 'HierarchiesRoot', 42, 1, 2,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- OID -  ������ ��� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID,  R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (13, 'OID',
         '���������� ������������� ��������� �������, ����������� �������� ������.',
         SP.G.TStr4000, 1, 2,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
-- �������� ��� ��������� ������ -  ������ ��� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID,  R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (14, 'HIERARCHY_ROOT_NAME',
         '�������� ��� ��������� �������, ����������� �������� ������. ��� ��������� ������� ������ ����.',
         SP.G.TStr4000, 1, 2,
         to_date('05-01-2014','dd-mm-yyyy'), 'SP');
END;    
/ 
--
-- ��������� ��������� ������� "Native Leaf".
--
BEGIN
-- ��� ������� - ������������ �������� ���� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (15, 'NAME',
         '��� ������� - ������������ �������� ���� ������.',
         SP.G.TStr4000, -1, 4, 
         to_date('10-05-2017','dd-mm-yyyy'), 'SP');
-- ��� �������� - ������������ �������� ���� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID,  R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (16, 'PARENT',
         '��� �������� - ������������ �������� ���� ������.',
         SP.G.TStr4000, -1, 4,
         to_date('10-05-2017','dd-mm-yyyy'), 'SP');
-- ��� ������� - "Single" - ������ ��� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID, N, S, X, Y, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (18, 'OBJECT_KIND',
         '��� ������� - "Single"  - ������ ��� ������',                        
         SP.G.TNote, 0, 'SINGLE', 0, 1, 1, 4,
         to_date('10-05-2017','dd-mm-yyyy'), 'SP');

-- ������ �� ������� - ������ ��� ������.
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID, E_VAL, N, R_ONLY, OBJ_ID,
         M_DATE, M_USER)
  VALUES
        (19, 'IS_SYSTEM',
         '������ ���� �������  - ������ ��� ������',                        
         SP.G.TBoolean, 'false', 0, 1, 4,
         to_date('10-05-2017','dd-mm-yyyy'), 'SP');
--
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID,  E_VAL, N, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (21, 'SP3DTYPE',
         '��� ������� ����������.',                        
         SP.G.TIType, 'notDef', 0, 1, 4,
         to_date('14-02-2018','dd-mm-yyyy'), 'SP');
END;
/         
--    
-- ��������� ��������� ������� "VirtualObject".
--
BEGIN
-- ��� �������
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID, S, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (-1, 'NAME',
         '�������� ������������ ����� ��������.',
         SP.G.TStr4000, '', 1, 3, 
         to_date('05-07-2015','dd-mm-yyyy'), 'SP');
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS, 
         TYPE_ID,  R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (-2, 'PARENT',
         '�������� ������������ ��������.',
         SP.G.TRel, 1, 3,
         to_date('05-07-2015','dd-mm-yyyy'), 'SP');
         
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID,  E_VAL, N, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (-3, 'USING_ROLE',
         '�������� ���������� ������� ���� �������������.',                        
         SP.G.TRole, '', null, 1,3,
         to_date('05-07-2015','dd-mm-yyyy'), 'SP');
         
INSERT INTO SP.OBJECT_PAR_S 
        (ID, NAME,
         COMMENTS,
         TYPE_ID,  E_VAL, N, R_ONLY, OBJ_ID, M_DATE, M_USER)
  VALUES
        (-4, 'EDIT_ROLE',
         '�������� ���������� ������� ���� �������������.',                        
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
  IS '��������� �������, ���������� �������� ����������� �������. (SP-CATALOG.sql)';
  
  
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
  IS '��������� �������, ���������� �������� ��������� �������. (SP-CATALOG.sql)';
  
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
  IS '��������� �������, ���������� �������� �������� �������. (SP-CATALOG.sql)';
  
  
-- end of file
  
