CREATE OR REPLACE PACKAGE SP.TJ#AEP
-- TJ Отчеты по электрической части для АЭП
-- by AM
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2020-12-21
-- update 2020-12-23 2020-12-24 2021-01-04 2021-01-13 2021-01-14 2021-01-15
--        2021-01-22 2021-01-26 2021-02-12 2021-02-15
--        2021-03-23 2021-03-25 2021-03-26 2021-03-29 2021-03-30
-- By Nikolay Krasilnikov       18-06-2021
--        
-- (SP.TJ#AEP.pks)
AS
-- Запись (строка) полного набора параметров кабельного журнала АЭП
Type R_CAB_JOURNAL Is Record
(
    -- Номер проекта АЭПа
    "PROJECT" VARCHAR2 (128),
    -- Номер кабельного журнала
    "CABLE LOG" VARCHAR2 (128),
    -- KKS (маркировка) кабеля
    "CABLE MARK" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- Тип (марка) кабеля
    "TYPE" VARCHAR2 (40),
    -- Число жил кабеля
    "CORE NUMBER" NUMBER,
    -- Сечение жилы кабеля
    "CORE SECTION" NUMBER,
    -- Номинальное напряжение кабеля
    "VOLTAGE" NUMBER,
    -- Номер технических условий
    "TU" VARCHAR2 (128),
    -- Класс безопасности
    "CLASS" VARCHAR2 (40),
    -- Номер в кабельном журнале
    "CABLE NUMBER" VARCHAR2 (40),
    -- Группа раскладки
    "GROUP R" VARCHAR2 (40),
    -- Диаметр кабеля
    "DIAMETER" NUMBER,
    -- KKS начала
    "FROM KKS" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- Координата X начала
    "FROM X" NUMBER,
    -- Координата Y начала
    "FROM Y" NUMBER,
    -- Координата Z начала
    "FROM Z" NUMBER,
    -- Отметка начала
    "FROM ZRel" VARCHAR2 (40),
    -- Запас на разделку с начала
    "FROM LAdd" NUMBER,
    -- Канал безопасности начала
    "FROM SYS" VARCHAR2 (40),
    -- KKS здания начала
    "FROM BUILDING" VARCHAR2 (40),
    -- KKS помещения начала
    "FROM ROOM" VARCHAR2 (128),
    -- Наименование оборудования начала
    "FROM NAME" VARCHAR2 (128),
    -- Наименование оборудования начала по английски
    "FROM NAME ENG" VARCHAR2 (128),
    -- KKS конца
    "TO KKS" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- Координата X конца
    "TO X" NUMBER,
    -- Координата Y конца
    "TO Y" NUMBER,
    -- Координата Z конца
    "TO Z" NUMBER,
    -- Отметка конца
    "TO ZRel" VARCHAR2 (40),
    -- Запас на разделку с конца
    "TO LAdd" NUMBER,
    -- Канал безопасности конца
    "TO SYS" VARCHAR2 (40),
    -- KKS здания конца
    "TO BUILDING" VARCHAR2 (40),
    -- KKS помещения конца
    "TO ROOM" VARCHAR2 (128),
    -- Наименование оборудования конца
    "TO NAME" VARCHAR2 (128),
    -- Наименование оборудования конца по английски
    "TO NAME ENG" VARCHAR2 (128),
    -- Длина кабеля
    "LENGTH" NUMBER,
    -- Параметр взаиморезервирования кабелей
    "REDUNDANCY" VARCHAR2 (40),
    -- Трасса
    "ROUTE" VARCHAR2 (512),
    -- Канал безопасности кабеля
    "CABLE SYS" VARCHAR2 (40),
    -- Примечания
    "NOTE" VARCHAR2 (128),
    -- Примечания по английски
    "NOTE ENG" VARCHAR2 (128),
    -- Спецификация
    "SPEC" VARCHAR2 (128)
);

-- Запись (строка) кабельного журнала по шаблону Access
Type R_CAB_JOURNAL_ACCESS Is Record
(
    -- Номер проекта АЭПа
    "PROJECT" VARCHAR2 (128),
    -- Номер кабельного журнала
    "CABLE LOG" VARCHAR2 (128),
    -- KKS (маркировка) кабеля
    "CABLE MARK" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- Тип (марка) кабеля
    "TYPE" VARCHAR2 (40),
    -- Число жил и сечение кабеля
    "CROSS-SECTION" VARCHAR2 (40),
    -- Номинальное напряжение кабеля
    "VOLTAGE" NUMBER,
    -- Номер технических условий
    "TU" VARCHAR2 (128),
    -- Класс безопасности
    "CLASS" VARCHAR2 (40),
    -- Номер в кабельном журнале
    "CABLE NUMBER" VARCHAR2 (40),
    -- Группа раскладки
    "GROUP R" VARCHAR2 (40),
    -- Диаметр кабеля
    "DIAMETER" NUMBER,
    -- KKS начала
    "FROM KKS" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- Координата X начала
    "FROM X" NUMBER,
    -- Координата Y начала
    "FROM Y" NUMBER,
    -- Координата Z начала
    "FROM Z" NUMBER,
    -- Отметка начала
    "FROM ZRel" VARCHAR2 (40),
    -- Запас на разделку с начала
    "FROM LAdd" NUMBER,
    -- Канал безопасности начала
    "FROM SYS" VARCHAR2 (40),
    -- KKS здания начала
    "FROM BUILDING" VARCHAR2 (40),
    -- KKS помещения начала
    "FROM ROOM" VARCHAR2 (128),
    -- Наименование оборудования начала
    "FROM NAME" VARCHAR2 (128),
    -- Наименование оборудования начала по английски
    "FROM NAME ENG" VARCHAR2 (128),
    -- KKS конца
    "TO KKS" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- Координата X конца
    "TO X" NUMBER,
    -- Координата Y конца
    "TO Y" NUMBER,
    -- Координата Z конца
    "TO Z" NUMBER,
    -- Отметка конца
    "TO ZRel" VARCHAR2 (40),
    -- Запас на разделку с конца
    "TO LAdd" NUMBER,
    -- Канал безопасности конца
    "TO SYS" VARCHAR2 (40),
    -- KKS здания конца
    "TO BUILDING" VARCHAR2 (40),
    -- KKS помещения конца
    "TO ROOM" VARCHAR2 (128),
    -- Наименование оборудования конца
    "TO NAME" VARCHAR2 (128),
    -- Наименование оборудования конца по английски
    "TO NAME ENG" VARCHAR2 (128),
    -- Длина кабеля
    "LENGTH" NUMBER,
    -- Параметр взаиморезервирования кабелей
    "REDUNDANCY" VARCHAR2 (40),
    -- Трасса
    "ROUTE" VARCHAR2 (512),
    -- Канал безопасности кабеля
    "CABLE SYS" VARCHAR2 (40),
    -- Примечания
    "NOTE" VARCHAR2 (128),
    -- Примечания по английски
    "NOTE ENG" VARCHAR2 (128),
    -- Спецификация
    "SPEC" VARCHAR2 (128)
);

-- Запись (строка) кабельного журнала по шаблону Word 
Type R_CAB_JOURNAL_WORD Is Record
(
    -- Номер в кабельном журнале
    "CABLE NUMBER" VARCHAR2 (40),
    -- KKS (маркировка) кабеля
    "CABLE MARK" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- Тип (марка) кабеля
    "TYPE" VARCHAR2 (40),
    -- Тип (марка) кабеля транслитом
    "TYPE TRANS" VARCHAR2 (40),
    -- Число жил и сечение кабеля
    "CROSS-SECTION" VARCHAR2 (40),
    -- Группа раскладки
    "GROUP R" VARCHAR2 (40),
    -- Класс безопасности
    "CLASS" VARCHAR2 (40),
    -- KKS начала
    "FROM KKS" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- Координата X начала
    "FROM X" NUMBER,
    -- Координата Y начала
    "FROM Y" NUMBER,
    -- Координата Z начала
    "FROM Z" NUMBER,
    -- KKS здания начала
    "FROM BUILDING" VARCHAR2 (40),
    -- KKS помещения начала
    "FROM ROOM" VARCHAR2 (128),
    -- Наименование оборудования начала
    "FROM NAME" VARCHAR2 (128),
    -- Наименование оборудования начала по английски
    "FROM NAME ENG" VARCHAR2 (128),
    -- KKS конца
    "TO KKS" SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE,
    -- Координата X конца
    "TO X" NUMBER,
    -- Координата Y конца
    "TO Y" NUMBER,
    -- Координата Z конца
    "TO Z" NUMBER,
    -- KKS здания конца
    "TO BUILDING" VARCHAR2 (40),
    -- KKS помещения конца
    "TO ROOM" VARCHAR2 (128),
    -- Наименование оборудования конца
    "TO NAME" VARCHAR2 (128),
    -- Наименование оборудования конца по английски
    "TO NAME ENG" VARCHAR2 (128),
    -- Длина кабеля
    "LENGTH" NUMBER,
    -- Трасса
    "ROUTE" VARCHAR2 (512),
    -- Имя общего щита
    "COMMON BOARD" VARCHAR2 (40),
    -- Имя общего щита ENG
    "COMMON BOARD ENG" VARCHAR2 (40),
    -- Примечания
    "NOTE" VARCHAR2 (128)
);

-- Запись (строка) таблицы потребности кабелей (итоговой таблицы) для шаблона Word
Type R_CAB_DEMAND Is Record
(
    -- Тип (марка) кабеля
    "TYPE" VARCHAR2 (40),
    -- Тип (марка) кабеля транслитом
    "TYPE TRANS" VARCHAR2 (40),
    -- Число жил и сечение кабеля
    "CROSS-SECTION" VARCHAR2 (40),
    -- Номинальное напряжение кабеля
    "VOLTAGE" VARCHAR2 (40),
    -- Длина кабеля
    "LENGTH" NUMBER,
    -- Диаметр металлорукава
    "METALHOSE DIAMETER" NUMBER,
    -- Длина металлорукава
    "METALHOSE LENGTH" NUMBER,
    -- Количество кабельных разделок
    "CABLE TERMINATIONS" NUMBER,
    -- Количество кабелей данной марки, сечения и напряжения
    "CABLE COUNT" NUMBER
);

-- Запись (строка) таблицы шкафов для заполнения координат шкафов и устройств
Type R_DEVICE_XYZ Is Record
(
    "ID устройства" NUMBER,
    "KKS устройства" VARCHAR2 (40),
    "Помещение" VARCHAR2 (128),
    "Наименование устройства" VARCHAR2 (128),
    "X" NUMBER,
    "Y" NUMBER,
    "Z" NUMBER
);

-- Запись (строка) таблицы кабелей для заполнения длины и трассы
Type R_CAB_LENGTH Is Record
(
    "ID кабеля" NUMBER,
    "KKS кабеля" VARCHAR2 (40),
    "Марка кабеля" VARCHAR2 (40),
    "Диаметр кабеля" NUMBER,
    "Откуда KKS" VARCHAR2 (40),
    "Откуда Пом." VARCHAR2 (128),
    "Откуда Наименование" VARCHAR2 (128),
    "Откуда X" NUMBER,
    "Откуда Y" NUMBER,
    "Откуда Z" NUMBER,
    "Куда KKS" VARCHAR2 (40),
    "Куда Пом." VARCHAR2 (128),
    "Куда Наименование" VARCHAR2 (128),
    "Куда X" NUMBER,
    "Куда Y" NUMBER,
    "Куда Z" NUMBER,
    "Длина" NUMBER,
    "Трасса" VARCHAR2 (512)
);

-- Запись (строка) параметров кабельного журнала, которые автоматически определяются внутри модели и записываются обратно в TJ
Type R_UPDATE_TJ Is Record
(
    -- Класс безопасности
    "CLASS" VARCHAR2 (40),
    -- Номер в кабельном журнале
    "CABLE NUMBER" VARCHAR2 (40),
    -- Группа раскладки
    "GROUP R" VARCHAR2 (40),
    -- Канал безопасности начала
    "FROM SYS" VARCHAR2 (40),
    -- Канал безопасности конца
    "TO SYS" VARCHAR2 (40),
    -- Канал безопасности кабеля
    "CABLE SYS" VARCHAR2 (40)  
);

-- Кабельный журнал (таблица всех параметров)
Type T_CAB_JOURNAL Is Table Of R_CAB_JOURNAL;

-- Кабельный журнал Access (таблица)
Type T_CAB_JOURNAL_ACCESS Is Table Of R_CAB_JOURNAL_ACCESS;

-- Кабельный журнал Word (таблица)
Type T_CAB_JOURNAL_WORD Is Table Of R_CAB_JOURNAL_WORD;

-- Таблица потребности кабелей для шаблона Word
Type T_CAB_DEMAND Is Table Of R_CAB_DEMAND;

-- Таблица координат шкафов и устройств
Type T_DEVICE_XYZ Is Table Of R_DEVICE_XYZ;

-- Таблица длин и трасс кабелей
Type T_CAB_LENGTH Is Table Of R_CAB_LENGTH;

-- Таблица параметров которые автоматически определяются и записываются обратно в TJ
Type T_UPDATE_TJ Is Table Of R_UPDATE_TJ;
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

Function V_CAB_JOURNAL_ACCESS(WorkID$ In Number default null) 
Return  T_CAB_JOURNAL_ACCESS Pipelined;

Function V_CAB_JOURNAL_WORD(WorkID$ In Number default null) 
Return  T_CAB_JOURNAL_WORD Pipelined;

Function V_CAB_DEMAND(WorkID$ In Number default null) 
Return  T_CAB_DEMAND Pipelined;

Function V_DEVICE_XYZ(WorkID$ In Number default null) 
Return  T_DEVICE_XYZ Pipelined;

Function V_CAB_LENGTH(WorkID$ In Number default null) 
Return  T_CAB_LENGTH Pipelined;

Procedure UPDATE_TJ(WorkID$ In Number default null);

Function AnalysisCabLength(LENGTH$ in out VARCHAR2) Return BOOLEAN;

end TJ#AEP;

/*
ID Work 30UPX КИП - 3658355200
ID Work 30UQA КИП - 3678514900
ID Work 31,32UQC КИП - 3678519300

ID Work 30UQA Силовые кабели - 3694932200

SELECT * FROM TABLE(SP.TJ#AEP.V_CAB_JOURNAL(WorkID$ => 3658355200 ))
SELECT * FROM TABLE(SP.TJ#AEP.V_CAB_JOURNAL_ACCESS(WorkID$ => 3658355200 ))
SELECT * FROM TABLE(SP.TJ#AEP.V_CAB_JOURNAL_WORD(WorkID$ => 3658355200 ))
SELECT * FROM TABLE(SP.TJ#AEP.V_CAB_DEMAND(WorkID$ => 3658355200 ))
SELECT * FROM TABLE(SP.TJ#AEP.V_DEVICE_XYZ(WorkID$ => 3658355200 ))
SELECT * FROM TABLE(SP.TJ#AEP.V_CAB_LENGTH(WorkID$ => 3658355200 ))

declare
WID NUMBER;
begin
WID := 3658355200;
SP.TJ#AEP.UPDATE_TJ(WID);
end;

declare
LENGTH$ VARCHAR2 (40);
r# VARCHAR2 (40);
a BINARY_INTEGER;
b BINARY_INTEGER;
begin
LENGTH$ := '*';
if INSTR(LENGTH$, '*', 1, 1) = 0 then
    a := 1;
    DBMS_OUTPUT.put_line(a);
    o(a);
    DBMS_OUTPUT.put_line(LENGTH$);
  else
    r# := SUBSTR(LENGTH$, 1, INSTR(LENGTH$,'*',1,1)-1);
    LENGTH$ := r#;
    b := 2;
    DBMS_OUTPUT.put_line(b);
    DBMS_OUTPUT.put_line('['||LENGTH$||']');
  end if;
end;
*/