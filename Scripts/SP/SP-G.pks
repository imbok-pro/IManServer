CREATE OR REPLACE PACKAGE SP.G AS
-- Globals package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 18.08.2010
-- update 19.10.2010 28.10.2010 03.11.2010 16.11.2010 19.01.2011 26.01.2011
--        10.02.2011 28.03.2011 05.05.2011 08.06.2011 12.10.2011 22.10.2011
--        02.11.2011 10.11.2011 24.11.2011 20.12.2011 16.01.2012 23.01.2012
--        27.01.2012 14.02.2012 16.03.2012 20.03.2012 11.04.2012 21.01.2013
--        09.06.2013 20.08.2013 22.08.2013 27.09.2013 04.10.2013 30.04.2014
--        04.06.2014 15.06.2014 16.06.2014 27.06.2014 02.07.2014 20.07.2014
--        22.07.2014 26.08.2014 30.08.2014 04.11.2014 01.03.2015 06.11.2015
--        03.02.2016 11.02.2016 17.02.2016 19.02.2016 23.02.2016 29.02.2015
--        16.09.2016 10.01.2017 28.02.2017 10.03.2017 13.03.2017 16.03.2017
--        10.04.2017-11.04.2017 01.12.2017 17.01.2018 13.02.2018 19.11.2020
--        07.03.2021 15.03.2021 26.06.2021 11.09.2021
-- ��������� ������.
-- �� ���� ������� ����� IM ������ ���������� ���������� ���������� ������.
-- ���� ������� ��� � ������ ������. ������� ������������, � ��� �����,
-- ��� �������� �������� � ����������� ��������.
Cmd_EXECUTE_MACRO CONSTANT NUMBER:=-2;
-- �� ���� ������� ����� IM ������ GenericSystem � ������ ������������
-- �������� �������. ������ ������� ��� � ������ ������.
Cmd_COMPOSITE_ORIGIN CONSTANT NUMBER:=-1;
Cmd_CANCEL CONSTANT NUMBER:=0;
Cmd_Return CONSTANT NUMBER:=1;
Cmd_Calculate CONSTANT NUMBER:=2;
Cmd_Go_To CONSTANT NUMBER:=3;
Cmd_For_Pars_In CONSTANT NUMBER:=4;
Cmd_Case CONSTANT NUMBER:=5;
Cmd_When_Others_End_Case CONSTANT NUMBER:=6;
Cmd_Create_Object CONSTANT NUMBER:=7;
Cmd_Delete_Object CONSTANT NUMBER:=8;
Cmd_Execute CONSTANT NUMBER:=9;
Cmd_Set_Root CONSTANT NUMBER:=10;
Cmd_Get_Objects CONSTANT NUMBER:=11;
Cmd_Get_Systems CONSTANT NUMBER:=12;
Cmd_Play CONSTANT NUMBER:=13;
Cmd_Get_Pars CONSTANT NUMBER:=14;
Cmd_Declare CONSTANT NUMBER:=15;
Cmd_For_Systems CONSTANT NUMBER:=16;
Cmd_For_Objects CONSTANT NUMBER:=17;
Cmd_Get_All_Systems CONSTANT NUMBER:=18;
Cmd_Model3D_Commit CONSTANT NUMBER:=19;
Cmd_Model3D_Rollback CONSTANT NUMBER:=20;
Cmd_Model3D_Refresh CONSTANT NUMBER:=21;
Cmd_Get_Selected CONSTANT NUMBER:=22;
Cmd_Get_User_Input CONSTANT NUMBER:=23;
Cmd_For_Selected CONSTANT NUMBER:=24;
Cmd_Get_Full_Objects CONSTANT NUMBER:=25;
Cmd_FUNCTION CONSTANT NUMBER:=26;
Cmd_Clear_Selected CONSTANT NUMBER:=27;
Cmd_Change_Parent CONSTANT NUMBER:=28;
Cmd_Is_Object_Exist CONSTANT NUMBER:=29;
Cmd_Declare_F CONSTANT NUMBER:=30;
Cmd_Update_Notes CONSTANT NUMBER:=31;
Cmd_Rename CONSTANT NUMBER:=32;
Cmd_Get_All_Objects CONSTANT NUMBER:=33;
Cmd_Get_All_FullObjects CONSTANT NUMBER:=34;
Cmd_Model3D_Flush CONSTANT NUMBER:=35;
Cmd_Set_GPars_Vals CONSTANT NUMBER:=36;
Cmd_Toggle_Server CONSTANT NUMBER:=37;
Cmd_Select_Objects CONSTANT NUMBER:=38;
Cmd_Reload_Model CONSTANT NUMBER:=39;
Cmd_Set_Pars CONSTANT NUMBER:=40;
 
-- ��������� �������� ���������� �����.
TUsed_Object CONSTANT NUMBER:=100;
TArr CONSTANT NUMBER:=101;
TClientCommand CONSTANT NUMBER:=102;
TBlob CONSTANT NUMBER:=103;
TClob CONSTANT NUMBER:=104;
TData CONSTANT NUMBER:=105;
TFileType CONSTANT NUMBER:=106;
TLogin CONSTANT NUMBER:=107;
--
TNumber CONSTANT NUMBER:=1;
TDate CONSTANT NUMBER:=2;
TStr4000 CONSTANT NUMBER:=3;
TNullBoolean CONSTANT NUMBER:=4;
TBoolean CONSTANT NUMBER:=5;
TInteger CONSTANT NUMBER:=6; 
TNullShort CONSTANT NUMBER:=7;
TNullInteger CONSTANT NUMBER:=8;
TCodeList CONSTANT NUMBER:=9;
TNullDouble CONSTANT NUMBER:=10;
TNullFloat CONSTANT NUMBER:=11;
TDouble CONSTANT NUMBER:=12; -- Ms ������������
TXY CONSTANT NUMBER:=13;
TXYZ CONSTANT NUMBER:=14;
TNoValue CONSTANT NUMBER:=15;
TNullDate CONSTANT NUMBER:=16;
TIType CONSTANT NUMBER:=17;
TTreeNode CONSTANT NUMBER:=18;
TCardinalPoint CONSTANT NUMBER:=19;
TCSType CONSTANT NUMBER:=20;
TCSHand CONSTANT NUMBER:=21;
TAxisType CONSTANT NUMBER:=22;
TNote CONSTANT NUMBER:=23;
TCurveType CONSTANT NUMBER:=24;
TFacePosition CONSTANT NUMBER:=25;
THandrailOrientation CONSTANT NUMBER:=26;
THandrailEndTreatment CONSTANT NUMBER:=27;
TPostConnType CONSTANT NUMBER:=28;
TGraphicPrimitive CONSTANT NUMBER:=29;
TSection CONSTANT NUMBER:=30;
TBeep CONSTANT NUMBER:=31;
TFlags CONSTANT NUMBER:=32;
TCPType CONSTANT NUMBER:=33;
TCPSubType CONSTANT NUMBER:=34;
TCableTrayShape CONSTANT NUMBER:=35; --����� ������� ���������� �����
TOID CONSTANT NUMBER:=36; -- ������������� (������������ ������, ����., GUID)
TID CONSTANT NUMBER:=37; -- ������������� (ORACLE, ���������� number)
TPositionDepth CONSTANT NUMBER:=38; -- Tekla (BEAM)
TPositionPlane CONSTANT NUMBER:=39; -- Tekla (BEAM)
TPositionRotation CONSTANT NUMBER:=40; -- Tekla (BEAM)
TComponentInput_1 CONSTANT NUMBER:=41; -- Tekla (����������)
TComponentInput_2 CONSTANT NUMBER:=42; -- Tekla (����������)
TComponentInput_3 CONSTANT NUMBER:=43; -- Tekla (����������)
TComponentInput_4 CONSTANT NUMBER:=44; -- Tekla (����������)
TComponentInput_5 CONSTANT NUMBER:=45; -- Tekla (����������)
TServerType CONSTANT NUMBER:=46;
TRel CONSTANT NUMBER:=47;
TDrawingType CONSTANT NUMBER:=48;
TSymRel CONSTANT NUMBER:= 49;

--------------------------------------------------------------------------------
TNTerritory CONSTANT NUMBER:=50;
TNLang CONSTANT NUMBER:=51;
TNNumChars CONSTANT NUMBER:=52;
TNSort CONSTANT NUMBER:=53;
TNDFormat CONSTANT NUMBER:=54;
TNotePurpose CONSTANT NUMBER:=55;
TObjectKind CONSTANT NUMBER:=56;
TAspectCode CONSTANT NUMBER:=57;
TGROUP CONSTANT NUMBER:=58;
TTRANS CONSTANT NUMBER:=59;
TMODIFIED CONSTANT NUMBER:=60;
TRole CONSTANT NUMBER:=61;
TSingle CONSTANT NUMBER:=62;
--------------------------------------------------------------------------------
--������������ Zuken e3.series
--
--���� �������� Zuken e3.series
TE3Type CONSTANT NUMBER:=63;
TTextAlignments CONSTANT NUMBER:=64;
TTextBalloonings CONSTANT NUMBER:=65;
TTextModes CONSTANT NUMBER:=66;
TTextStyles CONSTANT NUMBER:=67;
TE3PinPhyslConnDirection CONSTANT NUMBER:=68;
TE3PinTypeId CONSTANT NUMBER:=69;
TE3AttributeOwner2 CONSTANT NUMBER:=70;
TE3AttributeOwner CONSTANT NUMBER:=71;
TE3SymbolCodes CONSTANT NUMBER:=72;
--------------------------------------------------------------------------------
--T���� � �������� ������� ���������.
TPolar CONSTANT NUMBER:=73;
--����� � �������������� ������� ���������.
TCylindr CONSTANT NUMBER:=74;
-------------------------------------------------------------------------------- 
-- ��������� �������� �������.
SLocal CONSTANT NUMBER:=0;
SPrimary CONSTANT NUMBER:=1;
SSecondary CONSTANT NUMBER:=2;

-- ��������� �������� R_Only.
-- �������� ���������� ��� ����������� ����� �������� �������.
StoryLess CONSTANT NUMBER:=-2;
Required CONSTANT NUMBER:=-1;
ReadWrite CONSTANT NUMBER:=0;
ReadOnly CONSTANT NUMBER:=1;
-- ������������ � ���������� ����������.
-- ������ ��������� �������� ���� ��������������.
Fixed CONSTANT NUMBER:=2;

-- ��������� ���������� �����.
ADMIN_ROLE CONSTANT NUMBER:=0;
USER_ROLE CONSTANT NUMBER:=1;

-- ��������� ����� ��������.
NATIVE_OBJ CONSTANT NUMBER:=-1;
SINGLE_OBJ CONSTANT NUMBER:=0;
COMPOSITE_OBJ CONSTANT NUMBER:=1;
MACRO_OBJ CONSTANT NUMBER:=2;
OPERATION_OBJ CONSTANT NUMBER:=3;

-- ��������� �����.
-- ������ ����� ��� ���������� �� ���������.
OTHER_GROUP CONSTANT NUMBER:=9;

-- ���������, ������������ � ������ �������������.
-- ����� ��.
pi CONSTANT NUMBER:=2*ACOS(0);
-- �������� ��� ������� ���������, ��� ����� ����������� ��������� ���������, 
-- �������� �� ��� ������ ������.
Plane_Eps CONSTANT NUMBER:=0.00001;
--������ Ingr Math3D.DistTolerance
--��������, ���� ���������� �� ����� �� �������������
Dist_Eps CONSTANT NUMBER:=0.0000001;
--������ Ingr Math3D.RelativeTolerance
--��������, ���� ��� ������������ ������� ��������� 
Relative_Eps CONSTANT NUMBER:=0.0000000001;

DaemonPipe CONSTANT VARCHAR2(256) := 'SP_MACROS';

-- ��������� ��������� ��������������, ����������� ������� SP.MACROS.
----------------------------------------------------------------------------
-- �� ����������.
MS_NotDef CONSTANT VARCHAR2(128) := 'NotDef';
-- ���������� � �������, �������� ���������� ������.
MS_Starting CONSTANT VARCHAR2(128):= 'Starting';
-- �������� ���������� ��������.
-- �� ������� ��������� ���� ������� �� SP.Macro.WStateLimit ������� ������.
MS_Waiting CONSTANT VARCHAR2(128) := 'LongOperation Waiting';
-- ����� � ������.
MS_Ready CONSTANT VARCHAR2(128) := 'Ready';
-- ����� � ������, ������ ��� ���������� ���������� ��������������.
MS_Warning CONSTANT VARCHAR2(128) := 'Exit with Warning';
-- ����������� ��������������.
MS_Working CONSTANT VARCHAR2(128):= 'Working';
-- ����������� ���� ��� ��������������.
MS_Stepping CONSTANT VARCHAR2(128):= 'Stepping';
-- �������������.
MS_Paused CONSTANT VARCHAR2(128):= 'Paused';
-- ������� � ���������� ������.
MS_Error CONSTANT VARCHAR2(128):= 'Error';
-- ������ ���������. ������ ������� ��� �����������.
MS_Closing CONSTANT VARCHAR2(128):= 'Closing';
-- �������� �������� ������������:
-- 1 �������� �������������� ������ � ������� SP.WORK_COMMAND_PAR_S.
MS_WaitingUser CONSTANT VARCHAR2(128):= 'WaitingUser';
-- 2 �������� ����� ��������� ������������� ��������.
MS_WaitingSelection CONSTANT VARCHAR2(128):= 'WaitingSelection';
-- 3 �������� ������� ��������� ��������.
MS_ClearSelected CONSTANT VARCHAR2(128):= 'ClearSelected';
-- 4 �������� ���������� �������� ������ ��������� �������.
MS_MustBeep CONSTANT VARCHAR2(128):= 'MustBeep';

--������ �������� (����� ������������ ��� ����� �����)
TYPE TVALUES IS TABLE OF SP.TVALUE INDEX BY BINARY_INTEGER;
-- ��������� � ������� �������������.
TYPE TMACRO_PARS IS TABLE OF SP.TVALUE INDEX BY VARCHAR2(128);
-- ������ ������ ����������.
-- ������������ ��� ������ ��������.
TYPE TOBJECTS IS TABLE OF TMACRO_PARS INDEX BY BINARY_INTEGER;
-- ������ �������� ����� � ������.
TYPE TNUM IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(30);
-- ��������� ������� ������ � ������� �������������.
TYPE TMODEL_PARS IS TABLE OF SP.TMPAR INDEX BY VARCHAR2(128);
-- ��������� �������� � ������� �������������.
TYPE TCATALOG_PARS IS TABLE OF SP.TCPAR INDEX BY VARCHAR2(128);
-- ������ ���.
TYPE TNAMES IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
-- ������ �������� ���.
TYPE TSNAMES IS TABLE OF VARCHAR2(128) INDEX BY BINARY_INTEGER;
-- ������ ��� ������� � ���������������.
TYPE TINAMES IS TABLE OF VARCHAR2(40) INDEX BY BINARY_INTEGER;

--*****************************************************************************
-- ������� ���������� true, ���� ��� �������� ���� ��� a1=a2
-- ��� false, ���� �� ����� ��� ���� �� ���������� ����.
FUNCTION EQ(a1 NUMBER, a2 NUMBER) RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(EQ,WNPS);

FUNCTION EQ(a1 DATE, a2 DATE) RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(EQ,WNPS);

FUNCTION EQ(a1 VARCHAR2, a2 VARCHAR2) RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(EQ,WNPS);

FUNCTION EQ_R(a1 RAW, a2 RAW) RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(EQ_R,WNPS);

-- ������� ���������� true, ���� ���� �� �������� ���� ��� a1!=a2
-- ��� false, ���� ����� ��� ��� ��������� ����.
FUNCTION notEQ(a1 NUMBER, a2 NUMBER) RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(notEQ,WNPS);

FUNCTION notEQ(a1 DATE, a2 DATE) RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(notEQ,WNPS);

FUNCTION notEQ(a1 VARCHAR2, a2 VARCHAR2) RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(notEQ,WNPS);

FUNCTION notEQ_R(a1 RAW, a2 RAW) RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(notEQ_R,WNPS);

-- �� �� ����� �� ��� ������ �� sql.
-- ������� ���������� 1, ���� ��� �������� ���� ��� a1=a2
-- ��� 0, ���� �� ����� ��� ���� �� ���������� ����.
FUNCTION S_EQ(a1 NUMBER, a2 NUMBER) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(S_EQ,WNPS);

FUNCTION S_EQ(a1 DATE, a2 DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(S_EQ,WNPS);

FUNCTION S_EQ(a1 VARCHAR2, a2 VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(S_EQ,WNPS);

FUNCTION S_EQ_R(a1 RAW, a2 RAW) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(S_EQ_R,WNPS);

-- ������� ���������� 1, ���� ���� �� �������� ���� ��� a1!=a2
-- ��� 0, ���� ����� ��� ��� ��������� ����.
FUNCTION S_notEQ(a1 NUMBER, a2 NUMBER) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(S_notEQ,WNPS);

FUNCTION S_notEQ(a1 DATE, a2 DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(S_notEQ,WNPS);

FUNCTION S_notEQ(a1 VARCHAR2, a2 VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(S_notEQ,WNPS);

FUNCTION S_notEQ_R(a1 RAW, a2 RAW) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(S_notEQ,WNPS);

-- �������, ������������ �������� � ������� ��������.
FUNCTION UpEQ(a1 VARCHAR2, a2 VARCHAR2) RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(UpEQ,WNPS);

FUNCTION notUpEQ(a1 VARCHAR2, a2 VARCHAR2) RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(notUpEQ,WNPS);

FUNCTION S_UpEQ(a1 VARCHAR2, a2 VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(S_UpEQ,WNPS);

FUNCTION S_notUpEQ(a1 VARCHAR2, a2 VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(S_notUpEQ,WNPS);

-- ������� ���������� ������, ���� �������� ����� ��� ��� �����.
FUNCTION EQ(V1 IN SP.TValue, V2 IN SP.TValue)RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(EQ,WNPS);

-- ������� ���������� 1, ���� �������� ����� ��� ��� �����,
-- ����� "0".
FUNCTION S_EQ(V1 IN SP.TValue, V2 IN SP.TValue)RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(S_EQ,WNPS);

-- ������� ���������� ������, ���� ������ ������������ � �������
-- � �������� � ������� � �������� �� ������ ��������� ����� �������� ��������.
FUNCTION EQ(P IN TMACRO_PARS, ParName IN VARCHAR2, V IN SP.TValue)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(EQ,WNPS);

END G;
/
