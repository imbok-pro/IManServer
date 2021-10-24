CREATE OR REPLACE PACKAGE SP.Lobs
-- Lobs package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 08.03.2021
-- update 10.03.2021 14.03.2021 01.07.2021-03.07.2021 15.07.2021

AS

-- �������� Clob � Blob
PROCEDURE testLob(V in SP.TVALUE);

-- �������� ������������� � ��������� TAG||GUID|TYPE �����.
FUNCTION BL2Str(V in SP.TVALUE) return VARCHAR2;

-- ��������� �������� ���� ������ �� ���� �� ��� GUID.
-- ������ ����� ���� ���� TAG||GUID|TYPE
-- ��� ��������� ������ TAG � GUID ������������ � ������ �������� �� �������
-- Lobs
PROCEDURE S2BLob(S in VARCHAR2, V in out nocopy SP.TVALUE);

-- �������� ������������� � ��������� TAG||GUID|TYPE ���������� �����.
FUNCTION CL2Str(V in SP.TVALUE) return VARCHAR2;

-- ��������� �������� ���� ������ �� ��������� ���� �� ��� GUID.
-- ������ ����� ���� ���� TAG||GUID|TYPE. 
-- ��� ��������� ������ TAG � GUID ������������ � ����� ���������� ��
-- �������� ������� SP.LOB_S
PROCEDURE S2CLob(S in VARCHAR2, V in out nocopy SP.TVALUE);

-- ������ � ���� ������ �����, � ��������� ������ �� ���� ����.
-- ��� ���� ���� X ����� ��������� TAG �����,
-- a ���� Y - ������������� ��� ����(TFileType). 
FUNCTION LStore(BinFile in BLOB,
                tag in NUMBER default null,
                FileType in SP.TVALUE default null)
return SP.TVALUE;

-- ������ � ���� ������ ���������� �����, � ��������� ������ �� ���� ����.
-- ��� ���� ���� X ����� ��������� TAG �����,
-- a ���� Y - ������������� ��� ����(TFileType). 
FUNCTION LStore(TxtFile in CLOB,
                tag in NUMBER default null,
                FileType in SP.TVALUE default null)
return SP.TVALUE;

-- ������ ����� �� ������.
-- � ������������ ������ ���� ���� �� ������������� �������,
-- �������� ����������� ��������.
-- ���� ������ ����, �� ������ �� ���� ����� ����� �� ������� ���������.
FUNCTION getFile(FileRef in SP.TMPAR, D in DATE default null) return BLOB;

-- ������ ���������� ����� �� ������.
-- � ������������ ������ ���� ���� �� ������������� �������,
-- �������� ����������� ��������
-- ���� ������ ����, �� ������ �� ���� ����� ����� �� ������� ���������.
FUNCTION getTxtFile(FileRef in SP.TMPAR, D in DATE default null) return CLOB;

-- ������ ����� �� ������.
-- � ������������ ������ ���� ���� �� ������������� �������,
-- �������� ����������� ��������.
-- ����� ������ ���������� ���� �� ������� ��� �� ��������� ��� ���������� 
-- VAL.N � N, ����� ��������� null �����. 
FUNCTION getFilebyRef(FileRef in SP.TMPAR, N in NUMBER) return BLOB;

-- ������ ���������� ����� �� ������.
-- � ������������ ������ ���� ���� �� ������������� �������,
-- �������� ����������� ��������
-- ����� ������ ���������� ���� �� ������� ��� �� ��������� ��� ���������� 
-- VAL.N � N, ����� ��������� null �����. 
FUNCTION getTxtFilebyRef(FileRef in SP.TMPAR, N in NUMBER) return CLOB;

-- ������ ����� �� ������.
-- � ������������ ������ ���� ���� �� ������������� �������,
-- �������� ����������� ��������.
-- ���� �� ����� tag, �� ������ �� ���� ����� ����� �� ���������.
-- ���� ������ ����, �� ������ �� ���� ����� ����� �� ������� ���������,
-- �� � ������ tag.
FUNCTION getFilebyTag(FileRef in SP.TMPAR, TAG in NUMBER,
                      D in DATE default null) 
return BLOB; 

-- ������ ���������� ����� �� ������.
-- � ������������ ������ ���� ���� �� ������������� �������,
-- �������� ����������� ��������
-- ���� �� ����� tag, �� ������ �� ���� ����� ����� �� ���������.
-- ���� ������ ����, �� ������ �� ���� ����� ����� �� ������� ���������,
-- �� � ������ tag.
FUNCTION getTxtFilebyTag(FileRef in SP.TMPAR, TAG in NUMBER,
                         D in DATE default null)
return CLOB;

-- ���������� ����� TAG(X) � F_TYPE(Y) � ������ �� �������� �� ������� LOB_S
PROCEDURE refresh_LOB(Lob in out nocopy SP.TVALUE);

-- ���������� ���� �������� ���������� ����� Blob � Clob. ���������� �� ����� 
-- N, X � Y � ������������ � �������� Lob_s.
PROCEDURE refresh_all_LOBs;

-- ��������� ���� ����� � ������� LOB_S. ���� �������� F_Type null,
-- �� ���������� �������� �� Lob. 
PROCEDURE updateTYPE(Lob in out nocopy SP.TVALUE,
                     F_Type in SP.TVALUE default null);

-- ��������� ���� ����� � ������� LOB_S. ���� �������� TAG null,
-- �� ���������� �������� �� Lob. 
PROCEDURE updateTAG(Lob in out nocopy SP.TVALUE, TAG in NUMBER default null);

-- �������� ������, �� ������� ��� ������.
PROCEDURE Delete_not_Used;

end Lobs;
/
