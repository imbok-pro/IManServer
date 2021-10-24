CREATE or REPLACE PACKAGE THREADS.ExecI
-- KARBUILDER Threads.ExecInner PACKAGE
-- by Nikolai Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 11.11.2006
-- update 12.08.2007 24.12.2015 01.02.2016 03.02.2016 24.02.2016 
-- ���� ����� ���������� � ������ ������ �� ���������
AUTHID CURRENT_USER
AS
-- ������ ������������ � �������� �������.
Pars THREADS.Exec.TPars;

-- � ������ ������� ��� ���������� �������� ������� ����������� �������������
-- ������.
DebugThreadID PLS_INTEGER;

-- ��������� � ������� �������� ������ ������.
-- � ������ ������� �� ������������.
PROCEDURE ExecThread(PipeInName IN VARCHAR2);
PROCEDURE SendStateI(PrBar in NUMBER,Mess IN VARCHAR2);
PROCEDURE SendErrorI(Err IN VARCHAR2);
FUNCTION GetSignal return VARCHAR2;
end ExecI;
/

