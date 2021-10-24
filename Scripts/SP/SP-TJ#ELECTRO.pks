CREATE OR REPLACE PACKAGE SP.TJ#ELECTRO
-- TJ ������ �� ������������� �����
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2020-12-07
-- update 2020-12-08:2020-12-15:2020-12-19:2020-12-28

AS
--������ (������) ���������� �������.  
Type R_CAB_JOURNAL Is Record
(
    CABLE_ID NUMBER,
    -- KKS ������    
    CABLE_NAME SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    FROM_DEVICE_ID NUMBER,
    --KKS ����������
    FROM_DEVICE_NAME SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    FROM_LOCATION_ID NUMBER,
    -- KKS �����
    FROM_LOCATION_NAME SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- Location Properties ID - ������ �� ������������, � ������� �������� 
    -- �������� �����
    FROM_LOCPROP_ID NUMBER,
    TO_DEVICE_ID NUMBER,
    --KKS ����������
    TO_DEVICE_NAME SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    TO_LOCATION_ID NUMBER,
    -- KKS �����
    TO_LOCATION_NAME SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- Location Properties ID - ������ �� ������������, � ������� �������� 
    -- �������� �����
    TO_LOCPROP_ID NUMBER
);
--��������� ������ (�������).
Type T_CAB_JOURNAL Is Table Of R_CAB_JOURNAL;
--==============================================================================
-- ���������� ������
-- ��� ����� � ������� ��������� ���� ��� ��������.
book VARCHAR2(4000);
-- ��� ����� � �������� ��������� ���� ���, ��������.
sheet VARCHAR2(4000);
-- ����� ���� ��� ��������� ����.
curRowNum number;


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
/*
Implementation pattern

SELECT cj."CABLE_ID", cj."CABLE_NAME"
, cj."FROM_DEVICE_ID", cj."FROM_DEVICE_NAME"
, cj."FROM_LOCATION_ID", cj."FROM_LOCATION_NAME", cj."FROM_LOCPROP_ID"
, cj."TO_DEVICE_ID", cj."TO_DEVICE_NAME"
, cj."TO_LOCATION_ID", cj."TO_LOCATION_NAME", cj."TO_LOCPROP_ID" 
FROM TABLE(SP.TJ#ELECTRO.V_CAB_JOURNAL(WorkID$ => 3498170100 )) cj;

--3498170100
--3658355200
*/
-- ��������� ��������� ���� ���-�������� � ����� � ����� KOCEL.
-- !����� ������� ���������� ������� �� ����� ���������� ��������� ���
-- ������������� ���������� ������ book,sheet � curRowNum:=1!
-- ����� ���������� ���� ������� ���������� ��������� commit.
procedure add_Property2sheet(PNAME in VARCHAR2, PVALUE in VARCHAR2);                
procedure add_Property2sheet(PNAME in VARCHAR2, PVALUE in NUMBER);                
procedure add_Property2sheet(PNAME in VARCHAR2, PVALUE in DATE);                

end TJ#ELECTRO;