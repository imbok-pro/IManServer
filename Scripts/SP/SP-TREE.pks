CREATE OR REPLACE PACKAGE SP.TREE
-- CATALOG TREE package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 16.11.2010
-- update 13.12.2010 21.12.2010 06.10.2011 17.06.2013

AS

-- Получение имени объекта модели по полному имени.
-- Процедура отрезает путь от полного имени, но не проверяет
-- правильность пути или наличие объекта.
FUNCTION ShortName(Name in VARCHAR2) return VARCHAR2;

-- Процедура проверяет значение типа TreeNode.
-- Поле N должно содержать ссылку на узел дерева.
-- Если объект лист, то поле Y должно равняться "1", иначе "0".
PROCEDURE CHECK_VALUE(V in SP.TVALUE);

-- Процедура присваивает значение по полному пути в дереве каталога.
PROCEDURE S2V(S in VARCHAR2, V in out NOCOPY SP.TVALUE);

-- Функция предоставляет идентификатор узла по полному имени узла.
FUNCTION GetID(S in VARCHAR2)return NUMBER;

-- Функция предоставляет идентификатор родителя узла по полному имени узла.
FUNCTION GetParentID(S in VARCHAR2)return NUMBER;

-- Функция предоставляет полный путь к узлу по идентификатору узла.
-- либо, если N не задан, возвращает S
FUNCTION FullNodeName(NodeID in NUMBER,S in VARCHAR2) return VARCHAR2;

-- Функция используется для создания интерфейса построения дерева на клиенте.
-- Функция предоставляет множестро детей узла, если он не лист,
-- или множество соседей, если узел лист.
-- При выборе значений функция использует глобальную переменную SP.TG.CurValue.
FUNCTION NODES return SP.TS_VALUES_COMMENTS pipelined;

-- Функция предоставляет имя узла,
-- расположенного на -(i-м) уровне от листа.
-- Параметр ILevel это отрицательное число.
-- Для имени листа i=0.
FUNCTION NodeName(NodeID in NUMBER, ILevel in NUMBER) return VARCHAR2;

-- Функция предоставляет путь узла, обрезанный от корня до некоторого узла.
FUNCTION LastNodeNames(NodeID in NUMBER, FirstVisibleID in NUMBER) 
return VARCHAR2;

END TREE;
/
