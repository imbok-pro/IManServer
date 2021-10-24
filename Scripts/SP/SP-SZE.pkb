CREATE OR REPLACE PACKAGE BODY SP.SZE
-- SZE package body
-- �������������� ������������ �������
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2021-09-30
-- update 2021-09-30
AS
--==============================================================================
--���������� ������, ���� ���������� v ����� ��� SP.G.TXY ��� SP.G.TXYZ
Function IsXY(v In SP.A.TVal) Return Boolean
Is
Begin
  Return (v.T = SP.G.TXYZ) Or (v.T = SP.G.TXY);
End;
--==============================================================================
--��������� ��������� ���������� � �����.
Function DistXY(v1 in SP.A.TVal, v2 in SP.A.TVal) Return Number
Is
 dX Number;
 dY Number;
Begin
  
  If Not IsXY(v1) Then
    raise_application_error(-20033,
          'SP.SZE.DistXY. �������� v1 ����� ������������ ��� '||v1.T||'!');  
  End If;
  
  If Not IsXY(v1) Then
    raise_application_error(-20033,
          'SP.SZE.DistXY. �������� v2 ����� ������������ ��� '||v2.T||'!');  
  End If;
  
  dX:=v1.X-v2.X;
  dY:=v1.Y-v2.Y;
  Return Sqrt(dX*dX+dY*dY);
End;
--==============================================================================
--��������� ����������� �������� �� ������ Align3d$ ����� DistDefa$ ������.
--������� ������������� � ����� ������.
--������� ���������� ������, ���� �� ������ Align3d$ �������� ��������� 
--��� �� ����������� ��������.
Function GetMarkers(Align3d$  in SP.A.TVals
, DistDefa$ In Number  -- ����� ������ �� ���������
, DistDiff$ In Number  -- ����������� ������� ����� ������� �������
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
  --����� ��� ����� ��������, ������� ������ �������� Align3d$ � MarkPoint$
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
