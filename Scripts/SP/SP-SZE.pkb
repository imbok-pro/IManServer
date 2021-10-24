CREATE OR REPLACE PACKAGE BODY SP.SZE
-- SZE package body
-- Проектирование шумозащитных экранов
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2021-09-30
-- update 2021-09-30
AS
--==============================================================================
--Возвращает истину, если переменная v имеет тип SP.G.TXY или SP.G.TXYZ
Function IsXY(v In SP.A.TVal) Return Boolean
Is
Begin
  Return (v.T = SP.G.TXYZ) Or (v.T = SP.G.TXY);
End;
--==============================================================================
--Вычисляет Евклидово расстояние в плане.
Function DistXY(v1 in SP.A.TVal, v2 in SP.A.TVal) Return Number
Is
 dX Number;
 dY Number;
Begin
  
  If Not IsXY(v1) Then
    raise_application_error(-20033,
          'SP.SZE.DistXY. Параметр v1 имеет неподходящий тип '||v1.T||'!');  
  End If;
  
  If Not IsXY(v1) Then
    raise_application_error(-20033,
          'SP.SZE.DistXY. Параметр v2 имеет неподходящий тип '||v2.T||'!');  
  End If;
  
  dX:=v1.X-v2.X;
  dY:=v1.Y-v2.Y;
  Return Sqrt(dX*dX+dY*dY);
End;
--==============================================================================
--Первичная расстановка маркеров на трассе Align3d$ через DistDefa$ метров.
--Маркеры расставляются в узлах трассы.
--Функция возвращает истину, если на трассе Align3d$ возможно построить 
--ШЗЭ из стандартных элемнтов.
Function GetMarkers(Align3d$  in SP.A.TVals
, DistDefa$ In Number  -- длина пролёта по умолчанию
, DistDiff$ In Number  -- минмиальная разница между длинами пролётов
, MarkPoint$ In Out SP.G.TVALUES
) Return Boolean
Is
  i# BINARY_INTEGER;
  j# BINARY_INTEGER;
  tv# SP.A.TVal;
  mp# SP.TVALUE;  --marker point
Begin
  MarkPoint$.Delete;
  i#:=Align3d$.First;
  j#:=0;
  --далее идёт текст заглушки, которая просто копирует Align3d$ в MarkPoint$
  While Not i# Is Null Loop
    tv# := Align3d$(i#);
    mp# := SP.TVALUE(SP.G.TXYZ);
    mp#.X := tv#.X;
    mp#.Y := tv#.Y;
    mp#.N := 0.00;
    MarkPoint$(j#) := mp#;
    i# := Align3d$.Next(i#);
    j# := j#+1;
  End Loop;
  Return true;
End;
END SZE;
/
