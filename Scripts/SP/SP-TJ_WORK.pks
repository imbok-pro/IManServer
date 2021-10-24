CREATE OR REPLACE PACKAGE SP.TJ_WORK
-- Процедуры общего назначения для работы с объектом "РАБОТА" и подчинёнными
-- ему объектами
-- File: SP-TJ_WORK.pks
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-09-16
-- update 2019-09-17 2019-10-30 2019-11-21 2020-12-07:2020-12-17

AS
--==============================================================================
--тип данных для имён наименований типов кабельных конструкций 
SubType T$CABLE_CONSTRUCTUIN_TYPENAME Is Varchar2(20);

--тип данных для хранения GUID-ов в строковом представлении 
Type T_MODEL_OBJECTS Is Table Of SP.MODEL_OBJECTS%ROWTYPE;
--Отображение имен в ID
Type AA_ObjName2ID Is Table Of Number
    Index By SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
    
Type AA_ModObjOID2OID Is Table Of SP.MODEL_OBJECTS.OID%TYPE
Index By SP.MODEL_OBJECTS.OID%TYPE;    
--==============================================================================
SINAME_WORK CONSTANT Varchar2(40):='TJ.singles.РАБОТА';
SINAME_GENERYC_SYSTEM CONSTANT Varchar2(40):='PPM.singles._GENERIC_SYSTEM';
SINAME_DEVICE CONSTANT Varchar2(40):='TJ.singles.ИЗДЕЛИЕ';
SINAME_DEVICE_PIN CONSTANT Varchar2(40):='TJ.singles.PIN ИЗДЕЛИЯ';
SINAME_CABLE CONSTANT Varchar2(40):='TJ.singles.КАБЕЛЬ';
SINAME_CABLE_WIRE CONSTANT Varchar2(40):='TJ.singles.ЖИЛА КАБЕЛЯ';
SINAME_FUNCTIONAL_SYSTEM CONSTANT Varchar2(40):='TJ.singles.СИСТЕМА';
SINAME_LOCATION CONSTANT Varchar2(40):='TJ.singles.МЕСТО';
SINAME_IMAGE_ID CONSTANT Varchar2(40):='TJ.singles.ИДЕНТИФИКАТОР ИЗОБРАЖЕНИЯ';


--Имя сингла, обозначающего лоток в модели TJ
SINAME_TRAY CONSTANT Varchar2(40):='TJ.singles.ЛОТОК';
--Имя сингла, обозначающего учаток кабельной трассы в модели TJ
SINAME_CWS CONSTANT Varchar2(40):='TJ.singles.CABLE_WAY_SEGMENT';
--Имя сингла, обозначающего элемент отношения CableSegment в модели TJ
SINAME_CABLE_SEGMENT CONSTANT Varchar2(40):='TJ.singles.CableSegment';

--Имя папки с кабельными конструкциями
CABLE_CONSTRUCTIONS_NAME CONSTANT Varchar2(40):='КАБЕЛЬНЫЕ КОНСТРУКЦИИ';
--Имя папки с локами
TRAYS_NAME CONSTANT T$CABLE_CONSTRUCTUIN_TYPENAME :='ЛОТКИ';
--Имя папки с трубами
TUBES_NAME CONSTANT T$CABLE_CONSTRUCTUIN_TYPENAME :='ТРУБЫ';
--Имя папки с воздушными проёмами
AIRGAPS_NAME  CONSTANT T$CABLE_CONSTRUCTUIN_TYPENAME :='ВОЗДУХ';
--Имя папки отношений многие ко многим
REFERENCES_NAME CONSTANT Varchar2(20):='REFERENCES';

--==============================================================================
--Ключевая информация о параметре объекта каталога 
Type R_ObjParKey Is Record
(
  --ID Объекта каталога
  OBJ_ID NUMBER,
  --ID параметра объекта каталога
  OBJ_PAR_ID NUMBER
);
--==============================================================================
--Сегмент трассы кабеля
Type R_CABLE_WAY_SEGMENT Is Record
(
  --ID Кабеля
  CABLE_ID NUMBER,
  --Наименование кабеля
  CABLE_NAME SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
  --порядковый номер сегмента 
  ORDINAL NUMBER,
  --наименование сегмента
  SEGMENT_NAME SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
  --тип сегмента ('ВОЗДУХ','ТРУБЫ','ЛОТКИ')
  CABLE_CONSTRUCTUIN_TYPENAME T$CABLE_CONSTRUCTUIN_TYPENAME,
  --Длина сегмента
  LENGTH NUMBER,
  --минимальная аппликата сегмента
  Z_MIN NUMBER,
  --максимальная аппликата сегмента
  Z_MAX NUMBER
);
--Кабельные трассы
Type T_CABLE_WAYS Is Table Of R_CABLE_WAY_SEGMENT;
--==============================================================================
--Лог длинных строк
--Если строки короткие, то  делает их конкатенацию
--Если строки длинные, то записывает в лог начало (mess1$)
--а затем заменяет начало хвостом (mess2$)
Procedure D_Long(mess1$ In Out Varchar2, mess2$ In Varchar2, Tag$ In Varchar2 );
--==============================================================================
--Устанавливает Текущую работу.
--Если WorkID$ не есть объект типа работа, то возникает прерывание.
Procedure SetCurWork(WorkID$ In Number);
--==============================================================================
--Возвращает ID объекта "РАБОТА"
Function WorkID Return Number;
--==============================================================================
--Возвращает ID объекта каталога по его полному имени
Function GetObjectID(ObjFullName$ In Varchar2) Return Number;
--==============================================================================
--Возвращает ID объекта модели 
Function GetModelObjectID(
MODEL_ID$ In Number  --ID модели
, OBJ_ID$ In Number  --ID объекта каталога
, ModObjName$ In Varchar2  -- Имя объекта модели
) 
Return Number;
--==============================================================================
--Возвращает ID устройства модели по его имени (KKS) или Null
Function GetDeviceID(
MODEL_ID$ In Number  --ID модели
, DeviceName$ In Varchar2  -- Имя (KKS) устройства
) 
Return Number;
--==============================================================================
--Возвращает ID параметра объекта каталога по ID элемента и 
--его (параметра) имени.
Function GetObjectParID(ObjectID$ In Number, ParName$ In Varchar2)
Return Number;
--==============================================================================
--Возвращает ID параметра объекта каталога по полному имени объекта каталога и 
--его (параметра) имени.
Function GetObjectParID(ObjFullName$ In Varchar2, ParName$ In Varchar2)
Return Number;
--==============================================================================
--Возвращает ключевую информацию о параметре объекта каталога 
--(i.e. ID объекта каталога и ID параметра объекта каталога) 
--по полному имени объекта каталога и его (параметра) имени.
Function GetObjParKey(ObjFullName$ In Varchar2, ParName$ In Varchar2)
Return R_ObjParKey;
--==============================================================================
-- Быстро возвращает GENERYC_SYSTEM_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_GENERYC_SYSTEM_OBJECT_ID Return Number;
--==============================================================================
-- Быстро возвращает CABLE_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_CABLE_OBJECT_ID Return Number;
--==============================================================================
-- Быстро возвращает CABLE_WIRE_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_CABLE_WIRE_OBJECT_ID Return Number;
--==============================================================================
-- Быстро возвращает DEVICE_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_DEVICE_OBJECT_ID Return Number;
--==============================================================================
-- Быстро возвращает LOCATION_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_LOCATION_OBJECT_ID Return Number;
--==============================================================================
-- Быстро возвращает TRAY_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_TRAY_OBJECT_ID Return Number;
--==============================================================================
-- Быстро возвращает CWS_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_CWS_OBJECT_ID Return Number;
--==============================================================================
-- Быстро возвращает CABLE_SEGMENT_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_CABLE_SEGMENT_OBJECT_ID Return Number;
--==============================================================================
--Быстро возвращает ID параметра 'ZMIN_ZMAX_LENGTH' объекта CABLE_SEGMENT 
Function Get_PARID_ZMINMAX_LENGTH Return Number;
--==============================================================================
--Быстро возвращает ID параметра 'ORDINAL' объекта CABLE_SEGMENT 
Function Get_PARID_ORDINAL Return Number;
--==============================================================================
--Быстро возвращает ID параметра 'REF_CABLE' объекта CABLE_SEGMENT 
Function Get_PARID_REF_CABLE Return Number;
--==============================================================================
--Быстро возвращает ID параметра 'REF_SHELF' объекта CABLE_SEGMENT 
Function Get_PARID_REF_SHELF Return Number;
--==============================================================================
--Возвращает ID дочернего объекта или Null
Function GetChildByOID(ParentID$ In Number, ChildOID$ In Varchar2)
Return Number;

--==============================================================================
--Возвращает ID дочернего объекта или Null
Function GetChildByName(ParentID$ In Number, ChildName$ In Varchar2)
Return Number;

--==============================================================================
--Достаёт всех потомков объекта RootModObjID$, имеющих OBJ_ID = ObjectID$
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
-- Достаёт все псевдообъекты, подчинённые работе WorkID$
-- Вместо ID работы, может стоять ID любого другого объекта модели, 
-- которому подчинены устройства
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
-- Возвращает ассоциативный массив всех псевдообъектов (Имена и ID), 
-- подчинённых работе WorkID$. 
-- Вместо ID работы, может стоять ID любого другого объекта модели, 
-- которому подчинены устройства
Function Get#PDOs(WorkID$ In Number) Return SP.TJ_WORK.AA_ObjName2ID;
--==============================================================================
-- Возвращает ассоциативный массив всех устройств (Имена и ID), 
-- подчинённых работе WorkID$. 
-- Вместо ID работы, может стоять ID любого другого объекта модели, 
-- которому подчинены устройства
Function Get#DEVICES(WorkID$ In Number) Return SP.TJ_WORK.AA_ObjName2ID;
--==============================================================================
-- Заполняет индекс 'MOD_OBJ_NAME'->'RID' объектов-потомков RootModObjID$,
-- тип которых есть ObjectID$ 
Procedure Get_MODEL_OBJECT_IDX(RootModObjID$ In Number, ObjectID$ In Number,
  idx$ In Out Nocopy AA_ObjName2ID);
--==============================================================================
-- Очищает разделы 'REFERENCES' и подразделы 'ЛОТКИ' и 'ТРУБЫ' 
-- раздела 'КАБЕЛЬНЫЕ КОНСТРУКЦИИ', относящихся к работе WORK_ID$.
Procedure Cable_Constructions_Clear(WORK_ID$ In Number);
/*
--Implementation pattern

Begin
  SP.TJ_WORK.Cable_Constructions_Clear(WORK_ID$ => 3498170100);
  commit;
End;
*/
--==============================================================================
--Для работы возвращает все сегменты кабельных трасс
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
-- Перебирает все жилы кабеля до тех пор, пока не найдет первую попавшуюся жилу, 
-- у которой значение выбранного параметра (REF_PIN_FIRST или REF_PIN_SECOND) 
-- не есть Null и возвращает ID, соответствующий этому значению.
-- В случае провала возвращает Null.
-- Значение параметра ParamName$ может быть либо 'REF_PIN_FIRST' 
-- либо 'REF_PIN_SECOND'.
Function Get_CableRefPinID(CableID$ In Number, ParamName$ In Varchar2) 
Return Number;
--==============================================================================
--Возвращает значение булева параметра ParamName$ для объекта модели ModObjID$
--Если параметр отсутствует или он не булев, то возвращает null;
Function GetParamBoolean(ModObjID$ In Number,ParamName$ In Varchar2) 
Return Boolean;
--==============================================================================
-- В таблице SP.MODEL_OBJECTS заменяет все значения OID модели MidelID$, 
-- имеющиеся в ключе ассоциативного массива Oid_AA$ на соответствующие значения 
-- того же ассоциативного массива.
Procedure UpdateOIDs
(Oid_AA$ In Out NoCopy SP.TJ_WORK.AA_ModObjOID2OID, ModelID$ In Number);
--==============================================================================
End TJ_WORK;