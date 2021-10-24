CREATE OR REPLACE PACKAGE SP.E3#TJ
-- ��������� ������ ������� ���� Zuken e3.Series � Total Journal
-- ��. �������� 
-- E3.02.������������� ������ �� �� E3 � TJ.������� ���������.pdf
-- � ����� ...\vm-polinom\Pln\07_IMan\07_Server\E3Server\docs\E3\
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-07-03
-- update 2019-09-12 2019-10-28 2019-12-27 2020-07-29 2020-12-14:2020-12-16

AS

TYPE AA_ShortStr2ShortStr Is Table Of Varchar2(128) INDEX BY Varchar2(128);
TYPE AA_ShortStr2Int Is Table Of BINARY_INTEGER 
  Index By SP.V_MODEL_OBJECT_PARS.PARAM_NAME%TYPE;
  
--���� ������������ (�������� �����������)
EQP_DEVICE CONSTANT Varchar2(20):='Device';                 --E3TYPE
EQP_CABLE CONSTANT Varchar2(20):='Cable';                   --E3TYPE
EQP_TERMINAL CONSTANT Varchar2(20):='Terminal';             --E3TYPE
EQP_TERMINAL_BLOCK CONSTANT Varchar2(20):='TerminalBlock';  --E3TYPE

--==============================================================================
--��� ������� �����
--���� ������ ��������, ��  ������ �� ������������
--���� ������ �������, �� ���������� � ��� ������ (mess1$)
--� ����� �������� ������ ������� (mess2$)
Procedure D_Long(mess1$ In Out Varchar2, mess2$ In Varchar2, Tag$ In Varchar2 );
--==============================================================================
--�������� (���������) ��������� �� From$ � To$
Procedure COPY_MACRO_PARS
(From$ In SP.G.TMACRO_PARS, To$ In Out NoCopy SP.G.TMACRO_PARS);
--==============================================================================
-- ������� ��������� �� ������ From$, 
-- ������� �� ���������� � ��������� ������ Etalon$
Procedure REMOVE_MACRO_PARS
(Etalon$ In SP.G.TMACRO_PARS, From$ In Out NoCopy SP.G.TMACRO_PARS);
--==============================================================================
--�������� (���������) ������� �� From$ � To$
Procedure COPY_OBJECTS
(From$ In SP.G.TOBJECTS, To$ In Out NoCopy SP.G.TOBJECTS);
--==============================================================================
--���������� ID ������� ������ �� PARENT_MOD_OBJ_ID$ � ��� ����� 
Function Get_MOD_OBJ_ID
(PARENT_MOD_OBJ_ID$ In Number, MOD_OBJ_NAME$ In Varchar2) Return Number;
--==============================================================================
--���������� ����� ���������� ������ �����
Function Get_Locati�nSingleParams Return SP.G.TMACRO_PARS;
--==============================================================================
--���������� ����� ���������� ������ �������
Function Get_SystemSingleParams Return SP.G.TMACRO_PARS;
--==============================================================================
--���������� ����� ������������ ���������� ����������
Function Get_DeviceDynaParams Return SP.G.TMACRO_PARS;  
--==============================================================================
--���������� ����� ����������� ���������� ����������, ����������� ��� ����������
Function Get_DeviceStatParams Return SP.G.TMACRO_PARS;
--==============================================================================
-- ���������� ����� ����������� ���������� ����� ����������,
-- ����������� ��� ����������
--Function Get_DevicePinStatParams Return SP.G.TMACRO_PARS;
--==============================================================================
--���������� ����� ����������� ���������� ������, ����������� ��� ����������
Function Get_CableStatParams Return SP.G.TMACRO_PARS;
--==============================================================================
--���������� ����� CableParamList
--Function Get_CableParamList Return T_StrKeys;

--���������� ����� ������������ ���������� ������
Function Get_CableDynaParams Return SP.G.TMACRO_PARS;
--==============================================================================
--���������� ����� ����������� ���������� ���� ������, 
--����������� ��� ����������
Function Get_CableWireStatParams Return SP.G.TMACRO_PARS;
--==============================================================================
--���������� ����� ������������ ���������� ���� ������
Function Get_CableWireDynaParams Return SP.G.TMACRO_PARS;
--==============================================================================
--��������� DevicePin, ������������� � API Zuken e3.Series
Function E3RP_DevicePin Return SP.G.TMACRO_PARS;
--==============================================================================
--��������� Cable Wire, ������������� � API Zuken e3.Series
Function E3RP_CableWire Return SP.G.TMACRO_PARS;
--==============================================================================
--�������� �� �������� �������-����������������-������� �� ParentModObjID$,
--� ������� �������� ��������� SOURCE_SAPR ��������� � SourceSapr$
Procedure MarkToDelete1(ParentModObjID$ In Number, SourceSapr$ In Varchar2);
--==============================================================================
--�������� �� �������� �������-������� �� RootModObjID$,
--� ������� �������� ��������� SOURCE_SAPR ��������� � SourceSapr$
Procedure MarkToDeleteDesc(RootModObjID$ In Number);
--==============================================================================
--�������� �� �������� �������-����������������-������� �� ParentModObjID$,
--� ������� �������� ��������� ObjParID$ ��������� � SourceSapr$
Procedure MarkToDelete(ParentModObjID$ In Number, ObjParID$ In Number);

--==============================================================================
--�������� ������� ��������, � ������� ModObjID$
Procedure UnMarkToDelete(ModObjID$ In Number);
--==============================================================================
--������� �������-����������������-������� �� ParentModObjID$,
--� ������� SP.MODEL_OBJECTS.TO_DEL = 1.
--���� ��������� ������, �� ����� �������������� � ��� � ����� 
--'WARNING SP.E3#TJ.DeleteMarked' � ���������� ��������.
Procedure DeleteMarked(ParentModObjID$ In Number);
--==============================================================================
--������� �������-������� �� ParentModObjID$,
-- � ������� SP.MODEL_OBJECTS.OBJ_ID = ObjectID$
-- � SP.MODEL_OBJECTS.TO_DEL = 1.
--���� ��������� ������, �� ����� �������������� � ��� � ����� 
--'WARNING SP.E3#TJ.DeleteMarkedDesc' � ���������� ��������.
Procedure DeleteMarkedDesc(ParentModObjID$ In Number, ObjectID$ In Number);
/*

*/
--==============================================================================
--������ ������ ��� ������ ��� � �������� ��� TO_DEL=0
Function CreateOrUpdate
(IP$ In Out NoCopy SP.G.TMACRO_PARS, UsedObjectID$ In Number)
Return Varchar2;
--==============================================================================
--�������� ID ������� ������ �� ��� ������, ����� � ������� ��������
--���� ������� �� ����������, �� ������ ���.
Function GetOrCreateObject
(ModObjName$ In varchar2, PID$ in Number, ObjectID$ In Number) return Number;

--==============================================================================
--������� ��� �������, � ������� ������� FOLDER_ID$ � ���� SubFolderName$
--���� ���� ����������� (FOLDER_ID$/SubFolderName$) �� �������, 
--�� ������ �� ������
Procedure DeleteSubfolderContainment
(FOLDER_ID$ In Number, SubFolderName$ In Varchar2);
--==============================================================================
-- ������� (�������) ��� ��������� ���� TRel � ���� �������� ���� 
-- LOCATION_OBJECT, ���������� ������ WorkID$.
-- ������ ID ������ ����� ������ ID ������ ������� �������, �������� �������� � 
--�������� �������� ����� 
Procedure ClearLocationRELs(WorkID$ In Number);
--==============================================================================
--������� ���������� E3 �� ������ TJ
-- ���������� ������� ���� ������� � ���������� � API Zuken e3.Series 
-- � ��� �� ������, �� ������ OID
--������� ���������� ���� ��� ��� ����� DeviceName$, �� OID �� ����� DeviceOID$
--� ��������� ������ - ������ �� ������.
--TODO �� �������� �� ������, ����� ���-������ ��������� �� ����������
-- ��� ���� �� ��� �����.
--������� ������ ����������� � �������������� E3=>TJ (��������� ������)
Procedure DeleteE3Device(
PID$ In Number  --ID �������-������ ����������
, DeviceName$ In Varchar2  --��� ����������
, DeviceOID$ In Varchar2   --OID ����������
);

--==============================================================================
--������� ������ ��� �������, � ������� PARENT=ParentID$
  --ParentID$:=668152500;
Procedure DeleteCablesWihoutPositions(ParentID$ In Number);
/*

*/
--==============================================================================
--##############################################################################
--������ � ��������������� KKS � ������ TJ
--==============================================================================
--���������� ������� KKS->����� ��������� � ������� 
Type R_KKS_2FOLDER Is Record
(
  --ID ������� ������
  DEVICE_FOLDER_ID NUMBER,
  --ID ������� ������
  CABLE_FOLDER_ID NUMBER
);

Type T_KKS_2FOLDERS Is Table Of R_KKS_2FOLDER 
Index By SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;

Type T_KKS_1FOLDERS Is Table Of Number
Index By SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;

DEVICE_SECTION_NAME CONSTANT Varchar2(20):='����������';
CABLE_SECTION_NAME CONSTANT Varchar2(20):='������';

kks_AGREGATE_OBJECT_NAME CONSTANT Varchar2(40):='TJ.singles.KKS1_AGREGATE';
kks_SYSTEM_OBJECT_NAME CONSTANT Varchar2(40):='TJ.singles.KKS2_SYSTEM';
kks_SUBSYSTEM_OBJECT_NAME CONSTANT Varchar2(40):='TJ.singles.KKS3_SUBSYSTEM';

RepArray_SINGLE_NAME CONSTANT Varchar2(40):='TJ.singles.RepArray';

IMAGE_ID_SINGLE_NAME CONSTANT 
      Varchar2(40):='TJ.singles.������������� �����������';

--==============================================================================
-- ������ ���������� kks_AGREGATE_OBJECT_ID �, � ������ �������������, 
-- �������� ���.
Function Get_kks_AGREGATE_OBJECT_ID Return Number;
--==============================================================================
-- ������ ���������� kks_SYSTEM_OBJECT_ID �, � ������ �������������, 
-- �������� ���.
Function Get_kks_SYSTEM_OBJECT_ID Return Number;
--==============================================================================
-- ������ ���������� kks_SUBSYSTEM_OBJECT_ID �, � ������ �������������, 
-- �������� ���.
Function Get_kks_SUBSYSTEM_OBJECT_ID Return Number;
--==============================================================================
--��� ������� (��� �������, ��� ������) ParentID$ ���������� 
--  1. KKS_1FOLDER_AA$ - ������ KKS -> ������ �������������� 
--    (SP.MODEL_OBJECTS.ID)
--  2. KKS_2FOLDER_AA$ - ������ KKS -> (ID ����� ����������, ID ����� ������) 
Procedure Get_KKS_STRUCTURE_INDEXES(ParentID$ In Number
, KKS_1FOLDER_AA$ In Out NoCopy T_KKS_1FOLDERS
, KKS_2FOLDER_AA$ In Out NoCopy T_KKS_2FOLDERS);
--==============================================================================
--��� ������� (��� �������, ��� ������) ParentID$ ������������ KKS-�������������
--������� �� E3Systems$
--  1. KKS_1FOLDER_AA$ - ������ KKS -> ������ �������������� 
--    (SP.MODEL_OBJECTS.ID)
--  2. KKS_2FOLDER_AA$ - ������ KKS -> (ID ����� ����������, ID ����� ������) 
Procedure COMPLETE_KKS_STRUCTURE(
ParentID$ In Number, E3Systems$ In Out NoCopy SP.G.TOBJECTS
, KKS_1FOLDER_AA$ In Out NoCopy T_KKS_1FOLDERS
, KKS_2FOLDER_AA$ In Out NoCopy T_KKS_2FOLDERS);
--==============================================================================
--��� ������� (��� �������, ��� ������) ParentID$ ������������ KKS-�������������
-- ���������, ���������������� ��� �������� �������������������� ������, 
-- ��������������� ��������
--  1. 00
--  2. 00BHE KKS
--  3. 00BHE KKS00
Procedure COMPLETE_KKS_STRUCTURE_BHE_KKS(
ParentID$ In Number
, KKS_1FOLDER_AA$ In Out NoCopy T_KKS_1FOLDERS
, KKS_2FOLDER_AA$ In Out NoCopy T_KKS_2FOLDERS);

--==============================================================================
--������� ��� �������-�������-������ �� RootModObjID$
Procedure DeleteCables(RootModObjID$ In Number);

--==============================================================================
--������� ��� �������-�������-���������� �� RootModObjID$
Procedure DeleteDevices(RootModObjID$ In Number);

--==============================================================================
--##############################################################################
--���������� ������ �� Zuken e3.series � TJ
--==============================================================================
Type R_REP_ARRAYS_INFO Is Record
(
  --ID ������� ��������
  DELETED_GROUP_ID SP.ARRAYS.GROUP_ID%TYPE,
  DELETED_ARRAY_NAME SP.ARRAYS.NAME%TYPE,
  INSERTED_GROUP_ID SP.ARRAYS.GROUP_ID%TYPE,
  INSERTED_ARRAY_NAME SP.ARRAYS.NAME%TYPE,
  UPDATED_GROUP_ID SP.ARRAYS.GROUP_ID%TYPE,
  UPDATED_ARRAY_NAME SP.ARRAYS.NAME%TYPE
);


--==============================================================================
--�������������� ���������� ������
-- vSOURCE_SAPR_
-- sPROJECT_NUMBER_
Procedure Set_SOURCE_SAPR(E3_JOB_OID$ In Varchar2);
--==============================================================================
--���������� ���������� ������ SOURCE_SAPR
Function SOURCE_SAPR Return Varchar2;
--==============================================================================
--���������� ���������� ������ SOURCE_SAPR
Function PROJECT_NUMBER Return Varchar2;
--==============================================================================
-- ������ ���������� RepArray_SINGLE_ID �, � ������ �������������, 
-- �������� ���.
Function Get_RepArray_SINGLE_ID Return Number;
--==============================================================================
--���������� ���������� �� �������� ���������� �������������� ��������
--������ MODEL_ID$
--���� � ������ �� ������������� �������������� �������, �� ��� ���� 
--������������ ������ ����� Null.
Function Get_REP_ARRAYS_INFO(MODEL_ID$ In Number) Return R_REP_ARRAYS_INFO;

/*
--Implementation pattern

Declare
  ra_info# SP.E3#TJ.R_REP_ARRAYS_INFO;
Begin
  ra_info#:=SP.E3#TJ.Get_REP_ARRAYS_INFO(9100);

  DBMS_OUTPUT.Put_Line('DELETED_GROUP_ID ['||ra_info#.DELETED_GROUP_ID||']');
  DBMS_OUTPUT.Put_Line('DELETED_ARRAY_NAME ['||ra_info#.DELETED_ARRAY_NAME||']');

  DBMS_OUTPUT.Put_Line('INSERTED_GROUP_ID ['||ra_info#.INSERTED_GROUP_ID||']');
  DBMS_OUTPUT.Put_Line('INSERTED_ARRAY_NAME ['||ra_info#.INSERTED_ARRAY_NAME||']');
  
  DBMS_OUTPUT.Put_Line('UPDATED_GROUP_ID ['||ra_info#.UPDATED_GROUP_ID||']');
  DBMS_OUTPUT.Put_Line('UPDATED_ARRAY_NAME ['||ra_info#.UPDATED_ARRAY_NAME||']');
  
End;
*/
--==============================================================================
--������� ��� ���������� � ������ ������, ������� ��������� � ���������� ������
Procedure RepClear;
--==============================================================================
-- ������ � ����� ������� ��������� ������ ������ ����������, ���� ��� ���, � 
-- ���������� ��� false.
-- ���� ������ ����������, �� ���������� true.
-- ���� ����� �������� ���������, �� ���������� ����������.
Function Create1ReplicationObject(
RepModObjID$ In Out Number  --ID ������� ���������� �����������
) return Boolean;
--==============================================================================
--������� �������������� ������� ������� ������ � ������� (Job) Zuken e3.series.
Procedure ClearReplicationArrays;
--==============================================================================
--������� �������������� ������� �������� ������ � ������� (Job) Zuken e3.series.
Procedure ClearReplicationArrays(MODEL_ID$ In Number);
--==============================================================================
--������������ �������� ���������� ������.
--1.	�� ������� Inserted ��������� ��� ��������, 
--    ������������ � ������� Deleted.
--2.	�� ������� Updated ��������� ��� ��������, 
--    ������������ � ������� Deleted.
--3.	�� ������� Updated ��������� ��� ��������, 
--    ������������ � ������� Inserted.
--4.	�� ������� Updated ��������� ��� ��������� ��������.
Procedure NormalizeRepArrays(MODEL_ID$ In Number);

--==============================================================================
--�������� ���� ��������, OID ������� ���������������� � ������� �Deleted� 
-- ��� GROUP_NAME �RepArrays� �� ������ MODEL_ID$.
-- ���� OID ������������ � ������ �������, �� �������� �� ������� SP.ARRAYS
-- �� ����������.
Procedure RepDelete(MODEL_ID$ In Number, JOB_NUMBER$ In Varchar2);
--==============================================================================
--���������� ������ OIDs ����������� ��������
Function GetInsertedOIDs(MODEL_ID$ In Number, JOB_NUMBER$ In Varchar2) 
Return SP.TSHORTSTRINGS;
--==============================================================================
--���������� ������ OIDs ����������� ��� ��������� ��������
--������� ���� ����������� ������, ����� - ���������.
Function GetInsertedOrUpdatedOIDs(MODEL_ID$ In Number, JOB_NUMBER$ In Varchar2) 
Return SP.TSHORTSTRINGS;
--==============================================================================
-- ��� ������� ������� �� ModObjs$ �������� ��� SymRel �� Rel, 
-- ��� ���� ��������� OID �� ������� ����������� OID2OID_AA.
Procedure AllSymRel2Rel(ModObjs$ In Out NoCopy SP.G.TOBJECTS
,OID2OID_AA$ In AA_ShortStr2ShortStr);
--==============================================================================
-- � ������� � ������� ii$ �������������� ������� OBJECTS$ ������ ������, 
-- �� ������ �������������� �������� ������� IDX$,
-- ��� ParamName$ - ������� ��������� ��� ���������-������. 
Procedure ChangeRefOID 
(OBJECTS$ In Out NoCopy SP.G.TOBJECTS, ii$ in Number
, ParamName$ in Varchar2, IDX$ In SP.E3#TJ.AA_ShortStr2ShortStr);
--==============================================================================
-- � OBJECTS$(ii$) ������ ��� ��������� NameFrom$ �� NameTo$ 
-- ����� ������� � ��������
Function ChangeObjParName(OBJECTS$ In Out NoCopy SP.G.TOBJECTS,
ii$ in Number, NameFrom$ in Varchar2, NameTo$ In Varchar2)
Return Boolean;
--==============================================================================
--��������� ���������� ������� �������������� ����������� ������� �� ��������� 
--������. ���� ������ � ������ ���, �� ����� ��������� ������� ������. 
Function ImageID2ID_IDX_Init(IMAGE_FOLDER_ID$ In Number) 
Return AA_ShortStr2ShortStr;
--==============================================================================
-- ������� ������� ���� "������������� �����������" � ����� IMAGE_FOLDER_ID$
-- ��������� ������ ImageID2ID_IDX$ ���������� ID ��������� ��������������� 
-- �����������
Procedure CreateIMAGE_IDs(
IMAGE_FOLDER_ID$ In Number
, ImageID2ID_IDX$ In Out NoCopy AA_ShortStr2ShortStr);
--==============================================================================
--���������� ���������� ���������. ����� 1.
--������������ ����������� OID2OID_Device_IDX$ OID ���������� � HP_OID
--DEVICES$ - ���������� � ������ (����) ���������
--OID2OID_Device_IDX$ - ����������� OID ���������� � HP_OID
Procedure PrepareDevices1(DEVICES$ In Out NoCopy SP.G.TOBJECTS
, boIncludeTerminal$ In Boolean
, OID2OID_IDX$ In SP.E3#TJ.AA_ShortStr2ShortStr  --�����, �������
, OID2OID_Device_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr
, ImageID2ID_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr
);
--==============================================================================
--���������� ���������� ���������. ����� 2.
Procedure PrepareDevices2(OBJECTS$ In Out NoCopy SP.G.TOBJECTS
,KKS_2FOLDER_AA$ In SP.E3#TJ.T_KKS_2FOLDERS
,NO_KKS_2FOLDER$ In SP.E3#TJ.R_KKS_2FOLDER
,ImageID2ID_IDX$ In SP.E3#TJ.AA_ShortStr2ShortStr
,OID2OID_Device_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr
,OID2OID_DevicePin_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr
);
--==============================================================================
--���������� ���������� �������. 
Procedure PrepareCables(CABLES$ In Out NoCopy SP.G.TOBJECTS
, OID2OID_IDX$ In SP.E3#TJ.AA_ShortStr2ShortStr  --�����, �������
, OID2OID_DevicePin_IDX$ In SP.E3#TJ.AA_ShortStr2ShortStr
, KKS_2FOLDER_AA$ In SP.E3#TJ.T_KKS_2FOLDERS
, NO_KKS_2FOLDER$ In SP.E3#TJ.R_KKS_2FOLDER
);
--==============================================================================
-- ����������� ������ �������������� ������.
-- ���� �� ��� ������� �������� � �������������, �� 
-- ���������� ��������� �� ������.
-- � ��������� ������, ����� �� ������, ���������� Null.
Function VerifyFuncSystems(FUNC_SYSTEMS$ In Out NoCopy SP.G.TOBJECTS
, KKS_2FOLDER_AA$ In T_KKS_2FOLDERS
) Return Varchar2;
--==============================================================================
-- ��������/�������������� �������������� ������.
-- ���������� ��������� �� ������ ��� Null.
Function CreateOrUpdateFuncSystems(FUNC_SYSTEMS$ In Out NoCopy SP.G.TOBJECTS
,SYSTEM_FOLDER_ID$ Number
, OID2OID_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr  --�����, �������
) Return Varchar2;
--==============================================================================
-- ��������/�������������� ����.
-- ���������� ��������� �� ������ ��� Null.
Function CreateOrUpdateLocations(LOCATIONS$ In Out NoCopy SP.G.TOBJECTS
,LOCATION_FOLDER_ID$ Number
, OID2OID_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr  --�����, �������
) Return Varchar2;
--==============================================================================
-- ��������� ��� �������� ���������� PROPS ���� �������� ������ ���� 
-- TJ.singles.�����, ���������� ������ WorkID$
Procedure UpdLocationProps(WorkID$ In Number);
--==============================================================================
-- ��������/�������������� ��������������� �����������.
-- ���������� ��������� �� ������ ��� Null.
Function CreateOrUpdate_IMAGE_IDs(
ImageID2ID_IDX$ In Out NoCopy AA_ShortStr2ShortStr
,IMAGE_FOLDER_ID$ Number
)Return Varchar2;
--==============================================================================
--##############################################################################
--==============================================================================
--ID ��������
Type R_ObjectID Is Record
(
  --ID ������� 
  OBJECT_ID NUMBER
);
--������� ID ��������.
Type T_ObjectIDs Is Table Of R_ObjectID;
--==============================================================================
--���������� ID ������� ���� ��������, ��������������� �������� Zuken e3.series,
-- ��� �� ����������, ������, ������������ ����������, ����������� � �����.
-- ������������� (2020-07-29) ����� �������� ������ ������ � ����������.
Function GetAllDeviceObjIDs Return T_ObjectIDs pipelined;
/*
--Implementation pattern

select OBJECT_ID from TABLE(SP.E3#TJ.GetAllDeviceObjIDs);
*/
--==============================================================================

End E3#TJ;