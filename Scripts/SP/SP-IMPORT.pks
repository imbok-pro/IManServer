CREATE OR REPLACE PACKAGE SP.IMPORT
-- IMPORT package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 17.08.2010
-- update 19.11.2010 30.11.2010 15.03.2011 18.06.2013
AS
-- Функция формирует и исполняет скрипт из вспомогательной схемы ввода-вывода.
-- Константа определяет максимальный размер блока pls. Если размер скрипта 
-- превышает этот размер, то скрипт будет разбит на несколько блоков.
block_size constant NUMBER:=80;
-- Параметр item принимает одно из значений определённых в пакете экспорта.
-- В случае ошибки функция возвращает сообщение, иначе нулл.
function Script(item in VARCHAR2)return VARCHAR2;

end IMPORT;
/
