CREATE OR REPLACE PACKAGE SP.A
 -- ARRAYS package 
-- ����� ������ � ��������� ���������� IMan
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 17.01.2018
-- update 22.01.2018-23.01.2018 31.07.2021 28.09.2021

AS
-- ������ ��������.
type TVal is record (T NUMBER, E VARCHAR2(128),
                     N NUMBER, D DATE, S VARCHAR2(4000), X NUMBER, Y NUMBER);
type TVals is table of TVal index by binary_integer;
-- ������ ����� �����.
type TInts is table of pls_integer index by binary_integer;
-- ������ ������������ �����.
type TDbls is table of Float index by binary_integer;
-- ������ ��� ������������ �����.
type T2Dbl is record (X Float, Y Float);
type T2Dbls is table of T2Dbl index by binary_integer;

--�������� ���������� ��� ������ � ����������� ��������� Assign
NewValsAA A.TVals;
OldValsAA A.TVals;

-- ������� ������������� ��������� ��������.
-- ���� ������������� ������� �� ���� � �� ��������� � ������� �����������
-- ��������, �� ���������� ������������ ���������� � ���. 
FUNCTION ARR2S(V in SP.TVALUE) return VARCHAR2;

PROCEDURE S2ARR(S in VARCHAR2, V in out nocopy SP.TVALUE );

-- ������� ���������� ������ ������, ����������� ���������� �� ������� IMan.
-- V - ��������� �� ������ IMan.
function getIntArr(V in SP.TVALUE) return TInts;
function getDblArr(V in SP.TVALUE) return TDbls;
function get2DblArr(V in SP.TVALUE) return T2Dbls;
function getValArr(V in SP.TVALUE) return TVals;

-- ��������� ��������� ������ IMan �� ��������� ���� �������� ������.
-- ���� OLD-������ �����������, �� ��������� ������� ������ ��� �������� �������
-- ������� �� ���������� �������, � ����� ������� ���� ����� ��������.  
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TVals, OLD_Vals in TVals);
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TInts, OLD_Vals in TInts);
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TDbls, OLD_Vals in TDbls);
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in T2Dbls, OLD_Vals in T2Dbls);
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TVals);
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TInts);
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in TDbls);
PROCEDURE Assign(V in SP.TVALUE, NEW_Vals in T2Dbls);

FUNCTION Val2TVALUE(Vals in TVals, i in binary_integer) return SP.TVALUE;
PROCEDURE TVALUE2Val(Vals in out nocopy TVALS, i in binary_integer,
                     V in SP.TVALUE);

-- ��������� ��������� ���� S ��� ������� �������� ������� V.
-- P - ������ ����������.
PROCEDURE forArr(V in SP.TVALUE, S in VARCHAR2,
                 P in out nocopy SP.G.TMACRO_PARS);
-- ��������� ��������� ������� � ������� ����������.
FUNCTION getP return SP.G.TMACRO_PARS;
PROCEDURE setP(P in SP.G.TMACRO_PARS);

END A;  
