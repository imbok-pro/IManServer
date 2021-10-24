CREATE OR REPLACE PACKAGE BODY SP.TJ#AEP
-- TJ ������ �� ������������� ����� ��� ���
-- by AM
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2020-12-21
-- update 2020-12-23 2020-12-24 2021-01-04 2021-01-13 2021-01-14 2021-01-15
--        2021-01-22 2021-01-26 2021-02-12 2021-02-15
--        2021-03-23 2021-03-25 2021-03-26 2021-03-29 2021-03-30
-- By Nikolay Krasilnikov       18-06-2021
--        
--(SP.TJ#AEP.pkb)
AS
--==============================================================================
-- ������� ������������ ���������� �������
-- ��� ������ WorkID$ ���������� ������� ���������� �������
-- ���������:
-- ������ ID ������ ����� ������ ID ������ ������� �������, �������� �������� � 
-- �������� �������� ������ 

Type AA_Dict_64 Is Table Of Varchar2(64) Index By Varchar2(64);

TwistedCable_AA AA_Dict_64;
EquipmentCable_AA AA_Dict_64;


-- ������� ��� ������������ ������ ������ � ��������� ������� �� ������ ������ ������������ � ������ ��������� ������
-- ������ �������� �� ������������ ����� ������ ��. � "����� �������� �� ���������� ���������" (R01.KK34.0.0.ET.PZ.WD001)
Function GetCableNumber(i$ in Binary_Integer, CLASS$ in VARCHAR2, GROUP$ in VARCHAR2) Return VARCHAR2
Is
  CableNumber VARCHAR2 (40);
  Shifr VARCHAR2 (4);
  i_to_string VARCHAR2 (8);
Begin
  i_to_string := '000' || TO_CHAR(i$);
  
  if CLASS$ in ('1', '2') then
    if GROUP$ = '1' then
      Shifr := '1';
    elsif GROUP$ = '2' then
      Shifr := '2';
    elsif GROUP$ = '3' then
      Shifr := '3';
    elsif GROUP$ = '5' or GROUP$ = '6' then
      Shifr := '4';
    end if;
  elsif CLASS$ in ('3', '4') then
    if GROUP$ = '1' then
      Shifr := '5';
    elsif GROUP$ = '2' then
      Shifr := '6';
    elsif GROUP$ = '3' then
      Shifr := '7';
    elsif GROUP$ = '5' or GROUP$ = '6' then
      Shifr := '8';
    end if;
  else
    Shifr := '0';
  end if;
  
  CableNumber := Shifr ||'.'|| SUBSTR(i_to_string, LENGTH(i_to_string) - 3);
  return CableNumber;
End;


-- ������� ��� ����������� ������ ������������ ���������� �� ��� KKS ����
-- ����� ������������ ����� ������ ����� KKS ����, ���� ������ ����� 0, �� ����� ������������ ��������� ������
Function GetSecurityChannel(KKS$ in VARCHAR2) Return VARCHAR2
Is
  SecurityChannel VARCHAR2 (40);

Begin
  SecurityChannel := SUBSTR(KKS$, 3, 1);
  
  if SecurityChannel = '0' then
    SecurityChannel := '';
  elsif SecurityChannel in ('1', '2', '3', '4') then
    NULL;
  else
    SecurityChannel := '';
  end if;
  
  return SecurityChannel;
End;


-- ������� ��� �������� �������� �� ������ ����� �����, ���� �� �� ���������� true, ���� ��� �� false
Function IsTwistedPair(TYPE$ in VARCHAR2) Return BOOLEAN
Is

Begin
  
  if TwistedCable_AA(TYPE$) = 'Twisted' then
    return true;
  end if;
  return false;
  
Exception When Others Then
  return false;
End;


-- ������� ��� ����������� ����������� ������� ������ � ���� "����� ���"�"������� ����"
Function GetCableCrossSection(TYPE$ in VARCHAR2, "CORE NUMBER" in NUMBER, "CORE SECTION" in NUMBER) Return VARCHAR2
Is
  CableCrossSection VARCHAR2 (40);
  
Begin
  if EquipmentCable_AA.Exists(TYPE$) then
    CableCrossSection := NULL;
  else
    if IsTwistedPair(TYPE$) then
      if TRUNC("CORE SECTION") = "CORE SECTION" then
        CableCrossSection := TO_CHAR("CORE NUMBER"/2) ||'x2x'|| TO_.STR("CORE SECTION");
      else
        CableCrossSection := TO_CHAR("CORE NUMBER"/2) ||'x2x'|| REPLACE(TO_.STR("CORE SECTION",1), '.', ',');
      end if;
    else
      if TRUNC("CORE SECTION") = "CORE SECTION" then
        CableCrossSection := TO_CHAR("CORE NUMBER") ||'x'|| TO_.STR("CORE SECTION");
      else
        CableCrossSection := TO_CHAR("CORE NUMBER") ||'x'|| REPLACE(TO_.STR("CORE SECTION",1), '.', ',');
      end if;
    end if;
  end if;
  
  return CableCrossSection;
End;


-- ������� ��� �������������� ����� ������. ���� ������ ��������� � ����������� ������ � �������������,
-- �� ������� ������� �� �������
Function GetTypeTrans(TYPE$ in VARCHAR2) Return VARCHAR2
Is
  TypeTrans VARCHAR2 (40);
  
Begin
  if EquipmentCable_AA.Exists(TYPE$) then
    TypeTrans := EquipmentCable_AA(TYPE$);
  else
    TypeTrans := sp.TRANSLIT.TransSimple(TYPE$);
  end if;
  
  return TypeTrans;
End;


-- ������� ��� ������� �������� �� ����������� (� Excel) �������� ����� ������ ������ ���������� '*'
-- ���� ��, �� ������������ ������, ����� ���������������� ��� '*', � '*' ������������ � ������� ������ "����������" � �����
-- ���� ���, �� ������������ ����, ����� �� ����������
Function AnalysisCabLength(LENGTH$ in out VARCHAR2) Return BOOLEAN
Is
  r# VARCHAR2 (40);
  
Begin
  if INSTR(LENGTH$, '*', 1, 1) = 0 then
    return false;
  else
    r# := SUBSTR(LENGTH$, 1, INSTR(LENGTH$,'*',1,1) - 1);
    LENGTH$ := r#;
    return true;
  end if;
End;


-- ��������� ��� ���������� ��������� ��������� � ������ TJ, ����������� � ����� AEP2Access (������ �� � Access)
-- ����������� ��������� �������� �������: ����� � ��������� ������� � ����� ������������ ������
-- ����������� ��������� �������� ������: ����� ������������ �����
Procedure UPDATE_TJ(WorkID$ In Number default null)
Is
  rv R_UPDATE_TJ;
  i# Binary_Integer;
  ierr Binary_Integer;
  P SP.TMPAR;

Begin
  if WorkID$ is null then
    return;
  end if;
  
  i# := 0;
  ierr := 0;
  for rc in
  (
    select * from TABLE(SP.TJ#ELECTRO.V_CAB_JOURNAL(WorkID$))
    order by "CABLE_NAME"
  ) 
  Loop
    i# := i# + 1; 
    
    -- ����� ������������
    rv."CLASS" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Safety_class_of_cable');
    -- ������ ���������
    rv."GROUP R" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Group_of_laiment');
    -- ����� � ��������� �������, ������������ �� "CLASS" � "GROUP"
    rv."CABLE NUMBER" := GetCableNumber(i#, rv."CLASS", rv."GROUP R");
    -- ����� ������������ ������
    rv."FROM SYS" := GetSecurityChannel(rc.FROM_LOCATION_NAME);
    -- ����� ������������ �����
    rv."TO SYS" := GetSecurityChannel(rc.TO_LOCATION_NAME);
    -- ����� ������������ ������
    rv."CABLE SYS" := GetSecurityChannel(rc.CABLE_NAME);
    
    P := SP.TMPAR(rc.CABLE_ID, 'HP_Line_marking_in_cable_connections');
    P.VAL := S_(rv."CABLE NUMBER");
    P.SAVE;
    
    if rc.FROM_LOCPROP_ID is NULL then 
      D('��� ������ ['||rc.CABLE_NAME||'] �� ��������� ID ����� ������ ['||rc.FROM_LOCATION_NAME||
      '] �� ��������� ������������ (���������).', 'Error SP.TJ#AEP.UPDATE_TJ');
      ierr := ierr + 1;
    else
      P := SP.TMPAR(rc.FROM_LOCPROP_ID, 'AEP_Safety_system_of_board');
      P.VAL := S_(rv."FROM SYS");
      P.SAVE;
    end if;
    
    if rc.TO_LOCPROP_ID is NULL then 
      D('��� ������ ['||rc.CABLE_NAME||'] �� ��������� ID ����� ����� ['||rc.TO_LOCATION_NAME||
      '] �� ��������� ������������ (���������).', 'Error SP.TJ#AEP.UPDATE_TJ');
      ierr := ierr + 1;
    else
      P := SP.TMPAR(rc.TO_LOCPROP_ID, 'AEP_Safety_system_of_board');
      P.VAL := S_(rv."TO SYS");
      P.SAVE;
    end if;
    
    P := SP.TMPAR(rc.CABLE_ID, 'AEP_Safety_system_of_cable');
    P.VAL := S_(rv."CABLE SYS");
    P.SAVE;
   
  End Loop;
  if ierr > 0 then
    raise_application_error(-20033, '� ��������� SP.TJ#AEP.UPDATE_TJ ���������� ������ ��������������, �������� DebugLog
    � ����� "Error SP.TJ#AEP.UPDATE_TJ".');
  end if;
  return;
End;


Function V_CAB_JOURNAL(WorkID$ In Number default null) 
Return  T_CAB_JOURNAL Pipelined
Is
  rv R_CAB_JOURNAL;
  i# Binary_Integer; 
  
Begin
  rv."PROJECT" := NULL;
  rv."FROM ZRel" := NULL;
  rv."TO ZRel" := NULL;
  rv."REDUNDANCY" := NULL;
  rv."NOTE" := NULL;
  rv."NOTE ENG" := NULL;
  rv."SPEC" := NULL;
  
  if WorkID$ is null then
    return;
  end if;
  
  i# := 0;
  for rc in
  (
    select * from TABLE(SP.TJ#ELECTRO.V_CAB_JOURNAL(WorkID$))
    order by "CABLE_NAME"
  ) 
  Loop
    i# := i# + 1;    
    -- ����� ���������� �������
    rv."CABLE LOG" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Cable_log');
    -- KKS (����������) ������
    rv."CABLE MARK" := rc.CABLE_NAME;
    -- ��� (�����) ������
    rv."TYPE" := sp.getMPar_S(rc.CABLE_ID, 'HP_Cable_type');
    -- ����� ��� ������
    rv."CORE NUMBER" := sp.getMPar_N(rc.CABLE_ID, 'HP_Number_cable_cores');
    -- ������� ���� ������
    rv."CORE SECTION" := sp.getMPar_N(rc.CABLE_ID, 'HP_Cable_cross_section');
    -- ����������� ���������� ������
    rv."VOLTAGE" := sp.getMPar_N(rc.CABLE_ID, 'HP_Rated_voltage_cable');
    -- ����� ����������� �������
    rv."TU" := sp.getMPar_S(rc.CABLE_ID, 'AEP_TU');
    -- ����� ������������
    rv."CLASS" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Safety_class_of_cable');
    -- ������ ���������
    rv."GROUP R" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Group_of_laiment');
    -- ����� � ��������� �������, ������������ �� "CLASS" � "GROUP"
    rv."CABLE NUMBER" := GetCableNumber(i#, rv."CLASS", rv."GROUP R");
    -- ������� ������
    rv."DIAMETER" := sp.getMPar_N(rc.CABLE_ID, 'HP_Diametr_of_cable');
    -- KKS ������
    rv."FROM KKS" := rc.FROM_LOCATION_NAME;
    -- ���������� X ������
    rv."FROM X" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Installation_equipment_on_the_x');
    -- ���������� Y ������
    rv."FROM Y" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Installation_equipment_on_the_y');
    -- ���������� Z ������
    rv."FROM Z" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Elevation');
    -- ����� �� �������� � ������
    rv."FROM LAdd" := sp.getMPar_N(rc.CABLE_ID, 'AEP_From_Ladd');
    -- ����� ������������ ������
    rv."FROM SYS" := GetSecurityChannel(rc.FROM_LOCATION_NAME);
    -- KKS ������ ������
    rv."FROM BUILDING" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Building_name');
    -- KKS ��������� ������
    rv."FROM ROOM" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Room_number_and_name');
    -- ������������ ������������ ������
    rv."FROM NAME" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Equipment_name');
    -- ������������ ������������ ������ �� ���������
    rv."FROM NAME ENG" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'AEP_Name_of_equipment_eng');
    -- KKS �����
    rv."TO KKS" := rc.TO_LOCATION_NAME;
    -- ���������� X �����
    rv."TO X" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Installation_equipment_on_the_x');
    -- ���������� Y �����
    rv."TO Y" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Installation_equipment_on_the_y');
    -- ���������� Z �����
    rv."TO Z" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Elevation');
    -- ����� �� �������� � �����
    rv."TO LAdd" := sp.getMPar_N(rc.CABLE_ID, 'AEP_To_Ladd');
    -- ����� ������������ �����
    rv."TO SYS" := GetSecurityChannel(rc.TO_LOCATION_NAME);
    -- KKS ������ �����
    rv."TO BUILDING" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Building_name');
    -- KKS ��������� �����
    rv."TO ROOM" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Room_number_and_name');
    -- ������������ ������������ �����
    rv."TO NAME" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Equipment_name');
    -- ������������ ������������ ����� �� ���������
    rv."TO NAME ENG" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'AEP_Name_of_equipment_eng');
    -- ����� ������
    rv."LENGTH" := sp.getMPar_N(rc.CABLE_ID, 'HP_Cable_length');
    -- ������
    rv."ROUTE" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Route');
    -- ����� ������������ ������
    rv."CABLE SYS" := GetSecurityChannel(rc.CABLE_NAME);
       
    pipe row (rv);
  End Loop;
End V_CAB_JOURNAL;


Function V_CAB_JOURNAL_ACCESS(WorkID$ In Number default null) 
Return  T_CAB_JOURNAL_ACCESS Pipelined
Is
  rv R_CAB_JOURNAL_ACCESS;
  i# Binary_Integer;

Begin
  rv."PROJECT" := NULL;
  rv."FROM ZRel" := NULL;
  rv."TO ZRel" := NULL;
  rv."REDUNDANCY" := NULL;
  rv."NOTE" := NULL;
  rv."NOTE ENG" := NULL;
  rv."SPEC" := NULL;
  
  if WorkID$ is null then
    return;
  end if;
  
  i# := 0;
  for rc in
  (
    select * from TABLE(SP.TJ#ELECTRO.V_CAB_JOURNAL(WorkID$))
    order by "CABLE_NAME"
  ) 
  Loop 
    i# := i# + 1;
    -- ����� ���������� �������
    rv."CABLE LOG" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Cable_log');
    -- KKS (����������) ������
    rv."CABLE MARK" := REPLACE(rc.CABLE_NAME, '=', '');
    -- ��� (�����) ������
    rv."TYPE" := sp.getMPar_S(rc.CABLE_ID, 'HP_Cable_type');
    -- ����� ��� � ������� ������
    rv."CROSS-SECTION" := GetCableCrossSection
      (rv."TYPE", 
       sp.getMPar_N(rc.CABLE_ID, 'HP_Number_cable_cores'),
       sp.getMPar_N(rc.CABLE_ID, 'HP_Cable_cross_section'));
    -- ����������� ���������� ������
    rv."VOLTAGE" := sp.getMPar_N(rc.CABLE_ID, 'HP_Rated_voltage_cable');
    -- ����� ����������� �������
    rv."TU" := sp.getMPar_S(rc.CABLE_ID, 'AEP_TU');
    -- ����� ������������
    rv."CLASS" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Safety_class_of_cable');
    -- ������ ���������
    rv."GROUP R" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Group_of_laiment');
    -- ����� � ��������� �������, ������������ �� "CLASS" � "GROUP R"
    rv."CABLE NUMBER" := GetCableNumber(i#, rv."CLASS", rv."GROUP R");
    -- ������� ������
    rv."DIAMETER" := sp.getMPar_N(rc.CABLE_ID, 'HP_Diametr_of_cable');
    -- KKS ������
    rv."FROM KKS" := REPLACE(rc.FROM_LOCATION_NAME, '+', '');
    -- ���������� X ������
    rv."FROM X" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Installation_equipment_on_the_x');
    -- ���������� Y ������
    rv."FROM Y" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Installation_equipment_on_the_y');
    -- ���������� Z ������
    rv."FROM Z" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Elevation');
    -- ����� �� �������� � ������
    rv."FROM LAdd" := sp.getMPar_N(rc.CABLE_ID, 'AEP_From_Ladd');
    -- ����� ������������ ������
    rv."FROM SYS" := GetSecurityChannel(rc.FROM_LOCATION_NAME);
    -- KKS ������ ������
    rv."FROM BUILDING" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Building_name');
    -- KKS ��������� ������
    rv."FROM ROOM" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Room_number_and_name');
    -- ������������ ������������ ������
    rv."FROM NAME" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Equipment_name');
    -- ������������ ������������ ������ �� ���������
    rv."FROM NAME ENG" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'AEP_Name_of_equipment_eng');
    -- KKS �����
    rv."TO KKS" := REPLACE(rc.TO_LOCATION_NAME, '+', '');
    -- ���������� X �����
    rv."TO X" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Installation_equipment_on_the_x');
    -- ���������� Y �����
    rv."TO Y" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Installation_equipment_on_the_y');
    -- ���������� Z �����
    rv."TO Z" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Elevation');
    -- ����� �� �������� � �����
    rv."TO LAdd" := sp.getMPar_N(rc.CABLE_ID, 'AEP_To_Ladd');
    -- ����� ������������ �����
    rv."TO SYS" := GetSecurityChannel(rc.TO_LOCATION_NAME);
    -- KKS ������ �����
    rv."TO BUILDING" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Building_name');
    -- KKS ��������� �����
    rv."TO ROOM" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Room_number_and_name');
    -- ������������ ������������ �����
    rv."TO NAME" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Equipment_name');
    -- ������������ ������������ ����� �� ���������
    rv."TO NAME ENG" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'AEP_Name_of_equipment_eng');
    -- ����� ������
    rv."LENGTH" := sp.getMPar_N(rc.CABLE_ID, 'HP_Cable_length');
    -- ������
    rv."ROUTE" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Route');
    -- ����� ������������ ������
    rv."CABLE SYS" := GetSecurityChannel(rc.CABLE_NAME);
       
    pipe row (rv);
  End Loop;
End V_CAB_JOURNAL_ACCESS;


Function V_CAB_JOURNAL_WORD(WorkID$ In Number default null) 
Return  T_CAB_JOURNAL_WORD Pipelined
Is
  rv R_CAB_JOURNAL_WORD;
  i# Binary_Integer;

Begin
  
  if WorkID$ is null then
    return;
  end if;
  
  i# := 0;
  for rc in
  (
    select * from TABLE(SP.TJ#ELECTRO.V_CAB_JOURNAL(WorkID$))
    order by "CABLE_NAME"
  ) 
  Loop
    i# := i# + 1;
    -- KKS (����������) ������
    rv."CABLE MARK" := REPLACE(rc.CABLE_NAME, '=', '');
    -- ��� (�����) ������
    rv."TYPE" := sp.getMPar_S(rc.CABLE_ID, 'HP_Cable_type');
    -- ��� (�����) ������ ����������
    rv."TYPE TRANS" := GetTypeTrans(rv."TYPE");
    -- ����� ��� � ������� ������
    rv."CROSS-SECTION" := GetCableCrossSection
      (rv."TYPE", sp.getMPar_N(rc.CABLE_ID, 'HP_Number_cable_cores'),
       sp.getMPar_N(rc.CABLE_ID, 'HP_Cable_cross_section'));
     -- ������ ���������
    rv."GROUP R" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Group_of_laiment');
    -- ����� ������������
    rv."CLASS" := sp.getMPar_S
      (rc.CABLE_ID, 'AEP_Safety_class_of_cable');
    -- ����� � ��������� �������, ������������ �� "CLASS" � "GROUP R"
    rv."CABLE NUMBER" := GetCableNumber(i#, rv."CLASS", rv."GROUP R");
    -- KKS ������
    rv."FROM KKS" := REPLACE(rc.FROM_LOCATION_NAME, '+', '');
    -- ���������� X ������
    rv."FROM X" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Installation_equipment_on_the_x');
    -- ���������� Y ������
    rv."FROM Y" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Installation_equipment_on_the_y');
    -- ���������� Z ������
    rv."FROM Z" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Elevation');
    -- KKS ������ ������
    rv."FROM BUILDING" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Building_name');
    -- KKS ��������� ������
    rv."FROM ROOM" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Room_number_and_name');
    -- ������������ ������������ ������
    rv."FROM NAME" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Equipment_name');
    -- ������������ ������������ ������ �� ���������
    rv."FROM NAME ENG" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'AEP_Name_of_equipment_eng');
    -- KKS �����
    rv."TO KKS" := REPLACE(rc.TO_LOCATION_NAME, '+', '');
    -- ���������� X �����
    rv."TO X" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Installation_equipment_on_the_x');
    -- ���������� Y �����
    rv."TO Y" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Installation_equipment_on_the_y');
    -- ���������� Z �����
    rv."TO Z" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Elevation');
    -- KKS ������ �����
    rv."TO BUILDING" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Building_name');
    -- KKS ��������� �����
    rv."TO ROOM" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Room_number_and_name');
    -- ������������ ������������ �����
    rv."TO NAME" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Equipment_name');
    -- ������������ ������������ ����� �� ���������
    rv."TO NAME ENG" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'AEP_Name_of_equipment_eng');
    -- ����� ������
    rv."LENGTH" := sp.getMPar_N(rc.CABLE_ID, 'HP_Cable_length');
    -- ������
    rv."ROUTE" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Route');
    -- ��� ������ ����
    rv."COMMON BOARD" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'AEP_Name_of_common_board');
    -- ��� ������ ���� ENG
    rv."COMMON BOARD ENG" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'AEP_Name_of_common_board_eng');
    -- ����������
    rv."NOTE" := sp.getMPar_S(rc.CABLE_ID, '����������');
    
    pipe row (rv);
  End Loop;
End V_CAB_JOURNAL_WORD;


Function V_CAB_DEMAND(WorkID$ In Number default null) 
Return  T_CAB_DEMAND Pipelined
Is
  rv R_CAB_DEMAND;

Begin
  rv."METALHOSE DIAMETER" := NULL;
  rv."METALHOSE LENGTH" := NULL;
  
  if WorkID$ is null then
    return;
  end if;
  
  for rc in
  (
    select "TYPE", "CORE NUMBER", "CORE SECTION", "VOLTAGE", sum("LENGTH") as "LENGTH", count(*) as "CABLE COUNT"
    from TABLE(SP.TJ#AEP.V_CAB_JOURNAL(WorkID$))
    group by "TYPE", "CORE SECTION", "CORE NUMBER", "VOLTAGE"
    order by "TYPE", "CORE SECTION", "CORE NUMBER", "VOLTAGE"
  ) 
  Loop
    -- ��� (�����) ������
    rv."TYPE" := rc."TYPE";
    -- ��� (�����) ������ ����������
    rv."TYPE TRANS" := GetTypeTrans(rv."TYPE");
    -- ����� ��� � ������� ������
    rv."CROSS-SECTION" := GetCableCrossSection(rv."TYPE", rc."CORE NUMBER", rc."CORE SECTION");
    -- ����������� ���������� ������
    if TRUNC(rc."VOLTAGE") = rc."VOLTAGE" then
      rv."VOLTAGE" := TO_CHAR(rc."VOLTAGE");
    else
      rv."VOLTAGE" := REPLACE(TO_CHAR(rc."VOLTAGE", 'FM0.99'), '.', ',');
    end if;
    -- ��������� ����� ������� ������ �����, ������� � ����������
    rv."LENGTH" := rc."LENGTH";
    -- ���������� ������� ������ �����, ������� � ����������
    rv."CABLE COUNT" := rc."CABLE COUNT";
    -- ���������� ��������� ��������
    rv."CABLE TERMINATIONS" := rc."CABLE COUNT" * 2;
    
    pipe row (rv);
  End Loop;
End V_CAB_DEMAND;


Function V_DEVICE_XYZ(WorkID$ In Number default null) 
Return  T_DEVICE_XYZ Pipelined
Is
  rv R_DEVICE_XYZ;

Begin
  rv."X" := NULL;
  rv."Y" := NULL;
  rv."Z" := NULL;
  
  if WorkID$ is null then
    return;
  end if;
  
  for rc in
  (
    SELECT DISTINCT * FROM
    (
      SELECT 
      cj."FROM_LOCPROP_ID" as "ID ����������",
      cj."FROM_LOCATION_NAME" as "KKS ����������",
      sp.getMPar_S(cj.FROM_LOCPROP_ID, 'HP_Room_number_and_name') as "���������",
      sp.getMPar_S(cj.FROM_LOCPROP_ID, 'HP_Equipment_name') as "������������ ����������"
      FROM TABLE(SP.TJ#ELECTRO.V_CAB_JOURNAL(WorkID$)) cj
      UNION ALL
      SELECT 
      cj."TO_LOCPROP_ID" as "ID ����������",
      cj."TO_LOCATION_NAME" as "KKS ����������",
      sp.getMPar_S(cj.TO_LOCPROP_ID, 'HP_Room_number_and_name') as "���������",
      sp.getMPar_S(cj.TO_LOCPROP_ID, 'HP_Equipment_name') as "������������ ����������"
      FROM TABLE(SP.TJ#ELECTRO.V_CAB_JOURNAL(WorkID$)) cj
    )
  ) 
  Loop
    rv."ID ����������" := rc."ID ����������";
    rv."KKS ����������" := REPLACE(rc."KKS ����������", '+', '');
    rv."���������" := rc."���������";
    rv."������������ ����������" := rc."������������ ����������";
    
    pipe row (rv);
  End Loop;
End V_DEVICE_XYZ;


Function V_CAB_LENGTH(WorkID$ In Number default null) 
Return  T_CAB_LENGTH Pipelined
Is
  rv R_CAB_LENGTH;

Begin
  rv."�����" := NULL;
  rv."������" := '';
  
  if WorkID$ is null then
    return;
  end if;
  
  for rc in
  (
    SELECT DISTINCT * FROM
    (
      SELECT 
      cj."CABLE_ID" as "ID ������",
      cj."CABLE_NAME" as "KKS ������", 
      sp.getMPar_S(cj."CABLE_ID", 'HP_Cable_type') as "����� ������", 
      sp.getMPar_N(cj.CABLE_ID, 'HP_Diametr_of_cable') as "������� ������",
      cj."FROM_LOCATION_NAME" as "������ KKS",
      sp.getMPar_S(cj.FROM_LOCPROP_ID, 'HP_Room_number_and_name') as "������ ���.",
      sp.getMPar_S(cj.FROM_LOCPROP_ID, 'HP_Equipment_name') as "������ ������������",
      sp.getMPar_N(cj.FROM_LOCPROP_ID, 'HP_Installation_equipment_on_the_x') as "������ X",
      sp.getMPar_N(cj.FROM_LOCPROP_ID, 'HP_Installation_equipment_on_the_y') as "������ Y",
      sp.getMPar_N(cj.FROM_LOCPROP_ID, 'HP_Elevation') as "������ Z",
      cj."TO_LOCATION_NAME" as "���� KKS",
      sp.getMPar_S(cj.TO_LOCPROP_ID, 'HP_Room_number_and_name') as "���� ���.",
      sp.getMPar_S(cj.TO_LOCPROP_ID, 'HP_Equipment_name') as "���� ������������",
      sp.getMPar_N(cj.TO_LOCPROP_ID, 'HP_Installation_equipment_on_the_x') as "���� X",
      sp.getMPar_N(cj.TO_LOCPROP_ID, 'HP_Installation_equipment_on_the_y') as "���� Y",
      sp.getMPar_N(cj.TO_LOCPROP_ID, 'HP_Elevation') as "���� Z"
      FROM TABLE(SP.TJ#ELECTRO.V_CAB_JOURNAL(WorkID$)) cj
    )
  ) 
  Loop
    rv."ID ������" := rc."ID ������";
    rv."KKS ������" := REPLACE(rc."KKS ������", '=', '');
    rv."����� ������" := rc."����� ������";
    rv."������� ������" := rc."������� ������";
    rv."������ KKS" := REPLACE(rc."������ KKS", '+', '');
    rv."������ ���." := rc."������ ���.";
    rv."������ ������������" := rc."������ ������������";
    rv."������ X" := rc."������ X";
    rv."������ Y" := rc."������ Y";
    rv."������ Z" := rc."������ Z";
    rv."���� KKS" := REPLACE(rc."���� KKS", '+', '');
    rv."���� ���." := rc."���� ���.";
    rv."���� ������������" := rc."���� ������������";
    rv."���� X" := rc."���� X";
    rv."���� Y" := rc."���� Y";
    rv."���� Z" := rc."���� Z";
    
    pipe row (rv);
  End Loop;
End V_CAB_LENGTH;

Begin

  TwistedCable_AA('�������') := 'Twisted';
  TwistedCable_AA('�������(�)') := 'Twisted';
  TwistedCable_AA('�������(�)-LS') := 'Twisted';
  TwistedCable_AA('�������(�)-FRLS') := 'Twisted';
  TwistedCable_AA('�������(�)-HF') := 'Twisted';
  TwistedCable_AA('�������(�)-FRHF') := 'Twisted';
  
  EquipmentCable_AA('������ �������') := 'Cable of sensor';
  EquipmentCable_AA('������ ������') := 'Cable of pump';
  EquipmentCable_AA('������ ���������') := 'Cable of motor';
  EquipmentCable_AA('������ ������������') := 'Equipment cable';

End TJ#AEP;
/
