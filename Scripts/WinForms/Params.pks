CREATE OR REPLACE PACKAGE WForms.Params 
-- Params Package
-- by Nikolay Krasilnikov 
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 30.09.2010  
-- update 05.10.2010 01.12.2010 10.12.2010 14.12.2010 20.08.2015 14.01.2021
--        19.01.2021 27.01.2021 17.04.2021

-- Пакет выполняет функции ini файла - сохраняет и восстанавливает параметры
-- объектов форм.
AS
--- (Params.pks )
--  Запись содержит сведения, необходимые для сохранения параметров приложений,
--  для каждого пользователя.
TYPE TFORM_PARAM is RECORD 
(
/* Имя приложения или его части(формы).*/
OBJ_NAME VARCHAR2(4000),
/* Имя параметра.*/
PROP_NAME VARCHAR2(128),
/* Значение параметра в виде строки.*/
PROP_VALUE VARCHAR2(4000),
/* Порядок обработки параметров.*/
ORD NUMBER(9),
/* Если это поле не нулл, то значение здесь.*/
PROP_CLOB CLOB
);
TYPE TFORM_PARAMS is TABLE of TFORM_PARAM;
 
-- Функция проверяет существует ли актуальный набор параметров формы.
-- Если сохраненная сигнатура совпадает с сигнатурой переданной в параметрах,
-- то функция возвращает таблицу значений параметров,
-- иначе возвращается пустая таблица.
-- Запрос параметров выглядит следующим образом:
--  select OBJ_NAME,PROP_NAME,PROP_VALUE,ORD, PROP_CLOB 
--    from Table( FormParams.Get(pAppName, pFormName, pSingnature))
-- В результате параметы отсортированы по объекту и порядку.
-- Функция возвращает параметры формы для текущего пользователя.
-- Если нет параметров для текущего пользователя,
-- то функция возвращает параметры по умолчанию (пользователь - нулл).
-- Если нет параметров по умолчанию, то возвращается пустая таблица.
 function Get(
   pAppName VARCHAR2,
   pFormName VARCHAR2,
   pSingnature NUMBER) 
   return TFORM_PARAMS pipelined;

-- Запись параметра формы в базу. 
-- При записи происходит проверка, не изменилась ли форма или ее сигнатура.
-- Если форма или сигнатура изменилась, то предыдущие незафиксираванные
-- изменения удаляются.
procedure SetValue(
  pAppName VARCHAR2,
  pFormName VARCHAR2,
  pSingnature NUMBER,
  pObjName VARCHAR2,
  pPropName VARCHAR2,
  pPropValue VARCHAR2,
  pOrd NUMBER,
  pPropClob CLOB default null
  );

-- Удаление всех параметров компонента формы из базы. 
-- При записи происходит проверка, не изменилась ли форма или ее сигнатура.
-- Если форма или сигнатура изменилась, то предыдущие незафиксираванные
-- изменения удаляются.
procedure DelObject(
  pAppName VARCHAR2,
  pFormName VARCHAR2,
  pSingnature NUMBER,
  pObjName VARCHAR2);
 
-- Удаление неиспользуемого параметра формы из базы. 
-- Пперед удалением происходит проверка, не изменилась ли форма или ее
-- сигнатура.
-- Если форма или сигнатура изменилась, то предыдущие незафиксираванные
-- изменения удаляются.
procedure DelValue(
  pAppName VARCHAR2,
  pFormName VARCHAR2,
  pSingnature NUMBER,
  pObjName VARCHAR2,
  pPropName VARCHAR2);

-- По завершению редактирования формы необходимо вызвать эту процедуру для
-- фиксации изменений. 
procedure SetCommit(
  pAppName VARCHAR2,
  pFormName VARCHAR2,
 	pSingnature NUMBER);
  
-- Создает набор параметров по умолчанию из набора параметров
-- пользователя, по умолчанию текущего. 
procedure SetDefault(
  pAppName VARCHAR2,
  pFormName VARCHAR2,
 	pSingnature NUMBER,
  pUser VARCHAR2 default null);  

FUNCTION S_UpEQ(a1 VARCHAR2, a2 VARCHAR2) return NUMBER;
PRAGMA RESTRICT_REFERENCES(S_UpEQ,WNPS);  

FUNCTION S_EQ(a1 NUMBER, a2 NUMBER) return NUMBER;
PRAGMA RESTRICT_REFERENCES(S_EQ,WNPS);

END Params;
/
