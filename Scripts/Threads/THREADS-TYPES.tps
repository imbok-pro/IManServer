-- Threads for ORACLE
-- by Nikolai Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 11.11.2006
-- update 29.01.2016  
--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE THREADS.TNUMBERs 
/* ����� �����.*/
/* THREADS-TYPES.tps*/
IS TABLE OF NUMBER 
                   ');
END;
/
GRANT EXECUTE ON THREADS.TNUMBERs to public;
CREATE OR REPLACE PUBLIC SYNONYM TNUMBERS for THREADS.TNUMBERs;
/
--
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE THREADS.THREAD_REC
/* THREADS-TYPES.tps*/
/* ������ ��� ���������� ��������� ������, � �������� ���������������
������ ������� ������.*/
AS OBJECT
(
/* ������������� ������.*/
ID NUMBER,
/* ������������� ������ (JOB), � ������� ������� �����.*/
JobID NUMBER, 
/* ������� ��� ����� */
PipeName VARCHAR2(128), 
/* ���������� ����� ����������� �� ���� ����� ���������. */
BufSize NUMBER,  
/* ������������� ��������� ������.*/
StateID NUMBER,           
/* ��������� ������.*/
State VARCHAR2(100),           
/* % ����������.*/
PrBar NUMBER,						 
/* ����� ���������� ��������.*/
Moment DATE,           
/* ��������� ������.*/
Mess VARCHAR2(256),    
/* ��������� �� ������ ������, ��������� � ������.*/
ERR VARCHAR2(3000),     
/* ������� �������.*/
FlagDebug VARCHAR2(50),  
/* ������� �������� ������.*/
isImplicit VARCHAR2(50),
/* ����������� ������ ������.*/
CONSTRUCTOR FUNCTION THREAD_REC 
RETURN SELF AS RESULT
);
/
GRANT EXECUTE ON THREADS.THREAD_REC TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE THREADS.TTHREADS 
/* ����� ��������� ������.*/
/* THREADS-TYPES.tps*/
IS TABLE OF THREADS.THREAD_REC
                   ');
END;
/
GRANT EXECUTE ON THREADS.TTHREADS to public;
