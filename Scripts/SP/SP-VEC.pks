CREATE OR REPLACE PACKAGE SP.VEC
-- VEC работа с векторами
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-06-25
-- update 2019-07-03 2019-10-30:2019-11-06

AS

Type R_ApproximateValue Is Record
(
  VAL NUMBER, --значение 
  EPS NUMBER -- погрешность (абсолютная или относительная - зависит от конткста)
);

--Тип вектора. Координаты нумеруются начиная с единицы
Type AA_Vector Is Table Of Number Index By BINARY_INTEGER;
--Тип матрицы Нумерация строк и столбцов начинается с единицы
Type AA_Matrix Is Table Of AA_Vector Index By BINARY_INTEGER;

--------------------------------------------------------------------------------
--Возвращает значение переменной пакета Last_Norma_2_2, вычисленной одной из
--функцуий GetNorma2, IsZero_2, Normalize
Function GetLastNorma2_2 Return Number;
--==============================================================================
--Создаёт 3D-вектор 
Function CreateV3(X$ In Number, Y$ In Number, Z$ In Number) Return AA_Vector;
--==============================================================================
--Возвращает строковое предствление вектора X:Y:Z
Function to_str(v$ In AA_Vector) Return Varchar2;
--==============================================================================
--Возвращает результат вычитания v1$ - v2$
Function Substract(v1$ In AA_Vector, v2$ In AA_Vector) Return AA_Vector;
--==============================================================================
--Возвращает средневзвешенную точку m$*v1$ +(1-m$)*v2$
-- m$ должна быть в интервале [0;1]
Function Middle(m$ In Number, v1$ In AA_Vector, v2$ In AA_Vector) 
Return AA_Vector;
--==============================================================================
--Возвращает норму 1 вектора
Function GetNorma1(v$ In AA_Vector) Return Number;
--==============================================================================
--скалярное произведение
Function DotProduct(v1$ In AA_Vector, v2$ In AA_Vector) Return Number;
--==============================================================================
--Квадрат Эвклидова расстояния между векторами
Function Dist_2_2(v1$ In AA_Vector, v2$ In AA_Vector) Return Number;
--==============================================================================
-- Возвращает True, если вектора совпадают с точностью до ZeroVectorEps$ в 
-- Эвклидовой метрике.
Function EQ2_Vectors(v1$ In AA_Vector, v2$ In AA_Vector
, ZeroVectorEps$ In Number) Return Boolean;
--==============================================================================
--Возвращает истину если нормализуемый вектор v$ ненулевой
Function Normalize
(v$ In AA_Vector, ZeroVectorEps$ In Number, vr$ Out NoCopy AA_Vector) 
Return Boolean;
--==============================================================================
--Векторы параллельны друг другу
--вектор нулевой длины параллелен любому вектору
--ParallelEps$ два ЕДИНИЧЕЫХ вектора считаются сонаправленными, если расстояние 
--между ними не превосходит ParallelEps$
Function IsParallel(
v1$ In AA_Vector
, v2$ In AA_Vector
, ZeroVectorEps$ In Number  --с точностью до миллиметра (в строительстве)
, ParallelEps$ In Number  --с точностью до 0.0001
)
Return Boolean;
/*
Implementation pattern unit test

Declare
 v1 SP.VEC.AA_Vector;
 v2 SP.VEC.AA_Vector;
Begin
  v1:=SP.VEC.CreateV3(X$=>0.00, Y$ => 0.00, Z$ => 1240080-1240001.05);
  DBMS_OUTPUT.put_line('v1 ['||SP.VEC.to_str(v1)||']');
  
  v2:=SP.VEC.CreateV3(X$=>0.00, Y$ => 0.00, Z$ => 1240080-1242080);
  DBMS_OUTPUT.put_line('v2 ['||SP.VEC.to_str(v2)||']');
  
  If SP.VEC.IsParallel
    (v1, v2, ZeroVectorEps$ => 1.0, ParallelEps$ => 0.0001) Then
    DBMS_OUTPUT.put_line('OK');
  Else
    DBMS_OUTPUT.put_line('fail');
  End If;

End;

*/
--==============================================================================
--  Возвращает истину, если вектор v$ нулевой или 
--  горизонтальный, т.е. последняя координата 
--  вектора, полученного после его нормализвации по абсолютной величине 
--  не превосходит ParallelEps$
Function IsHorizontal(v$ In AA_Vector
, ZeroVectorEps$ In Number  --с точностью до миллиметра (в строительстве)
, ParallelEps$ In Number  --с точностью до 0.0001
) Return Boolean;
--==============================================================================
--  Возвращает истину, если вектор v$ нулевой или 
--  вертикальный, т.е. последняя координата вектора, полученного после его 
--  нормализвации почти равна единице с точностью ParallelEps$
Function IsVertical(v$ In AA_Vector
, ZeroVectorEps$ In Number  --с точностью до миллиметра (в строительстве)
, ParallelEps$ In Number  --с точностью до 0.0001
) Return Boolean;
--==============================================================================
--Возвращает тип направления
--  'Н' - horizontal горизонтальный
--  'V' - vertical вертикальный
--  'Z' - zero нулевой
--  'D' - diverse другой
Function GetDirectionType(v$ In AA_Vector
, ZeroVectorEps$ In Number  --с точностью до миллиметра (в строительстве)
, ParallelEps$ In Number  --с точностью до 0.0001
) Return Varchar2;
--==============================================================================
--Возвращает проекцию вектора v2$ на вектор v1$
Function Projection(v1$ In AA_Vector, v2$ In AA_Vector) Return AA_Vector;

END VEC;

