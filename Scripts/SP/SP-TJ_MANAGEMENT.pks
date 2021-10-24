CREATE OR REPLACE PACKAGE SP.TJ_MANAGEMENT
-- SP.TJ_MANAGEMENT package 
-- пакет для работы с моделью TJ
-- by Azarov. SP-TJ_MANAGEMENT.pkbs
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 08.02.18
-- update 30.03.19  26.07.19 01.08.19 08.08.19 18.09.19 04.11.19 23.12.19
--        17.06.2021 

AS
CurModelId NUMBER;
-- Текущий узел типа РАБОТА, который является корнем модели TJ.
TJ_WORK_ID NUMBER;
TJ_WORK_PATH VARCHAR2(4000);
--Идентификаторы объектов каталога
"TJ.singles.КАБЕЛЬ"  NUMBER;
"TJ.singles.ИЗДЕЛИЕ" NUMBER;
"TJ.singles.МЕСТО"   NUMBER;
"TJ.singles.МАРКА КАБЕЛЯ" NUMBER;
--Идентификаторы параметров объекта каталога "TJ.singles.ИЗДЕЛИЕ"
"HP_Primary_divace"  NUMBER;
"ИД Изображения"     NUMBER;
"Система"            NUMBER;
"HP_Image_layer"     NUMBER;
--Идентификаторы параметров объекта каталога "TJ.singles.МАРКА КАБЕЛЯ"
"Масса ед"           NUMBER;
"Диаметр"            NUMBER;

--Идентификаторы веток модели
--"КАБЕЛИ"  NUMBER;
--"ИЗДЕЛИЯ" NUMBER;
"МЕСТА"   NUMBER;
"СИСТЕМЫ" NUMBER;
"ИДЕНТИФИКАТОРЫ ИЗОБРАЖЕНИЙ" NUMBER;
"МАРКИ КАБЕЛЯ" NUMBER;
"ПОМЕЩЕНИЯ" NUMBER;

-- Идентификатор каталога для обнаружения всех объектов типа КАБЕЛЬ в моделях.
"КАБЕЛЬ" NUMBER;

-- Идентификатор каталога для обнаружения всех объектов типа ЖИЛА КАБЕЛЯ в моделях.
"ЖИЛА КАБЕЛЯ" NUMBER;
-- Идентификатор каталога для обнаружения всех объектов типа ИЗДЕЛИЕ в моделях.
"ИЗДЕЛИЕ" NUMBER;
-- Идентификатор каталога для обнаружения всех объектов типа ВЫВОД ИЗДЕЛИЯ в моделях.
"ВЫВОД ИЗДЕЛИЯ" NUMBER;
-- Идентификатор каталога для обнаружения всех объектов типа СИСТЕМА в моделях.
"СИСТЕМА" NUMBER;
-- Идентификатор каталога для обнаружения всех объектов типа +МЕСТО в моделях.
"+МЕСТО" NUMBER;
-- Id-ы систем, которые нужно обработать
selectedSystemIds SP.TNUMBERS;

-- строка таблицы кабельного журнала
type TJ_REC is record
(
"ID"                  NUMBER,
"Номер_порядковый"    NUMBER, 
"Система"             VARCHAR2(256),
"Марка"               VARCHAR2(256), 
"Откуда"              VARCHAR2(500), 
"Откуда_Подробно"     VARCHAR2(500), 
"Куда"                VARCHAR2(500),
"Куда_Подробно"       VARCHAR2(500), 
"Заводская_марка"     VARCHAR2(256),
"Число_жил_и_сечение" VARCHAR2(256),
"Напряжение"          NUMBER, 
"Класс_цепи"          VARCHAR2(256),
"Длина"               NUMBER,  
"покабконстр"         NUMBER, 
"втрубе"              NUMBER, 
"влотках"             NUMBER, 
"вкоробах"            NUMBER, 
"поперфпроф"          NUMBER, 
"наскобах"            NUMBER, 
"покабконстрвысота5м" NUMBER, 
"втрубевысота5м"      NUMBER, 
"влоткахвысота5м"     NUMBER, 
"вкоробахвысота5м"    NUMBER, 
"поперфпрофвысота5м"  NUMBER, 
"наскобахвысота5м"    NUMBER, 
"натросе"             NUMBER, 
"вкабканале"          NUMBER, 
"вземле"              NUMBER
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
"ID_Помещения"        NUMBER,
"XYZ"                 VARCHAR2(3000),  
"ID_Места"            NUMBER,
"ID_Системы"          NUMBER,
"Габариты"            VARCHAR2(3000), 
"ID_Изображения"      NUMBER,
"Дополнительно"       VARCHAR2(3000),
M_DATE                DATE              
);
type Device_TABLE is table of Device_REC;

type Tray_REC is record
(
--"ID"                  NUMBER,
"Номер_порядковый"    NUMBER, 
--"Система"             VARCHAR2(256),
"Марка"               VARCHAR2(256), 
"Откуда"              VARCHAR2(500), 
--"Откуда_Подробно"     VARCHAR2(500), 
"Куда"                VARCHAR2(500),
--"Куда_Подробно"       VARCHAR2(500), 
"Маршрут"             VARCHAR2(32000),
"Длины"               VARCHAR2(32000),
"Класс_цепи"          VARCHAR2(32000),
"Напряжение"          VARCHAR2(32000), 

"Заводская_марка"     VARCHAR2(32000),
"Число_жил_и_сечение" VARCHAR2(32000),
"Резерв"              VARCHAR2(32000),
"Длина"               NUMBER,  
"Общий_вес"           NUMBER,
"Сумма_диаметров"       NUMBER
);
type Tray_TABLE is table of Tray_REC;

type XY is record (Diameter NUMBER, Weight NUMBER);
TYPE CableTypes IS TABLE OF XY INDEX BY VARCHAR2(250);
"ХАРАКТЕРИСТИКИ КАБЕЛЯ" CableTypes;

FUNCTION get_CableWeight(cablename varchar2) return number;
FUNCTION get_CableDiameter(cablename varchar2) return number;

-- Процедура устанавливает Id текущей работы (корень всех объектов). 
PROCEDURE setCurTJWorkId(Work_Path VARCHAR2);
PROCEDURE setCurTJWorkId(Work_ID NUMBER);
-- замена кириллических букв на визуально похожие латинские буквы
--function replaceCurToLat(str varchar2) return varchar2;
-- замена латинских букв на визуально похожие кириллическиие буквы
--function replaceLatToCur(str varchar2) return varchar2;

-- Процедура обновляет данные временной таблицы TJ_CABLES. 
PROCEDURE updateTJ_CABLES;

-- Функция взвращает Id объекта (корень ветки объектов) по полному имени
FUNCTION getRoot(rootName VARCHAR2) RETURN NUMBER;

-- Функция возвращает идентификаторы всех КАБЕЛЕЙ текущей модели
FUNCTION get_Cables return SP.TNUMBERS pipelined;

-- Функция возвращает идентификаторы  и параметры всех ИЗДЕЛИЙ текущей модели
FUNCTION get_Devices return Device_TABLE pipelined;

-- возвращает наименования всех слоев для изделий текущей модели
FUNCTION get_LayerName return SP.TSTRINGS pipelined;

-- Функция ищет изделие по имени
FUNCTION getDevice(placeName VARCHAR2) RETURN NUMBER;

-- возвращает строку значений избранных параметров изделия 
FUNCTION getDeviceParameters(deviceId IN NUMBER) RETURN VARCHAR2;

-- формирует КЖ из данных кабелей для:
-- если SYSID != null и SYSID != 0 принадлежащих системе, 
-- если SYSID = null всех систем
-- SYSID = 0 систем, Id-ы которых находятся в коллекции selectedSystemIds
FUNCTION get_CableTable(SYSID in NUMBER, LengthParamName VARCHAR2) 
return TJ_TABLE pipelined;

-- формирует КЖ из данных распарсенного дампа BRCM
FUNCTION get_CableTableBRCM(WORK_ID in NUMBER) 
return TJ_TABLE pipelined;

-- формирует журнал кабельных трасс по лоткам
FUNCTION get_CableTrack(SYSID in NUMBER) return TJ_TABLE pipelined;

-- формирует журнал кабельных трасс по лоткам BRCM
FUNCTION get_TrayTableBRCM(WORK_ID in NUMBER) return Tray_TABLE pipelined;

-- таблица наполнения лотков кабелями
FUNCTION get_RouteTableBRCM(WORK_ID in NUMBER) return Tray_TABLE pipelined; 


-- возвращает ИЗДЕЛИЯ, находящиеся где угодно,
-- принадлежащие системе и имеющие заданный ИД изображения.
-- Для генерации перечней оборудования программой ReportGenerator
-- (функцию использует генератор транспортных форм для BRCM)
--FUNCTION get_Equipment(SYSID in NUMBER, VIEW_ID in NUMBER) return Equipment_TABLE pipelined;

-- возвращает ИЗДЕЛИЯ, находящиеся где угодно, имеющие заданный ИД изображения.
-- Для генерации перечней оборудования программой ReportGenerator
-- (функцию использует генератор транспортных форм для BRCM)
-- FUNCTION get_AllSystemsEquipment(VIEW_ID in NUMBER) return Equipment_TABLE pipelined;

-- формирует перечень изделий, относящихся к заданной (Id-ом) системе  
-- если идентификатор не задан, то бертся изделия всех систем
-- (функцию использует генератор КЖ)
FUNCTION get_EquipmentOfSystem(SYSID NUMBER, LengthParamName varchar2) return TJ_TABLE pipelined;

-- формирует перечень изделий, относящихся к како-либо из заданных 
-- (набором Id-ов в коллекции selectedSystemIds) систем 
FUNCTION get_EquipmentOfSystemArray(LengthParamName varchar2) return TJ_TABLE pipelined;

-- формирует перечень изделий, относящихся к заданному слою и 
-- имеющих заданный тип изображения
FUNCTION get_Equipment(LAYER in VARCHAR, VIEW_ID in NUMBER) return Equipment_TABLE pipelined;

-- заполняет коллекцию selectedSystemIds
FUNCTION set_selectedSystemIds(Ids SP.TNUMBERS) return NUMBER;
-- возвращает коллекцию selectedSystemIds
FUNCTION get_selectedSystemIds return SP.TNUMBERS pipelined;

-- читает значение параметра "Набор систем" текущей РАБОТЫ
--FUNCTION get_SystemSampling return SP.V;

-- записывает значение параметра "Набор систем" в текущую РАБОТУ
--FUNCTION set_SystemSampling (ids in SP.V) return SP.V;

FUNCTION TryDeleteDeletedObjects(ModelObjectPID$ In Number) 
Return BINARY_INTEGER; 

END TJ_MANAGEMENT;
