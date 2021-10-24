CREATE OR REPLACE PACKAGE SP.RGM
-- Грунты
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2018-03-01
-- update 2018-03-05 2018-03-13

AS
--==============================================================================
--Проба грунта
Type TGROUND_SAMPLE_REC is record
(
--ID пробы
SAMPLE_ID NUMBER,
SAMPLE_NAME Varchar2(128),
PIKET_ID Number,
PIKET_NAME Varchar2(64),
SAMPLE_DATE DATE,
Location Varchar2(4000),
---------------------------
X Number,
Y Number,
Z Number,
---------------------------
Ro Number,
Rod Number,
W Number,
Ws Number,
---------------------------
"Фракция_1" Number,
"Фракция_2" Number,
"Фракция_3" Number,
"Фракция_4" Number,
"Фракция_5" Number,
---------------------------
"Тип Грунта" Varchar2(128),
"Вх_Номер" Varchar2(128),
Remarks Varchar2(4000)
);

--Таблица проб грунта
Type TGROUND_SAMPLES is table of TGROUND_SAMPLE_REC;
--==============================================================================

--Возвращает все нижележащие по отношению к узлу MODEL_OBJ_ID$ пробы грунта
Function GetAllGroundSamples(MODEL_OBJ_ID$ In Number) 
Return RGM.TGROUND_SAMPLES Pipelined;

/*
--Образец использования
SELECT * FROM TABLE(SP.RGM.GetAllGroundSamples(548556600));

SELECT DISTINCT "Вх_Номер" FROM TABLE(SP.RGM.GetAllGroundSamples(548556600))
ORDER BY "Вх_Номер";

*/

--==============================================================================
-- Среди потомков объекта ROOT_OBJ_ID$ находит первую попавшуюся пробу  
-- с именем MOD_OBJ_NAME$ и возвращает её Входящий номер.
-- Если не находит, возвращает Null. 
Function GetSampleInputNum(ROOT_OBJ_ID$ In Number, MOD_OBJ_NAME$ In Varchar2) 
Return Varchar2;

--==============================================================================
-- Среди потомков объекта ROOT_OBJ_ID$ находит первую попавшуюся пробу  
-- с именем MOD_OBJ_NAME$ и возвращает её ID.
-- Если не находит, возвращает Null. 
Function GetSampleID(ROOT_OBJ_ID$ In Number, MOD_OBJ_NAME$ In Varchar2) 
Return Number;

--==============================================================================
--Возвращает имена параметров показателей пробы грунта
Function GetSampleParNames Return SP.G.TSNAMES;

--==============================================================================
-- Среди потомков объекта ROOT_OBJ_ID$ находит первый попавшшийся объект  
-- с именем 'Брак' и возвращает его ID.
-- Если не находит, возвращает Null. 
Function GetTrashID(ROOT_OBJ_ID$ In Number) Return Number;
--==============================================================================


end RGM;