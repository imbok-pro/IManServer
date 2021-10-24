CREATE OR REPLACE PACKAGE BODY SP.TG
as
-- Trigger package body
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 18.08.2010
-- update 20.10.2010 18.11.2010 07.12.2010 24.12.2010 04.06.2013 25.04.2014
--        15.06.2014 02.07.2014 25.08.2014-26.08.2014 08.09.2014 25.09.2014
--        23.10.2014 05.11.2014 01.04.2015 06.11.2015 09.06.2016 08.10.2016
--        17.10.2016 08.02.2017 05.06.2019 21.04.2021 08.09.2021

ModelName VARCHAR2(128);
ModelID NUMBER;
BuhName VARCHAR2(128);
BuhID NUMBER;

-------------------------------------------------------------------------------
PROCEDURE ResetFlags
is
begin
-- Проверять, что все таблицы и все флаги!!!

--Флаги работы триггеров.

SP_User_Deleting := false;

AfterDeleteSpRoles := false;

AfterUpdateCatalogTree := false;

AfterInsertSpRolesRels := false;
AfterUpdateSpRoles := false;
AfterDeleteSpRolesRels := false;
RolesDeleting := false;

AfterUpdateGroups := false;
AfterDeleteGroups := false;

AfterInsertRel_s := false;
AfterUpdateRel_s := false;
AfterDeleteRel_s := false;

AfterDeleteObjects := false;

AfterInsertObjectPars := false;
AfterUpdateObjectPars := false;
AfterDeleteObjectPars := false;

AfterInsertModObjects := false;
AfterUpdateModObjects := false;
AfterDeleteModObjects := false;

AfterInsertModObjPars := false;
AfterUpdateModObjPars := false;
AfterDeleteModObjPars := false;

AfterDeleteMOParStories := false;

AfterInsertMacros := false;
AfterUpdateMacros := false;
AfterDeleteMacros := false;

AfterInsertDocs := false;
AfterUpdateDocs := false;
AfterDeleteDocs := false;

AfterUpdateEnum := false;
AfterDeleteEnum := false;

AfterInsertTrans := false;
AfterUpdateTrans := false;
AfterDeleteTrans := false;

-- Флаги каскадного удаления параметров объектов.
ObjectParDeleting:= false;
ModObjParDeleting:= false;
ModelDeleting := null;
DeletingObject := '';

-- Прочее
ForceOID := false;

delete from	SP.DELETED_SP_ROLES;

delete from	SP.UPDATED_CATALOG_TREE;

delete from	SP.DELETED_REL_S;

delete from	SP.DELETED_OBJECTS;

delete from	SP.INSERTED_OBJECT_PAR_S;
delete from	SP.UPDATED_OBJECT_PAR_S;
delete from	SP.DELETED_OBJECT_PAR_S;

delete from	SP.INSERTED_MOD_OBJECTS;
delete from	SP.UPDATED_MOD_OBJECTS;

delete from	SP.INSERTED_MOD_OBJ_PAR_S;
delete from  SP.UPDATED_MOD_OBJ_PAR_S;
delete from  SP.DELETED_MOD_OBJ_PAR_S;

delete from	SP.INSERTED_MACROS;
delete from	SP.UPDATED_MACROS;
delete from	SP.DELETED_MACROS;

delete from	SP.UPDATED_ENUM_VAL_S;

end ResetFlags;

-------------------------------------------------------------------------------
FUNCTION Get_UserName return VARCHAR2
is
begin
  return UserName;
end Get_UserName; 

-------------------------------------------------------------------------------
FUNCTION Get_Admin return BOOLEAN
is
begin
  return SP_Admin;
end Get_Admin; 

-------------------------------------------------------------------------------
FUNCTION Get_ImportDATA return BOOLEAN
is
begin
  return ImportDATA;
end Get_ImportDATA; 

-------------------------------------------------------------------------------
FUNCTION Get_CheckValEnabled return BOOLEAN
is
begin
  return Check_ValEnabled;
end Get_CheckValEnabled; 

-------------------------------------------------------------------------------
FUNCTION Get_CurModel return NUMBER
is
begin
  return Cur_MODEL_ID;
end Get_CurModel;

-------------------------------------------------------------------------------
FUNCTION Get_CurModel_NAME return VARCHAR2
is
begin
  if ModelID = Cur_MODEL_ID and ModelName is not null then
    return ModelName;
  end if;
  ModelID := Cur_Model_ID;
  select Name into ModelName from SP.MODELS where ID = ModelID;
  return ModelName;
end Get_CurModel_NAME;

-------------------------------------------------------------------------------
FUNCTION Get_CurBuh return NUMBER
is
begin
  return Cur_Buh_ID;
end Get_CurBuh;

-------------------------------------------------------------------------------
FUNCTION Get_CurBuh_NAME return VARCHAR2
is
begin
  if BuhID = Cur_Buh_ID and BuhName is not null then
    return BuhName;
  end if;
  BuhID := Cur_Buh_ID;
  select Name into BuhName from SP.MODELS where ID = BuhID;
  return BuhName;
end Get_CurBuh_NAME;

-------------------------------------------------------------------------------
FUNCTION Get_CurServer return NUMBER
is
begin
  return Cur_Server;
end Get_CurServer;

-------------------------------------------------------------------------------
begin
  ModelName := null;
  ModelID := null;
  BuhName := null;
  BuhID := null;
end TG;
/
