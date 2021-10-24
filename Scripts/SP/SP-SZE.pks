CREATE OR REPLACE PACKAGE SP.SZE
-- SZE package
-- Проектирование шумозащитных экранов
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2021-09-30
-- update 2021-09-30

AS
--==============================================================================
--Вычисляет Евклидово расстояние в плане.
Function DistXY(v1 in SP.A.TVal, v2 in SP.A.TVal) Return Number;
--==============================================================================
--Первичная расстановка маркеров на трассе Align3d$ через DistDefa$ метров.
--Маркеры расставляются в узлах трассы.
--Функция возвращает истину, если на трассе Align3d$ возможно построить 
--ШЗЭ из стандартных элемнтов.
Function GetMarkers(Align3d$  in SP.A.TVals
, DistDefa$ In Number  -- длина пролёта по умолчанию
, DistDiff$ In Number  -- минмиальная разница между длинами пролётов
, MarkPoint$ In Out SP.G.TVALUES
) Return boolean;
--==============================================================================
END SZE;  
