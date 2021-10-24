CREATE OR REPLACE PACKAGE SP.Map
-- Map package 
-- таблица взаимоувязки значений
-- пакет используе схему KOCEL
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 16.07.2014 
-- update 

AS
type TMAP IS TABLE OF VARCHAR2(128) INDEX BY VARCHAR2(128);
type TMAPS IS TABLE OF TMAP INDEX BY VARCHAR2(128);
type TMAPREC is record
( 
  BOOK VARCHAR2(256), Sheet VARCHAR2(256),
  KeyColumn NUMBER(6),
  ValueColumn NUMBER(6)
);
type TMAPRECS IS TABLE OF TMAPREC INDEX BY VARCHAR2(128);
-- Максимальные значения ключей, значений и имён карт - 128 символов!


-- Функция предоставляет значение по ключу.
FUNCTION V(MapName IN VARCHAR2, K IN VARCHAR2)  return VARCHAR2;

-- Функция предоставляет значение по ключу.
-- Используется последняя использованная или настроенная карта.
FUNCTION V(K IN VARCHAR2)  return VARCHAR2;


-- Процедура Настраивает новую карту (справочник)
PROCEDURE NEW(
  -- Имя карты (одновременно в кеше может находиться сколько угодно карт)
  MapName IN VARCHAR2,
  -- Имя книги и листа в которых размещены колонки карты
  BOOK IN VARCHAR2, Sheet IN VARCHAR2,
  -- имя колонки и номер ряда ключа
  KeyColumn IN VARCHAR2, KeyColumnRow IN NUMBER,
  -- имя колонки и номер ряда значения.
  ValueColumn IN VARCHAR2, ValueColumnRow IN NUMBER);

END MAP;  
