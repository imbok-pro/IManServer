-- SP Roles
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 05.08.2010  
-- update 10.06.2013 29.01.2015 09.06.2016 08.10.2016 10.10.2016 22.11.2016
--        28.08.2020
--*****************************************************************************

-- ���� ������������� ����������� ���������, �������� ��� ������������ �������
-------------------------------------------------------------------------------
CREATE TABLE SP.SP_ROLES
(
  ID NUMBER,
  NAME VARCHAR2(30)NOT NULL,
  COMMENTS VARCHAR2(4000),
  ORA NUMBER(1) DEFAULT 0 NOT NULL,
  CONSTRAINT PK_SP_ROLES PRIMARY KEY (ID),
  CONSTRAINT CK_ROLES CHECK (ORA in (0,1))
);

CREATE UNIQUE INDEX SP.SP_ROLES_UK ON SP.SP_ROLES(upper(NAME));

COMMENT ON TABLE SP.SP_ROLES IS '����. (SP-ROLES.sql)';

COMMENT ON COLUMN SP.SP_ROLES.ID       IS '������������� ����.';
COMMENT ON COLUMN SP.SP_ROLES.NAME     IS '��� ����.';
COMMENT ON COLUMN SP.SP_ROLES.COMMENTS IS '����������.';
COMMENT ON COLUMN SP.SP_ROLES.ORA IS '�������, ������������, ��� ������ ���� �������� ��� ���� �������. ������ ��������� ������� ������������ ����� �����. ���� �������������� ������������ ���� ������������� ��� ������������� ������� ������ �������� IMan, �� � ���������� ��������� ��� �������� ORA.';

-------------------------------------------------------------------------------
CREATE GLOBAL TEMPORARY TABLE SP.DELETED_SP_ROLES
(
  OLD_ID NUMBER,
  OLD_NAME VARCHAR2(128),
  OLD_COMMENTS VARCHAR2(4000),
  OLD_ORA NUMBER(1)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.DELETED_SP_ROLES
  IS '��������� �������, ���������� �������� �������� �������.(SP-ROLES.sql)';

-------------------------------------------------------------------------------
CREATE GLOBAL TEMPORARY TABLE SP.UPDATED_SP_ROLES
(
  NEW_ID NUMBER,
  NEW_NAME VARCHAR2(128),
  NEW_COMMENTS VARCHAR2(4000),
  NEW_ORA NUMBER(1),
  OLD_ID NUMBER,
  OLD_NAME VARCHAR2(128),
  OLD_COMMENTS VARCHAR2(4000),
  OLD_ORA NUMBER(1)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.UPDATED_SP_ROLES
  IS '��������� �������, ���������� �������� ��������� �������.(SP-ROLES.sql)';


-- ��������� ������� �����,
-- �������� ������� ������������ � ������ �������� ������.
-------------------------------------------------------------------------------
CREATE GLOBAL TEMPORARY TABLE SP.USER_ROLES
(
  ROLE_ID NUMBER,
  ROLE_NAME VARCHAR2(30),
  CONSTRAINT PK_USER_ROLES PRIMARY KEY (ROLE_ID)
) ON COMMIT PRESERVE ROWS;

CREATE UNIQUE INDEX SP.USER_ROLES_UK ON SP.USER_ROLES(ROLE_NAME);


COMMENT ON TABLE SP.USER_ROLES 
  IS '���� �������� ������������. (SP-ROLES.sql)';

COMMENT ON COLUMN SP.USER_ROLES.ROLE_NAME IS '��� ���� ������������.';
COMMENT ON COLUMN SP.USER_ROLES.ROLE_ID   
  IS '������������� ���� ������������.';
  
GRANT SELECT ON SP.USER_ROLES TO PUBLIC;  

-- �������� �����.
-------------------------------------------------------------------------------
CREATE TABLE SP.SP_ROLES_RELS
(
  ID NUMBER,
  ROLE_ID NUMBER NOT NULL,
  GRANTED_ID NUMBER NOT NULL,
  CONSTRAINT PK_SP_ROLES_RELS PRIMARY KEY (ID),
  CONSTRAINT REF_RROLE_TO_ROLES 
  FOREIGN KEY (ROLE_ID)
  REFERENCES SP.SP_ROLES ON DELETE CASCADE,
  CONSTRAINT REF_RGRANTED_TO_ROLES 
  FOREIGN KEY (GRANTED_ID)
  REFERENCES SP.SP_ROLES ON DELETE CASCADE
);

CREATE UNIQUE INDEX SP.SP_ROLES_RELS_UK 
  ON SP.SP_ROLES_RELS(ROLE_ID, GRANTED_ID);
  
CREATE INDEX SP.SP_ROLES_ROLE_ID ON SP.SP_ROLES_RELS(ROLE_ID);
CREATE INDEX SP.SP_ROLES_GRANTED_ID ON SP.SP_ROLES_RELS(GRANTED_ID);

COMMENT ON TABLE SP.SP_ROLES_RELS IS '�������� �����. ���� ��� ���� ���������, �� ����� ����� ��������� � �������. ���� ���� ��������� ���� ������ � ������ ��������� ���� �� ��������, � ����� �������� ����������� �����, �� ����� ����� �� ����� ������������ � �������.  (SP-ROLES.sql)';

COMMENT ON COLUMN SP.SP_ROLES_RELS.ID         IS '������������� �����.';
COMMENT ON COLUMN SP.SP_ROLES_RELS.ROLE_ID    IS '��� ����, ���������� �����.';
COMMENT ON COLUMN SP.SP_ROLES_RELS.GRANTED_ID 
  IS '��� ����, �������������� �����.';

GRANT SELECT, INSERT ON SP.SP_ROLES_RELS TO PUBLIC;
  
-------------------------------------------------------------------------------
CREATE GLOBAL TEMPORARY TABLE SP.INSERTED_SP_ROLES_RELS
(
  NEW_ID NUMBER,
  NEW_ROLE_ID NUMBER,
  NEW_GRANTED_ID NUMBER
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.INSERTED_SP_ROLES_RELS
  IS '��������� �������, ���������� �������� ����������� �������.(SP-ROLES.sql)';

---------------------------------------------------------------------------------
--CREATE GLOBAL TEMPORARY TABLE SP.UPDATED_SP_ROLES_RELS
--(
--  NEW_ID NUMBER,
--  NEW_ROLE_ID NUMBER,
--  NEW_GRANTED_ID NUMBER,
--  OLD_ID NUMBER,
--  OLD_ROLE_ID NUMBER,
--  OLD_GRANTED_ID NUMBER
--)
--ON COMMIT DELETE ROWS;
--
--COMMENT ON TABLE SP.UPDATED_SP_ROLES_RELS
--  IS '��������� �������, ���������� �������� ��������� �������.(SP-ROLES.sql)';

-------------------------------------------------------------------------------
CREATE GLOBAL TEMPORARY TABLE SP.DELETED_SP_ROLES_RELS
(
  OLD_ID NUMBER,
  OLD_ROLE_ID NUMBER,
  OLD_GRANTED_ID NUMBER
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.DELETED_SP_ROLES_RELS
  IS '��������� �������, ���������� �������� �������� �������.(SP-ROLES.sql)';
  
-------------------------------------------------------------------------------
DECLARE
tmp VARCHAR2(4000);
SP_USER_ROLE NUMBER;
SP_ADMIN_ROLE NUMBER;
BEGIN
  SP_USER_ROLE:=SP.G.USER_ROLE;
  SP_ADMIN_ROLE:=0;
    tmp:='���� �������� ������������';
  INSERT INTO SP.SP_ROLES
    VALUES(SP_USER_ROLE,'SP_USER_ROLE',tmp,1);
    tmp:='���� ��������������';
  INSERT INTO SP.SP_ROLES
    VALUES(SP_ADMIN_ROLE,'SP_ADMIN_ROLE',tmp,1);
END;	
/

DECLARE
  tmpVar NUMBER;
BEGIN
  SELECT COUNT(*)INTO tmpVar FROM dual WHERE EXISTS 
  (SELECT * FROM DBA_ROLES WHERE ROLE='SP_USER_ROLE');
  IF tmpVar=0 THEN 
    EXECUTE IMMEDIATE('
      CREATE ROLE "SP_USER_ROLE" NOT IDENTIFIED;
    ');
  END IF;
END;
/

DECLARE
  tmpVar NUMBER;
BEGIN
  SELECT COUNT(*)INTO tmpVar FROM dual WHERE EXISTS 
  (SELECT * FROM DBA_ROLES WHERE ROLE='SP_ADMIN_ROLE');
  IF tmpVar=0 THEN 
    EXECUTE IMMEDIATE('
      CREATE ROLE "SP_ADMIN_ROLE" NOT IDENTIFIED;
    ');
  END IF;
END;
/


-- ��������������� ��������� ������� �����.
-------------------------------------------------------------------------------
CREATE GLOBAL TEMPORARY TABLE SP.NAMES
(
NAME VARCHAR2(4000)
) ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.NAMES 
  IS '��������������� ��������� ������� �����. (SP-ROLES.sql)';

COMMENT ON COLUMN SP.NAMES.NAME IS '���.';
  
GRANT SELECT ON SP.NAMES TO PUBLIC;  

-- end of file
