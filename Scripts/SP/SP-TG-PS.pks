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

-- Глобальные переменные.
-- **********************
-- Идентификатор пользователя. 
-- Без кавычек, вне зависимости от того присутствовали ли они при соединении.
-- Если при установлении соединения кавычки отсутствовали,
-- то имя пользователя всегда будет большими буквами.  
UserName VARCHAR2(30);
-- Флаг администратора.
SP_Admin BOOLEAN := false;
-- Идентификатор текущей модели.
Cur_MODEL_ID NUMBER := null;
-- Признак, что текущая модель локальная.
CurModel_LOCAL boolean := null;
-- Идентификатор текущей бухгалтерии - модели плана счетов.
Cur_Buh_ID NUMBER := null;
-- Идентификатор текущего сервера.
Cur_SERVER NUMBER := 0;
-- Текущее значение. 
-- Используется для передачи в запрос параметра типа SP.TVALUE.
CurValue SP.TVALUE;

--*************************
-- Дублёры глобальных параметров.
-- Флаг проверки типов (true - проверка обязательна).
Check_ValEnabled BOOLEAN:=true;
-- Флаг разрешающий протоколировать создание объектов на внешнем сервере
-- создавая аналогичные объекты во внутренней модели.
Create_Model BOOLEAN:=true;
-- Флаг разрешающий удалять существующий объект при запуске макропроцедуры
-- являющейся композитом, если у этих объектов совпадают имена.
Delete_Start_Composit BOOLEAN:=true;
-- Флаг разрешает проверку параметров на наличие обязательных значений
-- и на неизменность значений, предназначенных только для чтения.
TEST_MACRO_PARS BOOLEAN:=true;
--******************************
-- Управление триггерами таблиц.
-- Флаг импорта данных.
ImportDATA BOOLEAN := false;

-- Флаг удаления глобальных параметров пользователя.
SP_User_Deleting BOOLEAN := false;

-- Флаг работы триггера SP.SP_ROLES_ad
AfterDeleteSpRoles BOOLEAN := false;

-- Флаг работы триггера SP.SP_ROLES_RELS_ai
AfterInsertSpRolesRels BOOLEAN := false;
-- Флаг работы триггера SP.SP_ROLES_RELS_au
AfterUpdateSpRoles BOOLEAN := false;
-- Флаг работы триггера SP.SP_ROLES_RELS_ad
AfterDeleteSpRolesRels BOOLEAN := false;
-- Флаги каскадного удаления иерархии ролей.
RolesDeleting BOOLEAN := false;


-- Флаг работы триггера SP.CATALOG_TREE_au
AfterUpdateCatalogTree BOOLEAN := false;

-- Флаг работы триггера SP.GROUPS_ad
AfterUpdateGroups BOOLEAN := false;
-- Флаг работы триггера SP.GROUPS_ad
AfterDeleteGroups BOOLEAN := false;

-- Флаг работы триггера SP.REL_S_ai
AfterInsertRel_s BOOLEAN := false;
-- Флаг работы триггера SP.REL_S_au
AfterUpdateRel_s BOOLEAN := false;
-- Флаг работы триггера SP.REL_S_ad
AfterDeleteRel_s BOOLEAN := false;

-- Флаг работы триггера SP.OBJECTS_ad
AfterDeleteObjects BOOLEAN := false;

-- Флаг работы триггера SP.OBJECT_PAR_S_ai
AfterInsertObjectPars BOOLEAN := false;
-- Флаг работы триггера SP.OBJECT_PAR_S_au
AfterUpdateObjectPars BOOLEAN := false;
-- Флаг работы триггера SP.OBJECT_PAR_S_ad
AfterDeleteObjectPars BOOLEAN := false;

-- Флаг работы триггера SP.MODEL_OBJECT_S_ai
AfterInsertModObjects BOOLEAN := false;
-- Флаг работы триггера SP.MODEL_OBJECT_S_au
AfterUpdateModObjects BOOLEAN := false;
-- Флаг работы триггера SP.MODEL_OBJECT_S_ad
AfterDeleteModObjects BOOLEAN := false;

-- Флаг работы триггера SP.MODEL_OBJECT_PAR_S_ai
AfterInsertModObjPars BOOLEAN := false;
-- Флаг работы триггера SP.MODEL_OBJECT_PAR_S_au
AfterUpdateModObjPars BOOLEAN := false;
-- Флаг работы триггера SP.MODEL_OBJECT_PAR_S_ad
AfterDeleteModObjPars BOOLEAN := false;

-- Флаг работы триггера SP.MODEL_OBJECT_PAR_STORIES_ad
AfterDeleteMOParStories BOOLEAN := false;

-- Флаг работы триггера SP.MACROS_ai
AfterInsertMacros BOOLEAN := false;
-- Флаг работы триггера SP.MACROS_au
AfterUpdateMacros BOOLEAN := false;
-- Флаг работы триггера SP.MACROS_ad
AfterDeleteMacros BOOLEAN := false;

-- Флаг работы триггера SP.DOCS_ai
AfterInsertDOCs BOOLEAN := false;
-- Флаг работы триггера SP.DOCS_au
AfterUpdateDOCs BOOLEAN := false;
-- Флаг работы триггера SP.DOCS_ad
AfterDeleteDOCs BOOLEAN := false;

-- Флаги каскадного удаления параметров объектов.
ObjectParDeleting BOOLEAN := false;
ModObjParDeleting BOOLEAN := false;

-- Флаг каскадного удаления объектов модели.
ModelDeleting NUMBER := null;

-- Имя удаляемого объекта.
DeletingObject VARCHAR2(128) := '';

-- Флаг разрешения изменения "OID" для объекта модели
ForceOID BOOLEAN := false;

-- Флаги изменения именованых значений.
AfterUpdateEnum BOOLEAN := false;
AfterDeleteEnum BOOLEAN := false;

-- Флаг работы триггера SP.TRANS_ai
AfterInsertTrans BOOLEAN := false;
-- Флаг работы триггера SP.TRANS_au
AfterUpdateTrans BOOLEAN := false;
-- Флаг работы триггера SP.TRANS_ad
AfterDeleteTrans BOOLEAN := false;

--*****************************************************************************
-- Перед инициированием исключения мы должны сбросить флаги триггеров
-- и очистить временные таблицы.
-- Процедуру желательно применять и перед всеми откатами.
PROCEDURE ResetFlags;

-- Функции возвращающие переменные данного пакета для SQL.
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
-- Функция предоставляет имя текущей модели.
FUNCTION Get_CurModel_NAME return VARCHAR2;
--
FUNCTION Get_CurBuh return NUMBER;
pragma RESTRICT_REFERENCES(Get_CurBuh,WNDS);
--
-- Функция предоставляет имя текущей бухгалтерии.
FUNCTION Get_CurBuh_NAME return VARCHAR2;
--
FUNCTION Get_CurServer return NUMBER;
pragma RESTRICT_REFERENCES(Get_CurServer,WNDS);
--
END TG;
/
