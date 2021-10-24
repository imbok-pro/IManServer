CREATE OR REPLACE PACKAGE SP.C
-- Cache package 
-- пакет для кэширования параметров объекта модели
-- пакет использует временную таблицу SP.Obj_Cache
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 10.05.2017
-- update 14.11.2017 22.11.2017 30.11.2017 03.12.2017 05.12.2017

AS
TYPE TOBJECTS IS TABLE OF NUMBER INDEX BY SP.MOD_OBJ_PARS_CACHE.SET_KEY%type;

-- Процедура заполняет кэш параметров объекта.
-- Процедура использует механизм автономных транзакций, чтобы механизм
-- кэширования было возможно использовать внутри запросов.
-- Если необходимо поместить в кэш объект, созданный или изменённый в текущей
-- транзакции, то необходимо использовать процедуру addObject.
PROCEDURE setOBJECT(Object_ID in NUMBER);

-- Параметр setKey используется при необходимости одновременного использования 
-- кэша различными модулями.
-- Если параметр setKey не используется, то набор использует идентификатор "1"
PROCEDURE setOBJECT(Object_ID in NUMBER, setKey in VARCHAR2);

-- Процедура заполняет кэш параметров объекта.
-- Процедура используется, если необходимо поместить в кэш объект,
-- созданный или изменённый в текущей транзакции.
PROCEDURE addOBJECT(Object_ID in NUMBER, setKey in VARCHAR2);

-- Функция предоставляет параметр объекта модели.
-- Если идентификатор объекта не нулл и не совпадает с текущим загруженным
-- объектом, то происходит перезагрузка параметров в кэш. 
FUNCTION getMPAR(NAME in VARCHAR2, Object_ID in NUMBER default null) 
return SP.TMPAR;

-- Параметр setKey используется при необходимости одновременного использования 
-- кэша различными модулями.
FUNCTION getMPAR(NAME in VARCHAR2, Object_ID in NUMBER, setKey in VARCHAR2) 
return SP.TMPAR;

-- Функция предоставляет значение параметра объекта модели. 
-- Если идентификатор объекта не нулл и не совпадает с текущим загруженным
-- объектом, то происходит перезагрузка параметров в кэш. 
FUNCTION getMPAR_E(NAME in VARCHAR2, Object_ID in NUMBER default null) 
return VARCHAR2;

-- Параметр setKey используется при необходимости одновременного использования 
-- кэша различными модулями.
FUNCTION getMPAR_E(NAME in VARCHAR2, Object_ID in NUMBER, setKey in VARCHAR2) 
return VARCHAR2;

-- Функция предоставляет значение параметра объекта модели. 
-- Если идентификатор объекта не нулл и не совпадает с текущим загруженным
-- объектом, то происходит перезагрузка параметров в кэш. 
FUNCTION getMPAR_S(NAME in VARCHAR2, Object_ID in NUMBER default null) 
return VARCHAR2;

-- Параметр setKey используется при необходимости одновременного использования 
-- кэша различными модулями.
FUNCTION getMPAR_S(NAME in VARCHAR2, Object_ID in NUMBER, setKey in VARCHAR2) 
return VARCHAR2;

-- Функция предоставляет значение параметра объекта модели. 
-- Если идентификатор объекта не нулл и не совпадает с текущим загруженным
-- объектом, то происходит перезагрузка параметров в кэш. 
FUNCTION getMPAR_D(NAME in VARCHAR2, Object_ID in NUMBER default null) 
return DATE;

-- Параметр setKey используется при необходимости одновременного использования 
-- кэша различными модулями.
FUNCTION getMPAR_D(NAME in VARCHAR2, Object_ID in NUMBER, setKey in VARCHAR2) 
return DATE;

-- Функция предоставляет значение параметра объекта модели. 
-- Если идентификатор объекта не нулл и не совпадает с текущим загруженным
-- объектом, то происходит перезагрузка параметров в кэш. 
FUNCTION getMPAR_N(NAME in VARCHAR2, Object_ID in NUMBER default null) 
return NUMBER;

-- Параметр setKey используется при необходимости одновременного использования 
-- кэша различными модулями.
FUNCTION getMPAR_N(NAME in VARCHAR2, Object_ID in NUMBER, setKey in VARCHAR2) 
return NUMBER;

END C;  
