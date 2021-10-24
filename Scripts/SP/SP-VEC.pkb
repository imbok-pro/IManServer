CREATE OR REPLACE PACKAGE BODY SP.VEC
-- VEC ������ � ������������ ���������
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-06-25
-- update 2019-07-03 2019-10-30:2019-11-06
AS

--��������� ����������� ����� ������� ����� �� ��������
--GetNorma2, IsZero_2, Normalize
--�������� �������� ����� � ������� ������� ������ GetLastNorma2
Last_Norma_2 Number;
--������� ��������� ����������� ����� (Last_Norma_2*Last_Norma_2)
Last_Norma_2_2 Number;

--------------------------------------------------------------------------------
--���������� �������� ���������� ������ Last_Norma_2, ����������� ����� ��
--�������� GetNorma2, IsZero_2, Normalize
Function GetLastNorma2 Return Number
Is
Begin
  Return Last_Norma_2;
End;
--------------------------------------------------------------------------------
--���������� �������� ���������� ������ Last_Norma_2_2, ����������� ����� ��
--�������� GetNorma2, IsZero_2, Normalize
Function GetLastNorma2_2 Return Number
Is
Begin
  Return Last_Norma_2_2;
End;
--==============================================================================
--������ 3D-������ 
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
--������� ������ ����������� Dim$, ��� ���������� �������� ����� val$
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
--���������� True, ������ �������� ������� � ����������� ������� � ��������� �� 
--Eps$ (�.�. �������� ������ ��������� ������ Eps$).
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
--���������� ��������� ������������ ������� X:Y:Z
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
--���������� ��������� ��������� v1$ - v2$
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
--���������� ���������������� ����� m$*v1$ +(1-m$)*v2$
-- m$ ������ ���� � ��������� [0;1]
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
--���������� ����� 1 �������
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
--���������� ��������� ����� �������
--��������� ���������� ������ Last_Norma_2
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
--������� ��������� ���������� ����� ���������
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
--���������� True, ������ �������� ������� � ���������� ������� � ��������� �� 
--Eps$ (�.�. ������ �� ����� ��������� ��������� ������ Eps$).
--��������� ���������� ������ Last_Norma_2
Function IsZero_2(v$ In AA_Vector, ZeroVectorEps$ In Number) Return Boolean
Is
Begin
  If GetNorma2(v$)<ZeroVectorEps$ Then
    Return true;
  End If;
  Return False;
End IsZero_2;
--==============================================================================
-- ���������� True, ���� ������� ��������� � ��������� �� ZeroVectorEps$ � 
-- ���������� �������.
Function EQ2_Vectors(v1$ In AA_Vector, v2$ In AA_Vector
, ZeroVectorEps$ In Number) Return Boolean
Is
Begin
  Return Dist_2_2(v1$,v2$)<ZeroVectorEps$*ZeroVectorEps$;
End;
--==============================================================================
--���������� ������ ���� ������������� ������ v$ ���������
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
--��������� ������������
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
--������� ����������� ���� �����
--������ ������� ����� ���������� ������ �������
--ParallelEps$ ��� ��������� ������� ��������� ���������������, ���� ���������� 
--����� ���� �� ����������� ParallelEps$
Function IsParallel(
v1$ In AA_Vector
, v2$ In AA_Vector
, ZeroVectorEps$ In Number  --� ��������� �� ���������� (� �������������)
, ParallelEps$ In Number  --� ��������� �� 0.0001
)
Return Boolean
Is
  dp# Number;
  --��������������� �������
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
--  ���������� ������, ���� ������ v$ ������� ��� 
--  ��������������, �.�. ��������� ���������� 
--  �������, ����������� ����� ��� ������������� �� ���������� �������� 
--  �� ����������� ParallelEps$
Function IsHorizontal(v$ In AA_Vector
, ZeroVectorEps$ In Number  --� ��������� �� ���������� (� �������������)
, ParallelEps$ In Number  --� ��������� �� 0.0001
) Return Boolean
Is
  vn# AA_Vector;
Begin

  If Not Normalize(v$, ZeroVectorEps$, vn#) Then
    --������� ������ �������� ��������������
      Return True;
  End If;
  
  If ABS(vn#(vn#.Last)) <= ParallelEps$ Then
    Return True;
  End If;
  
  Return false;

End;
--==============================================================================
--  ���������� ������, ���� ������ v$ ������� ��� 
--  ������������, �.�. ��������� ���������� �������, ����������� ����� ��� 
--  ������������� ����� ����� ������� � ��������� ParallelEps$
Function IsVertical(v$ In AA_Vector
, ZeroVectorEps$ In Number  --� ��������� �� ���������� (� �������������)
, ParallelEps$ In Number  --� ��������� �� 0.0001
) Return Boolean
Is
  vn# AA_Vector;
Begin

  If Not Normalize(v$, ZeroVectorEps$, vn#) Then
    --������� ������ �������� ������������
      Return True;
  End If;
  
  If ABS(vn#(vn#.Last)-1.0) <= ParallelEps$ Then
    Return True;
  End If;
  
  Return false;

End;
--==============================================================================
--���������� ��� �����������
--  '�' - horizontal ��������������
--  'V' - vertical ������������
--  'Z' - zero �������
--  'D' - diverse ������
Function GetDirectionType(v$ In AA_Vector
, ZeroVectorEps$ In Number  --� ��������� �� ���������� (� �������������)
, ParallelEps$ In Number  --� ��������� �� 0.0001
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
--���������� �������� ������� v2$ �� ������ v1$
Function Projection(v1$ In AA_Vector, v2$ In AA_Vector) Return AA_Vector
Is
  rv# AA_Vector;
  v1_n# Number; --����� v1$
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

