CREATE OR REPLACE PACKAGE SP.BUH
-- BUH package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 26.08.2014
-- update 

AS


-- Получение имени текущей бухгалтерии.
FUNCTION CurBuhName return VARCHAR2;

-- Получение идентификатора текущей бухгалтерии.
FUNCTION CurBuh return NUMBER;

-- Процедура заполняет временную таблицу значениями операций по счёту.
PROCEDURE Turnover(Account in NUMBER, CONTRACTOR in NUMBER, 
                   DATE_IN in DATE, DATE_OUT in DATE,
                   VALID IN BOOLEAN default true);

-- Процедура заполняет временную таблицу значениями сальдо по всем счетам.
PROCEDURE BALANCE_LIST(DATE_IN in DATE, DATE_OUT in DATE,
                       VALID IN BOOLEAN default true);

END BUH;
/
