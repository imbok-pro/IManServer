CREATE OR REPLACE PACKAGE SP.Func
-- Func package
-- by Gracheva Irina
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 08.10.2010
-- update

AS
-- ‘ункции общего назначени€
-- ѕолучение названи€ типа параметра.
FUNCTION GetTypeName(pID in NUMBER)return VARCHAR2;

-- представление глобального параметра  в виде уникальной строки
FUNCTION GetUserS_Value(pID in NUMBER,UsrName in VARCHAR2)return VARCHAR2;
-- комментарий к значению параметра
FUNCTION GetUserValueComments(pID in NUMBER,UsrName in VARCHAR2)return VARCHAR2;

end Func;
/
