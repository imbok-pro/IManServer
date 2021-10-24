CREATE OR REPLACE PACKAGE SP.TJ_MANAGEMENT
-- SP.TJ_MANAGEMENT package 
-- ����� ��� ������ � ������� TJ
-- by Azarov. SP-TJ_MANAGEMENT.pkbs
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 08.02.18
-- update 30.03.19  26.07.19 01.08.19 08.08.19 18.09.19 04.11.19 23.12.19
--        17.06.2021 

AS
CurModelId NUMBER;
-- ������� ���� ���� ������, ������� �������� ������ ������ TJ.
TJ_WORK_ID NUMBER;
TJ_WORK_PATH VARCHAR2(4000);
--�������������� �������� ��������
"TJ.singles.������"  NUMBER;
"TJ.singles.�������" NUMBER;
"TJ.singles.�����"   NUMBER;
"TJ.singles.����� ������" NUMBER;
--�������������� ���������� ������� �������� "TJ.singles.�������"
"HP_Primary_divace"  NUMBER;
"�� �����������"     NUMBER;
"�������"            NUMBER;
"HP_Image_layer"     NUMBER;
--�������������� ���������� ������� �������� "TJ.singles.����� ������"
"����� ��"           NUMBER;
"�������"            NUMBER;

--�������������� ����� ������
--"������"  NUMBER;
--"�������" NUMBER;
"�����"   NUMBER;
"�������" NUMBER;
"�������������� �����������" NUMBER;
"����� ������" NUMBER;
"���������" NUMBER;

-- ������������� �������� ��� ����������� ���� �������� ���� ������ � �������.
"������" NUMBER;

-- ������������� �������� ��� ����������� ���� �������� ���� ���� ������ � �������.
"���� ������" NUMBER;
-- ������������� �������� ��� ����������� ���� �������� ���� ������� � �������.
"�������" NUMBER;
-- ������������� �������� ��� ����������� ���� �������� ���� ����� ������� � �������.
"����� �������" NUMBER;
-- ������������� �������� ��� ����������� ���� �������� ���� ������� � �������.
"�������" NUMBER;
-- ������������� �������� ��� ����������� ���� �������� ���� +����� � �������.
"+�����" NUMBER;
-- Id-� ������, ������� ����� ����������
selectedSystemIds SP.TNUMBERS;

-- ������ ������� ���������� �������
type TJ_REC is record
(
"ID"                  NUMBER,
"�����_����������"    NUMBER, 
"�������"             VARCHAR2(256),
"�����"               VARCHAR2(256), 
"������"              VARCHAR2(500), 
"������_��������"     VARCHAR2(500), 
"����"                VARCHAR2(500),
"����_��������"       VARCHAR2(500), 
"���������_�����"     VARCHAR2(256),
"�����_���_�_�������" VARCHAR2(256),
"����������"          NUMBER, 
"�����_����"          VARCHAR2(256),
"�����"               NUMBER,  
"�����������"         NUMBER, 
"������"              NUMBER, 
"�������"             NUMBER, 
"��������"            NUMBER, 
"����������"          NUMBER, 
"��������"            NUMBER, 
"�����������������5�" NUMBER, 
"������������5�"      NUMBER, 
"�������������5�"     NUMBER, 
"��������������5�"    NUMBER, 
"����������������5�"  NUMBER, 
"��������������5�"    NUMBER, 
"�������"             NUMBER, 
"����������"          NUMBER, 
"������"              NUMBER
);
type TJ_TABLE is table of TJ_REC;

type Equipment_REC is record
(
"ID"                  NUMBER,
"Place"               VARCHAR2(256), 
"KOD"                 VARCHAR2(256),  
"NAME"                VARCHAR2(256),  
"X"                   NUMBER,        
"Y"                   NUMBER, 
"Z"                   NUMBER, 
"Reserve"             NUMBER,
"View"                VARCHAR2(256),  
"ViewId"              NUMBER,
"SystemName"          VARCHAR2(256),  
"SystemId"            NUMBER
);
type Equipment_TABLE is table of Equipment_REC;

type Device_REC is record
(
"ID"                  NUMBER,
"NAME"                VARCHAR2(256),  
"COMMENTS"            VARCHAR2(3000),  
"ID_���������"        NUMBER,
"XYZ"                 VARCHAR2(3000),  
"ID_�����"            NUMBER,
"ID_�������"          NUMBER,
"��������"            VARCHAR2(3000), 
"ID_�����������"      NUMBER,
"�������������"       VARCHAR2(3000),
M_DATE                DATE              
);
type Device_TABLE is table of Device_REC;

type Tray_REC is record
(
--"ID"                  NUMBER,
"�����_����������"    NUMBER, 
--"�������"             VARCHAR2(256),
"�����"               VARCHAR2(256), 
"������"              VARCHAR2(500), 
--"������_��������"     VARCHAR2(500), 
"����"                VARCHAR2(500),
--"����_��������"       VARCHAR2(500), 
"�������"             VARCHAR2(32000),
"�����"               VARCHAR2(32000),
"�����_����"          VARCHAR2(32000),
"����������"          VARCHAR2(32000), 

"���������_�����"     VARCHAR2(32000),
"�����_���_�_�������" VARCHAR2(32000),
"������"              VARCHAR2(32000),
"�����"               NUMBER,  
"�����_���"           NUMBER,
"�����_���������"       NUMBER
);
type Tray_TABLE is table of Tray_REC;

type XY is record (Diameter NUMBER, Weight NUMBER);
TYPE CableTypes IS TABLE OF XY INDEX BY VARCHAR2(250);
"�������������� ������" CableTypes;

FUNCTION get_CableWeight(cablename varchar2) return number;
FUNCTION get_CableDiameter(cablename varchar2) return number;

-- ��������� ������������� Id ������� ������ (������ ���� ��������). 
PROCEDURE setCurTJWorkId(Work_Path VARCHAR2);
PROCEDURE setCurTJWorkId(Work_ID NUMBER);
-- ������ ������������� ���� �� ��������� ������� ��������� �����
--function replaceCurToLat(str varchar2) return varchar2;
-- ������ ��������� ���� �� ��������� ������� �������������� �����
--function replaceLatToCur(str varchar2) return varchar2;

-- ��������� ��������� ������ ��������� ������� TJ_CABLES. 
PROCEDURE updateTJ_CABLES;

-- ������� ��������� Id ������� (������ ����� ��������) �� ������� �����
FUNCTION getRoot(rootName VARCHAR2) RETURN NUMBER;

-- ������� ���������� �������������� ���� ������� ������� ������
FUNCTION get_Cables return SP.TNUMBERS pipelined;

-- ������� ���������� ��������������  � ��������� ���� ������� ������� ������
FUNCTION get_Devices return Device_TABLE pipelined;

-- ���������� ������������ ���� ����� ��� ������� ������� ������
FUNCTION get_LayerName return SP.TSTRINGS pipelined;

-- ������� ���� ������� �� �����
FUNCTION getDevice(placeName VARCHAR2) RETURN NUMBER;

-- ���������� ������ �������� ��������� ���������� ������� 
FUNCTION getDeviceParameters(deviceId IN NUMBER) RETURN VARCHAR2;

-- ��������� �� �� ������ ������� ���:
-- ���� SYSID != null � SYSID != 0 ������������� �������, 
-- ���� SYSID = null ���� ������
-- SYSID = 0 ������, Id-� ������� ��������� � ��������� selectedSystemIds
FUNCTION get_CableTable(SYSID in NUMBER, LengthParamName VARCHAR2) 
return TJ_TABLE pipelined;

-- ��������� �� �� ������ ������������� ����� BRCM
FUNCTION get_CableTableBRCM(WORK_ID in NUMBER) 
return TJ_TABLE pipelined;

-- ��������� ������ ��������� ����� �� ������
FUNCTION get_CableTrack(SYSID in NUMBER) return TJ_TABLE pipelined;

-- ��������� ������ ��������� ����� �� ������ BRCM
FUNCTION get_TrayTableBRCM(WORK_ID in NUMBER) return Tray_TABLE pipelined;

-- ������� ���������� ������ ��������
FUNCTION get_RouteTableBRCM(WORK_ID in NUMBER) return Tray_TABLE pipelined; 


-- ���������� �������, ����������� ��� ������,
-- ������������� ������� � ������� �������� �� �����������.
-- ��� ��������� �������� ������������ ���������� ReportGenerator
-- (������� ���������� ��������� ������������ ���� ��� BRCM)
--FUNCTION get_Equipment(SYSID in NUMBER, VIEW_ID in NUMBER) return Equipment_TABLE pipelined;

-- ���������� �������, ����������� ��� ������, ������� �������� �� �����������.
-- ��� ��������� �������� ������������ ���������� ReportGenerator
-- (������� ���������� ��������� ������������ ���� ��� BRCM)
-- FUNCTION get_AllSystemsEquipment(VIEW_ID in NUMBER) return Equipment_TABLE pipelined;

-- ��������� �������� �������, ����������� � �������� (Id-��) �������  
-- ���� ������������� �� �����, �� ������ ������� ���� ������
-- (������� ���������� ��������� ��)
FUNCTION get_EquipmentOfSystem(SYSID NUMBER, LengthParamName varchar2) return TJ_TABLE pipelined;

-- ��������� �������� �������, ����������� � ����-���� �� �������� 
-- (������� Id-�� � ��������� selectedSystemIds) ������ 
FUNCTION get_EquipmentOfSystemArray(LengthParamName varchar2) return TJ_TABLE pipelined;

-- ��������� �������� �������, ����������� � ��������� ���� � 
-- ������� �������� ��� �����������
FUNCTION get_Equipment(LAYER in VARCHAR, VIEW_ID in NUMBER) return Equipment_TABLE pipelined;

-- ��������� ��������� selectedSystemIds
FUNCTION set_selectedSystemIds(Ids SP.TNUMBERS) return NUMBER;
-- ���������� ��������� selectedSystemIds
FUNCTION get_selectedSystemIds return SP.TNUMBERS pipelined;

-- ������ �������� ��������� "����� ������" ������� ������
--FUNCTION get_SystemSampling return SP.V;

-- ���������� �������� ��������� "����� ������" � ������� ������
--FUNCTION set_SystemSampling (ids in SP.V) return SP.V;

FUNCTION TryDeleteDeletedObjects(ModelObjectPID$ In Number) 
Return BINARY_INTEGER; 

END TJ_MANAGEMENT;
