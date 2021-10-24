CREATE OR REPLACE TYPE SP.CS_CYLINDR AS OBJECT 
/* SP-CS_CYLINDR.tps
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2018-02-12 
-- update 2018-02-13
*/
( 
    /*���� ��������� ������� ���������*/
    P0 SP.TVALUE,
    /*
    ������� ������� ���������
    "LEFT" - ��� ������������ ����� �� ����, ���� ����������� ����� �� �� ��
    "RIGHT" - ��� ������������ ������ �� ����, ���� ����������� 0 �� ���� ��
    */
    CS_variant CHAR(5),
    /*������� ������� ���������, � ������� ���� �� ����� ����� �� ������
    �� ���������� ��� ������������ �������������� ������� ���������,
    ��� �������, ��� ���� ����� ���� �������� ������ 180 ��������.
    Polus   ����� � 3D ���������� ������� ��������� (��� SP.G.TXYZ),
            ���������� ������ �������� ������� ���������
    PLeft   ����� � 3D ���������� ������� ��������� (��� SP.G.TXYZ),
            ���������� ����� ������ ���� ����
    PRight  ����� � 3D ���������� ������� ��������� (��� SP.G.TXYZ),
            ���������� ����� ������� ���� ����
    */
    CONSTRUCTOR Function CS_CYLINDR
    (Polus In SP.TVALUE, PLeft SP.TVALUE, PRight SP.TVALUE) 
    Return SELF as Result,
  
    /*���������� ������� ���������.*/
    Member Procedure Assign
    (Self In Out NoCopy CS_CYLINDR, P0$ In SP.TVALUE, cs_variant In CHAR),
    
    /*
    ��������������� ��������� �� ��������� ������� � ���������
    ptIn$ SP.G.TCylindr
    ptOut$ SP.G.TXYZ  ������ ���� ���������� � �� ��� ������ ���� �����
    */
    Member Procedure ToDesc(Self In Out NoCopy CS_CYLINDR
    ,ptIn$ In Out Nocopy SP.TVALUE, ptOut$ In Out Nocopy SP.TVALUE),
    
    /*
    ��������������� ��������� �� ���������� ������� � ���������
    ptIn$ SP.G.TXYZ
    ptOut$ SP.G.TCylindr  ������ ���� ���������� � �� ��� ������ ���� �����
    */
    Member Procedure FromDesc(Self In Out NoCopy CS_CYLINDR
    ,ptIn$ In Out Nocopy SP.TVALUE, ptOut$ In Out Nocopy SP.TVALUE),

    /*
    ������������ ����� ptToMove$ �� ���� Angle$
    ptToRotate$ SP.G.TXYZ ��� SP.G.TCylindr
    Angle$ ���� ��������
    */
    Member Procedure Rotate(Self In Out NoCopy CS_CYLINDR
    ,ptToRotate$ In Out Nocopy SP.TVALUE, Angle$ In Number),

    /*
    ���������� ���� ��� ����� ptIn$ � ��������� ������� ���������
    ptIn$ ������ ���� SP.G.TXYZ 
    */
    Member Function GetAngle(Self In Out NoCopy CS_CYLINDR
    ,ptIn$ In Out Nocopy SP.TVALUE) return Number,
    
    /*������� ATAN2(dy,dx) �������������� �������� ������� ���������*/
    Member Function Arctg2(Self In Out NoCopy CS_CYLINDR
    ,dy$ in Number, dx$ in Number) return Number,
    
    /*���������� �� ����� �� �� ��.*/
    Static Function ArctgLeft(dy In Number, dx In Number) Return Number,
    
    /*���������� �� ���� �� ���� ��*/
    Static Function ArctgRight(dy In Number, dx In Number) Return Number
);

