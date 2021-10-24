-- SP Docs
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 07.10.2013
-- update 08.10.2013 10.10.2013 14.06.2014 08.07.2015
--***************************************************************************** 

-- Documents.
-------------------------------------------------------------------------------
CREATE TABLE SP.DOCS( 
  ID NUMBER NOT NULL,
	PREV_ID NUMBER,
  PARAGRAPH VARCHAR2(4000),
  IMAGE_ID NUMBER ,
  FORMAT_ID NUMBER default 0 NOT NULL,
	GROUP_ID NUMBER not null,
	USING_ROLE NUMBER,
  M_DATE DATE,
  M_USER VARCHAR2(60),
	CONSTRAINT PK_DOCS PRIMARY KEY (ID),
	CONSTRAINT CHK_DOCS CHECK (ID!=PREV_ID),
  CONSTRAINT REF_DOCS_INTERNAL
    FOREIGN KEY (PREV_ID) 
    REFERENCES SP.DOCS (ID) ON DELETE SET NULL,
  CONSTRAINT REF_DOCS_to_USING_ROLES 
  FOREIGN KEY (USING_ROLE)
  REFERENCES SP.SP_ROLES (ID) ON DELETE SET NULL,
  CONSTRAINT REF_DOCS_TO_GROUPS
  FOREIGN KEY (GROUP_ID)
  REFERENCES SP.GROUPS (ID)
	);
  
CREATE UNIQUE INDEX SP.DOCS_ORDER ON SP.DOCS(GROUP_ID, PREV_ID);

COMMENT ON TABLE SP.DOCS
  IS '������ �������� ������������� ��������� ������ � ����� �������� ������������� ��������� �� ������ ����. ������ ���������� ������ ����� � ���� ��������� �����������. � ����� ������ ����� ���� ��������� ����������, ��� ��� ���� ��������� ���� �� ����� � ����� ������� �������� ������������������. (SP-DOCS.sql)';

COMMENT ON COLUMN SP.DOCS.ID
  IS '���������� �������������.';
COMMENT ON COLUMN SP.MACROS.PREV_ID
  IS '������ �� ������������� ����������� ���������.';
COMMENT ON COLUMN SP.DOCS.PARAGRAPH
  IS '����� ���������.';
COMMENT ON COLUMN SP.DOCS.IMAGE_ID
  IS '������ �� �����������.';
COMMENT ON COLUMN SP.DOCS.FORMAT_ID
  IS '������ �� ������.';
COMMENT ON COLUMN SP.DOCS.GROUP_ID  IS '������ �� ������.';
COMMENT ON COLUMN SP.DOCS.USING_ROLE 
  IS '����, ������� ������ ����� ������������, ����� ������ ��������. ������������, ������� SP_ADMIN_ROLE, ����� ������ ��. ���� ���� ����, �� �������� ��������.';
COMMENT ON COLUMN SP.DOCS.M_DATE 
  IS '���� �������� ��� ��������� ��������� ���������.';
COMMENT ON COLUMN SP.DOCS.M_USER 
  IS '������������ ��������� ��� ���������� �������� ���������.';

CREATE GLOBAL TEMPORARY TABLE SP.INSERTED_DOCS( 
  NEW_ID NUMBER,
	NEW_PREV_ID NUMBER,
  NEW_PARAGRAPH VARCHAR2(4000),
  NEW_IMAGE_ID NUMBER,
  NEW_FORMAT_ID NUMBER,
	NEW_GROUP_ID NUMBER,
	NEW_USING_ROLE NUMBER,
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.INSERTED_DOCS
  IS '��������� �������, ���������� �������� ����������� �������.(SP-DOCS.sql)';
  
CREATE GLOBAL TEMPORARY TABLE SP.UPDATED_DOCS( 
  NEW_ID NUMBER,
	NEW_PREV_ID NUMBER,
  NEW_PARAGRAPH VARCHAR2(4000),
  NEW_IMAGE_ID NUMBER,
  NEW_FORMAT_ID NUMBER,
	NEW_GROUP_ID NUMBER,
	NEW_USING_ROLE NUMBER,
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60),
  OLD_ID NUMBER,
	OLD_PREV_ID NUMBER,
  OLD_PARAGRAPH VARCHAR2(4000),
  OLD_IMAGE_ID NUMBER,
  OLD_FORMAT_ID NUMBER,
	OLD_GROUP_ID NUMBER,
	OLD_USING_ROLE NUMBER,
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.UPDATED_DOCS
  IS '��������� �������, ���������� �������� ��������� �������.(SP-DOCS.sql)';
  
CREATE GLOBAL TEMPORARY TABLE SP.DELETED_DOCS( 
  OLD_ID NUMBER,
	OLD_PREV_ID NUMBER,
  OLD_PARAGRAPH VARCHAR2(4000),
  OLD_IMAGE_ID NUMBER,
  OLD_FORMAT_ID NUMBER,
	OLD_GROUP_ID NUMBER,
	OLD_USING_ROLE NUMBER,
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.DELETED_DOCS
  IS '��������� �������, ���������� �������� �������� �������.(SP-DOCS.sql)';
 

-- end of file
  
