CREATE OR REPLACE PACKAGE SP.TREE
-- CATALOG TREE package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 16.11.2010
-- update 13.12.2010 21.12.2010 06.10.2011 17.06.2013

AS

-- ��������� ����� ������� ������ �� ������� �����.
-- ��������� �������� ���� �� ������� �����, �� �� ���������
-- ������������ ���� ��� ������� �������.
FUNCTION ShortName(Name in VARCHAR2) return VARCHAR2;

-- ��������� ��������� �������� ���� TreeNode.
-- ���� N ������ ��������� ������ �� ���� ������.
-- ���� ������ ����, �� ���� Y ������ ��������� "1", ����� "0".
PROCEDURE CHECK_VALUE(V in SP.TVALUE);

-- ��������� ����������� �������� �� ������� ���� � ������ ��������.
PROCEDURE S2V(S in VARCHAR2, V in out NOCOPY SP.TVALUE);

-- ������� ������������� ������������� ���� �� ������� ����� ����.
FUNCTION GetID(S in VARCHAR2)return NUMBER;

-- ������� ������������� ������������� �������� ���� �� ������� ����� ����.
FUNCTION GetParentID(S in VARCHAR2)return NUMBER;

-- ������� ������������� ������ ���� � ���� �� �������������� ����.
-- ����, ���� N �� �����, ���������� S
FUNCTION FullNodeName(NodeID in NUMBER,S in VARCHAR2) return VARCHAR2;

-- ������� ������������ ��� �������� ���������� ���������� ������ �� �������.
-- ������� ������������� ��������� ����� ����, ���� �� �� ����,
-- ��� ��������� �������, ���� ���� ����.
-- ��� ������ �������� ������� ���������� ���������� ���������� SP.TG.CurValue.
FUNCTION NODES return SP.TS_VALUES_COMMENTS pipelined;

-- ������� ������������� ��� ����,
-- �������������� �� -(i-�) ������ �� �����.
-- �������� ILevel ��� ������������� �����.
-- ��� ����� ����� i=0.
FUNCTION NodeName(NodeID in NUMBER, ILevel in NUMBER) return VARCHAR2;

-- ������� ������������� ���� ����, ���������� �� ����� �� ���������� ����.
FUNCTION LastNodeNames(NodeID in NUMBER, FirstVisibleID in NUMBER) 
return VARCHAR2;

END TREE;
/
