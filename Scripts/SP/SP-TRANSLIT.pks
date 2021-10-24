CREATE OR REPLACE PACKAGE SP.TRANSLIT
-- TRANSLIT package body
--
-- �������������� �������� ����� ��������� ��������� 
--
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2021-03-23
-- update 

AS

--==============================================================================
-- ���������� �������������� �������� ������ ��������� ��������� 
-- � ������������ � ���� Р7.0.34-2014
-- ��� ������� ����� �������� ���������� ����������������, 
-- ��������� ������� ��������� ��� ����.
FUNCTION TransSimple(Str$ In Varchar2) return Varchar2;
/*

Implementation pattern:

SELECT SP.TRANSLIT.TransSimple('����� �������� ������!') as ttt from Dual;
*/
--==============================================================================

END TRANSLIT;
/
