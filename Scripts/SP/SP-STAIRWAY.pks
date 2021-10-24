CREATE OR REPLACE PACKAGE SP.STAIRWAY
-- STAIRWAY package 
-- заполняет ряд значений допустимых при проектировании лестницы 
-- by Gracheva Irina
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 06.07.2011 
-- update 08.08.2011,22.08.2011 07.09.2011

AS
-- Функция предоставляет множестро высот лестничного марша
FUNCTION SetOfStairH return SP.TS_VALUES_COMMENTS pipelined;

-- Функция предоставляет множестро высот стремянки
FUNCTION SetOfLadderH return SP.TS_VALUES_COMMENTS pipelined;

-- Функция предоставляет множестро длин лестничной площадки
FUNCTION SetOfLanding return SP.TS_VALUES_COMMENTS pipelined;

-- Функция строку типа X * Y переводит в  TVALUE с заполненными X и Y
PROCEDURE LandSV
		  (LandingSize IN VARCHAR2,V in out NOCOPY SP.TVALUE);

-- Функция - находим высоту этажа ( длину площадки) 
-- Floor - номер этажа
-- HFloor - значение по умолчанию
-- HVar - величина, из которой нужно выбрать значение,
-- H - высота, L - длина
FUNCTION stairH( Floor number,
				 HFloor number,
				 HVar varchar2,
				 Litera varchar2) RETURN NUMBER;

-- Функция предоставляет множестро высот перил
FUNCTION SetOfRailH return SP.TS_VALUES_COMMENTS pipelined;

-- Функция предоставляет множестро высот оград
FUNCTION SetOfBarrierH return SP.TS_VALUES_COMMENTS pipelined;

-- Функция возвращает расстояние между вертикальными стойками перил
FUNCTION GetRailVertL (H in number, alfa in number)return number;

END STAIRWAY;  
