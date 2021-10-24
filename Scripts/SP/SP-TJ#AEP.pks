CREATE OR REPLACE PACKAGE SP.TJ#AEP
-- TJ ������ �� ������������� ����� ��� ���
-- by AM
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2020-12-21
-- update 2020-12-23 2020-12-24 2021-01-04 2021-01-13 2021-01-14 2021-01-15
--        2021-01-22 2021-01-26 2021-02-12 2021-02-15
--        2021-03-23 2021-03-25 2021-03-26 2021-03-29 2021-03-30
-- By Nikolay Krasilnikov       18-06-2021
--        
-- (SP.TJ#AEP.pks)
AS
-- ������ (������) ������� ������ ���������� ���������� ������� ���
Type R_CAB_JOURNAL Is Record
(
    -- ����� ������� ����
    "PROJECT" VARCHAR2 (128),
    -- ����� ���������� �������
    "CABLE LOG" VARCHAR2 (128),
    -- KKS (����������) ������
    "CABLE MARK" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- ��� (�����) ������
    "TYPE" VARCHAR2 (40),
    -- ����� ��� ������
    "CORE NUMBER" NUMBER,
    -- ������� ���� ������
    "CORE SECTION" NUMBER,
    -- ����������� ���������� ������
    "VOLTAGE" NUMBER,
    -- ����� ����������� �������
    "TU" VARCHAR2 (128),
    -- ����� ������������
    "CLASS" VARCHAR2 (40),
    -- ����� � ��������� �������
    "CABLE NUMBER" VARCHAR2 (40),
    -- ������ ���������
    "GROUP R" VARCHAR2 (40),
    -- ������� ������
    "DIAMETER" NUMBER,
    -- KKS ������
    "FROM KKS" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- ���������� X ������
    "FROM X" NUMBER,
    -- ���������� Y ������
    "FROM Y" NUMBER,
    -- ���������� Z ������
    "FROM Z" NUMBER,
    -- ������� ������
    "FROM ZRel" VARCHAR2 (40),
    -- ����� �� �������� � ������
    "FROM LAdd" NUMBER,
    -- ����� ������������ ������
    "FROM SYS" VARCHAR2 (40),
    -- KKS ������ ������
    "FROM BUILDING" VARCHAR2 (40),
    -- KKS ��������� ������
    "FROM ROOM" VARCHAR2 (128),
    -- ������������ ������������ ������
    "FROM NAME" VARCHAR2 (128),
    -- ������������ ������������ ������ �� ���������
    "FROM NAME ENG" VARCHAR2 (128),
    -- KKS �����
    "TO KKS" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- ���������� X �����
    "TO X" NUMBER,
    -- ���������� Y �����
    "TO Y" NUMBER,
    -- ���������� Z �����
    "TO Z" NUMBER,
    -- ������� �����
    "TO ZRel" VARCHAR2 (40),
    -- ����� �� �������� � �����
    "TO LAdd" NUMBER,
    -- ����� ������������ �����
    "TO SYS" VARCHAR2 (40),
    -- KKS ������ �����
    "TO BUILDING" VARCHAR2 (40),
    -- KKS ��������� �����
    "TO ROOM" VARCHAR2 (128),
    -- ������������ ������������ �����
    "TO NAME" VARCHAR2 (128),
    -- ������������ ������������ ����� �� ���������
    "TO NAME ENG" VARCHAR2 (128),
    -- ����� ������
    "LENGTH" NUMBER,
    -- �������� �������������������� �������
    "REDUNDANCY" VARCHAR2 (40),
    -- ������
    "ROUTE" VARCHAR2 (512),
    -- ����� ������������ ������
    "CABLE SYS" VARCHAR2 (40),
    -- ����������
    "NOTE" VARCHAR2 (128),
    -- ���������� �� ���������
    "NOTE ENG" VARCHAR2 (128),
    -- ������������
    "SPEC" VARCHAR2 (128)
);

-- ������ (������) ���������� ������� �� ������� Access
Type R_CAB_JOURNAL_ACCESS Is Record
(
    -- ����� ������� ����
    "PROJECT" VARCHAR2 (128),
    -- ����� ���������� �������
    "CABLE LOG" VARCHAR2 (128),
    -- KKS (����������) ������
    "CABLE MARK" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- ��� (�����) ������
    "TYPE" VARCHAR2 (40),
    -- ����� ��� � ������� ������
    "CROSS-SECTION" VARCHAR2 (40),
    -- ����������� ���������� ������
    "VOLTAGE" NUMBER,
    -- ����� ����������� �������
    "TU" VARCHAR2 (128),
    -- ����� ������������
    "CLASS" VARCHAR2 (40),
    -- ����� � ��������� �������
    "CABLE NUMBER" VARCHAR2 (40),
    -- ������ ���������
    "GROUP R" VARCHAR2 (40),
    -- ������� ������
    "DIAMETER" NUMBER,
    -- KKS ������
    "FROM KKS" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- ���������� X ������
    "FROM X" NUMBER,
    -- ���������� Y ������
    "FROM Y" NUMBER,
    -- ���������� Z ������
    "FROM Z" NUMBER,
    -- ������� ������
    "FROM ZRel" VARCHAR2 (40),
    -- ����� �� �������� � ������
    "FROM LAdd" NUMBER,
    -- ����� ������������ ������
    "FROM SYS" VARCHAR2 (40),
    -- KKS ������ ������
    "FROM BUILDING" VARCHAR2 (40),
    -- KKS ��������� ������
    "FROM ROOM" VARCHAR2 (128),
    -- ������������ ������������ ������
    "FROM NAME" VARCHAR2 (128),
    -- ������������ ������������ ������ �� ���������
    "FROM NAME ENG" VARCHAR2 (128),
    -- KKS �����
    "TO KKS" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- ���������� X �����
    "TO X" NUMBER,
    -- ���������� Y �����
    "TO Y" NUMBER,
    -- ���������� Z �����
    "TO Z" NUMBER,
    -- ������� �����
    "TO ZRel" VARCHAR2 (40),
    -- ����� �� �������� � �����
    "TO LAdd" NUMBER,
    -- ����� ������������ �����
    "TO SYS" VARCHAR2 (40),
    -- KKS ������ �����
    "TO BUILDING" VARCHAR2 (40),
    -- KKS ��������� �����
    "TO ROOM" VARCHAR2 (128),
    -- ������������ ������������ �����
    "TO NAME" VARCHAR2 (128),
    -- ������������ ������������ ����� �� ���������
    "TO NAME ENG" VARCHAR2 (128),
    -- ����� ������
    "LENGTH" NUMBER,
    -- �������� �������������������� �������
    "REDUNDANCY" VARCHAR2 (40),
    -- ������
    "ROUTE" VARCHAR2 (512),
    -- ����� ������������ ������
    "CABLE SYS" VARCHAR2 (40),
    -- ����������
    "NOTE" VARCHAR2 (128),
    -- ���������� �� ���������
    "NOTE ENG" VARCHAR2 (128),
    -- ������������
    "SPEC" VARCHAR2 (128)
);

-- ������ (������) ���������� ������� �� ������� Word 
Type R_CAB_JOURNAL_WORD Is Record
(
    -- ����� � ��������� �������
    "CABLE NUMBER" VARCHAR2 (40),
    -- KKS (����������) ������
    "CABLE MARK" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- ��� (�����) ������
    "TYPE" VARCHAR2 (40),
    -- ��� (�����) ������ ����������
    "TYPE TRANS" VARCHAR2 (40),
    -- ����� ��� � ������� ������
    "CROSS-SECTION" VARCHAR2 (40),
    -- ������ ���������
    "GROUP R" VARCHAR2 (40),
    -- ����� ������������
    "CLASS" VARCHAR2 (40),
    -- KKS ������
    "FROM KKS" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- ���������� X ������
    "FROM X" NUMBER,
    -- ���������� Y ������
    "FROM Y" NUMBER,
    -- ���������� Z ������
    "FROM Z" NUMBER,
    -- KKS ������ ������
    "FROM BUILDING" VARCHAR2 (40),
    -- KKS ��������� ������
    "FROM ROOM" VARCHAR2 (128),
    -- ������������ ������������ ������
    "FROM NAME" VARCHAR2 (128),
    -- ������������ ������������ ������ �� ���������
    "FROM NAME ENG" VARCHAR2 (128),
    -- KKS �����
    "TO KKS" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- ���������� X �����
    "TO X" NUMBER,
    -- ���������� Y �����
    "TO Y" NUMBER,
    -- ���������� Z �����
    "TO Z" NUMBER,
    -- KKS ������ �����
    "TO BUILDING" VARCHAR2 (40),
    -- KKS ��������� �����
    "TO ROOM" VARCHAR2 (128),
    -- ������������ ������������ �����
    "TO NAME" VARCHAR2 (128),
    -- ������������ ������������ ����� �� ���������
    "TO NAME ENG" VARCHAR2 (128),
    -- ����� ������
    "LENGTH" NUMBER,
    -- ������
    "ROUTE" VARCHAR2 (512),
    -- ��� ������ ����
    "COMMON BOARD" VARCHAR2 (40),
    -- ��� ������ ���� ENG
    "COMMON BOARD ENG" VARCHAR2 (40),
    -- ����������
    "NOTE" VARCHAR2 (128)
);

-- ������ (������) ������� ����������� ������� (�������� �������) ��� ������� Word
Type R_CAB_DEMAND Is Record
(
    -- ��� (�����) ������
    "TYPE" VARCHAR2 (40),
    -- ��� (�����) ������ ����������
    "TYPE TRANS" VARCHAR2 (40),
    -- ����� ��� � ������� ������
    "CROSS-SECTION" VARCHAR2 (40),
    -- ����������� ���������� ������
    "VOLTAGE" VARCHAR2 (40),
    -- ����� ������
    "LENGTH" NUMBER,
    -- ������� �������������
    "METALHOSE DIAMETER" NUMBER,
    -- ����� �������������
    "METALHOSE LENGTH" NUMBER,
    -- ���������� ��������� ��������
    "CABLE TERMINATIONS" NUMBER,
    -- ���������� ������� ������ �����, ������� � ����������
    "CABLE COUNT" NUMBER
);

-- ������ (������) ������� ������ ��� ���������� ��������� ������ � ���������
Type R_DEVICE_XYZ Is Record
(
    "ID ����������" NUMBER,
    "KKS ����������" VARCHAR2 (40),
    "���������" VARCHAR2 (128),
    "������������ ����������" VARCHAR2 (128),
    "X" NUMBER,
    "Y" NUMBER,
    "Z" NUMBER
);

-- ������ (������) ������� ������� ��� ���������� ����� � ������
Type R_CAB_LENGTH Is Record
(
    "ID ������" NUMBER,
    "KKS ������" VARCHAR2 (40),
    "����� ������" VARCHAR2 (40),
    "������� ������" NUMBER,
    "������ KKS" VARCHAR2 (40),
    "������ ���." VARCHAR2 (128),
    "������ ������������" VARCHAR2 (128),
    "������ X" NUMBER,
    "������ Y" NUMBER,
    "������ Z" NUMBER,
    "���� KKS" VARCHAR2 (40),
    "���� ���." VARCHAR2 (128),
    "���� ������������" VARCHAR2 (128),
    "���� X" NUMBER,
    "���� Y" NUMBER,
    "���� Z" NUMBER,
    "�����" NUMBER,
    "������" VARCHAR2 (512)
);

-- ������ (������) ���������� ���������� �������, ������� ������������� ������������ ������ ������ � ������������ ������� � TJ
Type R_UPDATE_TJ Is Record
(
    -- ����� ������������
    "CLASS" VARCHAR2 (40),
    -- ����� � ��������� �������
    "CABLE NUMBER" VARCHAR2 (40),
    -- ������ ���������
    "GROUP R" VARCHAR2 (40),
    -- ����� ������������ ������
    "FROM SYS" VARCHAR2 (40),
    -- ����� ������������ �����
    "TO SYS" VARCHAR2 (40),
    -- ����� ������������ ������
    "CABLE SYS" VARCHAR2 (40)  
);

-- ��������� ������ (������� ���� ����������)
Type T_CAB_JOURNAL Is Table Of R_CAB_JOURNAL;

-- ��������� ������ Access (�������)
Type T_CAB_JOURNAL_ACCESS Is Table Of R_CAB_JOURNAL_ACCESS;

-- ��������� ������ Word (�������)
Type T_CAB_JOURNAL_WORD Is Table Of R_CAB_JOURNAL_WORD;

-- ������� ����������� ������� ��� ������� Word
Type T_CAB_DEMAND Is Table Of R_CAB_DEMAND;

-- ������� ��������� ������ � ���������
Type T_DEVICE_XYZ Is Table Of R_DEVICE_XYZ;

-- ������� ���� � ����� �������
Type T_CAB_LENGTH Is Table Of R_CAB_LENGTH;

-- ������� ���������� ������� ������������� ������������ � ������������ ������� � TJ
Type T_UPDATE_TJ Is Table Of R_UPDATE_TJ;
--==============================================================================
--������� ������������ ���������� �������
--��� ������ WorkID$ ���������� ������� ���������� �������
--���������:
--������ ID ������ ����� ������ ID ������ ������� �������, �������� �������� � 
--�������� �������� ������ 
--����� ������� ��� ���������� ��������� ��� ��������������� ���������� �����
--����� ������������ �������

Function V_CAB_JOURNAL(WorkID$ In Number default null) 
Return  T_CAB_JOURNAL Pipelined;

Function V_CAB_JOURNAL_ACCESS(WorkID$ In Number default null) 
Return  T_CAB_JOURNAL_ACCESS Pipelined;

Function V_CAB_JOURNAL_WORD(WorkID$ In Number default null) 
Return  T_CAB_JOURNAL_WORD Pipelined;

Function V_CAB_DEMAND(WorkID$ In Number default null) 
Return  T_CAB_DEMAND Pipelined;

Function V_DEVICE_XYZ(WorkID$ In Number default null) 
Return  T_DEVICE_XYZ Pipelined;

Function V_CAB_LENGTH(WorkID$ In Number default null) 
Return  T_CAB_LENGTH Pipelined;

Procedure UPDATE_TJ(WorkID$ In Number default null);

Function AnalysisCabLength(LENGTH$ in out VARCHAR2) Return BOOLEAN;

end TJ#AEP;

/*
ID Work 30UPX ��� - 3658355200
ID Work 30UQA ��� - 3678514900
ID Work 31,32UQC ��� - 3678519300

ID Work 30UQA ������� ������ - 3694932200

SELECT * FROM TABLE(SP.TJ#AEP.V_CAB_JOURNAL(WorkID$ => 3658355200 ))
SELECT * FROM TABLE(SP.TJ#AEP.V_CAB_JOURNAL_ACCESS(WorkID$ => 3658355200 ))
SELECT * FROM TABLE(SP.TJ#AEP.V_CAB_JOURNAL_WORD(WorkID$ => 3658355200 ))
SELECT * FROM TABLE(SP.TJ#AEP.V_CAB_DEMAND(WorkID$ => 3658355200 ))
SELECT * FROM TABLE(SP.TJ#AEP.V_DEVICE_XYZ(WorkID$ => 3658355200 ))
SELECT * FROM TABLE(SP.TJ#AEP.V_CAB_LENGTH(WorkID$ => 3658355200 ))

declare
WID NUMBER;
begin
WID := 3658355200;
SP.TJ#AEP.UPDATE_TJ(WID);
end;

declare
LENGTH$ VARCHAR2 (40);
r# VARCHAR2 (40);
a BINARY_INTEGER;
b BINARY_INTEGER;
begin
LENGTH$ := '*';
if INSTR(LENGTH$, '*', 1, 1) = 0 then
    a := 1;
    DBMS_OUTPUT.put_line(a);
    o(a);
    DBMS_OUTPUT.put_line(LENGTH$);
  else
    r# := SUBSTR(LENGTH$, 1, INSTR(LENGTH$,'*',1,1)-1);
    LENGTH$ := r#;
    b := 2;
    DBMS_OUTPUT.put_line(b);
    DBMS_OUTPUT.put_line('['||LENGTH$||']');
  end if;
end;
*/