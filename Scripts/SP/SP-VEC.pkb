CREATE OR REPLACE PACKAGE BODY SP.VEC
-- VEC работа с многомерными векторами
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-06-25
-- update 2019-07-03 2019-10-30:2019-11-06
AS

--Последняя вычесленная длина вектора одной из процедур
--GetNorma2, IsZero_2, Normalize
--Получить значение можно с помощью функции пакета GetLastNorma2
Last_Norma_2 Number;
--квадрат последней вычисленной нормы (Last_Norma_2*Last_Norma_2)
Last_Norma_2_2 Number;

--------------------------------------------------------------------------------
--Возвращает значение переменной пакета Last_Norma_2, вычисленной одной из
--функцуий GetNorma2, IsZero_2, Normalize
Function GetLastNorma2 Return Number
Is
Begin
  Return Last_Norma_2;
End;
--------------------------------------------------------------------------------
--Возвращает значение переменной пакета Last_Norma_2_2, вычисленной одной из
--функцуий GetNorma2, IsZero_2, Normalize
Function GetLastNorma2_2 Return Number
Is
Begin
  Return Last_Norma_2_2;
End;
--==============================================================================
--Создаёт 3D-вектор 
Function CreateV3(X$ In Number, Y$ In Number, Z$ In Number) Return AA_Vector
Is
  rv# AA_Vector;
Begin
  rv#(1):=X$;
  rv#(2):=Y$;
  rv#(3):=Z$;
  return rv#;
End;
--==============================================================================
--Создает вектор размерности Dim$, все координаты которого равны val$
Function CreateVector(Dim$ In BINARY_INTEGER, val$ In Number) Return AA_Vector
Is
  rv# AA_Vector;
Begin
  For i In 1..Dim$
  Loop
    rv#(i):=val$;
  End Loop;
  Return rv#;
End CreateVector;
--==============================================================================
--Возвращает True, вектор является нулевым в равномерной метрике с точностью до 
--Eps$ (т.е. максимум модуля координат меньше Eps$).
Function IsZero_Inf(v$ In AA_Vector, Eps$ In Number) Return Boolean
Is
Begin
  for i in v$.First..v$.Last 
  Loop
    If ABS(v$(i))>Eps$ Then
      Return False;
    End If;
  End Loop;
  Return true;
End IsZero_Inf;
--==============================================================================
--Возвращает строковое предствление вектора X:Y:Z
Function to_str(v$ In AA_Vector) Return Varchar2
Is
  rv# Varchar2(4000);
Begin
  
  for i in v$.First..v$.Last 
  Loop
    If i=1 Then
      rv#:=to_char(v$(i));
    Else
      rv#:=rv#||':'||to_char(v$(i));
    End If;
  End Loop;
  Return rv#;
End to_str;
--==============================================================================
--Возвращает результат вычитания v1$ - v2$
Function Substract(v1$ In AA_Vector, v2$ In AA_Vector) Return AA_Vector
Is
  rv# AA_Vector;
  d# Number;
Begin
  For i in 1..v1$.Count Loop
    rv#(i):=v1$(i)-v2$(i);
  End Loop;
  Return rv#;
End Substract;
--==============================================================================
--Возвращает средневзвешенную точку m$*v1$ +(1-m$)*v2$
-- m$ должна быть в интервале [0;1]
Function Middle(m$ In Number, v1$ In AA_Vector, v2$ In AA_Vector) 
Return AA_Vector
Is
  rv# AA_Vector;
  d# Number;
Begin
  d#:=1.0-m$;
  For i in 1..v1$.Count Loop
    rv#(i):=m$*v1$(i) + d#*v2$(i);
  End Loop;
  Return rv#;
End Middle;
--==============================================================================
--Возвращает норму 1 вектора
Function GetNorma1(v$ In AA_Vector) Return Number
Is
  rv# Number;
Begin
  rv#:=0.0;
  for i in v$.First..v$.Last 
  Loop
    rv#:=rv#+ABS(v$(i));
  End Loop;
  Return rv#;
End;
--==============================================================================
--Возвращает эвклидову норму вектора
--Заполняет переменную пакета Last_Norma_2
Function GetNorma2(v$ In AA_Vector) Return Number
Is
  t# Number;
Begin
  Last_Norma_2_2:=0.0;
  
  for i in v$.First..v$.Last 
  Loop
    t#:=v$(i);
    Last_Norma_2_2:=Last_Norma_2_2+(t#*t#);
  End Loop;
  Last_Norma_2:= SQRT(Last_Norma_2_2);
  Return Last_Norma_2;
End;
--==============================================================================
--Квадрат Эвклидова расстояния между векторами
Function Dist_2_2(v1$ In AA_Vector, v2$ In AA_Vector) Return Number
Is
  rv# Number;
  d# Number;
Begin
  rv#:=0.00;
  For i in 1..v1$.Count Loop
    d#:=v1$(i)-v2$(i);
    rv#:=rv# + (d#*d#);
  End Loop;
  Return rv#;
End Dist_2_2;
--==============================================================================
--Возвращает True, вектор является нулевым в евклидовой метрике с точностью до 
--Eps$ (т.е. корень из суммы квадратов координат меньше Eps$).
--Заполняет переменную пакета Last_Norma_2
Function IsZero_2(v$ In AA_Vector, ZeroVectorEps$ In Number) Return Boolean
Is
Begin
  If GetNorma2(v$)<ZeroVectorEps$ Then
    Return true;
  End If;
  Return False;
End IsZero_2;
--==============================================================================
-- Возвращает True, если вектора совпадают с точностью до ZeroVectorEps$ в 
-- Эвклидовой метрике.
Function EQ2_Vectors(v1$ In AA_Vector, v2$ In AA_Vector
, ZeroVectorEps$ In Number) Return Boolean
Is
Begin
  Return Dist_2_2(v1$,v2$)<ZeroVectorEps$*ZeroVectorEps$;
End;
--==============================================================================
--Возвращает истину если нормализуемый вектор v$ ненулевой
Function Normalize
(v$ In AA_Vector, ZeroVectorEps$ In Number, vr$ Out NoCopy AA_Vector) 
Return Boolean
Is
Begin
  If IsZero_2(v$, ZeroVectorEps$) Then
    vr$:=CreateVector(v$.Count,0.00);
    Return False;
  End If;
  
  For i in 1..v$.Count Loop
    vr$(i):=v$(i)/Last_Norma_2;
  End Loop;
  Return True;
End;
--==============================================================================
--скалярное произведение
Function DotProduct(v1$ In AA_Vector, v2$ In AA_Vector) Return Number
Is
  rv# Number;
Begin
  rv#:=0.00;
  For i in 1..v1$.Count Loop
    rv#:=rv# + (v1$(i)*v2$(i));
  End Loop;
  Return rv#;
End DotProduct;
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
Return Boolean
Is
  dp# Number;
  --нормализованные вектора
  v1n# AA_Vector; 
  v2n# AA_Vector; 
Begin
  If Not Normalize(v1$, ZeroVectorEps$, v1n#) Then
    Return True;
  End If;

  If Not Normalize(v2$, ZeroVectorEps$, v2n#) Then
    Return True;
  End If;
  
  If 1.0 - ABS(DotProduct(v1n#, v2n#)) <= ParallelEps$*ParallelEps$*0.5 Then
    Return True;
  End If;
  
  Return false;
End IsParallel;
--==============================================================================
--  Возвращает истину, если вектор v$ нулевой или 
--  горизонтальный, т.е. последняя координата 
--  вектора, полученного после его нормализвации по абсолютной величине 
--  не превосходит ParallelEps$
Function IsHorizontal(v$ In AA_Vector
, ZeroVectorEps$ In Number  --с точностью до миллиметра (в строительстве)
, ParallelEps$ In Number  --с точностью до 0.0001
) Return Boolean
Is
  vn# AA_Vector;
Begin

  If Not Normalize(v$, ZeroVectorEps$, vn#) Then
    --Нулевой вектор является горизонтальным
      Return True;
  End If;
  
  If ABS(vn#(vn#.Last)) <= ParallelEps$ Then
    Return True;
  End If;
  
  Return false;

End;
--==============================================================================
--  Возвращает истину, если вектор v$ нулевой или 
--  вертикальный, т.е. последняя координата вектора, полученного после его 
--  нормализвации почти равна единице с точностью ParallelEps$
Function IsVertical(v$ In AA_Vector
, ZeroVectorEps$ In Number  --с точностью до миллиметра (в строительстве)
, ParallelEps$ In Number  --с точностью до 0.0001
) Return Boolean
Is
  vn# AA_Vector;
Begin

  If Not Normalize(v$, ZeroVectorEps$, vn#) Then
    --Нулевой вектор является вертикальным
      Return True;
  End If;
  
  If ABS(vn#(vn#.Last)-1.0) <= ParallelEps$ Then
    Return True;
  End If;
  
  Return false;

End;
--==============================================================================
--Возвращает тип направления
--  'Н' - horizontal горизонтальный
--  'V' - vertical вертикальный
--  'Z' - zero нулевой
--  'D' - diverse другой
Function GetDirectionType(v$ In AA_Vector
, ZeroVectorEps$ In Number  --с точностью до миллиметра (в строительстве)
, ParallelEps$ In Number  --с точностью до 0.0001
) Return Varchar2
Is
  vn# AA_Vector;
  z# Number;
Begin
  If Not Normalize(v$, ZeroVectorEps$, vn#) Then
      Return 'Z';
  End If;
  
  z#:=vn#(vn#.Last);
  If ABS(z#) <= ParallelEps$ Then
    Return 'H';
  End If;

  If ABS(z#-1.0) <= ParallelEps$ Then
    Return 'V';
  End If;
  
  Return 'D';

End;
--==============================================================================
--Возвращает проекцию вектора v2$ на вектор v1$
Function Projection(v1$ In AA_Vector, v2$ In AA_Vector) Return AA_Vector
Is
  rv# AA_Vector;
  v1_n# Number; --норма v1$
  dp_v12# Number;
  t# Number;
Begin

  v1_n#:=0.0;
  dp_v12#:=0.0;
  For i in 1..v1$.Count Loop
    t#:=v1$(i);
    v1_n#:=v1_n#+t#*t#;
    dp_v12#:=dp_v12#+t#*v2$(i);
  End Loop;
  v1_n#:=SQRT(v1_n#);
  
  t#:=dp_v12#/v1_n#;
  
  For i in 1..v1$.Count Loop
    rv#(i):=(t#*v1$(i))-v2$(i);
  End Loop;
  
  Return rv#;
End Projection;
 
END VEC;

