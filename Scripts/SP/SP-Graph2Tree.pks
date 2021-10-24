CREATE OR REPLACE PACKAGE SP.Graph2Tree
-- SP Graph as Tree package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 03.06.2013
-- update 09.06.2013 25.06.2013 25.06.2013 16.10.2013 31.10.2013
--        22.03.2015

AS
-- !!! ������� ���������� ����������
MaxRecords PLS_INTEGER:=10000;
ACommit BOOLEAN :=false;
-- ������ �����.
TYPE TNUMBERS IS TABLE OF NUMBER INDEX BY VARCHAR2(128);
-- ������ ���.
TYPE TNAMES IS TABLE OF VARCHAR2(128) INDEX BY VARCHAR2(128);
-- ����� ������.
TYPE TBOOLEANS IS TABLE OF BOOLEAN INDEX BY VARCHAR2(128);
TYPE T2NUMBERS is TABLE of SP.TNUMBERS INDEX by VARCHAR2(128);
Root TNUMBERS;
RootName TNAMES;
MaxLevel TNUMBERS;
/* 
NID - ������������� ��������						 
PID - ������������� ��������						 
TEXT - �������� ��������
������� ������� ������ ������������� ��� ������ ������, � ������� ������ ����
� ������� �� ������������� ����� ������ ��������.
������ ������ ���� NID||'L'||Level||D||occurence 
*/
-- ��������� ������������� ������������� ��������� �������.
FUNCTION GetRoot(Set_Name in VARCHAR2 default '0') return NUMBER;
-- ��������� ������������� �������� ������� �� �������������� ����.
PROCEDURE SetRoot(NID in NUMBER,Set_Name in VARCHAR2 default '0');
-- ��������� ������������� �������� ���� �� ����� ����.
PROCEDURE SetRootbyName(NewRoot in VARCHAR2,Set_Name in VARCHAR2 default '0');
-- ��������� ������������� ������������ ������� ������������.
PROCEDURE SetMaxLevel(NewMaxLevel in NUMBER,Set_Name in VARCHAR2 default '0');
-- ������� ������������� �������������� ����� � ������ ����� � ���-�� �������.
FUNCTION SelectNodes(Set_Name in VARCHAR2 default '0') return SP.TNumbers;
-- ��������� ���������� ������� ������������ ������ ���������������.
PROCEDURE Reset(Set_Name in VARCHAR2 default '0');
-- ������� ������������� ���� � ���� ������ � ������ ����� � ���-�� �������.
FUNCTION SelectTree(Set_Name in VARCHAR2 default '0') 
  return SP.TGRAPH2TREE_NODES pipelined;
-- ��������� ��������� ����� ���� � ������ ��������, ��������� ����� N_Text
-- � �������� � ������ N_Pnode.
PROCEDURE Ins_Group_or_Link(N_Pnode in VARCHAR2,N_Text in VARCHAR2);
-- ��������� ��������� ������ ��� �����. 
PROCEDURE Upd_Group_or_Link(N_Pnode in VARCHAR2,--����� ��������.
                            N_Text in VARCHAR2, --����� ���.
                            O_Node in VARCHAR2, --����������� ����.
                            O_Pnode in VARCHAR2 --������ ��������.
                            );
-- ��������� �������� ��������� ����� (���������� �����) � ������. 
-- ����������� ����� ������� ����� ������: 
-- ��������������� ���� � ��������������� ��� ��������.
PROCEDURE Upd_Link_Line(O_Node in VARCHAR2, 
                        O_Pnode in VARCHAR2,
                        NewLine in NUMBER -- ����� ����� O_Node � O_Pnode.
                        );
-- ���������� ��������� ��� ������������ ��������.
PROCEDURE Del_Group_or_Link(O_Node in out VARCHAR2,
                            O_Pnode in out VARCHAR2,
                            Set_Name in VARCHAR2 default '0');
-- ��������� ���������� ��������.
PROCEDURE DoDelete(Set_Name in VARCHAR2 default '0');
-- ������� ���������� ����������� ������������ ����� ����� Src_Node �
-- Dest_Node (� �������� ��������).
FUNCTION Is_Link_Possible(Src_Node in VARCHAR2,Dest_Node in VARCHAR2)
return BOOLEAN;
-- ��������� NID �� Node (��� PID �� PNode).
FUNCTION NID(Node in VARCHAR2)return NUMBER;
pragma RESTRICT_REFERENCES(NID,RNDS,WNDS,RNPS,WNPS);
-- ��������� LEVEL �� Node ��� PNode.
FUNCTION Node_L(Node in VARCHAR2)return NUMBER;
-- ������� ������������� ������ ������.
-- ��� ������ �������� ������� ���������� ���������� ���������� SP.TG.CurValue.
FUNCTION GROUP_Nodes return SP.TS_VALUES_COMMENTS pipelined;

End Graph2Tree;
/

