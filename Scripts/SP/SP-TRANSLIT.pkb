CREATE OR REPLACE PACKAGE BODY SP.TRANSLIT
-- TRANSLIT package body
--
-- �������������� �������� ����� ��������� ��������� 
--
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2021-03-23
-- update 2021-03-26
AS

Type AA_Dict Is Table Of Varchar2(8) Index By Varchar2(2);

SimpleDict AA_Dict;

--==============================================================================
-- ������������� ������� ��� ���������� �������������� � �������� �� ���������
Procedure SimpleDictInit
As

Begin
  SimpleDict('�'):='a';
  SimpleDict('�'):='b';
  SimpleDict('�'):='v';
  SimpleDict('�'):='g';
  SimpleDict('�'):='d';
  SimpleDict('�'):='e';
  SimpleDict('�'):='yo';
  SimpleDict('�'):='zh';
  SimpleDict('�'):='z';
  SimpleDict('�'):='i';
  SimpleDict('�'):='j';
  SimpleDict('�'):='k';
  SimpleDict('�'):='l';
  SimpleDict('�'):='m';
  SimpleDict('�'):='n';
  SimpleDict('�'):='o';
  SimpleDict('�'):='p';
  SimpleDict('�'):='r';
  SimpleDict('�'):='s';
  SimpleDict('�'):='t';
  SimpleDict('�'):='u';
  SimpleDict('�'):='f';
  SimpleDict('�'):='x';
  SimpleDict('�'):='c';
  SimpleDict('�'):='ch';
  SimpleDict('�'):='sh';
  SimpleDict('�'):='shh';
  SimpleDict('�'):='''''';  --��� ���������
  SimpleDict('�'):='y';
  SimpleDict('�'):='''';  --���� ��������
  SimpleDict('�'):='e';
  SimpleDict('�'):='yu';
  SimpleDict('�'):='ya';
  
  SimpleDict('�'):='A';
  SimpleDict('�'):='B';
  SimpleDict('�'):='V';
  SimpleDict('�'):='G';
  SimpleDict('�'):='D';
  SimpleDict('�'):='E';
  SimpleDict('�'):='YO';
  SimpleDict('�'):='ZH';
  SimpleDict('�'):='Z';
  SimpleDict('�'):='I';
  SimpleDict('�'):='J';
  SimpleDict('�'):='K';
  SimpleDict('�'):='L';
  SimpleDict('�'):='M';
  SimpleDict('�'):='N';
  SimpleDict('�'):='O';
  SimpleDict('�'):='P';
  SimpleDict('�'):='R';
  SimpleDict('�'):='S';
  SimpleDict('�'):='T';
  SimpleDict('�'):='U';
  SimpleDict('�'):='F';
  SimpleDict('�'):='X';
  SimpleDict('�'):='C';
  SimpleDict('�'):='CH';
  SimpleDict('�'):='SH';
  SimpleDict('�'):='SHH';
  SimpleDict('�'):='''''';  --��� ���������
  SimpleDict('�'):='Y';
  SimpleDict('�'):='''';  --���� ��������
  SimpleDict('�'):='E';
  SimpleDict('�'):='YU';
  SimpleDict('�'):='YA';

End SimpleDictInit;
--==============================================================================
-- ���������� �������������� �������� ������ ��������� ��������� 
-- � ������������ � ���� Р7.0.34-2014
-- ������ ������� ����� �� ��������� ��������������, 
-- ��������� ������� ��������� ��� ����.
FUNCTION TransSimpleChar(Char$ In Varchar2) return Varchar2
is
  rv Varchar2(4000);
begin
  return SimpleDict(Char$);
Exception When Others Then
  Return Char$;
end TransSimpleChar;  

--==============================================================================
-- ���������� �������������� �������� ������ ��������� ��������� 
-- � ������������ � ���� Р7.0.34-2014
-- ��� ������� ����� �������� ���������� ����������������, 
-- ��������� ������� ��������� ��� ����.
FUNCTION TransSimple(Str$ In Varchar2) return Varchar2
is
  rv Varchar2(4000);
  r# CLOB;
  iLen# BINARY_INTEGER;
begin
  iLen#:=LENGTH(Str$);
  If iLen#<1 Then
    Return rv;
  End If;

  DBMS_LOB.CREATETEMPORARY(r#, cache => false, dur => DBMS_LOB.CALL );
  
  For i in 1..iLen# Loop
    DBMS_Lob.append(r#,TransSimpleChar(SUBSTR(Str$,i,1)));
  End Loop;
  rv:=TO_CHAR(SUBSTR(r#,1,4000)); 
  --DBMS_LOB.CLOSE(r#);
  return rv;
end TransSimple;  

--==============================================================================
Begin
  --������������� ������� ��� ���������� �������������� � �������� �� ���������.
  SimpleDictInit; 
END TRANSLIT;
/
