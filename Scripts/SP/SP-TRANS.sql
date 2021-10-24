-- SP TRANS
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 21.08.2014
-- update 22.08.2014-25.08.2014
--*****************************************************************************

-- ������� ����������.
-------------------------------------------------------------------------------
CREATE TABLE SP.TRANS
(
  ID NUMBER,
  D DATE NOT NULL,
  BLOCK_ID NUMBER,
  BUH_ID NUMBER NOT NULL,
  S NUMBER DEFAULT 0 NOT NULL,
  N NUMBER DEFAULT 0 NOT NULL,
  A_DEBET NUMBER,
  C_DEBET NUMBER NOT NULL,
  A_CREDIT NUMBER,
  C_CREDIT NUMBER NOT NULL,
  MACRO NUMBER,
  COMMENTS VARCHAR2(4000) NOT NULL,
  VALIDATED DATE,
  M_DATE DATE NOT NULL,
  M_USER VARCHAR2(60) NOT NULL,
  CONSTRAINT PK_TRANS PRIMARY KEY (ID),
  CONSTRAINT REF_TRANS_TO_BUH
    FOREIGN KEY (BUH_ID)
    REFERENCES SP.MODELS (ID),
  CONSTRAINT REF_TRANS_TO_A_DEBET
    FOREIGN KEY (A_DEBET)
    REFERENCES SP.MODEL_OBJECTS (ID),
  CONSTRAINT REF_TRANS_TO_C_DEBET
    FOREIGN KEY (C_DEBET)
    REFERENCES SP.MODEL_OBJECTS (ID),
  CONSTRAINT REF_TRANS_TO_A_CREDIT
    FOREIGN KEY (A_CREDIT)
    REFERENCES SP.MODEL_OBJECTS (ID),
  CONSTRAINT REF_TRANS_TO_C_CREDIT
    FOREIGN KEY (C_CREDIT)
    REFERENCES SP.MODEL_OBJECTS (ID),
  CONSTRAINT REF_TRANS_TO_MACRO
    FOREIGN KEY (MACRO)
    REFERENCES SP.OBJECTS (ID)
);

--CREATE UNIQUE INDEX SP.TRANS ON SP.TRANS (UPPER(NAME));

COMMENT ON TABLE SP.TRANS IS '������ �������� (����������).';

COMMENT ON COLUMN SP.TRANS.ID IS '������������� ��������.';
COMMENT ON COLUMN SP.TRANS.D IS '���� ����������  ����������. ��� ������� ��� ���� �� ��������� � ����� ��������� ��������.';
COMMENT ON COLUMN SP.TRANS.BLOCK_ID IS '������������� ����� ��������. ��������� �������� ����� ���������� � ���������� ����.';
COMMENT ON COLUMN SP.TRANS.BUH_ID IS '������������� �����������. ������������� ������, ���������� ���� ������ ��� ������ �����������.';
COMMENT ON COLUMN SP.TRANS.S IS '����� ��������.';
COMMENT ON COLUMN SP.TRANS.N IS '����������.';
COMMENT ON COLUMN SP.TRANS.A_DEBET IS '������ �� ������ ������.';
COMMENT ON COLUMN SP.TRANS.C_DEBET IS '������ �� ����������� ������.';
COMMENT ON COLUMN SP.TRANS.A_CREDIT IS '������ �� ������ �������.';
COMMENT ON COLUMN SP.TRANS.C_CREDIT IS '������ �� ����������� �������.';
COMMENT ON COLUMN SP.TRANS.MACRO IS '������ �� �������������, ��������� ���� ���� ��������.';
COMMENT ON COLUMN SP.TRANS.COMMENTS IS '���������� � ��������.';
COMMENT ON COLUMN SP.TRANS.VALIDATED IS '���� ������������ ������� ����� ��������. ���������� �� ���� ��������, ���� ��� ������������ ���������� ������������ ��������: ����, ��� ...';
COMMENT ON COLUMN SP.TRANS.M_DATE 
  IS '���� ��������� ��� ��������� ������ �������� � �������.';
COMMENT ON COLUMN SP.TRANS.M_USER 
  IS '������������ ��������� ������ ��� ���������� ��������.';

--INSERT INTO SP.TRANS VALUES(0,....
--  to_date('05-01-2014','dd-mm-yyyy'), 'SP');

CREATE GLOBAL TEMPORARY TABLE SP.INSERTED_TRANS
(  
  NEW_ID NUMBER,
  NEW_D DATE,
  NEW_BLOCK_ID NUMBER,
  NEW_BUH_ID NUMBER,
  NEW_S NUMBER,
  NEW_N NUMBER,
  NEW_A_DEBET NUMBER,
  NEW_C_DEBET NUMBER,
  NEW_A_CREDIT NUMBER,
  NEW_C_CREDIT NUMBER,
  NEW_MACRO NUMBER,
  NEW_COMMENTS VARCHAR2(4000),
  NEW_VALIDATED DATE,
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.INSERTED_TRANS
  IS '��������� �������, ���������� �������� ����������� �������.';

CREATE GLOBAL TEMPORARY TABLE SP.UPDATED_TRANS
(
  NEW_ID NUMBER,
  NEW_D DATE,
  NEW_BLOCK_ID NUMBER,
  NEW_BUH_ID NUMBER,
  NEW_S NUMBER,
  NEW_N NUMBER,
  NEW_A_DEBET NUMBER,
  NEW_C_DEBET NUMBER,
  NEW_A_CREDIT NUMBER,
  NEW_C_CREDIT NUMBER,
  NEW_MACRO NUMBER,
  NEW_COMMENTS VARCHAR2(4000),
  NEW_VALIDATED DATE,
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60),
  OLD_ID NUMBER,
  OLD_D DATE,
  OLD_BLOCK_ID NUMBER,
  OLD_BUH_ID NUMBER,
  OLD_S NUMBER,
  OLD_N NUMBER,
  OLD_A_DEBET NUMBER,
  OLD_C_DEBET NUMBER,
  OLD_A_CREDIT NUMBER,
  OLD_C_CREDIT NUMBER,
  OLD_MACRO NUMBER,
  OLD_COMMENTS VARCHAR2(4000),
  OLD_VALIDATED DATE,
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;
COMMENT ON TABLE SP.UPDATED_TRANS
  IS '��������� �������, ���������� �������� ��������� �������.';
  
CREATE GLOBAL TEMPORARY TABLE SP.DELETED_TRANS
(
  OLD_ID NUMBER,
  OLD_D DATE,
  OLD_BLOCK_ID NUMBER,
  OLD_BUH_ID NUMBER,
  OLD_S NUMBER,
  OLD_N NUMBER,
  OLD_A_DEBET NUMBER,
  OLD_C_DEBET NUMBER,
  OLD_A_CREDIT NUMBER,
  OLD_C_CREDIT NUMBER,
  OLD_MACRO NUMBER,
  OLD_COMMENTS VARCHAR2(4000),
  OLD_VALIDATED DATE,
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;
COMMENT ON TABLE SP.DELETED_TRANS
  IS '��������� �������, ���������� �������� �������� �������.';


-- ������. 
CREATE GLOBAL TEMPORARY TABLE SP.OBOROT
(
  ID NUMBER,
  D DATE,
  BLOCK_ID NUMBER,
  S_DEBET NUMBER,
  S_CREDIT NUMBER,
  S_SALDO NUMBER,
  N_DEBET NUMBER,
  N_CREDIT NUMBER,
  N_SALDO NUMBER,
  ACCOUNT NUMBER,
  ACCOUNT_NAME VARCHAR2(4000),
  ACCOUNT_FULL_NAME VARCHAR2(4000),
  ACCOUNT_NUMBER_NAME VARCHAR2(4000),
  CONTRACTOR NUMBER,
  CONTRACTOR_NAME VARCHAR2(4000),
  MACRO NUMBER,
  MACRO_NAME VARCHAR2(4000),
  COMMENTS VARCHAR2(4000),
  VALIDATED DATE,
  MODIFIED VARCHAR2(128),
  M_DATE DATE,
  M_USER VARCHAR2(60)
)
ON COMMIT PRESERVE ROWS;

COMMENT ON TABLE SP.OBOROT
  IS '��������� �������, ���������� �������� �������� �� ������ ���� ����� ��� �������� � ������������ ��������� ������ ����� ������ ��������. ������� ������������ ��� ��������� �������� �� ������ ���� �����.';

COMMENT ON COLUMN SP.OBOROT.ID IS '������������� ��������.';
COMMENT ON COLUMN SP.OBOROT.D IS '���� ��������.';
COMMENT ON COLUMN SP.OBOROT.BLOCK_ID IS '������������� ����� ��������, �������� ����������� ������ ��������.';
COMMENT ON COLUMN SP.OBOROT.S_DEBET IS '����� ������. ��� ���� ��� ���������� ��������.';
COMMENT ON COLUMN SP.OBOROT.S_CREDIT IS '����� ������� ��� ���� ��� ��������� ��������.';
COMMENT ON COLUMN SP.OBOROT.S_SALDO IS '��������� ������ (����� ���������� ������� ��������).';
COMMENT ON COLUMN SP.OBOROT.N_DEBET IS '����� ���������� ��� ����, ���� ���������� �����������.';
COMMENT ON COLUMN SP.OBOROT.N_CREDIT IS '������ ���������� ��� ����, ���� ���������� ����������.';
COMMENT ON COLUMN SP.OBOROT.N_SALDO IS '��������� ������ �� ���������� (����� ���������� ������� ��������).';
COMMENT ON COLUMN SP.OBOROT.ACCOUNT IS '������ �� ����������������� ���� ��� ������ ��������.';
COMMENT ON COLUMN SP.OBOROT.ACCOUNT_NAME IS '��� ������� - ������������������ �����.';
COMMENT ON COLUMN SP.OBOROT.ACCOUNT_FULL_NAME IS '������ ��� ����� ����� - ������ ���� ������� ����� �� ����� ������ ���������� ���� ������ �����������, ������� ����������� ��������.';
COMMENT ON COLUMN SP.OBOROT.ACCOUNT_NUMBER_NAME IS '���� ������� �����, �� ���������� ��� ������ ������������ �������, � �� ��� ������������ ������. ��. ����������� � ���� "ACCOUNT_NAME"';
COMMENT ON COLUMN SP.OBOROT.CONTRACTOR IS '������ �� ����������� �������������� �����.';
COMMENT ON COLUMN SP.OBOROT.CONTRACTOR_NAME IS '��� ������� ����������� �������������� �����.';
COMMENT ON COLUMN SP.OBOROT.MACRO IS '������ �� �������������, ��������� ��� ����������.';
COMMENT ON COLUMN SP.OBOROT.MACRO_NAME IS '������ ��� �������������, ��������� ��� ����������.';
COMMENT ON COLUMN SP.OBOROT.COMMENTS IS '���������� � ����������.';
COMMENT ON COLUMN SP.OBOROT.VALIDATED IS '���� ������������.';
COMMENT ON COLUMN SP.OBOROT.MODIFIED IS '������� ��������� ������ �� ��������� �������. ���� �������� ��������� �������� ���� modified.';
COMMENT ON COLUMN SP.OBOROT.M_DATE 
  IS '���� ��������� ��� ��������� ������ �������� � �������.';
COMMENT ON COLUMN SP.OBOROT.M_USER 
  IS '������������ ��������� ������ ��� ���������� ��������.';

-- ��������� ����������.
CREATE GLOBAL TEMPORARY TABLE SP.TRANS_DOC_S
(
  TRANS_ID NUMBER,
  BLOCK_ID NUMBER,
  DOC_ID NUMBER
)
ON COMMIT PRESERVE ROWS;

COMMENT ON TABLE SP.TRANS_DOC_S
  IS '��������� �������, ���������� �������� ����������, ������������ � ������ ��������.';

-- ������.
CREATE GLOBAL TEMPORARY TABLE SP.BALANS
(
  ACCOUNT_ID NUMBER,
  ACCOUNT_NAME VARCHAR2(4000),
  ACCOUNT_NUMBER NUMBER(5),
  CONTRACTOR NUMBER,
  CONTRACTOR_NAME VARCHAR2(4000),
  PARENT_ACCOUNT NUMBER,
  S_DEBET NUMBER,
  S_CREDIT NUMBER,
  S_SALDO_IN NUMBER,
  S_SALDO_OUT NUMBER,
  N_DEBET NUMBER,
  N_CREDIT NUMBER,
  N_SALDO_IN NUMBER,
  N_SALDO_OUT NUMBER
)
ON COMMIT PRESERVE ROWS;

COMMENT ON TABLE SP.BALANS
  IS '��������� �������, ���������� ������ ������ � ������������ ��������� ������� � ������ �� ������� ����� � �����������.';

COMMENT ON COLUMN SP.BALANS.ACCOUNT_ID IS '������ �� ����.';
COMMENT ON COLUMN SP.BALANS.ACCOUNT_NAME IS '��� ������� - �����.';
COMMENT ON COLUMN SP.BALANS.ACCOUNT_NUMBER IS '�������� �������� "����� �����" ��� ������� ������� ����.';
COMMENT ON COLUMN SP.BALANS.CONTRACTOR IS '������ �� ����������� �������������� �����.';
COMMENT ON COLUMN SP.BALANS.CONTRACTOR_NAME IS '��� ������� ����������� �������������� �����.';
COMMENT ON COLUMN SP.BALANS.PARENT_ACCOUNT IS '������ �� ����, �������� �������� �������� ������ ����.';
COMMENT ON COLUMN SP.BALANS.S_DEBET IS '������. ������ �� ������.';
COMMENT ON COLUMN SP.BALANS.S_CREDIT IS '������. ������ �� �������.';
COMMENT ON COLUMN SP.BALANS.S_SALDO_IN IS '������. �������� ������.';
COMMENT ON COLUMN SP.BALANS.S_SALDO_OUT IS '������. ��������� ������.';
COMMENT ON COLUMN SP.BALANS.N_DEBET IS '����������. ������ �� ������.';
COMMENT ON COLUMN SP.BALANS.N_CREDIT IS '����������. ������ �� �������.';
COMMENT ON COLUMN SP.BALANS.N_SALDO_IN IS '����������. �������� ������.';
COMMENT ON COLUMN SP.BALANS.N_SALDO_OUT IS '����������. ��������� ������.';

-- end of file
  