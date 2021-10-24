CREATE OR REPLACE PACKAGE SP.VEC
-- VEC ������ � ���������
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-06-25
-- update 2019-07-03 2019-10-30:2019-11-06

AS

Type R_ApproximateValue Is Record
(
  VAL NUMBER, --�������� 
  EPS NUMBER -- ����������� (���������� ��� ������������� - ������� �� ��������)
);

--��� �������. ���������� ���������� ������� � �������
Type AA_Vector Is Table Of Number Index By BINARY_INTEGER;
--��� ������� ��������� ����� � �������� ���������� � �������
Type AA_Matrix Is Table Of AA_Vector Index By BINARY_INTEGER;

--------------------------------------------------------------------------------
--���������� �������� ���������� ������ Last_Norma_2_2, ����������� ����� ��
--�������� GetNorma2, IsZero_2, Normalize
Function GetLastNorma2_2 Return Number;
--==============================================================================
--������ 3D-������ 
Function CreateV3(X$ In Number, Y$ In Number, Z$ In Number) Return AA_Vector;
--==============================================================================
--���������� ��������� ������������ ������� X:Y:Z
Function to_str(v$ In AA_Vector) Return Varchar2;
--==============================================================================
--���������� ��������� ��������� v1$ - v2$
Function Substract(v1$ In AA_Vector, v2$ In AA_Vector) Return AA_Vector;
--==============================================================================
--���������� ���������������� ����� m$*v1$ +(1-m$)*v2$
-- m$ ������ ���� � ��������� [0;1]
Function Middle(m$ In Number, v1$ In AA_Vector, v2$ In AA_Vector) 
Return AA_Vector;
--==============================================================================
--���������� ����� 1 �������
Function GetNorma1(v$ In AA_Vector) Return Number;
--==============================================================================
--��������� ������������
Function DotProduct(v1$ In AA_Vector, v2$ In AA_Vector) Return Number;
--==============================================================================
--������� ��������� ���������� ����� ���������
Function Dist_2_2(v1$ In AA_Vector, v2$ In AA_Vector) Return Number;
--==============================================================================
-- ���������� True, ���� ������� ��������� � ��������� �� ZeroVectorEps$ � 
-- ���������� �������.
Function EQ2_Vectors(v1$ In AA_Vector, v2$ In AA_Vector
, ZeroVectorEps$ In Number) Return Boolean;
--==============================================================================
--���������� ������ ���� ������������� ������ v$ ���������
Function Normalize
(v$ In AA_Vector, ZeroVectorEps$ In Number, vr$ Out NoCopy AA_Vector) 
Return Boolean;
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
--  ���������� ������, ���� ������ v$ ������� ��� 
--  ��������������, �.�. ��������� ���������� 
--  �������, ����������� ����� ��� ������������� �� ���������� �������� 
--  �� ����������� ParallelEps$
Function IsHorizontal(v$ In AA_Vector
, ZeroVectorEps$ In Number  --� ��������� �� ���������� (� �������������)
, ParallelEps$ In Number  --� ��������� �� 0.0001
) Return Boolean;
--==============================================================================
--  ���������� ������, ���� ������ v$ ������� ��� 
--  ������������, �.�. ��������� ���������� �������, ����������� ����� ��� 
--  ������������� ����� ����� ������� � ��������� ParallelEps$
Function IsVertical(v$ In AA_Vector
, ZeroVectorEps$ In Number  --� ��������� �� ���������� (� �������������)
, ParallelEps$ In Number  --� ��������� �� 0.0001
) Return Boolean;
--==============================================================================
--���������� ��� �����������
--  '�' - horizontal ��������������
--  'V' - vertical ������������
--  'Z' - zero �������
--  'D' - diverse ������
Function GetDirectionType(v$ In AA_Vector
, ZeroVectorEps$ In Number  --� ��������� �� ���������� (� �������������)
, ParallelEps$ In Number  --� ��������� �� 0.0001
) Return Varchar2;
--==============================================================================
--���������� �������� ������� v2$ �� ������ v1$
Function Projection(v1$ In AA_Vector, v2$ In AA_Vector) Return AA_Vector;

END VEC;

