CREATE OR REPLACE PACKAGE SP.RGM
-- ������
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2018-03-01
-- update 2018-03-05 2018-03-13

AS
--==============================================================================
--����� ������
Type TGROUND_SAMPLE_REC is record
(
--ID �����
SAMPLE_ID NUMBER,
SAMPLE_NAME Varchar2(128),
PIKET_ID Number,
PIKET_NAME Varchar2(64),
SAMPLE_DATE DATE,
Location Varchar2(4000),
---------------------------
X Number,
Y Number,
Z Number,
---------------------------
Ro Number,
Rod Number,
W Number,
Ws Number,
---------------------------
"�������_1" Number,
"�������_2" Number,
"�������_3" Number,
"�������_4" Number,
"�������_5" Number,
---------------------------
"��� ������" Varchar2(128),
"��_�����" Varchar2(128),
Remarks Varchar2(4000)
);

--������� ���� ������
Type TGROUND_SAMPLES is table of TGROUND_SAMPLE_REC;
--==============================================================================

--���������� ��� ����������� �� ��������� � ���� MODEL_OBJ_ID$ ����� ������
Function GetAllGroundSamples(MODEL_OBJ_ID$ In Number) 
Return RGM.TGROUND_SAMPLES Pipelined;

/*
--������� �������������
SELECT * FROM TABLE(SP.RGM.GetAllGroundSamples(548556600));

SELECT DISTINCT "��_�����" FROM TABLE(SP.RGM.GetAllGroundSamples(548556600))
ORDER BY "��_�����";

*/

--==============================================================================
-- ����� �������� ������� ROOT_OBJ_ID$ ������� ������ ���������� �����  
-- � ������ MOD_OBJ_NAME$ � ���������� � �������� �����.
-- ���� �� �������, ���������� Null. 
Function GetSampleInputNum(ROOT_OBJ_ID$ In Number, MOD_OBJ_NAME$ In Varchar2) 
Return Varchar2;

--==============================================================================
-- ����� �������� ������� ROOT_OBJ_ID$ ������� ������ ���������� �����  
-- � ������ MOD_OBJ_NAME$ � ���������� � ID.
-- ���� �� �������, ���������� Null. 
Function GetSampleID(ROOT_OBJ_ID$ In Number, MOD_OBJ_NAME$ In Varchar2) 
Return Number;

--==============================================================================
--���������� ����� ���������� ����������� ����� ������
Function GetSampleParNames Return SP.G.TSNAMES;

--==============================================================================
-- ����� �������� ������� ROOT_OBJ_ID$ ������� ������ ����������� ������  
-- � ������ '����' � ���������� ��� ID.
-- ���� �� �������, ���������� Null. 
Function GetTrashID(ROOT_OBJ_ID$ In Number) Return Number;
--==============================================================================


end RGM;