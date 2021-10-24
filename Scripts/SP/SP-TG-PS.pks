CREATE OR REPLACE PACKAGE SP.TG AS
-- Trigger package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 18.08.2010
-- update 13.10.2010 18.11.2010 07.12.2010 24.12.2010 11.05.2011 02.11.2011
--        24.11.2011 04.06.2013 08.10.2013 10.10.2013 25.04.2014 15.06.2014
--        02.07.2014 25.08.2014-26.08.2014 08.09.2014 25.09.2014 23.10.2014
--        05.11.2014 01.04.2015 22.04.2015 08.07.2015 09.07.2015 06.11.2015
--        09.06.2016 08.10.2016 17.10.2016 08.02.2017 05.06.2019 21.01.2021

-- ****************************************************************************

-- ���������� ����������.
-- **********************
-- ������������� ������������. 
-- ��� �������, ��� ����������� �� ���� �������������� �� ��� ��� ����������.
-- ���� ��� ������������ ���������� ������� �������������,
-- �� ��� ������������ ������ ����� �������� �������.  
UserName VARCHAR2(30);
-- ���� ��������������.
SP_Admin BOOLEAN := false;
-- ������������� ������� ������.
Cur_MODEL_ID NUMBER := null;
-- �������, ��� ������� ������ ���������.
CurModel_LOCAL boolean := null;
-- ������������� ������� ����������� - ������ ����� ������.
Cur_Buh_ID NUMBER := null;
-- ������������� �������� �������.
Cur_SERVER NUMBER := 0;
-- ������� ��������. 
-- ������������ ��� �������� � ������ ��������� ���� SP.TVALUE.
CurValue SP.TVALUE;

--*************************
-- ������ ���������� ����������.
-- ���� �������� ����� (true - �������� �����������).
Check_ValEnabled BOOLEAN:=true;
-- ���� ����������� ��������������� �������� �������� �� ������� �������
-- �������� ����������� ������� �� ���������� ������.
Create_Model BOOLEAN:=true;
-- ���� ����������� ������� ������������ ������ ��� ������� ��������������
-- ���������� ����������, ���� � ���� �������� ��������� �����.
Delete_Start_Composit BOOLEAN:=true;
-- ���� ��������� �������� ���������� �� ������� ������������ ��������
-- � �� ������������ ��������, ��������������� ������ ��� ������.
TEST_MACRO_PARS BOOLEAN:=true;
--******************************
-- ���������� ���������� ������.
-- ���� ������� ������.
ImportDATA BOOLEAN := false;

-- ���� �������� ���������� ���������� ������������.
SP_User_Deleting BOOLEAN := false;

-- ���� ������ �������� SP.SP_ROLES_ad
AfterDeleteSpRoles BOOLEAN := false;

-- ���� ������ �������� SP.SP_ROLES_RELS_ai
AfterInsertSpRolesRels BOOLEAN := false;
-- ���� ������ �������� SP.SP_ROLES_RELS_au
AfterUpdateSpRoles BOOLEAN := false;
-- ���� ������ �������� SP.SP_ROLES_RELS_ad
AfterDeleteSpRolesRels BOOLEAN := false;
-- ����� ���������� �������� �������� �����.
RolesDeleting BOOLEAN := false;


-- ���� ������ �������� SP.CATALOG_TREE_au
AfterUpdateCatalogTree BOOLEAN := false;

-- ���� ������ �������� SP.GROUPS_ad
AfterUpdateGroups BOOLEAN := false;
-- ���� ������ �������� SP.GROUPS_ad
AfterDeleteGroups BOOLEAN := false;

-- ���� ������ �������� SP.REL_S_ai
AfterInsertRel_s BOOLEAN := false;
-- ���� ������ �������� SP.REL_S_au
AfterUpdateRel_s BOOLEAN := false;
-- ���� ������ �������� SP.REL_S_ad
AfterDeleteRel_s BOOLEAN := false;

-- ���� ������ �������� SP.OBJECTS_ad
AfterDeleteObjects BOOLEAN := false;

-- ���� ������ �������� SP.OBJECT_PAR_S_ai
AfterInsertObjectPars BOOLEAN := false;
-- ���� ������ �������� SP.OBJECT_PAR_S_au
AfterUpdateObjectPars BOOLEAN := false;
-- ���� ������ �������� SP.OBJECT_PAR_S_ad
AfterDeleteObjectPars BOOLEAN := false;

-- ���� ������ �������� SP.MODEL_OBJECT_S_ai
AfterInsertModObjects BOOLEAN := false;
-- ���� ������ �������� SP.MODEL_OBJECT_S_au
AfterUpdateModObjects BOOLEAN := false;
-- ���� ������ �������� SP.MODEL_OBJECT_S_ad
AfterDeleteModObjects BOOLEAN := false;

-- ���� ������ �������� SP.MODEL_OBJECT_PAR_S_ai
AfterInsertModObjPars BOOLEAN := false;
-- ���� ������ �������� SP.MODEL_OBJECT_PAR_S_au
AfterUpdateModObjPars BOOLEAN := false;
-- ���� ������ �������� SP.MODEL_OBJECT_PAR_S_ad
AfterDeleteModObjPars BOOLEAN := false;

-- ���� ������ �������� SP.MODEL_OBJECT_PAR_STORIES_ad
AfterDeleteMOParStories BOOLEAN := false;

-- ���� ������ �������� SP.MACROS_ai
AfterInsertMacros BOOLEAN := false;
-- ���� ������ �������� SP.MACROS_au
AfterUpdateMacros BOOLEAN := false;
-- ���� ������ �������� SP.MACROS_ad
AfterDeleteMacros BOOLEAN := false;

-- ���� ������ �������� SP.DOCS_ai
AfterInsertDOCs BOOLEAN := false;
-- ���� ������ �������� SP.DOCS_au
AfterUpdateDOCs BOOLEAN := false;
-- ���� ������ �������� SP.DOCS_ad
AfterDeleteDOCs BOOLEAN := false;

-- ����� ���������� �������� ���������� ��������.
ObjectParDeleting BOOLEAN := false;
ModObjParDeleting BOOLEAN := false;

-- ���� ���������� �������� �������� ������.
ModelDeleting NUMBER := null;

-- ��� ���������� �������.
DeletingObject VARCHAR2(128) := '';

-- ���� ���������� ��������� "OID" ��� ������� ������
ForceOID BOOLEAN := false;

-- ����� ��������� ���������� ��������.
AfterUpdateEnum BOOLEAN := false;
AfterDeleteEnum BOOLEAN := false;

-- ���� ������ �������� SP.TRANS_ai
AfterInsertTrans BOOLEAN := false;
-- ���� ������ �������� SP.TRANS_au
AfterUpdateTrans BOOLEAN := false;
-- ���� ������ �������� SP.TRANS_ad
AfterDeleteTrans BOOLEAN := false;

--*****************************************************************************
-- ����� �������������� ���������� �� ������ �������� ����� ���������
-- � �������� ��������� �������.
-- ��������� ���������� ��������� � ����� ����� ��������.
PROCEDURE ResetFlags;

-- ������� ������������ ���������� ������� ������ ��� SQL.
--
FUNCTION Get_UserName return VARCHAR2;
pragma RESTRICT_REFERENCES(Get_UserName,WNDS);
--
FUNCTION Get_Admin return BOOLEAN;
pragma RESTRICT_REFERENCES(Get_Admin,WNDS);
--
FUNCTION Get_ImportDATA return BOOLEAN;
pragma RESTRICT_REFERENCES(Get_ImportDATA,WNDS);
--
FUNCTION Get_CheckValEnabled return BOOLEAN;
pragma RESTRICT_REFERENCES(Get_CheckValEnabled,WNDS);
--
FUNCTION Get_CurModel return NUMBER;
pragma RESTRICT_REFERENCES(Get_CurModel,WNDS);
--
-- ������� ������������� ��� ������� ������.
FUNCTION Get_CurModel_NAME return VARCHAR2;
--
FUNCTION Get_CurBuh return NUMBER;
pragma RESTRICT_REFERENCES(Get_CurBuh,WNDS);
--
-- ������� ������������� ��� ������� �����������.
FUNCTION Get_CurBuh_NAME return VARCHAR2;
--
FUNCTION Get_CurServer return NUMBER;
pragma RESTRICT_REFERENCES(Get_CurServer,WNDS);
--
END TG;
/
