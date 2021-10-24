CREATE OR REPLACE PACKAGE SP.STAIRWAY
-- STAIRWAY package 
-- ��������� ��� �������� ���������� ��� �������������� �������� 
-- by Gracheva Irina
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 06.07.2011 
-- update 08.08.2011,22.08.2011 07.09.2011

AS
-- ������� ������������� ��������� ����� ����������� �����
FUNCTION SetOfStairH return SP.TS_VALUES_COMMENTS pipelined;

-- ������� ������������� ��������� ����� ���������
FUNCTION SetOfLadderH return SP.TS_VALUES_COMMENTS pipelined;

-- ������� ������������� ��������� ���� ���������� ��������
FUNCTION SetOfLanding return SP.TS_VALUES_COMMENTS pipelined;

-- ������� ������ ���� X * Y ��������� �  TVALUE � ������������ X � Y
PROCEDURE LandSV
		  (LandingSize IN VARCHAR2,V in out NOCOPY SP.TVALUE);

-- ������� - ������� ������ ����� ( ����� ��������) 
-- Floor - ����� �����
-- HFloor - �������� �� ���������
-- HVar - ��������, �� ������� ����� ������� ��������,
-- H - ������, L - �����
FUNCTION stairH( Floor number,
				 HFloor number,
				 HVar varchar2,
				 Litera varchar2) RETURN NUMBER;

-- ������� ������������� ��������� ����� �����
FUNCTION SetOfRailH return SP.TS_VALUES_COMMENTS pipelined;

-- ������� ������������� ��������� ����� �����
FUNCTION SetOfBarrierH return SP.TS_VALUES_COMMENTS pipelined;

-- ������� ���������� ���������� ����� ������������� �������� �����
FUNCTION GetRailVertL (H in number, alfa in number)return number;

END STAIRWAY;  
