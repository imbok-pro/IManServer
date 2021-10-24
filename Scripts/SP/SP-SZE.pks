CREATE OR REPLACE PACKAGE SP.SZE
-- SZE package
-- �������������� ������������ �������
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2021-09-30
-- update 2021-09-30

AS
--==============================================================================
--��������� ��������� ���������� � �����.
Function DistXY(v1 in SP.A.TVal, v2 in SP.A.TVal) Return Number;
--==============================================================================
--��������� ����������� �������� �� ������ Align3d$ ����� DistDefa$ ������.
--������� ������������� � ����� ������.
--������� ���������� ������, ���� �� ������ Align3d$ �������� ��������� 
--��� �� ����������� ��������.
Function GetMarkers(Align3d$  in SP.A.TVals
, DistDefa$ In Number  -- ����� ������ �� ���������
, DistDiff$ In Number  -- ����������� ������� ����� ������� �������
, MarkPoint$ In Out SP.G.TVALUES
) Return boolean;
--==============================================================================
END SZE;  
