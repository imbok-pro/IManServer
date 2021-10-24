CREATE OR REPLACE PACKAGE SP.TJ#ELECTRO
-- TJ Отчеты по электрической части
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2020-12-07
-- update 2020-12-08:2020-12-15:2020-12-19:2020-12-28

AS
--Запись (строка) кабельного журнала.  
Type R_CAB_JOURNAL Is Record
(
    CABLE_ID NUMBER,
    -- KKS кабеля    
    CABLE_NAME SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    FROM_DEVICE_ID NUMBER,
    --KKS Устройства
    FROM_DEVICE_NAME SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    FROM_LOCATION_ID NUMBER,
    -- KKS места
    FROM_LOCATION_NAME SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- Location Properties ID - ссылка на псевдообъект, в котором записаны 
    -- свойства места
    FROM_LOCPROP_ID NUMBER,
    TO_DEVICE_ID NUMBER,
    --KKS Устройства
    TO_DEVICE_NAME SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    TO_LOCATION_ID NUMBER,
    -- KKS места
    TO_LOCATION_NAME SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- Location Properties ID - ссылка на псевдообъект, в котором записаны 
    -- свойства места
    TO_LOCPROP_ID NUMBER
);
--Кабельный журнал (таблица).
Type T_CAB_JOURNAL Is Table Of R_CAB_JOURNAL;
--==============================================================================
-- ПЕРЕМЕННЫЕ пакета
-- Имя книги к которой добавляем пары имя значение.
book VARCHAR2(4000);
-- Имя листа к которому добавляем пары имя, значение.
sheet VARCHAR2(4000);
-- Номер ряда для очередной пары.
curRowNum number;


--==============================================================================
--Главное предствление кабельного журнала
--Для работы WorkID$ возвращает таблицу кабельного журнала
--Замечания:
--Вместо ID работы может стоять ID любого другого объекта, потомком которого в 
--иерархии является кабель 
--Вызов функции без аргументов необходим для автоматического заполнения листа
--косел результатами запроса
Function V_CAB_JOURNAL(WorkID$ In Number default null) 
Return  T_CAB_JOURNAL Pipelined;
/*
Implementation pattern

SELECT cj."CABLE_ID", cj."CABLE_NAME"
, cj."FROM_DEVICE_ID", cj."FROM_DEVICE_NAME"
, cj."FROM_LOCATION_ID", cj."FROM_LOCATION_NAME", cj."FROM_LOCPROP_ID"
, cj."TO_DEVICE_ID", cj."TO_DEVICE_NAME"
, cj."TO_LOCATION_ID", cj."TO_LOCATION_NAME", cj."TO_LOCPROP_ID" 
FROM TABLE(SP.TJ#ELECTRO.V_CAB_JOURNAL(WorkID$ => 3498170100 )) cj;

--3498170100
--3658355200
*/
-- Процедуры добавляют пары имя-значение к листу в книге KOCEL.
-- !Перед началом заполнения свойств на листе необходимо присвоить или
-- ПЕРЕПРИСВОИТЬ переменные пакета book,sheet и curRowNum:=1!
-- После заполнения всех свойств необходимо выполнить commit.
procedure add_Property2sheet(PNAME in VARCHAR2, PVALUE in VARCHAR2);                
procedure add_Property2sheet(PNAME in VARCHAR2, PVALUE in NUMBER);                
procedure add_Property2sheet(PNAME in VARCHAR2, PVALUE in DATE);                

end TJ#ELECTRO;