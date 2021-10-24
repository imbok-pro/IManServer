CREATE OR REPLACE PACKAGE SP.TO_
-- TO_ package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 16.08.2010 
-- update 01.12.2011 21.05.2015 11.06.2015
as
-- Всегда с точкой.
FUNCTION STR(val in NUMBER)return VARCHAR2;
-- С заданным количеством разрядов после запятой.
-- Допустимое количество разрядов +-10.
FUNCTION STR(val in NUMBER, prec in NUMBER)return VARCHAR2;
FUNCTION STR(val in BOOLEAN)return VARCHAR2;
-- Перевод строки.
FUNCTION STR return VARCHAR2; 
FUNCTION STR(val in DATE)return VARCHAR2;
FUNCTION STR(val in TIMESTAMP)return VARCHAR2;
FUNCTION STR(val in RAW)return VARCHAR2;
FUNCTION STR(val in SP.TVALUE)return VARCHAR2;
FUNCTION STR(val in SP.G.TMACRO_PARS)return VARCHAR2;
FUNCTION DATA(val in VARCHAR2) return RAW;
FUNCTION BIN(val in NUMBER, width in NUMBER default 31) return VARCHAR2;
FUNCTION HEX(val in NUMBER) return VARCHAR2;
end; 	 	
/
