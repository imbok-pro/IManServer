CREATE OR REPLACE PACKAGE SP.IMPORT
-- IMPORT package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 17.08.2010
-- update 19.11.2010 30.11.2010 15.03.2011 18.06.2013
AS
-- ������� ��������� � ��������� ������ �� ��������������� ����� �����-������.
-- ��������� ���������� ������������ ������ ����� pls. ���� ������ ������� 
-- ��������� ���� ������, �� ������ ����� ������ �� ��������� ������.
block_size constant NUMBER:=80;
-- �������� item ��������� ���� �� �������� ����������� � ������ ��������.
-- � ������ ������ ������� ���������� ���������, ����� ����.
function Script(item in VARCHAR2)return VARCHAR2;

end IMPORT;
/
