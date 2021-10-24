CREATE OR REPLACE PACKAGE SP.BUH
-- BUH package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 26.08.2014
-- update 

AS


-- ��������� ����� ������� �����������.
FUNCTION CurBuhName return VARCHAR2;

-- ��������� �������������� ������� �����������.
FUNCTION CurBuh return NUMBER;

-- ��������� ��������� ��������� ������� ���������� �������� �� �����.
PROCEDURE Turnover(Account in NUMBER, CONTRACTOR in NUMBER, 
                   DATE_IN in DATE, DATE_OUT in DATE,
                   VALID IN BOOLEAN default true);

-- ��������� ��������� ��������� ������� ���������� ������ �� ���� ������.
PROCEDURE BALANCE_LIST(DATE_IN in DATE, DATE_OUT in DATE,
                       VALID IN BOOLEAN default true);

END BUH;
/
