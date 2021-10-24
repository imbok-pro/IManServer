-- TYPES
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 17.08.2010 
-- update 06.09.2010 14.09.2010 16.09.2010 08.10.2010 13.10.2010 20.10.2010
--        28.10.2010 19.11.2010 24.11.2010 10.12.2010 17.12.2010 09.02.2011
--		    18.03.2011 11.05.2011 17.10.2011 10.11.2011 27.01.2012 11.04.2012 
--        04.04.2013 09.04.2013 04.06.2013 17.06.2013 22.08.2013 03.07.2014
--        21.04.2015 12.03.2018
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE SP.TValue 
/* ������������� �������� ��� ���������� ������� �������� ��� ������,
� ����� ���������� ����������. ���� ���������� �������� Check_ValEnabled ��
����������, �� �������� �������� �� ������������ �� ���� ������ ����! */
/* SP-TValue.tps*/
AS OBJECT
(
/* ��� ���������.*/
T  NUMBER,
/* ���� ����� ��������� �������� ��� ��������� ��� ������ ��������.*/
COMMENTS VARCHAR2(4000),
/* ������ ���� ������������ ��� ����������� ������� � ������������� � ������� Get_User_Input. ���� R_ONLY = 0, �� �������� ��������� ����� ������ � ����������. ���� R_ONLY = 1, �� �������� ��������� ����� ������ ������. ���� R_ONLY = -1, �� �������� ��������� ������ ���� ����������� ��������� �������������. */
R_ONLY NUMBER(1),
/* ���� ��� ����� �������� ����� ��������, �� ���� �������� ��� ��������
��������. ��� �� �������� � ���� ������������� ������� �������� � ����
������.*/
E  VARCHAR2(128),
/* ����� ��������.*/
N  NUMBER,
/* ����� ��������.*/
D  DATE,
/* ����� ��������. 
��� ������� �� ��������� � �������������� �������� � ���� ������.*/
S  VARCHAR2(4000),
/* ����� ��������.*/
X  NUMBER,
/* ����� ��������.*/
Y  NUMBER,
--
/* ����������� ��� �������� ���� ��������.*/
CONSTRUCTOR FUNCTION TValue 
RETURN SELF AS RESULT,
/* ����������� ��������� ������������� ���� ��������.*/
CONSTRUCTOR FUNCTION TValue(ValueType IN VARCHAR2) 
RETURN SELF AS RESULT,
/* ����������� ��������� ������������� ���� ��������.*/
CONSTRUCTOR FUNCTION TValue(ValueType IN NUMBER) 
RETURN SELF AS RESULT,
/* ����������� ��������� �������� �, ���� ��� �� �������� � ���������� ������� 
"Safe" != 0, �� ����������� ��������� ������ �������� �� ������ ��������,
������������ ��� ������� ����.*/
CONSTRUCTOR FUNCTION TValue(ValueType IN VARCHAR2,StrValue IN VARCHAR2,
                            Safe IN NUMBER DEFAULT 0)
RETURN SELF AS RESULT,
/* ����������� ��������� �������� �, ���� ��� �� �������� � ���������� ������� 
"Safe" != 0,  �� ����������� ��������� ������ �������� �� ������ ��������,
������������ ��� ������� ����.*/
CONSTRUCTOR FUNCTION TValue(ValueType IN NUMBER,StrValue IN VARCHAR2,
                            Safe IN NUMBER DEFAULT 0)
RETURN SELF AS RESULT,
/* ����������� ��������� ������������� ���� �������� � ������ ��������.*/
CONSTRUCTOR FUNCTION TValue(ValueType IN VARCHAR2,NumValue IN NUMBER)
RETURN SELF AS RESULT,
/* ����������� ��������� ������������� ���� �������� � ������ ��������.*/
CONSTRUCTOR FUNCTION TValue(ValueType IN NUMBER,NumValue IN NUMBER)
RETURN SELF AS RESULT,
/* ����������� ��������� ��� �������� �, ���� ��� ����� ����������� ��������,
�� ������� ��������� ��� ��������. ���� �������� "DisN" ����� ���� ��� "1", 
�� ���� ���� ����� ���� ��� ����������� �� ��������� "D".
����������� ��������� �������� �, ���� ��� �� �������� � ���������� ������� 
"Safe" != 0,  �� ����������� ��������� ������ �������� �� ������ ��������,
������������ ��� ������� ����. ��� ���������� ����, ���� ��������� ���� S, �� ����������� ������ �� ������������� ������� � ������, �� ����������� �������� ��� �����. ���� ������ ���������������, �� ����� ���������� ������.*/
CONSTRUCTOR FUNCTION TValue(ValueType IN NUMBER,
                            N    IN NUMBER,
                            D    IN DATE DEFAULT NULL,
                            DisN IN NUMBER DEFAULT 1,
                            S    IN VARCHAR2,
                            X    IN NUMBER,
                            Y    IN NUMBER,
                            Safe IN NUMBER DEFAULT 0)
RETURN SELF AS RESULT,
/*����������� ��������� ������������� ���� �������� � ������ ��������. 
���� �������� "DisN" ����� ���� ��� "1", �� ���� ���� ����� ���� ���
����������� �� ��������� "D".��� ���������� ����, ���� ��������� ���� S, �� ����������� ������ �� ������������� ������� � ������, �� ����������� �������� ��� �����. ���� ������ ���������������, �� ����� ���������� ������.*/
CONSTRUCTOR FUNCTION TValue(ValueType IN NUMBER,
                            E    IN VARCHAR2,
                            N    IN NUMBER,
                            D    IN DATE DEFAULT NULL,
                            DisN IN NUMBER DEFAULT 1,
                            S    IN VARCHAR2,
                            X    IN NUMBER,
                            Y    IN NUMBER)
RETURN SELF AS RESULT,
--
/* ������� ������������� ��� ��������� ������  ��������� �� ��������������
   ���� � ���������������� � ������ ��������. 
   �������� ������. ���� ������ ������� � ���������� � ��������� ������,
   �� ����� �����!*/
MAP MEMBER FUNCTION map_values(self IN OUT NOCOPY SP.TVALUE) RETURN VARCHAR2,
/* ������� ���������� ��� ���� ��������.*/
MEMBER FUNCTION TypeName RETURN VARCHAR2,
/* ������� ���������� �������� � ���� ������.*/
MEMBER FUNCTION asString(self IN OUT NOCOPY SP.TVALUE) RETURN VARCHAR2,
/* ������� ���������� �������� � ���� ����������� ����, ���� ��� ��������,
����� ��������� ����������.*/
MEMBER FUNCTION asBoolean RETURN BOOLEAN,
/* ������� ���������� �������� � ���� ����������� ����, ���� ��� ��������,
����� ��������� ����������.*/
MEMBER FUNCTION B RETURN BOOLEAN,
/* ��������� ��������� ��� ���� �������� �� ��������� ��� ����������
�������������, ���� ��� ��������. ���� �������� �� �������� � ���������� ���� 
"Safe" = true,  �� ��������� ��������� ������ �������� �� ������ ��������,
������������ ��� ������� ����. ���� ��� ���������� ��� ���� "Safe" != true
�� ��������� ����������.*/
MEMBER PROCEDURE Assign(self IN OUT NOCOPY SP.TVALUE, StrValue IN VARCHAR2,
                        Safe in BOOLEAN default false),
/* ��������� ��������� ��� ���� �������� �� ��������� ����������� ��������,
���� ��� ��������, ����� ��������� ����������.*/
MEMBER PROCEDURE Assign(self IN OUT NOCOPY SP.TVALUE, BoolValue IN BOOLEAN),
/* ��������� ��������� ��� ���� �������� �� ��������� ��������� ��������,
���� ��� ��������, ����� ��������� ����������.*/
MEMBER PROCEDURE Assign(self IN OUT NOCOPY SP.TVALUE, NumValue IN NUMBER),
/* ��������� �������� ��� ���� ��������.*/
MEMBER PROCEDURE Assign(self IN OUT NOCOPY SP.TVALUE, Val IN SP.TVALUE),
/* ��������� ������������� ���� R_ONLY = 1.*/
MEMBER PROCEDURE READ_ONLY(self IN OUT NOCOPY SP.TVALUE),
/* ��������� ������������� ���� R_ONLY = 0.*/
MEMBER PROCEDURE READ_WRITE(self IN OUT NOCOPY SP.TVALUE),
/* ��������� ������������� ���� R_ONLY = -1.*/
MEMBER PROCEDURE REQUIRED(self IN OUT NOCOPY SP.TVALUE)
);
/
GRANT EXECUTE ON SP.TValue TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM V_ FOR SP.TValue; 
--
-- end of file
