CREATE OR REPLACE PACKAGE SP.A
 -- ARRAYS package 
-- пакет работы с массивами фреймворка IMan
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 17.01.2018
-- update 22.01.2018-23.01.2018 31.07.2021 28.09.2021

AS
-- Массив значений.
type TVal is record (T NUMBER, E VARCHAR2(128),
                     N NUMBER, D DATE, S VARCHAR2(4000), X NUMBER, Y NUMBER);
type TVals is table of TVal index by binary_integer;
-- Массив целых чисел.
type TInts is table of pls_integer index by binary_integer;
-- Массив вещественных чисел.
type TDbls is table of Float index by binary_integer;
-- Массив пар вещественных чисел.
type T2Dbl is record (X Float, Y Float);
type T2Dbls is table of T2Dbl index by binary_integer;

--Пакетные переменные для работы с процедурами семейства Assign
NewValsAA A.TVals;
OldValsAA A.TVals;

-- Функция предоставляет строковое значение.
-- Если идентификатор объекта не нулл и не совпадает с текущим загруженным
-- объектом, то происходит перезагрузка параметров в кэш. 
FUNCTION ARR2S(V in SP.TVALUE) return VARCHAR2;

PROCEDURE S2ARR(S in VARCHAR2, V in out nocopy SP.TVALUE );

-- Функция возвращает Массив пакета, заполненный значениями из массива IMan.
-- V - указатель на массив IMan.
function getIntArr(V in SP.TVALUE) return TInts;
function getDblArr(V in SP.TVALUE) return TDbls;
function get2DblArr(V in SP.TVALUE) return T2Dbls;
function getValArr(V in SP.TVALUE) return TVals;

-- Процедура обновляет массив IMan на основании двух массивов пакета.
-- Если OLD-массив отсутствует, то процедура сначала удалит все значения данного
-- массива из постоянной таблицы, а потом добавит туда новые значения.  
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TVals, OLD_Vals in TVals);
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TInts, OLD_Vals in TInts);
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TDbls, OLD_Vals in TDbls);
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in T2Dbls, OLD_Vals in T2Dbls);
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TVals);
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TInts);
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TDbls);
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in T2Dbls);

FUNCTION Val2TVALUE(Vals in TVals, i in binary_integer) return SP.TVALUE;
PROCEDURE TVALUE2Val(Vals in out nocopy TVALS, i in binary_integer,
                     V in SP.TVALUE);

-- Процедура выполняет блок S для каждого эмемента массива V.
-- P - массив параметров.
PROCEDURE forArr(V in SP.TVALUE, S in VARCHAR2,
                 P in out nocopy SP.G.TMACRO_PARS);
-- Служебные процедуры доступа к массиву параметров.
FUNCTION getP return SP.G.TMACRO_PARS;
PROCEDURE setP(P in SP.G.TMACRO_PARS);

END A;  
