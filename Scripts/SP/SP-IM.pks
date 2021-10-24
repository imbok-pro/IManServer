CREATE OR REPLACE PACKAGE SP.IM
-- IntergraphManager package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 19.08.2010
-- update 12.10.2010 03.11.2010 09.11.2010 15.11.2010 24.11.2010 09.12.2010
--        11.11.2011 18.11.2011 23.11.2011 11.01.2012 17.01.2012 30.01.2012
--        04.04.2013 25.08.2013 29.08.2013 16.06.2014 20.06.2014 24.06.2014
--        03.07.2014 26.20.2014-03.11.2014 25.05.2015 03.02.2016 25.02.2016
--        29.02.2016 06.11.2016 10.04.2017-11.04.2017 17.04.2017 11.09.2017
--        07.11.2017 01.12.2017 14.12.2017 19.02.2018 05.03.2018 22.04.2019
--        23.07.2019 01.10.2020 12.11.2020 18.05.2021

AS
-- ������ ����� �������� ������� �������������� ������� ���������� � ���������
-- �������.

-- ��������� �� ���������� ������ (��������������).
WM SP.COMMANDS.COMMENTS%type;
-- ��������� � ����������� ������.
EM SP.COMMANDS.COMMENTS%type;
-- ��� ������� ������������� �������, �� ������� IMan.
-- ������ ��� ��������� ���������� ������� IMan ��� ����, ����
-- ���������� ������ ��������� �������.
CurCommand NUMBER;
-- ������ ���������� �������.
PP SP.G.TMACRO_PARS;
-- ������ ��������.
OS SP.G.TOBJECTS;
-- ������ ��������, ������������ � �������� ������ �� ���������� ������.
SS SP.G.TOBJECTS;
-- ������ ��������� ��������������.
-- ������ ��������� ��� ������� �������������� ��� ����� ��� ���������
-- �������� get_Messages.
MESSAGES SP.G.TNAMES;

-----------------------------
-- �������������� ������� �� ����������� � ������������ ����� ����� ������ ��� 
-- ���������� � ��������� �������� �� ������� ������.
-- ����� �������� �������������� �� ������� ������� ���������� �������� ��
-- ������ �������� ����������, ������������ ��������� ����������� ���������.
-- ����� ���������� ���� �����������, ������ ��� �� ���������� ��������
-- �������� ����������, ������������ ����� ���������.
-- ������� ������ ������� �������� ���������� �� ������� ����� ���� ����������:
--   Sp.IM.Set_Par(<ParName>,SP.TVALUE(<ParType>,N,D,DisN,S,X,Y));
--   Sp.IM.Set_Par(<ParName>,SP.TVALUE(<ParType>,<S_Value>));
-- ���, ParName - ��� ���������
--      ParType - ��� ���������
--      S_Value - �������� ��������� � ���� ������.
---------------------------

-- ������� ���������  ��� �������� �������� ���� � ������� ����������,
-- ���� ������ ��������� � ������ ����� ����������, ���� ������ ����������, 
-- ���� ������ - � ������ ���������� ������.  
-- ������� ���������� ����, ���� �� ��������� ��� ��������� �� ������.
-- ������� ��������� ��������, ���� ������� �����������.
FUNCTION Set_Par(ParName in VARCHAR2, ParValue in SP.TVALUE)return VARCHAR2;

-- ��������������� ������� �������. �������� ��� �������� �� ����� ���������.
-- �� ����� ���� ����������� ��� ���������� ���������.
-- � ������ ���������� ��������� �������� �� ������.
-- ���������� (�� ��������� � �� ��������) ���������� ��������� ����������
-- SP3DTYPE,IS_SYSTEM � IS_TINY
FUNCTION Set_Par(ParName in VARCHAR2, ParValue in VARCHAR2)return VARCHAR2;

-- ������� �������� ��������� ������� �������� �� ��������� ������� �������
-- ���������� �������. 
-- ��� ������� ������������ ����� ���� �������� ��������� Set_Par.
-- ������� ���������� ����, ���� �� ��������� ��� ��������� �� ������.
-- ObjectName - ������ ��� �������, ��������: (SysObjects.#Native Object).
-- ���� ������� �������� null, �� ������� �� ���������� ������, �� �
-- �� ��������� ������� 
FUNCTION Set_Pars(ObjectName in VARCHAR2) return VARCHAR2;
FUNCTION Set_Pars(ObjectID in NUMBER) return VARCHAR2;

-- ������� ������������� ��� �������� �� ������ ���������� ��������.
-- ������� ������������ � �������� "GET_SELECTED", "GET_OBJECTS",
-- "GET_SYSYEMS" � "GET_ALL_SYSYEMS" � "Set_Root".
-- ������� ���������� ����, ���� �� ��������� ��� ��������� �� ������.
FUNCTION Set_ObjectPar(ObjectNum in NUMBER,
                       ParName in VARCHAR2,
                       ParValue in TValue) 
return VARCHAR2;

-- ��������� ������� ������ ��������.
PROCEDURE Clear_Objects;

-- ��������� ������������ ��� ������������ ����� ��������� �������
-- � ��������� ����� ������� ������. 
-- ��������� ������� �������� �������� �������, ��������� �������� ��������
-- ������� � ������������ � �������� ������ ��������� �� �������!
PROCEDURE SET_SERVER(ModelName in VARCHAR2, ServerType in NUMBER);

-- ��������� ������������ ��� ��������� ���������� ������� SP.M.ROOT � 
-- ������������ �� ��������� �������� ������� �������� �������.
-- � ��������� ����� ���������� ������� "SET_PATH" ���������� ������� ���
-- ���������. ��������� ���������� ������ �� ������� "OS",
-- �������� ��� ����, ��� �� ������������.
-- ������ �� ������� ��������� ������� ������ ��� ���� ����� �� ������������ ��
-- ���������� ������ IMan.
-- ���� ������� ������ ���������� �� ���������� ������, �� ��������� ���������
-- �������� "ID" ���������� ��������������� �������.
-- ���� ������� ������ �������� ������ ��������,
-- �� ��������� ��������� ��� ID ������ "1".
-- � ��������� �������, ���� ������ ����������� �� ���������� ������,
-- ��� "ID" ����� ���������� � ����. 
PROCEDURE SET_ROOT;   

-- ������ ��������������.
-- ���� � �������������� ���� ���������, �� ������ ������� �� �����
-- ������� ���� �������.
-- ������� ���������� ����, ���� �� ��������� ��� ��������� �� ������.
FUNCTION START_MACRO(MacroName in VARCHAR2) return VARCHAR2;
FUNCTION START_MACRO(ObjectID in NUMBER) return VARCHAR2;

-- ����� ��������� ������� ��������������, ������, � �����, �������� �������,
-- ��������������� ��������� ������������� �������,
-- ������� ���������� ���������.
-- ���� ����������� ��� ��������� ������� G.Cmd_CANCEL ��� G.Cmd_Return.
FUNCTION get_COMMAND return NUMBER;

-- ������� ������������� ��������� �� ������.
-- � ����������� ��� ������� ����� ��������� ������� G.Cmd_CANCEL.
FUNCTION get_EM return VARCHAR2;  

-- ������� ������������� ��������� �� ���������� ������.
-- � ����������� ��� ������� ����� ��������� ������� G.Cmd_Get_User_Input.
FUNCTION get_WM return VARCHAR2;  

-- ������� ������������� ��� ��������� �������������� � ���� CLOB,
-- ����� ���� ������� ������ ���������.
FUNCTION get_MESSAGES return CLOB;  

-- ������� ������������� ��������� ������� ������� ��� ������� �� �������������
-- SP.V_COMMAND_PAR_S, 
-- ���� ���� ���� (�������������� �� �������� ��� ����������� �������
-- "GET_USER_INPUT").
-- ���� ��� ���������� ������� ������� ���������� ���������, �� ��� ����������
-- ��������� ��������� ������:
-- select NAME ParName,T ParType,E ValueName,N,D,S,X,Y
--   from table(SP.IM.get_PARS);
FUNCTION get_PARS return SP.TIMAN_PARS pipelined;

-- ������� ������������� ��������� �������� �������� �������.
-- ������:
-- select NAME ParName,T ParType,E ValueName,N,D,S,X,Y
--   from table(SP.IM.get_ROOT);
FUNCTION get_ROOT return SP.TIMAN_PARS pipelined;

-- ������� ������������� ���� � �������� �������� �������.
FUNCTION get_ROOT_FULL_NAME return VARCHAR2;

-- ����� �������� ���������� ���������� ������� G.Cmd_CREATE_OBJECT
-- ������ ������� �� ������ ��������� ��������� � ���� ���������� �������,
-- ����� ���� ��������� �� ������� ��� ���������.
-- ���������� ��������� ��������� ����������.
PROCEDURE INSERTED_or_UPDATED;

-- ����� �������� ���������� ���������� ������� G.Cmd_UPDATE_NOTES
-- ������ ��������� �� ������� ��������� ��������������� ���.
-- ���������� ��������� ��������� ����������.
PROCEDURE NOTES_UPDATED;

-- ����� �������� ���������� ���������� ������ G.Cmd_Change_Parent
-- ��� G.Cmd_Rename
-- ������ ��������� �� ������� ��������� ��������������� ���.
-- ���������� ��������� ��������� ����������.
PROCEDURE RENAMED;

-- ����� �������� ���������� ���������� ������� G.Cmd_DELETE_OBJECT 
-- ������ ��������� �� ������� ��������� ��������������� ���.
-- ���������� ��������� ��������� ����������.
PROCEDURE DELETED;

-- �������� ������� �������� �� ��������� ���������� ��������������.
-- ���������� � �������� ��������� ��� ���� ����� ������.
-- ���������� ��������� ��������� ���������� (���������� �����).
PROCEDURE HALT;

-- ����� ���������� ������ G.Cmd_CANCEL ��� G.Cmd_Return ������ �����
-- ������������� ���������� ��������������.
-- ���������� ��������� ��������� ����������.
PROCEDURE CONFIRM_END;

-- ������������ ������ � ��������� ������ - ������������ RELOAD_MODEL.
--******************************
-- 1. �������� ��� ������� ������������ ��������� ������� �������
-- ��� ������� � ��������. ������� ��������� �������� "ID" ������� ������� �� �������� ������ ������. ���� ����� ������ ��������� ��� ������, �� �������� ����� ����, � ���� �� ������ ��������, �� - "1"
PROCEDURE Mark_to_Delete; 

-- 2. ���������� ��������� ������� �� ���������� ������,
-- ������ ������� �� ��������.
-- ������� ���������� null, ��� ������� ���������� ��� ��������� �� ������.
-- ������� ���������� �����, ��� ������.
FUNCTION FLUSH_OBJECTS return VARCHAR2;

-- 3. ������� ���������� ���������� ������� �� ���������� ������.
-- ������� ���������� null, ��� ������� ���������� ��� ��������� �� ������.
-- ������� ���������� �����, ��� ������.
FUNCTION DELETE_MARKED return VARCHAR2;

-- 4. �������� ������� ���������� ������ �� ������� ���� "Rel".
-- ������� ���������� null, ��� ������� ���������� ��� ��������� �� ������.
-- ������� �� ��������� commit � ������ ��������� ���������� ��������.
-- ������� �� ���������� �����, ��� ������.
-- ��� ������� ��� ���������� ������� ������.

FUNCTION SYM2REL return VARCHAR2;

-- 5. ��������� �������� �� �������� ���������� �������������.
-- ��������� ��������� ����������.
-- ���� ������������� ����������� � �������, �� ������ ���� ���������
-- ���������� �����.
PROCEDURE Model_Reloaded;
--******************************

-- �������������� ������� ��� ������ � ��������� �������.
--****************************************************************************
-- ���������� � ������ ��������� �������� "SS" ������� � ��������������� "ID".
PROCEDURE SELECT_OBJECT(ID in VARCHAR2);

-- ������� ������� ��������� ��������.
PROCEDURE CLEAR_SELECTED;

-- ������� ������������� ��������� ������� �� ���������� ������, ����� ������:
-- select NAME ParName,T ParType,E ValueName,N,D,S,X,Y,R_ONLY,OBJECT_INDEX
--   from table(SP.IM.get_SELECTED);
FUNCTION get_SELECTED return SP.TIMAN_PARS pipelined;

-- ��� ������������� ��������� �������� � ������ ��������, ��� ����������
-- ������� GET_SELECTED ����� ��������� ��������� ����.
-- begin SP.IM.OS:=SP.IM.SS; end;

-- ������� ���������� ������ OS � ������ SYSTEMS �������� ������.
-- ������� ������ �� ������ ���� �� ���� ����� �� �������.
-- ������� ���������� ��������� �� ������.
FUNCTION CopyOS2SYSTEMS return VARCHAR2;

-- ��������� ���������� ������ OS � ������ OBJECTS �������� ������
-- ������� ������ �� ������ ���� �� ���� ����� �� �������.
-- ������� ���������� ��������� �� ������.
FUNCTION CopyOS2OBJECTS return VARCHAR2;

-- ������� ���������� ��������� �������.
-- ���� �������� TINY - false, �� ����� ���������� ��� ��������� �������,
-- ����� - ���� ���������, �������������� � ������� PP.
-- ������������ ��� ������ � ���������� �������.
FUNCTION get_OBJECT return SP.TIMAN_PARS pipelined;

-- ��������� ��������� ��������� �������.
-- ����������� ��������� � ��� ������ ������� ���� ���������� � ������� PP.
-- ������������ ��� ������ � ���������� �������.
PROCEDURE set_OBJECT;

-- ������� ������������� ������� ������, ���������� � ���������� ����������
-- �������� ������� ������ Fill_OBJECTS, Fill_FULL_OBJECTS, Fill_SYSTEMS.
-- ��� ��������� �������� ���������� ��������� ������:
-- select NAME ParName,T ParType,E ValueName,N,D,S,X,Y,R_ONLY,OBJECT_INDEX
--   from table(SP.IM.get_OBJECTS);
FUNCTION get_OBJECTS return SP.TIMAN_PARS pipelined;

-- ��������� ��������� ��� ����������� ��-�� �������,
-- ������������ � ������� O.
PROCEDURE Fill_OBJECT(O in out SP.G.TMACRO_PARS,
                      -- ���� �������� TINY = true, �� ����������� ������
                      -- ������� ��-��, � ��� �� ��������� �������������� �
                      -- ������� O.
                      -- ���� � ������� O ������������ �������� TINY,
                      -- �� �� ����� ��������� ��� ������� ���������� �
                      -- ������ �� ��������� ������.
                      TINY in BOOLEAN default false);

-- ��������� �������� ��� �������� ������� ������� PP � ��������� �� tiny
-- ������� ������ OS.
PROCEDURE Fill_OBJECTS;

-- ��������� �������� ��� �������� ������� ������� PP � ��������� �� tiny
-- ������� ������ OS.
PROCEDURE Fill_SYSTEMS;

-- ��������� �������� ��� �������� ������� ������� PP � ��������� ��� ������
-- OS.
PROCEDURE Fill_FULL_OBJECTS;

-- ������� ���������� ID �������, ���� ������, ��������� � ��������� 
-- (PP - ���� �������� �����������) �������� ������, ������������ � ������� ������.
-- ������� ���������� "0", ���� ������ ����������� � ������.
-- ���� ������ ����������, �� � ����� ���������� ������� ����������� 
-- �������� "EXISTS" = true, ����� �������� �� ����� �����������,
-- �� ������ false. 
FUNCTION IS_OBJECT_EXIST(O in out SP.G.TMACRO_PARS) return number;

FUNCTION IS_OBJECT_EXIST return number;

-- ��������� ��������� ��������� ������� ������, ������ PP ���������� ������ �
-- ����� ��������.
-- ��������� ������������ ��� ���������� ������� SET_PARS �� ��������� ������.
-- ���� ��������� ������, �� ���������� � � EM.
PROCEDURE UPDATE_MOD_OBJ_PARS;

-- ��������� �������� ���� �������� ������� PP � ��������� ��� ������ OS.
PROCEDURE Fill_ALL_FULL_OBJECTS;

-- ��������� �������� ���� �������� ������� PP � ��������� �� tiny
-- ������� ������ OS.
PROCEDURE Fill_ALL_OBJECTS;

-- ����� ���� �������� ������� PP ��������� �������� ������� � ��������� �� 
--tiny-������� ������ OS.
PROCEDURE Fill_ALL_SYSTEMS;

-- ��������� �������� ���� �������� ������� ������� PP � ��������� �� �������
-- ������� ������ OS.
PROCEDURE Fill_ALL_FULL_SYSTEMS;


--****************************************************************************
/*
--Implementation pattern
Declare
  v SP.TVALUE;
  cnt Number;
Begin
  SP.IM.PP.Delete;
  --v:=ID_(943496400);
  v:=ID_(947728000);
  SP.IM.PP('ID'):=v;
  SP.IMT.FILL_ALL_OBJECTS;
  
  WITH IDs As
  (
    SELECT DISTINCT OBJECT_INDEX
    FROM TABLE (SP.IM.get_OBJECTS)
  )
  SELECT COUNT(*) Into cnt
  FROM IDs
  ;
  
  DBMS_OUTPUT.Put_Line('��������: '||to_char(cnt));
End;
/
Select obs.NAME, obs.T, obs.E, obs.N, obs.D, obs.S, obs.X, obs.Y
    , obs.R_ONLY, obs.OBJECT_INDEX 
From TABLE(SP.IM.get_OBJECTS) obs
Order By obs.OBJECT_INDEX, obs.NAME
;

*/
/*
--Implementation pattern
Declare
  v SP.TVALUE;
  cnt Number;
Begin
  SP.SET_CURMODEL('BRCM||DUMP');
  SP.IM.PP.Delete;
  --v:=ID_(943496400);
  
  V:=S_('/Project_INT_RACEWAY');
  SP.IM.PP('NAME'):=v;

  --v:=ID_(1020442300);
  --SP.IM.PP('ID'):=v;

  SP.IMT.FILL_ALL_FULL_OBJECTS;
--  SP.IMT.FILL_ALL_SYSTEMS;
  
  WITH IDs As
  (
    SELECT DISTINCT OBJECT_INDEX
    FROM TABLE (SP.IM.get_OBJECTS)
  )
  SELECT COUNT(*) Into cnt
  FROM IDs
  ;
  
  DBMS_OUTPUT.Put_Line('��������: '||to_char(cnt));
End;


/
Select obs.NAME, obs.T, obs.E, obs.N, obs.D, obs.S, obs.X, obs.Y
    , obs.R_ONLY, obs.OBJECT_INDEX 
From TABLE(SP.IM.get_OBJECTS) obs
Order By obs.OBJECT_INDEX, obs.NAME
;
/



Select Count(*) as cnt
       FROM table(SP.IM.get_OBJECTS) 
;

Select NAME, T, E, SP.TO_.STR(N) As N,
       D, S, SP.TO_.STR(X) As X, SP.TO_.STR(Y) As Y, R_ONLY,
       LPAD(to_char(OBJECT_INDEX),6,'0') As OINDEX 
       FROM table(SP.IM.get_OBJECTS) 
ORDER BY OINDEX, NAME
;

*/

-- ��������� �������

--1. ������� ����� �������� �� �������������� ���� � ����� ��������.
--  declare
--   EnumValue VARCHAR2(100);
--   EM SP.COMMANDS.COMMENTS%type;
-- begin
--   execute immediate('
--     declare
--       V SP.TVALUE;
--     begin
--       V:=SP.TVALUE(ValueType => :ParType,
--           N=>:N, D=>:D, DisN=>:DisN, S=>:S, X=>:X, Y=>:Y);
--       :RESULT:=V.E;
--     exception when others then
--       :EM := SQLERRM;
--     end;
--                     ')
--     using 51,'',sysdate,0,'RUSSIAN','','', out EnumValue,out em; 
--   o(EnumValue);
--  o('EM = '||EM);
-- end;
--2. ������� �������� ��������� � ���� ������ �� �������������� ����
-- � ��������� ����� ���������.
-- declare
--   ValS SP.COMMANDS.COMMENTS%type;
--   EM SP.COMMANDS.COMMENTS%type;
-- begin
--   execute immediate('
--     declare
--       V SP.TVALUE;
--     begin
--       V:=SP.TVALUE(ValueType => :ParType,
--           N=>:N, D=>:D, DisN=>:DisN, S=>:S, X=>:X, Y=>:Y);
--       :ValS := SP.Val_to_Str(V);
--     exception when others then
--       :EM := SQLERRM;
--     end;
--                     ')
--     using 4,1,sysdate,0,'','','', out ValS,out em;
--   o(ValS);
--  o('EM = '||EM);
-- end;

--3. ������� ���� ����� �������� �� �������������� ���� � ��������
-- ��������� � ���� ������.
-- declare
--   rn VARCHAR2(40);
--   rd DATE;
--   rx VARCHAR2(40);
--   ry VARCHAR2(40);
--   EM SP.COMMANDS.COMMENTS%type;
--   ValS SP.COMMANDS.COMMENTS%type;
--   rs SP.COMMANDS.COMMENTS%type;
-- begin
--   execute immediate('
--     declare
--       V SP.TVALUE;
--     begin
--       V:=SP.TVALUE(:ParType);
--       SP.Str_to_Val(:ValS,V);
--       :RN:=SP.TO_.STR(V.N);
--       :RD:=V.D;
--       :RS:=V.S;
--       :RX:=SP.TO_.STR(V.X);
--       :RY:=SP.TO_.STR(V.Y);
--     exception when others then
--       :EM := SQLERRM;
--     end;
--                     ')
--     using 2,'09-12-2010',out rn, out rd, out rs ,out rx, out ry, 
--     		out em;
--   o(rd);
--   ��� ��� ����
--     using 2,'09-12-2010',out rn, out rd, out rs ,out rx, out ry, 
--     		out em;
--   o(rd);
--   ����� ���
--  o('EM = '||EM);
-- end; 
--4. ������� ���� ����� �������� �� �������������� ���� � ����� ��������.
-- declare
--   rn VARCHAR2(40);
--   rd DATE;
--   rs SP.COMMANDS.COMMENTS%type;
--   rx VARCHAR2(40);
--   ry VARCHAR2(40);
--   EM SP.COMMANDS.COMMENTS%type;
-- begin
--   execute immediate('
--     declare
--       V SP.TVALUE;
--     begin
--       V:=SP.TVALUE(:ParType,:E_VAL);
--       :RN:=SP.TO_.STR(V.N);
--       :RD:=V.D;
--       :RS:=V.S;
--       :RX:=SP.TO_.STR(V.X);
--       :RY:=SP.TO_.STR(V.Y);
--     exception when others then
--       :EM := SQLERRM;
--     end;
--                     ')
--     using 5,'true',out rn, out rd, out rs, out rx, out ry,out em;
--   o(rn);
--  o('EM = '||EM);
-- end;


-- 5. ������ ������ ���������� ��������� �������� � ������������ �
-- ��� ��� ���������, ������������ ����.
-- select S_VALUE, COMMENTS from table(SP.SET_OF_VALUES(SP.TVALUE(<TypeID>)));
-- ��� TypeID ������������� ���� ���������.
-- ��� ���������� ����� TypeID ����� ���������� ���������� �� ������ SP.G.
-- ������ TypeID ����� ����������� "���" ����.

-- 6. ��������� ����� ������.
-- declare
-- P SP.TGPAR;
-- begin
--   P:=SP.TGPAR('CurModel');
--   P.VAL.Assign('<��� ������>');
--   P.Save;
-- end;   

-- 7. ������ ����� ����, �������������� �� ���������� "N" �� ������ ����
-- �� ����������� � �������.
-- NodeName(NodeID in NUMBER, ILevel in NUMBER);
-- NodeID - ��� ���� "N" �������� ���� TTreeNode.

end IM;
/
