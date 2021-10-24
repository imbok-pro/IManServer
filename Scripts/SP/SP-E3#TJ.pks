CREATE OR REPLACE PACKAGE SP.E3#TJ
-- Процедуры обмена данными межу Zuken e3.Series и Total Journal
-- см. документ 
-- E3.02.Синхронизация данных КЖ из E3 в TJ.Рабочие материалы.pdf
-- в папке ...\vm-polinom\Pln\07_IMan\07_Server\E3Server\docs\E3\
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-07-03
-- update 2019-09-12 2019-10-28 2019-12-27 2020-07-29 2020-12-14:2020-12-16

AS

TYPE AA_ShortStr2ShortStr Is Table Of Varchar2(128) INDEX BY Varchar2(128);
TYPE AA_ShortStr2Int Is Table Of BINARY_INTEGER 
  Index By SP.V_MODEL_OBJECT_PARS.PARAM_NAME%TYPE;
  
--типы оборудования (значения соответству)
EQP_DEVICE CONSTANT Varchar2(20):='Device';                 --E3TYPE
EQP_CABLE CONSTANT Varchar2(20):='Cable';                   --E3TYPE
EQP_TERMINAL CONSTANT Varchar2(20):='Terminal';             --E3TYPE
EQP_TERMINAL_BLOCK CONSTANT Varchar2(20):='TerminalBlock';  --E3TYPE

--==============================================================================
--Лог длинных строк
--Если строки короткие, то  делает их конкатенацию
--Если строки длинные, то записывает в лог начало (mess1$)
--а затем заменяет начало хвостом (mess2$)
Procedure D_Long(mess1$ In Out Varchar2, mess2$ In Varchar2, Tag$ In Varchar2 );
--==============================================================================
--копирует (добавляет) параметры из From$ в To$
Procedure COPY_MACRO_PARS
(From$ In SP.G.TMACRO_PARS, To$ In Out NoCopy SP.G.TMACRO_PARS);
--==============================================================================
-- Удаляет параметры из списка From$, 
-- которые не содержатся в эталонном списке Etalon$
Procedure REMOVE_MACRO_PARS
(Etalon$ In SP.G.TMACRO_PARS, From$ In Out NoCopy SP.G.TMACRO_PARS);
--==============================================================================
--копирует (добавляет) объекты из From$ в To$
Procedure COPY_OBJECTS
(From$ In SP.G.TOBJECTS, To$ In Out NoCopy SP.G.TOBJECTS);
--==============================================================================
--Возвращает ID объекта модели по PARENT_MOD_OBJ_ID$ и его имени 
Function Get_MOD_OBJ_ID
(PARENT_MOD_OBJ_ID$ In Number, MOD_OBJ_NAME$ In Varchar2) Return Number;
--==============================================================================
--Возвращает набор параметров сингла МЕСТО
Function Get_LocatiоnSingleParams Return SP.G.TMACRO_PARS;
--==============================================================================
--Возвращает набор параметров сингла СИСТЕМА
Function Get_SystemSingleParams Return SP.G.TMACRO_PARS;
--==============================================================================
--Возвращает набор динамических параметров устройства
Function Get_DeviceDynaParams Return SP.G.TMACRO_PARS;  
--==============================================================================
--Возвращает набор статических параметров устройства, необходимых для репликации
Function Get_DeviceStatParams Return SP.G.TMACRO_PARS;
--==============================================================================
-- Возвращает набор статических параметров пинов устройства,
-- необходимых для репликации
--Function Get_DevicePinStatParams Return SP.G.TMACRO_PARS;
--==============================================================================
--Возвращает набор статических параметров кабеля, необходимых для репликации
Function Get_CableStatParams Return SP.G.TMACRO_PARS;
--==============================================================================
--Возвращает копию CableParamList
--Function Get_CableParamList Return T_StrKeys;

--Возвращает набор динамических параметров кабеля
Function Get_CableDynaParams Return SP.G.TMACRO_PARS;
--==============================================================================
--Возвращает набор статических параметров жилы кабеля, 
--необходимых для репликации
Function Get_CableWireStatParams Return SP.G.TMACRO_PARS;
--==============================================================================
--Возвращает набор динамических параметров жилы кабеля
Function Get_CableWireDynaParams Return SP.G.TMACRO_PARS;
--==============================================================================
--Параметры DevicePin, запрашиваемые у API Zuken e3.Series
Function E3RP_DevicePin Return SP.G.TMACRO_PARS;
--==============================================================================
--Параметры Cable Wire, запрашиваемые у API Zuken e3.Series
Function E3RP_CableWire Return SP.G.TMACRO_PARS;
--==============================================================================
--Помечает на удаление объекты-непосредственные-потомки от ParentModObjID$,
--у которых значение параметра SOURCE_SAPR совпадает с SourceSapr$
Procedure MarkToDelete1(ParentModObjID$ In Number, SourceSapr$ In Varchar2);
--==============================================================================
--Помечает на удаление объекты-потомки от RootModObjID$,
--у которых значение параметра SOURCE_SAPR совпадает с SourceSapr$
Procedure MarkToDeleteDesc(RootModObjID$ In Number);
--==============================================================================
--Помечает на удаление объекты-непосредственные-потомки от ParentModObjID$,
--у которых значение параметра ObjParID$ совпадает с SourceSapr$
Procedure MarkToDelete(ParentModObjID$ In Number, ObjParID$ In Number);

--==============================================================================
--Отменяет пометку удаления, у объекта ModObjID$
Procedure UnMarkToDelete(ModObjID$ In Number);
--==============================================================================
--Удаляет объекты-непосредственные-потомки от ParentModObjID$,
--у которых SP.MODEL_OBJECTS.TO_DEL = 1.
--Если возникает ошибка, то пишет предупреждение в лог с тегом 
--'WARNING SP.E3#TJ.DeleteMarked' и продолжает работать.
Procedure DeleteMarked(ParentModObjID$ In Number);
--==============================================================================
--Удаляет объекты-потомки от ParentModObjID$,
-- у которых SP.MODEL_OBJECTS.OBJ_ID = ObjectID$
-- и SP.MODEL_OBJECTS.TO_DEL = 1.
--Если возникает ошибка, то пишет предупреждение в лог с тегом 
--'WARNING SP.E3#TJ.DeleteMarkedDesc' и продолжает работать.
Procedure DeleteMarkedDesc(ParentModObjID$ In Number, ObjectID$ In Number);
/*

*/
--==============================================================================
--Создаёт объект или меняет его и помечает ему TO_DEL=0
Function CreateOrUpdate
(IP$ In Out NoCopy SP.G.TMACRO_PARS, UsedObjectID$ In Number)
Return Varchar2;
--==============================================================================
--Получает ID Объекта модели по его предку, имени и объекту каталога
--Если объекта не существует, то создаёт его.
Function GetOrCreateObject
(ModObjName$ In varchar2, PID$ in Number, ObjectID$ In Number) return Number;

--==============================================================================
--Удаляет все объекты, у которых дедушка FOLDER_ID$ и папа SubFolderName$
--Есди ткой конструкции (FOLDER_ID$/SubFolderName$) не найдено, 
--то ничего не делает
Procedure DeleteSubfolderContainment
(FOLDER_ID$ In Number, SubFolderName$ In Varchar2);
--==============================================================================
-- Очищает (удаляет) все параметры типа TRel у всех объектов типа 
-- LOCATION_OBJECT, подчинённых работе WorkID$.
-- Вместо ID работы может стоять ID любого другого объекта, потомком которого в 
--иерархии является МЕСТО 
Procedure ClearLocationRELs(WorkID$ In Number);
--==============================================================================
--Удаляет устройство E3 из модели TJ
-- Устройство некогда было удалено и воссоздано в API Zuken e3.Series 
-- с тем же именем, но другим OID
--Удаляет устройство если имя его равно DeviceName$, но OID не равен DeviceOID$
--в противном случае - ничего не делает.
--TODO Не дописана на случай, когда кто-нибудь ссылается на устройство
-- или один из его пинов.
--Рабочая версия размещается в макропроцедуре E3=>TJ (КАБЕЛЬНЫЙ ЖУРНАЛ)
Procedure DeleteE3Device(
PID$ In Number  --ID объекта-предка устройства
, DeviceName$ In Varchar2  --Имя устройства
, DeviceOID$ In Varchar2   --OID устройства
);

--==============================================================================
--Удаляет кабели без позиций, у которых PARENT=ParentID$
  --ParentID$:=668152500;
Procedure DeleteCablesWihoutPositions(ParentID$ In Number);
/*

*/
--==============================================================================
--##############################################################################
--РАБОТА С КЛАССИФИКАТОРОМ KKS В МОДЕЛИ TJ
--==============================================================================
--Консеквент индекса KKS->папки устройств и кабелей 
Type R_KKS_2FOLDER Is Record
(
  --ID Объекта модели
  DEVICE_FOLDER_ID NUMBER,
  --ID Объекта модели
  CABLE_FOLDER_ID NUMBER
);

Type T_KKS_2FOLDERS Is Table Of R_KKS_2FOLDER 
Index By SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;

Type T_KKS_1FOLDERS Is Table Of Number
Index By SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;

DEVICE_SECTION_NAME CONSTANT Varchar2(20):='УСТРОЙСТВА';
CABLE_SECTION_NAME CONSTANT Varchar2(20):='КАБЕЛИ';

kks_AGREGATE_OBJECT_NAME CONSTANT Varchar2(40):='TJ.singles.KKS1_AGREGATE';
kks_SYSTEM_OBJECT_NAME CONSTANT Varchar2(40):='TJ.singles.KKS2_SYSTEM';
kks_SUBSYSTEM_OBJECT_NAME CONSTANT Varchar2(40):='TJ.singles.KKS3_SUBSYSTEM';

RepArray_SINGLE_NAME CONSTANT Varchar2(40):='TJ.singles.RepArray';

IMAGE_ID_SINGLE_NAME CONSTANT 
      Varchar2(40):='TJ.singles.ИДЕНТИФИКАТОР ИЗОБРАЖЕНИЯ';

--==============================================================================
-- Быстро возвращает kks_AGREGATE_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_kks_AGREGATE_OBJECT_ID Return Number;
--==============================================================================
-- Быстро возвращает kks_SYSTEM_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_kks_SYSTEM_OBJECT_ID Return Number;
--==============================================================================
-- Быстро возвращает kks_SUBSYSTEM_OBJECT_ID и, в случае необходимости, 
-- кэширует его.
Function Get_kks_SUBSYSTEM_OBJECT_ID Return Number;
--==============================================================================
--Для объекта (как правило, это работа) ParentID$ возвращает 
--  1. KKS_1FOLDER_AA$ - индекс KKS -> раздел классификатора 
--    (SP.MODEL_OBJECTS.ID)
--  2. KKS_2FOLDER_AA$ - индекс KKS -> (ID папки УСТРОЙСТВА, ID папки КАБЕЛИ) 
Procedure Get_KKS_STRUCTURE_INDEXES(ParentID$ In Number
, KKS_1FOLDER_AA$ In Out NoCopy T_KKS_1FOLDERS
, KKS_2FOLDER_AA$ In Out NoCopy T_KKS_2FOLDERS);
--==============================================================================
--Для объекта (как правило, это работа) ParentID$ доопределяет KKS-классификатор
--данными из E3Systems$
--  1. KKS_1FOLDER_AA$ - индекс KKS -> раздел классификатора 
--    (SP.MODEL_OBJECTS.ID)
--  2. KKS_2FOLDER_AA$ - индекс KKS -> (ID папки УСТРОЙСТВА, ID папки КАБЕЛИ) 
Procedure COMPLETE_KKS_STRUCTURE(
ParentID$ In Number, E3Systems$ In Out NoCopy SP.G.TOBJECTS
, KKS_1FOLDER_AA$ In Out NoCopy T_KKS_1FOLDERS
, KKS_2FOLDER_AA$ In Out NoCopy T_KKS_2FOLDERS);
--==============================================================================
--Для объекта (как правило, это работа) ParentID$ доопределяет KKS-классификатор
-- разделами, предназначенными для хранения неклассифицированных данных, 
-- соотвествующими индексам
--  1. 00
--  2. 00BHE KKS
--  3. 00BHE KKS00
Procedure COMPLETE_KKS_STRUCTURE_BHE_KKS(
ParentID$ In Number
, KKS_1FOLDER_AA$ In Out NoCopy T_KKS_1FOLDERS
, KKS_2FOLDER_AA$ In Out NoCopy T_KKS_2FOLDERS);

--==============================================================================
--Удаляет все объекты-потомки-кабели от RootModObjID$
Procedure DeleteCables(RootModObjID$ In Number);

--==============================================================================
--Удаляет все объекты-потомки-устройства от RootModObjID$
Procedure DeleteDevices(RootModObjID$ In Number);

--==============================================================================
--##############################################################################
--РЕПЛИКАЦИЯ ДАННЫХ ИЗ Zuken e3.series в TJ
--==============================================================================
Type R_REP_ARRAYS_INFO Is Record
(
  --ID Объекта каталога
  DELETED_GROUP_ID SP.ARRAYS.GROUP_ID%TYPE,
  DELETED_ARRAY_NAME SP.ARRAYS.NAME%TYPE,
  INSERTED_GROUP_ID SP.ARRAYS.GROUP_ID%TYPE,
  INSERTED_ARRAY_NAME SP.ARRAYS.NAME%TYPE,
  UPDATED_GROUP_ID SP.ARRAYS.GROUP_ID%TYPE,
  UPDATED_ARRAY_NAME SP.ARRAYS.NAME%TYPE
);


--==============================================================================
--Инициализирует переменные пакета
-- vSOURCE_SAPR_
-- sPROJECT_NUMBER_
Procedure Set_SOURCE_SAPR(E3_JOB_OID$ In Varchar2);
--==============================================================================
--Возвращает переменную пакета SOURCE_SAPR
Function SOURCE_SAPR Return Varchar2;
--==============================================================================
--Возвращает переменную пакета SOURCE_SAPR
Function PROJECT_NUMBER Return Varchar2;
--==============================================================================
-- Быстро возвращает RepArray_SINGLE_ID и, в случае необходимости, 
-- кэширует его.
Function Get_RepArray_SINGLE_ID Return Number;
--==============================================================================
--Возвращает информацию об основных параметрах репликационных массивов
--модели MODEL_ID$
--Если в модели не предусмотрены репликационные массивы, то все поля 
--возвращенной записи будут Null.
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
--Очищает все переменные и буфера пакета, имеющие отношение к репликации данных
Procedure RepClear;
--==============================================================================
-- Создаёт в корне текущей локальной модели объект репликации, если его нет, и 
-- возвращает его false.
-- Если объект существует, то возвращает true.
-- Если таких объектов несколько, то возбуждает исключение.
Function Create1ReplicationObject(
RepModObjID$ In Out Number  --ID объекта управления репликацией
) return Boolean;
--==============================================================================
--Очищает репликационные массивы текущей модели и проекта (Job) Zuken e3.series.
Procedure ClearReplicationArrays;
--==============================================================================
--Очищает репликационные массивы заданной модели и проекта (Job) Zuken e3.series.
Procedure ClearReplicationArrays(MODEL_ID$ In Number);
--==============================================================================
--Нормализация массивов репликации модели.
--1.	Из массива Inserted удаляются все элементы, 
--    содержащиеся в массиве Deleted.
--2.	Из массива Updated удаляются все элементы, 
--    содержащиеся в массиве Deleted.
--3.	Из массива Updated удаляются все элементы, 
--    содержащиеся в массиве Inserted.
--4.	Из массива Updated удаляются все повторные элементы.
Procedure NormalizeRepArrays(MODEL_ID$ In Number);

--==============================================================================
--Удаление всех объектов, OID которых зарегистрированы в разделе “Deleted” 
-- для GROUP_NAME “RepArrays” из модели MODEL_ID$.
-- Если OID присутствуют в других моделях, то удаления из таблицы SP.ARRAYS
-- не происходит.
Procedure RepDelete(MODEL_ID$ In Number, JOB_NUMBER$ In Varchar2);
--==============================================================================
--Возвращает список OIDs добавленных объектов
Function GetInsertedOIDs(MODEL_ID$ In Number, JOB_NUMBER$ In Varchar2) 
Return SP.TSHORTSTRINGS;
--==============================================================================
--Возвращает список OIDs добавленных или изменённых объектов
--Сначала идут добавленные записи, потом - изменённые.
Function GetInsertedOrUpdatedOIDs(MODEL_ID$ In Number, JOB_NUMBER$ In Varchar2) 
Return SP.TSHORTSTRINGS;
--==============================================================================
-- Для каждого объекта из ModObjs$ заменяет все SymRel на Rel, 
-- при этом подменяет OID из словаря соотвествий OID2OID_AA.
Procedure AllSymRel2Rel(ModObjs$ In Out NoCopy SP.G.TOBJECTS
,OID2OID_AA$ In AA_ShortStr2ShortStr);
--==============================================================================
-- В объекте с номером ii$ ассоциативного массива OBJECTS$ меняет ссылку, 
-- на другую соответственно входному словарю IDX$,
-- где ParamName$ - заранее известное имя параметра-ссылки. 
Procedure ChangeRefOID 
(OBJECTS$ In Out NoCopy SP.G.TOBJECTS, ii$ in Number
, ParamName$ in Varchar2, IDX$ In SP.E3#TJ.AA_ShortStr2ShortStr);
--==============================================================================
-- В OBJECTS$(ii$) меняет имя параметра NameFrom$ на NameTo$ 
-- путем вставки и удаления
Function ChangeObjParName(OBJECTS$ In Out NoCopy SP.G.TOBJECTS,
ii$ in Number, NameFrom$ in Varchar2, NameTo$ In Varchar2)
Return Boolean;
--==============================================================================
--Первичное заполнение индекса идентификаторо изображений данными из локальной 
--модели. Если данных в модели нет, то будет возвращен пустоцй индекс. 
Function ImageID2ID_IDX_Init(IMAGE_FOLDER_ID$ In Number) 
Return AA_ShortStr2ShortStr;
--==============================================================================
-- Создает объекты типа "ИДЕНТИФИКАТОР ИЗОБРАЖЕНИЯ" в папке IMAGE_FOLDER_ID$
-- заполняет индекс ImageID2ID_IDX$ значениями ID созданных идентификаторов 
-- изображений
Procedure CreateIMAGE_IDs(
IMAGE_FOLDER_ID$ In Number
, ImageID2ID_IDX$ In Out NoCopy AA_ShortStr2ShortStr);
--==============================================================================
--Подготовка параметров устройств. Часть 1.
--Формирование отображения OID2OID_Device_IDX$ OID устройства в HP_OID
--DEVICES$ - устройства и выводы (пины) устройств
--OID2OID_Device_IDX$ - отображение OID устройства в HP_OID
Procedure PrepareDevices1(DEVICES$ In Out NoCopy SP.G.TOBJECTS
, boIncludeTerminal$ In Boolean
, OID2OID_IDX$ In SP.E3#TJ.AA_ShortStr2ShortStr  --места, системы
, OID2OID_Device_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr
, ImageID2ID_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr
);
--==============================================================================
--Подготовка параметров устройств. Часть 2.
Procedure PrepareDevices2(OBJECTS$ In Out NoCopy SP.G.TOBJECTS
,KKS_2FOLDER_AA$ In SP.E3#TJ.T_KKS_2FOLDERS
,NO_KKS_2FOLDER$ In SP.E3#TJ.R_KKS_2FOLDER
,ImageID2ID_IDX$ In SP.E3#TJ.AA_ShortStr2ShortStr
,OID2OID_Device_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr
,OID2OID_DevicePin_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr
);
--==============================================================================
--Подготовка параметров кабелей. 
Procedure PrepareCables(CABLES$ In Out NoCopy SP.G.TOBJECTS
, OID2OID_IDX$ In SP.E3#TJ.AA_ShortStr2ShortStr  --места, системы
, OID2OID_DevicePin_IDX$ In SP.E3#TJ.AA_ShortStr2ShortStr
, KKS_2FOLDER_AA$ In SP.E3#TJ.T_KKS_2FOLDERS
, NO_KKS_2FOLDER$ In SP.E3#TJ.R_KKS_2FOLDER
);
--==============================================================================
-- Верификация списка функциональных систем.
-- Если не все системы занесены в классификатор, то 
-- возвращает сообщение об ошибке.
-- В противном случае, когда всё хорошо, возвращает Null.
Function VerifyFuncSystems(FUNC_SYSTEMS$ In Out NoCopy SP.G.TOBJECTS
, KKS_2FOLDER_AA$ In T_KKS_2FOLDERS
) Return Varchar2;
--==============================================================================
-- Создание/редактирование функциональных систем.
-- Возвращает сообщение об ошибке или Null.
Function CreateOrUpdateFuncSystems(FUNC_SYSTEMS$ In Out NoCopy SP.G.TOBJECTS
,SYSTEM_FOLDER_ID$ Number
, OID2OID_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr  --места, системы
) Return Varchar2;
--==============================================================================
-- Создание/редактирование мест.
-- Возвращает сообщение об ошибке или Null.
Function CreateOrUpdateLocations(LOCATIONS$ In Out NoCopy SP.G.TOBJECTS
,LOCATION_FOLDER_ID$ Number
, OID2OID_IDX$ In Out NoCopy SP.E3#TJ.AA_ShortStr2ShortStr  --места, системы
) Return Varchar2;
--==============================================================================
-- Обновляет все значения папаметров PROPS всех объектов модели типа 
-- TJ.singles.МЕСТО, подчинённых работе WorkID$
Procedure UpdLocationProps(WorkID$ In Number);
--==============================================================================
-- Создание/редактирование идентификаторов изображений.
-- Возвращает сообщение об ошибке или Null.
Function CreateOrUpdate_IMAGE_IDs(
ImageID2ID_IDX$ In Out NoCopy AA_ShortStr2ShortStr
,IMAGE_FOLDER_ID$ Number
)Return Varchar2;
--==============================================================================
--##############################################################################
--==============================================================================
--ID объектов
Type R_ObjectID Is Record
(
  --ID Объекта 
  OBJECT_ID NUMBER
);
--таблица ID объектов.
Type T_ObjectIDs Is Table Of R_ObjectID;
--==============================================================================
--Возвращает ID синглов всех объектов, соответствующих изделиям Zuken e3.series,
-- как то устройства, кабели, терминальные устройства, соединители и блоки.
-- Первоначально (2020-07-29) союда включены только кабели и устройства.
Function GetAllDeviceObjIDs Return T_ObjectIDs pipelined;
/*
--Implementation pattern

select OBJECT_ID from TABLE(SP.E3#TJ.GetAllDeviceObjIDs);
*/
--==============================================================================

End E3#TJ;