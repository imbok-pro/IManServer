CREATE OR REPLACE PACKAGE SP.B
-- BUILD package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 07.09.2010
-- update 01.11.2010 19.11.2010 17.12.2010 04.03.2011 10.05.2011 01.11.2011
--        20.12.2011 20.03.2012 28.03.2012 28.11.2014 06.01.2015 31.03.2015
--        29.07.2021

AS
-- Во всех процедурах и функциях данного пакета для совместимости со старыми
-- версиями если имя не содержит точки, то ищем объект только по имени.
--
-- Пересобираем макропакет и компилируем его.
-- Данную операцию можно поизводить один раз при создании новой макропроцедуры.
-- Если удалось скомпилировать пакет, то функция возвращает нулл. 
-- Если не удалось скомпилировать пакет,
-- то функция возвращает сообщение об ошибке.
FUNCTION COMPILE_MACRO(MACRO_FULL_NAME IN VARCHAR2)return VARCHAR2;
FUNCTION COMPILE_MACRO(MACRO_ID IN NUMBER) return VARCHAR2;
--
-- Пересобираем тело макропакета и компилируем его.
-- Если удалось скомпилировать пакет, то функция возвращает нулл. 
-- Если не удалось скомпилировать пакет,
-- то функция возвращает сообщение об ошибке.
FUNCTION COMPILE_MACRO_BODY(MACRO_FULL_NAME IN VARCHAR2) return VARCHAR2;
FUNCTION COMPILE_MACRO_BODY(MACRO_ID IN NUMBER) return VARCHAR2;
--
-- Функция перекомпилирует все объекты с ошибками и возвращает количество
-- недееспособных объектов макроопределений.
-- Подробный отчёт об ошибках и предупреждениях можно получить при помощи
-- функции SP.COMPILE_ERRORS.
FUNCTION COMPILE_ALL return NUMBER;
--
-- Функция предоставляет для просмотра тело пакета макропроцедуры.
FUNCTION MACRO_BODY_SOURCE(MACRO_FULL_NAME IN VARCHAR2) 
  return SP.TSOURCE pipelined;
FUNCTION MACRO_BODY_SOURCE_AS_CLOB(MACRO_FULL_NAME IN VARCHAR2) 
  return CLOB;
FUNCTION MACRO_BODY_LISTING_AS_CLOB(MACRO_FULL_NAME IN VARCHAR2) 
  return CLOB;
FUNCTION MACRO_BODY_SOURCE(MACRO_ID IN NUMBER) return SP.TSOURCE pipelined;
-- Функция предоставляет для просмотра ошибки компиляции тела пакета
-- макропроцедуры.
FUNCTION MACRO_BODY_ERRORS(MACRO_NAME IN VARCHAR2) 
  return SP.TERROR_RECORDS pipelined;
FUNCTION MACRO_BODY_ERRORS(MACRO_ID IN NUMBER)
  return SP.TERROR_RECORDS pipelined;
-- Функция предоставляет для просмотра ошибки компиляции внешних функций,
-- созданных командами FUNCTIONS макропроцедуры.
FUNCTION MACRO_FUNCTION_ERRORS(MACRO_FULL_NAME IN VARCHAR2) 
  return SP.TERROR_RECORDS pipelined;
FUNCTION MACRO_FUNCTION_ERRORS(MACRO_ID IN NUMBER)
  return SP.TERROR_RECORDS pipelined;
-- Процедура удаляет пакеты из схемы SP_IM, которые не имеют соответствующих
-- макропроцедур.
PROCEDURE DROP_MACRO;
-- Процедура удаляет пакет макропроцедуры.
PROCEDURE DROP_MACRO(MACRO_FULL_NAME IN VARCHAR2);
PROCEDURE DROP_MACRO(MACRO_ID IN NUMBER);
-- Процедура удаляет тело пакета макропроцедуры.
PROCEDURE DROP_MACRO_BODY(MACRO_FULL_NAME IN VARCHAR2); 
PROCEDURE DROP_MACRO_BODY(MACRO_ID IN NUMBER);

-- Функция возвращает состояние объекта ("VALID" или "INVALID")
FUNCTION STATUS(MACRO_ID IN NUMBER) return VARCHAR;

-- Функция возвращает готовый для установки скрипт макропроцедуры.
-- Параметр Q=-1, позволяет устанавливать макропроцедуру,
-- переписывая существующую макропроцедуру при совпадении имён. 
FUNCTION MACRO_SOURCE(MACRO_FULL_NAME IN VARCHAR2, Q in NUMBER default 0) 
  return SP.TSOURCE pipelined;
FUNCTION MACRO_SOURCE_AS_CLOB(MACRO_FULL_NAME IN VARCHAR2,
                              Q in NUMBER default 0)
  return CLOB;

-- Функция возвращает готовый для установки скрипт макропроцедур.
-- Параметр Q=-1, позволяет устанавливать макропроцедуры,
-- переписывая существующую макропроцедуру при совпадении имён.
FUNCTION MACRO_SOURCES(Macros IN SP.TNUMBERS, Q in NUMBER default -1) 
  return SP.TSOURCE pipelined;
  
-- Функция возвращает готовый для установки скрипт макропроцедур,
-- изменённых после некоторой даты.
-- Если параметр Changed_After => null, то возвращаем null. 
FUNCTION MACRO_SOURCES_AS_CLOB(Changed_After IN DATE)
  return CLOB;

-- Процедура клонирует макропроцедуру.
-- При клонировании группа сохраняется. 
-- Если опущен второй параметр,
-- то добавляется префикс "Clone_of".
PROCEDURE CloneMacro(
     MacroName IN VARCHAR2,
	   NewShortName IN VARCHAR2 default null);
END B;
/
