CREATE OR REPLACE PACKAGE SP.RolesTree
-- SP RolesTree package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 22.03.2015
-- update 23.03.2015 19.08.2015

AS
-- !!! ������� ���������� ����������
MaxRecords PLS_INTEGER:=10000;
type TN is table of NUMBER index by VARCHAR2(60);
type TS is table of VARCHAR2(60) index by VARCHAR2(60);
Root TN;
RootName TS;
/* 
NID - ������������� ����						 
PID - ������������� ��������						 
TEXT - ��� ����
  ������� ������� ������ ������������� ��� ������ ������, � ������� ������ ����
� ������� �� ������������� ����� ������ ��������.
  ������ ������ ���� NID||'L'||Level||D||occurence. 
  ������������ ����� ����������� � ����������� ���������,
������ �� ������� ����� ����� ���� ������.
  ��� ����, �������� TreeName ���������� ��� ������.
  ���� �������� �� ������ ������������ ����� � ������ "1"
*/
-- ��������� ������������� ������������� ��������� �������.
-- TreeName ��� ������.
FUNCTION GetRoot(TreeName in VARCHAR2 default '1') return NUMBER;

-- ��������� ������������� �������� ������� �� �������������� ����.
PROCEDURE SetRoot(NID in NUMBER, TreeName in VARCHAR2 default '1');

-- ��������� ������������� �������� ���� �� ����� ����.
PROCEDURE SetRootbyName(NewRoot in VARCHAR2, TreeName in VARCHAR2 default '1');

-- ������� ������������� ������ �����.
FUNCTION SelectTree(TreeName in VARCHAR2 default '1') 
return SP.TROLE_RECORDS pipelined;
  
-- ��������� ��������� ����� ���� � ������ ���������. 
-- ��������� ���������� commit.
PROCEDURE Ins_Role_Link(N_Pnode in VARCHAR2,--����� ��������.
                        RoleName in VARCHAR2 -- ����������� ����.
                        );
-- ��������� ���������� ���� � ������� ��������. 
-- ��������� ���������� commit.
PROCEDURE Upd_Role_Link(N_Pnode in VARCHAR2,--����� ��������.
                        O_Node in VARCHAR2, --����������� ����.
                        O_Pnode in VARCHAR2 --������ ��������.
                        );

-- ���������� ��������� ��� ������������ ��������.
PROCEDURE Del_Role_or_Link(O_Node in out VARCHAR2, 
                           O_Pnode in out VARCHAR2,
                           TreeName in VARCHAR2 default '1'
                          );
                            
-- ��������� ���������� ��������.
-- ��������� ���������� commit.
PROCEDURE DoDelete(TreeName in VARCHAR2 default '1');

-- ������� ���������� ����������� ������������ ����� ����� Src_Node �
-- Dest_Node (� �������� ��������).
FUNCTION Is_Link_Possible(Src_Node in VARCHAR2,Dest_Node in VARCHAR2)
return BOOLEAN;

-- ��������� NID �� Node (��� PID �� PNode).
FUNCTION NID(Node in VARCHAR2)return NUMBER;
pragma RESTRICT_REFERENCES(NID,RNDS,WNDS,RNPS,WNPS);

-- ��������� LEVEL �� Node ��� PNode.
FUNCTION Node_L(Node in VARCHAR2)return NUMBER;


End RolesTree;
/

