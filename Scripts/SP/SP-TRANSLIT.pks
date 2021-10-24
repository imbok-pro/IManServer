CREATE OR REPLACE PACKAGE SP.TRANSLIT
-- TRANSLIT package body
--
-- Транслитерация русского языка латинским алфавитом 
--
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2021-03-23
-- update 

AS

--==============================================================================
-- Упрощенная транслитерация русского письма латинским алфавитом 
-- В соответствии с ГОСТ Р 7.0.34-2014
-- Все русские буквы заменяет латинскими буквосочетсниями, 
-- остальные символы оставляет как есть.
FUNCTION TransSimple(Str$ In Varchar2) return Varchar2;
/*

Implementation pattern:

SELECT SP.TRANSLIT.TransSimple('Какой чудесный подъём!') as ttt from Dual;
*/
--==============================================================================

END TRANSLIT;
/
