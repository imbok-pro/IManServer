CREATE OR REPLACE PACKAGE SP.TJ_WORK
-- ��������� ������ ���������� ��� ������ � �������� "������" � �����������
-- ��� ���������
-- File: SP-TJ_WORK.pks
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-09-16
-- update 2019-09-17 2019-10-30 2019-11-21 2020-12-07:2020-12-17

AS
--==============================================================================
--��� ������ ��� ��� ������������ ����� ��������� ����������� 
SubType T$CABLE_CONSTRUCTUIN_TYPENAME Is Varchar2(20);

--��� ������ ��� �������� GUID-�� � ��������� ������������� 
Type T_MODEL_OBJECTS Is Table Of SP.MODEL_OBJECTS%ROWTYPE;
--����������� ���� � ID
Type AA_ObjName2ID Is Table Of Number
    Index By SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
    
Type AA_ModObjOID2OID Is Table Of SP.MODEL_OBJECTS.OID%TYPE
Index By SP.MODEL_OBJECTS.OID%TYPE;    
--==============================================================================
SINAME_WORK CONSTANT Varchar2(40):='TJ.singles.������';
SINAME_GENERYC_SYSTEM CONSTANT Varchar2(40):='PPM.singles._GENERIC_SYSTEM';
SINAME_DEVICE CONSTANT Varchar2(40):='TJ.singles.�������';
SINAME_DEVICE_PIN CONSTANT Varchar2(40):='TJ.singles.PIN �������';
SINAME_CABLE CONSTANT Varchar2(40):='TJ.singles.������';
SINAME_CABLE_WIRE CONSTANT Varchar2(40):='TJ.singles.���� ������';
SINAME_FUNCTIONAL_SYSTEM CONSTANT Varchar2(40):='TJ.singles.�������';
SINAME_LOCATION CONSTANT Varchar2(40):='TJ.singles.�����';
SINAME_IMAGE_ID CONSTANT Varchar2(40):='TJ.singles.������������� �����������';


--��� ������, ������������� ����� � ������ TJ
SINAME_TRAY CONSTANT Varchar2(40):='TJ.singles.�����';
--��� ������, ������������� ������ ��������� ������ � ������ TJ
SINAME_CWS CONSTANT Varchar2(40):='TJ.singles.CABLE_WAY_SEGMENT';
--��� ������, ������������� ������� ��������� CableSegment � ������ TJ
SINAME_CABLE_SEGMENT CONSTANT Varchar2(40):='TJ.singles.CableSegment';

--��� ����� � ���������� �������������
CABLE_CONSTRUCTIONS_NAME CONSTANT Varchar2(40):='��������� �����������';
--��� ����� � ������
TRAYS_NAME CONSTANT T$CABLE_CONSTRUCTUIN_TYPENAME :='�����';
--��� ����� � �������
TUBES_NAME CONSTANT T$CABLE_CONSTRUCTUIN_TYPENAME :='�����';
--��� ����� � ���������� �������
AIRGAPS_NAME  CONSTANT T$CABLE_CONSTRUCTUIN_TYPENAME :='������';
--��� ����� ��������� ������ �� ������
REFERENCES_NAME CONSTANT Varchar2(20):='REFERENCES';

--==============================================================================
--�������� ���������� � ��������� ������� �������� 
Type R_ObjParKey Is Record
(
  --ID ������� ��������
  OBJ_ID NUMBER,
  --ID ��������� ������� ��������
  OBJ_PAR_ID NUMBER
);
--==============================================================================
--������� ������ ������
Type R_CABLE_WAY_SEGMENT Is Record
(
  --ID ������
  CABLE_ID NUMBER,
  --������������ ������
  CABLE_NAME SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
  --���������� ����� �������� 
  ORDINAL NUMBER,
  --������������ ��������
  SEGMENT_NAME SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
  --��� �������� ('������','�����','�����')
  CABLE_CONSTRUCTUIN_TYPENAME T$CABLE_CONSTRUCTUIN_TYPENAME,
  --����� ��������
  LENGTH NUMBER,
  --����������� ��������� ��������
  Z_MIN NUMBER,
  --������������ ��������� ��������
  Z_MAX NUMBER
);
--��������� ������
Type T_CABLE_WAYS Is Table Of R_CABLE_WAY_SEGMENT;
--==============================================================================
--��� ������� �����
--���� ������ ��������, ��  ������ �� ������������
--���� ������ �������, �� ���������� � ��� ������ (mess1$)
--� ����� �������� ������ ������� (mess2$)
Procedure D_Long(mess1$ In Out Varchar2, mess2$ In Varchar2, Tag$ In Varchar2 );
--==============================================================================
--������������� ������� ������.
--���� WorkID$ �� ���� ������ ���� ������, �� ��������� ����������.
Procedure SetCurWork(WorkID$ In Number);
--==============================================================================
--���������� ID ������� "������"
Function WorkID Return Number;
--==============================================================================
--���������� ID ������� �������� �� ��� ������� �����
Function GetObjectID(ObjFullName$ In Varchar2) Return Number;
--==============================================================================
--���������� ID ������� ������ 
Function GetModelObjectID(
MODEL_ID$ In Number  --ID ������
, OBJ_ID$ In Number  --ID ������� ��������
, ModObjName$ In Varchar2  -- ��� ������� ������
) 
Return Number;
--==============================================================================
--���������� ID ���������� ������ �� ��� ����� (KKS) ��� Null
Function GetDeviceID(
MODEL_ID$ In Number  --ID ������
, DeviceName$ In Varchar2  -- ��� (KKS) ����������
) 
Return Number;
--==============================================================================
--���������� ID ��������� ������� �������� �� ID �������� � 
--��� (���������) �����.
Function GetObjectParID(ObjectID$ In Number, ParName$ In Varchar2)
Return Number;
--==============================================================================
--���������� ID ��������� ������� �������� �� ������� ����� ������� �������� � 
--��� (���������) �����.
Function GetObjectParID(ObjFullName$ In Varchar2, ParName$ In Varchar2)
Return Number;
--==============================================================================
--���������� �������� ���������� � ��������� ������� �������� 
--(i.e. ID ������� �������� � ID ��������� ������� ��������) 
--�� ������� ����� ������� �������� � ��� (���������) �����.
Function GetObjParKey(ObjFullName$ In Varchar2, ParName$ In Varchar2)
Return R_ObjParKey;
--==============================================================================
-- ������ ���������� GENERYC_SYSTEM_OBJECT_ID �, � ������ �������������, 
-- �������� ���.
Function Get_GENERYC_SYSTEM_OBJECT_ID Return Number;
--==============================================================================
-- ������ ���������� CABLE_OBJECT_ID �, � ������ �������������, 
-- �������� ���.
Function Get_CABLE_OBJECT_ID Return Number;
--==============================================================================
-- ������ ���������� CABLE_WIRE_OBJECT_ID �, � ������ �������������, 
-- �������� ���.
Function Get_CABLE_WIRE_OBJECT_ID Return Number;
--==============================================================================
-- ������ ���������� DEVICE_OBJECT_ID �, � ������ �������������, 
-- �������� ���.
Function Get_DEVICE_OBJECT_ID Return Number;
--==============================================================================
-- ������ ���������� LOCATION_OBJECT_ID �, � ������ �������������, 
-- �������� ���.
Function Get_LOCATION_OBJECT_ID Return Number;
--==============================================================================
-- ������ ���������� TRAY_OBJECT_ID �, � ������ �������������, 
-- �������� ���.
Function Get_TRAY_OBJECT_ID Return Number;
--==============================================================================
-- ������ ���������� CWS_OBJECT_ID �, � ������ �������������, 
-- �������� ���.
Function Get_CWS_OBJECT_ID Return Number;
--==============================================================================
-- ������ ���������� CABLE_SEGMENT_OBJECT_ID �, � ������ �������������, 
-- �������� ���.
Function Get_CABLE_SEGMENT_OBJECT_ID Return Number;
--==============================================================================
--������ ���������� ID ��������� 'ZMIN_ZMAX_LENGTH' ������� CABLE_SEGMENT 
Function Get_PARID_ZMINMAX_LENGTH Return Number;
--==============================================================================
--������ ���������� ID ��������� 'ORDINAL' ������� CABLE_SEGMENT 
Function Get_PARID_ORDINAL Return Number;
--==============================================================================
--������ ���������� ID ��������� 'REF_CABLE' ������� CABLE_SEGMENT 
Function Get_PARID_REF_CABLE Return Number;
--==============================================================================
--������ ���������� ID ��������� 'REF_SHELF' ������� CABLE_SEGMENT 
Function Get_PARID_REF_SHELF Return Number;
--==============================================================================
--���������� ID ��������� ������� ��� Null
Function GetChildByOID(ParentID$ In Number, ChildOID$ In Varchar2)
Return Number;

--==============================================================================
--���������� ID ��������� ������� ��� Null
Function GetChildByName(ParentID$ In Number, ChildName$ In Varchar2)
Return Number;

--==============================================================================
--������ ���� �������� ������� RootModObjID$, ������� OBJ_ID = ObjectID$
Function V_MODEL_OBJECTS_DESC(RootModObjID$ In Number, ObjectID$ In Number) 
Return T_MODEL_OBJECTS Pipelined;
/*
--Implementation pattern
SELECT mo.ID, mo.MODEL_ID, mo.MOD_OBJ_NAME, mo.OID, mo.OBJ_ID
, mo.PARENT_MOD_OBJ_ID, mo.COMPOSIT_ID, mo.START_COMPOSIT_ID, mo.MODIFIED
, mo.USING_ROLE, mo.EDIT_ROLE, mo.M_DATE, mo.M_USER, mo.TO_DEL
FROM TABLE(SP.TJ_WORK.V_MODEL_OBJECTS_DESC(
RootModObjID$ => 1139434400, ObjectID$ => SP.TJ_WORK.Get_DEVICE_OBJECT_ID )) mo
;

*/

--==============================================================================
-- ������ ��� �������������, ���������� ������ WorkID$
-- ������ ID ������, ����� ������ ID ������ ������� ������� ������, 
-- �������� ��������� ����������
Function V_#PDO(WorkID$ In Number) Return T_MODEL_OBJECTS Pipelined;
/*
--Implementation pattern
SELECT mo.ID, mo.MODEL_ID, mo.MOD_OBJ_NAME, mo.OID, mo.OBJ_ID
, mo.PARENT_MOD_OBJ_ID, mo.COMPOSIT_ID, mo.START_COMPOSIT_ID, mo.MODIFIED
, mo.USING_ROLE, mo.EDIT_ROLE, mo.M_DATE, mo.M_USER, mo.TO_DEL
FROM TABLE(SP.TJ_WORK.V_#PDO(WorkID$ => 1139434400)) mo
;

*/
--==============================================================================
-- ���������� ������������� ������ ���� �������������� (����� � ID), 
-- ���������� ������ WorkID$. 
-- ������ ID ������, ����� ������ ID ������ ������� ������� ������, 
-- �������� ��������� ����������
Function Get#PDOs(WorkID$ In Number) Return SP.TJ_WORK.AA_ObjName2ID;
--==============================================================================
-- ���������� ������������� ������ ���� ��������� (����� � ID), 
-- ���������� ������ WorkID$. 
-- ������ ID ������, ����� ������ ID ������ ������� ������� ������, 
-- �������� ��������� ����������
Function Get#DEVICES(WorkID$ In Number) Return SP.TJ_WORK.AA_ObjName2ID;
--==============================================================================
-- ��������� ������ 'MOD_OBJ_NAME'->'RID' ��������-�������� RootModObjID$,
-- ��� ������� ���� ObjectID$ 
Procedure Get_MODEL_OBJECT_IDX(RootModObjID$ In Number, ObjectID$ In Number,
  idx$ In Out Nocopy AA_ObjName2ID);
--==============================================================================
-- ������� ������� 'REFERENCES' � ���������� '�����' � '�����' 
-- ������� '��������� �����������', ����������� � ������ WORK_ID$.
Procedure Cable_Constructions_Clear(WORK_ID$ In Number);
/*
--Implementation pattern

Begin
  SP.TJ_WORK.Cable_Constructions_Clear(WORK_ID$ => 3498170100);
  commit;
End;
*/
--==============================================================================
--��� ������ ���������� ��� �������� ��������� �����
Function V_CABLE_WAYS(WORK_ID$ In Number) Return T_CABLE_WAYS Pipelined;
/*

--Implementation pattern

SELECT cw.CABLE_ID, cw.CABLE_NAME, cw.ORDINAL, cw.SEGMENT_NAME
, cw.CABLE_CONSTRUCTUIN_TYPENAME, cw.LENGTH, cw.Z_MIN, cw.Z_MAX
FROM TABLE(SP.TJ_WORK.V_CABLE_WAYS(WORK_ID$ => 3498170100 )) cw
ORDER BY cw.CABLE_NAME, cw.ORDINAL
;

*/
--==============================================================================
-- ���������� ��� ���� ������ �� ��� ���, ���� �� ������ ������ ���������� ����, 
-- � ������� �������� ���������� ��������� (REF_PIN_FIRST ��� REF_PIN_SECOND) 
-- �� ���� Null � ���������� ID, ��������������� ����� ��������.
-- � ������ ������� ���������� Null.
-- �������� ��������� ParamName$ ����� ���� ���� 'REF_PIN_FIRST' 
-- ���� 'REF_PIN_SECOND'.
Function Get_CableRefPinID(CableID$ In Number, ParamName$ In Varchar2) 
Return Number;
--==============================================================================
--���������� �������� ������ ��������� ParamName$ ��� ������� ������ ModObjID$
--���� �������� ����������� ��� �� �� �����, �� ���������� null;
Function GetParamBoolean(ModObjID$ In Number,ParamName$ In Varchar2) 
Return Boolean;
--==============================================================================
-- � ������� SP.MODEL_OBJECTS �������� ��� �������� OID ������ MidelID$, 
-- ��������� � ����� �������������� ������� Oid_AA$ �� ��������������� �������� 
-- ���� �� �������������� �������.
Procedure UpdateOIDs
(Oid_AA$ In Out NoCopy SP.TJ_WORK.AA_ModObjOID2OID, ModelID$ In Number);
--==============================================================================
End TJ_WORK;