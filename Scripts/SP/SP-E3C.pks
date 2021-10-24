CREATE OR REPLACE PACKAGE SP.E3C
-- Работа с каталогом Zuken e3.Series
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2018-03-19
-- update 2018-03-21 2019-02-01 2021-02-12:2021-02-17

AS

Type T_MODEL_OBJECT_PAR_S Is Table Of SP.MODEL_OBJECT_PAR_S%ROWTYPE;
--==============================================================================
E3C_LINK VARCHAR2(128);
E3C_SCHEMA VARCHAR2(128);
--==============================================================================
--Из строки создает 40-символьную строку, используя алгоритм перемешивания SHA1
--
--Тупо содрано из 
-- https://stackoverflow.com/questions/
--                  1749753/making-a-sha1-hash-of-a-row-in-oracle
FUNCTION SHA1(STRING_TO_ENCRIPT VARCHAR2) RETURN VARCHAR2; 
--==============================================================================
--Из строки создает 32-символьную строку, используя алгоритм перемешивания MD5
--
--Тупо содрано из 
-- https://stackoverflow.com/questions/
--                  1749753/making-a-sha1-hash-of-a-row-in-oracle
FUNCTION MD5(STRING_TO_ENCRIPT VARCHAR2) RETURN VARCHAR2; 
--==============================================================================
--возвращает имя Link'а к БД Zuken e3.series
Function GetE3C_LINK Return Varchar2;
--==============================================================================
--Cоздает индекс OID по строке, используя алгоритм перемешивания SHA1
FUNCTION Str2OID(STRING_TO_ENCRIPT VARCHAR2) RETURN VARCHAR2;
--==============================================================================
--Возвращает набор всех классов каталога Zuken e3.series 
Function GetCatalogClasses Return  SP.G.TOBJECTS;
--==============================================================================
--Возвращает объект каталога по его OID
Function GetCatalogObject(OID$ In Varchar2) Return SP.G.TMACRO_PARS;
--==============================================================================
--Возвращает все объекты каталога, принадлежащие данному классу
Function GetCatalogObjects(ClassName$ In Varchar2) Return SP.G.TOBJECTS;
--==============================================================================
-- Определяет, содержится ли выражение LPNTR$ в поле cable.Entry  
Function IsCable(LPNTR$ In Varchar2) Return Boolean;
--==============================================================================
-- Определяет, содержится ли LPNTR, соответствующее COMPONENT_OID$  
--в поле cable.Entry  
Function IsCable(COMPONENT_OID$ In Varchar2) Return Boolean;
--==============================================================================
--Возвращает информацию о проводах и пучках
--Имеются параметры NAME, OID и POID. 
Function GetWiresAndBundles(COMPONENT_OID$ In Varchar2) Return SP.G.TOBJECTS;
--==============================================================================
--Параметр в строку
Function Par2StrDEBUG(ParID$ In Number) Return Varchar2;
--==============================================================================
--Для всех потомков объекта ROOT_MOD_OBJ_ID
--ищет все параметры, последнее изменение которых было позже даты ModDate$
FUNCTION GetModifiedPars(
ROOT_MOD_OBJ_ID$ In Number  --корень поддерева объектов
, ModDate$ In DATE  --дата, после которой параметры были изменены
) 
return SP.E3C.T_MODEL_OBJECT_PAR_S pipelined;
--==============================================================================
--устаревшая версия (новую версию см. ниже).
--Для всех потомков объекта ROOT_MOD_OBJ_ID
--ищет все параметры, последнее изменение которых было позже даты ModDate$
--
--данная функция употребляется для внесения изменений (дельты) из модели TJ
--в проект Zuken e3.Series
FUNCTION GetModifiedObjectPars(
ROOT_MOD_OBJ_ID$ In Number  --корень поддерева объектов
, ModDate$ In DATE  --дата, после которой параметры были изменены
) 
return SP.G.TOBJECTS;

/*
--Implementation pattern
Declare
  ObjSet#  SP.G.TOBJECTS;
Begin
ObjSet# := SP.E3C.GetModifiedObjectPars(

ROOT_MOD_OBJ_ID$ => 11539400 
, ModDate$ => TO_DATE('2019-01-28 00:00:00','YYYY-MM-DD HH24:MI:SS')
--))
); 

DBMS_OUTPUT.Put_Line('Count = '||ObjSet#.Count);
End;
*/
--==============================================================================
-- Ищет все параметры, кроме встроенных, Rel и SymRel, 
-- последнее изменение которых было позже даты ModDate$
Function GetObjParamVals(ModObjID$ In Number, ModDate$ In DATE) 
Return SP.MO.TPars Pipelined;
--==============================================================================
--Для всех потомков объекта ROOT_MOD_OBJ_ID
--ищет все параметры, последнее изменение которых было позже даты ModDate$
--
--данная функция употребляется для внесения изменений (дельты) из модели TJ
--в проект Zuken e3.Series
FUNCTION GetModifiedObjectPars(
ROOT_MOD_OBJ_ID$ In Number  --корень поддерева объектов
, ModDate$ In DATE  --дата, после которой параметры были изменены
, ObjectID$ In Number -- ID объекта каталога, для которого запрашиваются параметры
) 
return SP.G.TOBJECTS;
/*
--Implementation pattern

Declare
  ObjSet#  SP.G.TOBJECTS;
Begin
ObjSet# := SP.E3C.GetModifiedObjectPars(

ROOT_MOD_OBJ_ID$ => 2696588000 
, ModDate$ => TO_DATE('2019-01-28 00:00:00','YYYY-MM-DD HH24:MI:SS')
, ObjectID$ => SP.TJ_WORK.GetObjectID(SP.TJ_WORK.SINAME_DEVICE)
); 

DBMS_OUTPUT.Put_Line('Count = '||ObjSet#.Count);
End;

*/
--==============================================================================
--Меняет ссылки всех объектов с макры From$ на макру To$
--Это нужно делать, когда вы отладили новую версию макры
-- и хотите удалить старую версию, а ссылки уже готовых объектов 
-- переделать на новую версию.
Procedure UpdateStartComositRef(From$ In Varchar2, To$ In Varchar2);
/*
--Implementation pattern
Begin
    SP.E3C.UpdateStartComositRef
    ('E3=>TJ (КАБЕЛЬНЫЙ ЖУРНАЛ)_OBSOLETE', 'E3=>TJ (КАБЕЛЬНЫЙ ЖУРНАЛ)');
    commit;
End;
*/
--==============================================================================
-- Для работы WorkID$ возвращает дату последней синхронизации из TJ в проект 
-- Zuken e3.series.
-- Если WorkID$ не есть ID работы, то исключение.
-- Усли у работы отсутвует параметр "SYNC_DATE_FROM_TJ_TO_E3", то создаёт
-- его со значением 2000-01-01 и возвращает его значение.
Function GetSyncDateFromTJ2E3(WorkID$ In Number) Return Date;
/*
--Implementation pattern

select SP.E3C.GetSynkDateFromTJ2E3(1234567890) as ddd From Dual;

select SP.E3C.GetSynkDateFromTJ2E3(2696588800) as ddd From Dual;

select SP.E3C.GetSynkDateFromTJ2E3(2696588000) as ddd From Dual;

*/
--==============================================================================

/*
--Тесты
begin

DBMS_OUTPUT.put_line(SP.E3C.E3C_LINK);

end;
*/
End E3C;