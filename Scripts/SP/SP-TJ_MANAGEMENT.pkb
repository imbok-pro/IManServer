CREATE OR REPLACE PACKAGE BODY SP.TJ_MANAGEMENT
-- SP.TJ_MANAGEMENT package body
-- ����� ��� ������ � ������� TJ
-- by Azarov SP-TJ_MANAGEMENT.pkb 
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 08.02.18
-- update 30.03.19 31.05.19 24.07.2019 26.07.19 31.07.19 05.08.19 23.12.19

AS


"����� �� ������" CONSTANT VARCHAR2(50):= '����� �� ������';
                                          --  '';
"��� ����������"  CONSTANT VARCHAR2(50):= '��� ����������';
                                          --  '';
-------------------------------------------------------------------------------                                            
-- ��������� ��������� selectedSystemIds
FUNCTION set_selectedSystemIds(Ids SP.TNUMBERS) return NUMBER
is
BEGIN
 --d(Ids.count,'TEST set_selectedSystemIds');
 --selectedSystemIds.Delete;
 selectedSystemIds := Ids;
 return selectedSystemIds.Count;
END;
-------------------------------------------------------------------------------                                            
-- ���������� ��������� selectedSystemIds
FUNCTION get_selectedSystemIds return SP.TNUMBERS pipelined
is
BEGIN
 --d(Ids.count,'TEST get_selectedSystemIds');
for rec in
  (
   select column_value from table(selectedSystemIds) 
  )
  LOOP
   pipe row(rec.column_value);
  END LOOP;
END;
-------------------------------------------------------------------------------                                            

PROCEDURE setConstants
is
BEGIN
--�������������� ����� ������
select id into CurModelId from SP.MODELS where NAME = SP.TGpar('CurModel').Val.S;
d('������� ������ ='||SP.TGpar('CurModel').Val.S||'  id = '|| CurModelId, 'setConstants');

select id into "TJ.singles.������" from SP.V_OBJECTS 
where FULL_NAME = 'TJ.singles.������';

select id into "TJ.singles.�������" from SP.V_OBJECTS 
where FULL_NAME = 'TJ.singles.�������';

select id into "TJ.singles.�����" from SP.V_OBJECTS 
where FULL_NAME = 'TJ.singles.�����';

select id into "TJ.singles.����� ������" from SP.V_OBJECTS 
where FULL_NAME = 'TJ.singles.����� ������';

/*
select id into "������" from SP.MODEL_OBJECTS 
where PARENT_MOD_OBJ_ID = TJ_WORK_ID and MOD_OBJ_NAME = '������';

select id into "�������" from SP.MODEL_OBJECTS 
where PARENT_MOD_OBJ_ID = TJ_WORK_ID and MOD_OBJ_NAME = '�������';
*/
select id into "�����" from SP.MODEL_OBJECTS 
where PARENT_MOD_OBJ_ID = TJ_WORK_ID and MOD_OBJ_NAME = '�����';

select id into "�������" from SP.MODEL_OBJECTS 
where PARENT_MOD_OBJ_ID = TJ_WORK_ID and MOD_OBJ_NAME = '�������';

select id into "�������������� �����������" from SP.MODEL_OBJECTS 
where PARENT_MOD_OBJ_ID = TJ_WORK_ID and MOD_OBJ_NAME = '�������������� �����������';

begin
select id into "����� ������" from SP.MODEL_OBJECTS 
where PARENT_MOD_OBJ_ID = TJ_WORK_ID and MOD_OBJ_NAME = '����� ������';
exception
when no_data_found then
d('����������� ���� "����� ������"','WORNING: SP.TJ_MANAGEMENT.setConstants');
end;

-- ���������� ID-� ��������� ���������� ��� ������� "TJ.singles.�������"
select id into "HP_Primary_divace"
        from SP.OBJECT_PAR_S
        where NAME = 'HP_Primary_divace' and OBJ_ID = "TJ.singles.�������";
select id into "�� �����������"
        from SP.OBJECT_PAR_S
        where NAME = '�� �����������' and OBJ_ID = "TJ.singles.�������";
select id into "�������"
        from SP.OBJECT_PAR_S
        where NAME = '�������' and OBJ_ID = "TJ.singles.�������";
select id into "HP_Image_layer"
        from SP.OBJECT_PAR_S
        where NAME = 'HP_Image_layer' and OBJ_ID = "TJ.singles.�������";

-- ���������� ID-� ��������� ���������� ��� ������� "TJ.singles.����� ������"
select id into "�������"
        from SP.OBJECT_PAR_S
        where NAME = '�������' and OBJ_ID = "TJ.singles.����� ������";
select id into "����� ��"
        from SP.OBJECT_PAR_S
        where NAME = '����� ��' and OBJ_ID = "TJ.singles.����� ������";

-- �������� ���-������� ����� ������
--d('TEST','SP.TJ_MANAGEMENT."�������������� ������"');
for r in
(
select o.MOD_OBJ_NAME, pd.N d, pm.N m
from SP.MODEL_OBJECTS o, SP.MODEL_OBJECT_PAR_S pd, SP.MODEL_OBJECT_PAR_S pm
where o.OBJ_ID = "TJ.singles.����� ������"
and o.PARENT_MOD_OBJ_ID = "����� ������"
      and pd.OBJ_PAR_ID = "�������"
      and pd.MOD_OBJ_ID = o.id 
      and pm.OBJ_PAR_ID = "����� ��"
      and pm.MOD_OBJ_ID = o.id 
)
LOOP 
--d(r.d||' '||r.d,'SP.TJ_MANAGEMENT."�������������� ������"');
 "�������������� ������"(r.MOD_OBJ_NAME).Diameter := r.d;
 "�������������� ������"(r.MOD_OBJ_NAME).Weight := r.m;
END LOOP;
--d('���������� ������ �������������������','WORNING: SP.TJ_MANAGEMENT.setConstants');
END;
                                            
-------------------------------------------------------------------------------
PROCEDURE setCurTJWorkId(Work_ID in NUMBER)
is
BEGIN
begin
if Work_ID is NULL then
 d('������ �������� � �������','ERROR SP.TJ_MANAGEMENT.setCurTJWorkId(Work_ID NUMBER)');
 return;
end if;

select FULL_NAME into TJ_WORK_PATH from SP.V_MODEL_OBJECTS where ID = Work_ID;
TJ_WORK_ID := Work_ID;
exception
when no_data_found then
d('������ � ������ Id='|| Work_ID || ' �� ������� '||SQLERRM,'ERROR SP.TJ_MANAGEMENT.setCurTJWorkId(Work_ID NUMBER)');
end;
setConstants;
--d('���������� ������ ���������','OK SP.TJ_MANAGEMENT.setCurTJWorkId(Work_ID NUMBER)');
END setCurTJWorkId;
-------------------------------------------------------------------------------
PROCEDURE setCurTJWorkId(Work_Path VARCHAR2)
is
BEGIN
if Work_Path is NULL then
 d('������ �������� � �������','ERROR SP.TJ_MANAGEMENT.setCurTJWorkId(Work_Path VARCHAR2)');
 return;
end if;
TJ_WORK_PATH := RTRIM(Work_Path,'/'); -- � ��� ����� ��������, �� ���������
begin
TJ_WORK_ID := SP.MO.MOD_OBJ_ID_BY_FULL_NAME(TJ_WORK_PATH);
--select FULL_NAME from SP.V_MODEL_OBJECTS where ID = TJ_WORK_ID;
-- ��������� ������ ���� id ����������� ������
-- select id into TJ_WORK_ID from SP.V_CUR_MODEL_OBJECTS where CATALOG_NAME='������' and FULL_NAME = TJ_WORK_PATH;
exception
when no_data_found then
d('������ � ������ "'|| Work_Path || '" �� ������� '||SQLERRM,'ERROR SP.TJ_MANAGEMENT.setCurTJWorkId(TJ_WORK_PATH VARCHAR2)');
return;
end;
setConstants;
--d('���������� ������ ���������','OK SP.TJ_MANAGEMENT.setCurTJWorkId(TJ_WORK_PATH)');
END setCurTJWorkId;

--------------------------------------------------------------------------------
-- ���������� Id ���� �������� � ������ rootName
FUNCTION getRoot(rootName VARCHAR2) RETURN NUMBER
is
id number;
BEGIN
 CASE rootName
   WHEN 'CurModelId' THEN return CurModelId;
   WHEN 'TJ_WORK_ID' THEN return "TJ_WORK_ID";
   WHEN 'TJ_WORK_PATH' THEN return "TJ_WORK_PATH";
  -- WHEN '������' THEN return "������";
  -- WHEN '�������' THEN return "�������";
   WHEN '�����' THEN return "�����";
   WHEN '�������' THEN return "�������";
   WHEN '�������������� �����������' THEN return "�������������� �����������";
   WHEN '����� ������' THEN return "����� ������";
   WHEN '���������' THEN return "���������";
   --WHEN '' THEN return "";
   ELSE return null;
 END CASE;  
END;
--------------------------------------------------------------------------------
-- ������ ������������� ���� �� ��������� ������� ��������� �����

function replaceCurToLat(str varchar2) return varchar2
 as      
 begin                                            
 return translate(str,
          '�����������������', -- ������������e ����� ������� �������� ��� ���������e
          'ABCEHKMOPTXaceoxy'  -- ���������e ����� ������� �������� ��� ������������e
         );        
 end;          
 
--------------------------------------------------------------------------------
-- ������ ��������� ���� �� ��������� ������� �������������� �����
function replaceLatToCur(str varchar2) return varchar2
 as      
 begin                                            
 return translate(str,
          'ABCEHKMOPTXaceoxy',  -- ���������e ����� ������� �������� ��� ������������e
          '�����������������' -- ������������e ����� ������� �������� ��� ���������e
         );        
 end;          
 
-------------------------------------------------------------------------------- 
-- ���������� �������������� ���� ������� ������� ������
FUNCTION get_Cables return SP.TNUMBERS pipelined
is
begin 
 for rec in
 (
 select id
    from SP.V_MODEL_OBJECTS where   
    MODEL_ID = CurModelId and
    OBJ_ID = "TJ.singles.������"
 )
 loop
  pipe row(rec.id);
 end loop;
end;
 
-------------------------------------------------------------------------------- 
-- ���������� �������������� � ��������� ���� ������� ������� ������
FUNCTION get_Devices return Device_TABLE pipelined
is
begin 
 for rec in
 (
 select id, MOD_OBJ_NAME "NAME", 
        SP.GETMPAR_S(ID,'����������') "COMMENT",
        SP.TMPAR(ID,'���������').Val.N "ID_���������",
        SP.Val_to_Str(SP.TMPAR(ID,'XYZ').Val) "XYZ",
        SP.TMPAR(ID,'�����').Val.N "ID_�����", 
        SP.TMPAR(ID,'�������').Val.N "ID_�������", 
        SP.Val_to_Str(SP.TMPAR(ID,'�������� �������').Val) "��������",
        SP.TMPAR(ID,'�� �����������').Val.N "ID_�����������",
        SP.TMPAR(ID,'�������������').Val.S "�������������",
        M_DATE
    from SP.V_MODEL_OBJECTS k where   
    MODEL_ID = CurModelId and
    OBJ_ID = "TJ.singles.�������"
 )
 loop
  pipe row(rec);
 end loop;
end;

-------------------------------------------------------------------------------- 
-- ���������� ������������ ���� ����� ��� ������� ������� ������
FUNCTION get_LayerName return SP.TSTRINGS pipelined
is
begin 
 for rec in
 (
/* 
 select DISTINCT nvl(TMPAR(id,'HP_Image_layer').Val.S,'TMP_Layer') layerName 
    from MODEL_OBJECTS where   
    OBJ_ID = "TJ.singles.�������"
    and MODEL_ID = CurModelId
    order by layerName
*/    
-- ����� ���������� ������
select DISTINCT pd.S  layerName
    from MODEL_OBJECTS o, MODEL_OBJECT_PAR_S pd 
    where   
    o.MODEL_ID = CurModelId and
    o.OBJ_ID = "TJ.singles.�������"
    and 
      pd.OBJ_PAR_ID = "HP_Image_layer"
      and pd.MOD_OBJ_ID = o.id
UNION
    select 'TMP_Layer' as layerName from dual          
order by layerName
 )
 loop
  pipe row(rec.layerName);
 end loop;
end; 
--------------------------------------------------------------------------------
-- ����� ������� � ������, "�����������" (� ������ ������ ��������� ���)
-- ���������������� ��������� �����.
-- ���������� �������: �� ��������� ����� ��� ����� �������� ��� ������� 
-- (���������� �������, ���. ��������� �������� ������ ��� ��������� �������).
-- ��� ����������� ����� ����� ���������� ��������� ����; �������� ��������� 
-- ������� =00BJK00 ��������� ����� +BJK00 
 FUNCTION getDevice(placeName VARCHAR2) RETURN NUMBER
is
 devid number;
 name varchar2(100);
 begin                                            
-- ��������� ������ - ��� ����� ��� ������� == ��� ����� 
-- (� ��������� �� 1-�� ������� (+ ��� =), � ��� ��������� ���� ���������)
 name := LTRIM(placeName,'+');
 select id into devid from SP.V_MODEL_OBJECTS where MOD_OBJ_NAME =
                                     '=' || name
                                     --and PARENT_MOD_OBJ_ID = "�������"
                                     and --CATALOG_NAME = '�������'
                                           OBJ_ID = "TJ.singles.�������"
                                     and MODEL_ID = CurModelId;
 return devid; 
 exception
 when NO_DATA_FOUND then 
 -- ������, ����� ��������� ��������� ���� 
   begin
   select id into devid from SP.V_MODEL_OBJECTS where MOD_OBJ_NAME =
                                     '=00' || name 
                                     --and PARENT_MOD_OBJ_ID = "�������"
                                     and --CATALOG_NAME = '�������'
                                           OBJ_ID = "TJ.singles.�������"
                                     and MODEL_ID = CurModelId;
   return devid;
   exception
    when NO_DATA_FOUND then 
     -- ����� ����������� ����� ������� � ����� ��������� ����� 
     -- (���� �� �����, �.�. ����� ���������� �������� �������)
       d('�� ������� ��������������� ������������� ��� ����� '||placeName
       --||' ASCIISTR()='||ASCIISTR(placeName)
       , 'WARNING in SP.TJ_MANAGEMENT.getdevice');
       return null;

     when TOO_MANY_ROWS then raise;  
   end;
 when TOO_MANY_ROWS then raise;  
 when others then
    d('������ '||SQLERRM||
      ' BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE(),
      'ERROR in SP.TJ_MANAGEMENT.getdevice');
    raise;     
 end;      

-------------------------------------------------------------------------------
-- deprecated procedure
-- ��������� ��������� ������, ��������������� ������� ������, � ���-������� TJ_CABLES. 
-- � ������, ����� �������� "�������" � ������ ���������� �������������� 
-- ������ � ������. 
/*
PROCEDURE updateTJ_CABLES_OLD
is
 KID number := 0;
 rowcount int := 0;
 Primary_divaceId1 number;
 "�����1" varchar2(500);
 Primary_divaceId2 number;
 "�����2" varchar2(500);
 mp TMPAR;
BEGIN
for r in 
(
select 
kID, kName, device1Id, device2Id, 
TMPAR(kID,'�������').Val.N systemId, -- ������� ������
TMPAR(kID,'�').Val.N      "�"
from
    (
       -- ������� �� �����    
      select 
      k.id kID, k.MOD_OBJ_NAME kName, 
      ( select PARENT_MOD_OBJ_ID from SP.V_MODEL_OBJECTS where 
                  id = GETMPAR_N(j.id,'REF_PIN_FIRST'))  device1Id, 
      ( select PARENT_MOD_OBJ_ID from SP.V_MODEL_OBJECTS where 
                   id = GETMPAR_N(j.id,'REF_PIN_SECOND')) device2Id 
      from SP.V_MODEL_OBJECTS k, SP.V_MODEL_OBJECTS j
      where 
             k.CATALOG_NAME = '������'
             and j.PARENT_MOD_OBJ_id = k.ID
             and j.CATALOG_NAME = '���� ������'
             and k.PARENT_MOD_OBJ_ID = "������"           
    )
order by KID    
) 
loop
-- ��������� � ������� ������ ���� ������ � ������ r.KID ��� �� �������� 
if r.KID != KID 
-- � �� ������ �� null
and r.device1Id is not null and r.device2Id is not null 
then
  begin 
    KID :=r.KID;
    begin
--    o('add cable id= '||r.KID);  
    if r.device1Id is not null then 
      -- � ������������� ������� ��������� HP_Primary_divace �� �������������
        mp := TMPAR(r.device1Id,'HP_Primary_divace');  
      -- ���������, �������� �� ���������� ���������
      -- ������-�� �������: �������� ���������� ������ ����
      if mp.Val.N = 1 then 
         Primary_divaceId1 := r.device1Id;
      else 
        if GETMPAR_N(r.device1Id,'�����') is not null then         
          "�����1" := GETMPAR_S(GETMPAR_N(r.device1Id,'�����'),'NAME');
          Primary_divaceId1 := getdevice("�����1");
        else 
          "�����1" := "����� �� ������";
          Primary_divaceId1 := null;
          d('������ '||KID||' �� ����� ���������� �� ����� �����!!!',
          'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
        end if;
      end if;  
    else
      Primary_divaceId1 := null;
      d('������ '||KID||' �� ����� ���������� �� ����� �����!!!',
        'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
    end if;
    EXCEPTION
      WHEN OTHERS THEN
        d(''||KID||'  ������ '||SQLERRM,
        'ERROR SP.TJ_MANAGEMENT.updateTJ_CABLES');
    end;
      
    if r.device2Id is not null then 
      mp := TMPAR(r.device2Id,'HP_Primary_divace');     
      if mp.Val.N = 1 
      then 
         Primary_divaceId2 := r.device2Id;
       else 
         if GETMPAR_N(r.device2Id,'�����') is not null then         
             "�����2" := GETMPAR_S(GETMPAR_N(r.device2Id,'�����'),'NAME');
             Primary_divaceId2 := getdevice("�����2");
         else 
             "�����2" := "����� �� ������";
             Primary_divaceId2 := null;
             d('������ '||r.KName||' id='||KID||' �� ����� ���������� �� ������ �����!!!',
             'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
         end if;
       end if;
    else   
      Primary_divaceId2 := null;
      d('������ '||KID||' �� ����� ���������� �� ������ �����!!!',
      'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
    end if;
    
    -- d('try add cable id= '|| r.KID,'SP.TJ_MANAGEMENT.updateTJ_CABLES');  
    insert into "SP"."TJ_CABLES"(CID, CNAME, DEVICE1ID, DEVICE2ID, 
                                DEVICE1, DEVICE2, PLACE1,  PLACE2, 
                                SYSTEMID, SYSTEM, "�")    
    values (r.KID, r.KName, Primary_divaceId1, Primary_divaceId2, 
              CASE 
              when Primary_divaceId1 is null then ''
              else GETMPAR_S(Primary_divaceId1,'NAME')
              end,                 
              CASE 
              when Primary_divaceId2 is null then ''
              else GETMPAR_S(Primary_divaceId2,'NAME')
              end,        
              "�����1", "�����2", r.systemId, 
              CASE 
              when r.systemId is null then '�� ������� �������!'
              else GETMPAR_S(r.systemId,'NAME')
              end,                 
              r."�"              
    );
    --rowcount := rowcount + 1;
    --d('rowcount= '|| rowcount,'SP.TJ_MANAGEMENT.updateTJ_CABLES');  
  EXCEPTION
    WHEN OTHERS THEN
      d(''||KID||'  ������ '||SQLERRM,
      'ERROR SP.TJ_MANAGEMENT.updateTJ_CABLES');
--      o(rowcount||'  '||KID||'������ ������ SP.TJ_MANAGEMENT '||SQLERRM);
  end;
end if; -- r.KID != KID 
end loop;
--d('� SP.TJ_CABLES ��������� ����� '||rowcount,'OK SP.TJ_MANAGEMENT.updateTJ_CABLES');
--ROLLBACK;
--RAISE;
END updateTJ_CABLES_OLD;
*/
--------------------------------------------------------------------------------
-- ������� ���� ������� � ������ �� ��������� �������
PROCEDURE updateTJ_CABLES
is
 KID number;
 KPID number;
 rowcount int;
 Primary_divaceId1 number;
 "�����1" varchar2(500);
 Primary_divaceId2 number;
 "�����2" varchar2(500);
 mp TMPAR;
BEGIN
--d('start updateTJ_CABLES','updateTJ_CABLES');
--delete from SP.TJ_CABLES;
--d(CurModelId,CurModelId);

for cable in 
(
    -- ������� �� �������    
    select 
    id cableID, MOD_OBJ_NAME cableName, 
    TMPAR(id,'�������').Val.N cableSystemId, -- ������� ������
    TMPAR(id,'�').Val.N       cableNumber
    from MODEL_OBJECTS --V_MODEL_OBJECTS
    where 
        --CATALOG_NAME = '������'
        OBJ_ID = "TJ.singles.������" 
        and MODEL_ID = CurModelId
        --and PARENT_MOD_OBJ_ID = "������"       
)      
LOOP
-- ������� �� ����� ������
  for cablePin in 
  (
    select 
    id pinID, 
    GETMPAR_N(id,'REF_PIN_FIRST')  pinId1,
    GETMPAR_N(id,'REF_PIN_SECOND') pinId2,
    ROWNUM 
    from V_MODEL_OBJECTS
    where 
        PARENT_MOD_OBJ_id = cable.cableID and 
        CATALOG_NAME = '���� ������'
        order by 
        pinId1 nulls last, pinId2 nulls last, ROWNUM           
  )
  loop
  /*
  -- ���������� ������ ����������������
    if cable.cableName = '=03BUB0003BUB00-1001' or 
       cable.cableName = '=03BUB0003BUB00-1002' or
       cable.cableName = '=03BUB0003BUB00-1038' or
       cable.cableName = '=00BFA60BFA60 1001'
    then
       d('������ ROWNUM='||cablePin.ROWNUM||'  '||cable.cableName||
         ' cablePin.pinId1 = '||cablePin.pinId1 ||
         ' cablePin.pinId2 = '||cablePin.pinId2,
            'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
    end if;
    */  
    if cablePin.pinId1 is not null then
     --select PARENT_MOD_OBJ_ID into Primary_divaceId1 
     --from SP.V_MODEL_OBJECTS 
     --where id = cablePin.pinId1;
        KPID:= GETMPAR_N(cablePin.pinId1,'PID');
        KID := GETMPAR_N(KPID,'�����');
            if KID is null then
                Primary_divaceId1 := null;
                d('��� ������ ������� '||GETMPAR_S(KPID,'NAME')||' id='||KPID||
                  ' �� ������ �����!!!',
                  'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
            else
                "�����1" := GETMPAR_S(KID,'NAME');
                Primary_divaceId1 := getdevice("�����1");
                -- � ������������� ������� ��������� HP_Primary_divace �� �������������
                -- mp := TMPAR(Primary_divaceId1,'HP_Primary_divace');  
                -- ���������, �������� �� ���������� ���������
                -- ���� ��� ������������� ����� ��������      
            end if;           
    else
          d('������ '||cable.cableName||' id='||cable.cableID||
            ' �� ����� ���������� �� ����� �����! cablePin.pinId1='||
            cablePin.pinId1,
            'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
            "�����1" := null;
            Primary_divaceId1 := null;
    end if;   

   --o('2'); 
    if cablePin.pinId2 is not null then
        KPID:= GETMPAR_N(cablePin.pinId2,'PID');
        KID := GETMPAR_N(KPID,'�����');
        if KID is null then
            Primary_divaceId2 := null;
            d('��� ������� ������� '||GETMPAR_S(KPID,'NAME')||' id='||KPID||
              ' �� ������ �����!!!',
              'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
        else
            "�����2" := GETMPAR_S(KID,'NAME');
            Primary_divaceId2 := getdevice("�����2");
        end if;           
    else
            d('������ '||cable.cableName||' id='||cable.cableID||
            ' �� ����� ���������� �� ������ �����! cablePin.pinId2='||
            cablePin.pinId2,
            'WARNING SP.TJ_MANAGEMENT.updateTJ_CABLES');
            "�����2" := null;
            Primary_divaceId2 := null;
    end if;   
-- ������� ����� ������ �� ��������� �� ����� ������
  exit;  --when cablePin.ROWNUM > 1; ��� �� ��������!!!
  end loop;
  
-- ��������� � ������� ������ 
  BEGIN
    insert into "SP"."TJ_CABLES"(CID, CNAME, DEVICE1ID, DEVICE2ID, 
                                DEVICE1, DEVICE2, PLACE1,  PLACE2, 
                                SYSTEMID, "SYSTEM", "�")    
    values (cable.cableID, cable.cableName, 
            Primary_divaceId1, Primary_divaceId2, 
              CASE 
              when Primary_divaceId1 is null then ''
              else GETMPAR_S(Primary_divaceId1,'NAME')
              end,                 
              CASE 
              when Primary_divaceId2 is null then ''
              else GETMPAR_S(Primary_divaceId2,'NAME')
              end,        
              "�����1", "�����2", cable.cableSystemId, 
              CASE 
              when cable.cableSystemId is null then '�� ������� �������!'
              else GETMPAR_S(cable.cableSystemId,'NAME')
              end,                 
              cable.cableNumber              
    );
    --rowcount := rowcount + 1;
    --d('rowcount= '|| rowcount,'SP.TJ_MANAGEMENT.updateTJ_CABLES');  
  EXCEPTION
    WHEN OTHERS THEN
      d('������ id='||cable.cableID||'  ������ '||SQLERRM,
      'ERROR SP.TJ_MANAGEMENT.updateTJ_CABLES');
--      o(rowcount||'  '||KID||'������ ������ SP.TJ_MANAGEMENT '||SQLERRM);
  END;
  
END LOOP;      
      
--d('� SP.TJ_CABLES ��������� ����� '||rowcount,'OK SP.TJ_MANAGEMENT.updateTJ_CABLES');
--ROLLBACK;
--RAISE;
END updateTJ_CABLES;
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- ���������� ������ �������� ��������� ���������� ������� 
-- (��������������� � ������ �� ������������ ��������) 
-- ��� ������ ���.���������� �� ������� � ��������� ������
FUNCTION getDeviceParameters(deviceId IN NUMBER) RETURN VARCHAR2
is
tmpid NUMBER;
tvN NUMBER;
s varchar2(3000) := null;
sname varchar2(3000);
"�������" varchar2(3000);
begin
 if deviceId is null then return '';
 else 

-- ����������
  if GETMPAR_S(deviceId, '����������') is not null
  then  s := s ||'\n'||GETMPAR_S(deviceId, '����������'); end if; 
  
-- if GETMPAR_S(deviceId, 'HP_Room_number_and_name') is not null
-- then  s := s || '\n'||GETMPAR_S(deviceId, 'HP_Room_number_and_name'); end if;

-- �������
-- ��������� - � ��������� ����, ����� - ������
  if GETMPAR_N(deviceId, 'HP_Elevation') is not null
  then  "�������" :=  TO_CHAR( GETMPAR_N(deviceId, 'HP_Elevation')/1000, 
                              'Sfm99990.0000'); 
  -- ������� �� 1000 ����������� ���, ��� � E3 ���������� �������� � ��
  else 
       if TMPAR(deviceId, '�������').Val.N is not null then
            "�������" := GETMPAR_S(GETMPAR_N(deviceId, '�������'), 'NAME'); 
            -- ���������� ������� ��������
            if REGEXP_INSTR("�������",'^-?[0-9]*\.?[0-9]*$') = 0 
            then -- ��� �� ������������� �����
                "�������" := null; 
            end if;
       else "�������" := null;      
       end if;
  end if;
  if "�������" is not null then 
        s := s || '\n���. ' ||
        case when SUBSTR("�������",1,1) != '+' and SUBSTR("�������",1,1) != '-'
        then '+' end            
        || "�������";
  end if;
  
-- ���������
  tmpid := TMPAR(deviceId,'���������').Val.N;  
  if tmpid is not null then
    s := s || '\n���. '||
             TRIM(GETMPAR_S(tmpid, 'NAME')||' '||GETMPAR_S(tmpid,'������������')
             ||' '|| TMPAR(deviceId,'������������ ���������').Val.S);                     
  end if; 
  
-- ������� ���������
tvN := TMPAR(deviceId, '������� ���������').Val.N;
if tvN is not null
then
  sname := GETMPAR_S(tvN, '������������');
  if sname is not null then 
    s := s ||'\n'||sname; 
  else
    s := s ||'\n'||GETMPAR_S(tvN, 'NAME'); 
  end if;
end if;  
/*
  if TMPAR(deviceId, 'HP_Coordinate_system').Val.S is not null
  then
  s := s ||'\n'||GETMPAR_S(deviceId, 'HP_Coordinate_system'); end if; 
*/  
  RETURN TRIM(s);
  
 end if;
end;

-------------------------------------------------------------------------------- 
-- ������������� ������ ��� �� ������, ����������� �� ������� ������ Excel 
-- ��� ���������� ������ �� E3.
-- �� ������ ������ ���������� �� ����� ���� � �����, 
-- � ��������� ���� � ������ �������� ���������������. ��� ��������� ����������.
-- �� ������ ������ ��������� ���������� � ������ E3 ����� ���� ��������� �������������, 
-- ����� ������������ ���������� (����, �����), ������� ��������� � ������ 
-- ��������� ��������� (��������� - �� ���� ��������� �����������). ��������, 
-- ���� ��� ��������� ���������� ��������� (��������� - ��������) ����������� 
-- �����, � ������� ��������� ������������ ���������� 
-- (� � ������� �������� ���� �������). 
-- ������������� ����� ��� ����� � ��� ���������� ���������� � ������ ���: 
-- �������� "=" � "+" ���������� ���� (�����/����������), � ��� ���������� 
-- ��������� �������� ��������� �����.  
-- LengthParamName - ��� ���������, �� �������� ������� ����� ������

FUNCTION get_CableTable(SYSID in NUMBER, LengthParamName VARCHAR2) 
return TJ_TABLE pipelined
is
begin
 for rec in
 (
 select * from
  (
    select  
    CID "ID",
    TMPAR(CID,'�').Val.N "�����_����������", 
    --cname   "�����",  
    
    -- �������� �������    
    (select MOD_OBJ_NAME from SP.V_MODEL_OBJECTS mo where mo.id = GETMPAR_N(CID,'�������')) "�������",
    
    -- ������ ����� ������� �������� ���������
    -- GETMPAR_S(CID,'POSITION') "�����", 
    TMPAR(CID,'POSITION').Val.S "�����", 
    
    CASE WHEN Device1 is null THEN "����� �� ������" ELSE 
     Device1
    END "������",

    CASE WHEN Device1 is null THEN '' ELSE 
     getDeviceParameters(Device1Id)
    END "������_��������",

    CASE WHEN Device2 is null THEN "����� �� ������" ELSE 
     Device2
    END "����",
 
    CASE WHEN Device2 is null THEN '' ELSE 
     getDeviceParameters(Device2Id)
    END "����_��������",

    GETMPAR_S(CID,'���') "���������_�����",
    GETMPAR_S(CID,'����� ��� � �������') "�����_���_�_�������",
    GETMPAR_N(CID,'����������') ����������,
    to_.STR(TMPAR(CID,'����� ����').Val)  "�����_����",
    -- ����� ������, ����������� ��� ����� ���� �������� ������
    --GETMPAR_N(CID,'�����') "�����", 
    -- ����� ������, ����������� �������� E3
    --CEIL(nvl(TMPAR(CID,'HP_Cable_length').Val.N,0)) "�����", 
    
    CEIL(nvl(TMPAR(CID,LengthParamName).Val.N,0)) "�����", 
    
    GETMPAR_N(CID,'�����������') "�����������",
    GETMPAR_N(CID,'������') "������",
    GETMPAR_N(CID,'�������') "�������",
    GETMPAR_N(CID,'��������') "��������",
    GETMPAR_N(CID,'����������') "����������",
    GETMPAR_N(CID,'��������') "��������",
    GETMPAR_N(CID,'�����������������5�') "�����������������5�",
    GETMPAR_N(CID,'������������5�') "������������5�",
    GETMPAR_N(CID,'�������������5�') "�������������5�",
    GETMPAR_N(CID,'��������������5�') "��������������5�",
    GETMPAR_N(CID,'����������������5�') "����������������5�",
    GETMPAR_N(CID,'��������������5�') "��������������5�",
    GETMPAR_N(CID,'�������') "�������",
    GETMPAR_N(CID,'����������') "����������",
    GETMPAR_N(CID,'������') "������"
    from SP.TJ_CABLES 
    where 
-- ���� ������ ���� ���������� �������
SYSTEMID = SYSID and SYSID > 0 
-- ���� ��� �������
or 
 1 =
  CASE
   WHEN SYSID is null THEN 1
   ELSE  0
  END
 or
-- ���� ����� ������ ������
 SYSID = 0 and SYSTEMID in 
   (select column_value from table(TJ_MANAGEMENT.get_selectedSystemIds) )
  )
  order by 
  "�����_����������" --���������� �� ���������
 )
 loop  
    pipe row(rec);
 end loop;        
end;

-------------------------------------------------------------------------------- 
-- ����������� ������� ��������� �� �������� � ��������, ���������� � ����������
-- �������� ����� BRCM
-- ��� ���� ������ ������ � �������� ��������������� WORK_ID
FUNCTION get_CableTableBRCM(WORK_ID in NUMBER) 
return TJ_TABLE pipelined
is
begin
for rec in
(
    SELECT 
    CABLE_ID, 
    SP.TMPAR(CABLE_ID, '�').Val.N �����_����������, 
 -- �������� �������    
   (select MOD_OBJ_NAME from SP.V_MODEL_OBJECTS mo where mo.id = GETMPAR_N(CABLE_ID,'�������')) "�������",    
    --SP.TMPAR(CABLE_ID, 'POSITION').Val.S "�����", 
    CABLE_NAME "�����", 

    nvl((select  Device1 from SP.TJ_CABLES where CID = CABLE_ID),"����� �� ������") "������",
    getDeviceParameters((select DEVICE1ID from SP.TJ_CABLES where CID = CABLE_ID)) "������_��������",
    nvl((select  Device2 from SP.TJ_CABLES where CID = CABLE_ID),"����� �� ������") "����",
    getDeviceParameters((select DEVICE2ID from SP.TJ_CABLES where CID = CABLE_ID)) "����_��������", 
    
    GETMPAR_S(CABLE_ID, '���') "���������_�����",
    GETMPAR_S(CABLE_ID, '����� ��� � �������') "�����_���_�_�������",
    GETMPAR_N(CABLE_ID, '����������') "����������",
    to_.STR(SP.TMPAR(CABLE_ID, '����� ����').Val) "�����_����",
    nvl("������",0) + nvl("�����",0) + nvl("�����",0) "�����",  
--    nvl("������",0) "�����������", nvl("�����",0) "������", nvl("�����",0) "�������",
--    nvl("������",0) "������", nvl("�����",0) "�����", nvl("�����",0) "�����",
    nvl("������",0) , nvl("�����",0) , nvl("�����",0) ,
    -- ��������� �������� �������� � ������ ������ ������� �� ����������
    0 ��������111,0 ����������,0 ��������,0 �����������������5�, 
    0 ������������5�,0 �������������5�,0 ��������������5�,0 ����������������5�,
    0 ��������������5�, 0 �������,0 ����������,0 ������
    from
    (
    select 
    CABLE_ID, CABLE_NAME, CABLE_CONSTRUCTUIN_TYPENAME, CEIL(sum(LENGTH)) ss
    FROM TABLE(SP.TJ_WORK.V_CABLE_WAYS(WORK_ID))
    GROUP BY CABLE_ID, CABLE_NAME, CABLE_CONSTRUCTUIN_TYPENAME
    ORDER BY CABLE_NAME
    )
    pivot 
    (
       sum(ss)
       for CABLE_CONSTRUCTUIN_TYPENAME in 
       ('������' as "������",'�����' as "�����",'�����' as "�����")
    )
)
 loop  
  pipe row(rec);
  null;
 end loop;        
end;

-------------------------------------------------------------------------------- 
/*
FUNCTION get_CableSUMMTableBRCM(WORK_ID in NUMBER) 
return TJ_TABLE pipelined
is
begin
for rec in
(
*/

-- ����������, ��� ������ ���� �� ��������� ������������ 
-------------------------------------------------------------------------------- 
FUNCTION get_TrayTableBRCM(WORK_ID in NUMBER) 
return Tray_TABLE pipelined
is
--i int :=0 ;
begin
--d('start get_TrayTableBRCM','get_TrayTableBRCM');
for rec in
(
    SELECT 
--    CABLE_ID "ID", 
    SP.TMPAR(CABLE_ID, '�').Val.N "�����_����������", 
-- �������� �������    
--   (select MOD_OBJ_NAME from SP.V_MODEL_OBJECTS mo where mo.id = GETMPAR_N(CABLE_ID,'�������')) "�������",    
    --SP.TMPAR(CABLE_ID, 'POSITION').Val.S "�����", 
    CABLE_NAME "�����", 
    nvl((select  Device1 from SP.TJ_CABLES where CID = CABLE_ID),"����� �� ������") ||
    getDeviceParameters((select DEVICE1ID from SP.TJ_CABLES where CID = CABLE_ID))
    "������",
    --getDeviceParameters((select DEVICE1ID from SP.TJ_CABLES where CID = CABLE_ID)) "������_��������",
    nvl((select  Device2 from SP.TJ_CABLES where CID = CABLE_ID),"����� �� ������") ||
    getDeviceParameters((select DEVICE2ID from SP.TJ_CABLES where CID = CABLE_ID)) 
    "����",
--    getDeviceParameters((select DEVICE2ID from SP.TJ_CABLES where CID = CABLE_ID)) "����_��������",     
    trays "�������",
    SEGMENT_LENGTH "�����",
    to_.STR(SP.TMPAR(CABLE_ID, '����� ����').Val) "�����_����",   
    TO_CHAR(GETMPAR_N(CABLE_ID, '����������')) "����������",   
    GETMPAR_S(CABLE_ID, '���') "���������_�����",
    GETMPAR_S(CABLE_ID, '����� ��� � �������') "�����_���_�_�������",
    '' "������",
    LENGTH "�����",
    0 "�����_���",
    0 "�����_�����"
    from
    (
    SELECT CABLE_ID, CABLE_NAME,      
      LISTAGG(
          (
          -- ��� ����� ���������, ����� ��� �������
          CASE WHEN INSTR(SEGMENT_NAME,'Tube#') = 1 
          THEN SUBSTR(SEGMENT_NAME,1,INSTR(SEGMENT_NAME,':')-1) 
          ELSE SEGMENT_NAME
          END), '\n') WITHIN GROUP (order by ORDINAL) trays, 
      LISTAGG(CEIL(LENGTH),'\n') WITHIN GROUP (order by ORDINAL) SEGMENT_LENGTH,
      sum(CEIL(LENGTH)) "LENGTH"
    FROM TABLE(SP.TJ_WORK.V_CABLE_WAYS(WORK_ID)) 
    GROUP BY CABLE_ID, CABLE_NAME
    ORDER BY CABLE_NAME 
    )
)
 loop  
--  d('i='||i,'get_TrayTableBRCM');
  pipe row(rec);
--  i:=i+1;
 end loop;        
-- d('stop i='||i,'get_TrayTableBRCM');
  EXCEPTION
    WHEN OTHERS THEN
      d('  ������ '||SQLERRM,'ERROR SP.TJ_MANAGEMENT.get_TrayTableBRCM'); 
end;


-------------------------------------------------------------------------------- 
FUNCTION get_CableWeight(cablename varchar2) return number
is
begin
if "�������������� ������".EXISTS(cablename)
then return nvl("�������������� ������"(cablename).Weight,0);
else return 0;
end if;
end;

FUNCTION get_CableDiameter(cablename varchar2) return number
is
begin
if "�������������� ������".EXISTS(cablename)
then return nvl("�������������� ������"(cablename).Diameter,0);
else return 0;
end if;
end;

-------------------------------------------------------------------------------- 
-- ������� ���������� ������/����� ������ �������� 
-- (������ �������� ��������� ����� � ����� �����)
FUNCTION get_RouteTableBRCM(WORK_ID in NUMBER) 
return Tray_TABLE pipelined
is
 r Tray_REC;
 i int := 1;
begin
for rec in
(
   with T1 as ( 
             SELECT SEGMENT_NAME, CABLE_NAME, CEIL(LENGTH) leng, ORDINAL, 
                  SP.GETMPAR_S(CABLE_ID,'HP_Cable_type') HP_Cable_type,
                  SP.GETMPAR_N(CABLE_ID,'HP_Number_cable_cores')||'x'||
                     SP.GETMPAR_N(CABLE_ID,'HP_Cable_cross_section') Prop,
                  to_.str(SP.TMPAR(CABLE_ID,'����� ����').VAL) "�����_����",
                  GETMPAR_N(CABLE_ID, '����������') "����������"
                  FROM TABLE(SP.TJ_WORK.V_CABLE_WAYS(WORK_ID))
                  where CABLE_CONSTRUCTUIN_TYPENAME = '�����'
                  
              )                  
                SELECT SEGMENT_NAME,
                  LISTAGG(CABLE_NAME,'\n')  WITHIN GROUP (order by ORDINAL) "�������", 
                  LISTAGG(leng,'\n')  WITHIN GROUP (order by ORDINAL) "�����",
-- ����� ������ �������� ����� ���� � ���������� (��� �������� ������������� � ����� �����)
                  LISTAGG("�����_����",'\n')  WITHIN GROUP (order by ORDINAL) "�����_����",
                  LISTAGG("����������", '\n')  WITHIN GROUP (order by ORDINAL) "����������",
-- ��� ������                  
                  LISTAGG(HP_Cable_type,'\n')  WITHIN GROUP (order by ORDINAL) "���������_�����",
                  LISTAGG(Prop,'\n')  WITHIN GROUP (order by ORDINAL) "�����_���_�_�������",
-- key                  
                  LISTAGG(get_CableDiameter(HP_Cable_type||' '||Prop),'\n') WITHIN GROUP (order by ORDINAL) "������_���",
-- values
                  sum(leng) "�����",
                  sum(leng * get_CableWeight(HP_Cable_type||' '||Prop)) "�����_���",
                  sum(get_CableDiameter(HP_Cable_type||' '||Prop)) "�����_���������"                  
                FROM T1
                GROUP BY SEGMENT_NAME
                ORDER BY SEGMENT_NAME
)
 loop  
  r."�����_����������" := i;
  r."�����" := rec.SEGMENT_NAME;
  r."�������" := rec."�������";
  r."�����" := rec."�����";
  r."�����_����" := rec."�����_����";
  r."����������" := rec."����������";
  r."���������_�����" := rec."���������_�����";
  r."�����_���_�_�������" := rec."�����_���_�_�������";
--  r."������" := rec."������_���";
  r."�����" := rec."�����";
  r."�����_���" := rec."�����_���";
  r."�����_���������" := rec."�����_���������";
  pipe row(r);
  i := i + 1;
 end loop;        
  EXCEPTION
    WHEN OTHERS THEN
      d('  ������ '||SQLERRM,'ERROR SP.TJ_MANAGEMENT.get_RouteTableBRCM'); 
end;

-------------------------------------------------------------------------------- 

/*
-- deprecated procedure variant
-- ���������� �������, ����������� � ���� "�������",
-- ������������� ������� � ������� �������� �� �����������.
-- ��������� ���������� ��������� ������ 
-- (����� ������� ��������� � ���� "�������")
FUNCTION get_Equipment(SYSID in NUMBER, VIEW_ID in NUMBER) 
return Equipment_TABLE pipelined
is
begin
for rec in
(
select ID, "Place", "KOD", NAME, X, Y, Z, 1500 as Reserve, "View", ViewId,
"SystemName", SystemId
from
(
select ID, KOD, NAME,
nvl(TMPAR(id,'XYZ���').Val.X,0) x,
nvl(TMPAR(id,'XYZ���').Val.Y,0) y,
nvl(TMPAR(id,'XYZ���').Val.N /*- :ZCorrect* /,0) z,
ViewId,

CASE WHEN ViewId is null THEN 'NULL_ViewId' 
ELSE GETMPAR_S(ViewId,'NAME')
END "View",           

TRIM
( LEADING '+' FROM  
  case when PlaceId is NULL then ''
  else GETMPAR_S(PlaceId,'NAME') 
  end
) "Place",

CASE WHEN SystemId is null THEN 'NULL_SystemId' 
ELSE  TMPAR(SystemId,'NAME').Val.S 
END "SystemName",           
SystemId
from 
   (
    select id, MOD_OBJ_NAME KOD, GETMPAR_S(id,'����������') NAME,
    GETMPAR_N(id,'�� �����������') ViewId,
    GETMPAR_N(id,'�������') SystemId,
    GETMPAR_N(id,'�����') PlaceId,
    GETMPAR_N(id,'HP_Primary_divace') HP_Primary_divace
    from V_MODEL_OBJECTS 
    where  PARENT_MOD_OBJ_ID = "�������" and CATALOG_NAME = '�������'
   )
   where 
   -- ������ "Primary-�������" (�� ����, �� ��������, ...)
   HP_Primary_divace = 1 
   and  
   ViewId = VIEW_ID
   and 
    ( 
     SystemId = SYSID
     or
     1 =
     CASE WHEN SYSID is null THEN 1
      ELSE  0
     END
    )
 )                
)
loop  
    pipe row(rec);
 end loop;  
 exception
 when OTHERS then 
  d('������ '||SQLERRM||
      ' BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()||' '|| 'SYSID='||SYSID||' '||'VIEW_ID='||VIEW_ID,
      'Error SP.TJ_MANAGEMENT.get_Equipment');
    raise;     
end;
*/
-------------------------------------------------------------------------------- 
-- ��������� ������ ���������������� �������
-- ��������� ���������� ���������
-------------------------------------------------------------------------------- 
/*
����� ������� �� �����: �� �������� �� ���������
-- ���������� �������, ����������� ��� ������ (� �������� �������� ������),
-- ������������� ������� SYSID � ������� �������� �� ����������� (VIEW_ID).
-- ��� ��������� �������� ������������ ���������� ReportGenerator
-- (������������� ������������ ���� ��� BRCM)
FUNCTION get_Equipment(SYSID in NUMBER, VIEW_ID in NUMBER)  
return Equipment_TABLE pipelined
is
id NUMBER;
ids TNUMBERS;
rec Equipment_REC;
selectrdSystemName varchar2(256);
begin
--*********************************************************************************
-- ������ ��� ��������� ������ id-�� ������� ���� ���� ������, 
-- ���� ������� ������ �������� �������,
-- ��� ���� �������� ������ "Primary-�������" (�� ����, �� ��������, ...).
-- 1. id-� ������� ����� ������
if SYSID is null then 
select o.id BULK COLLECT into ids 
from SP.MODEL_OBJECTS o, SP.MODEL_OBJECT_PAR_S pd, SP.MODEL_OBJECT_PAR_S ii
where o.OBJ_ID = "TJ.singles.�������"
      and o.MODEL_ID = CurModelId
      and pd.OBJ_PAR_ID = "HP_Primary_divace"
      and pd.MOD_OBJ_ID = o.id 
      and pd.N = 1
      
      and ii.OBJ_PAR_ID = "�� �����������"
      and ii.MOD_OBJ_ID = o.id 
      and ii.N = VIEW_ID;
      
      --and GETMPAR_N(o.id,'HP_Primary_divace') = 1 
      --and GETMPAR_N(o.id,'�� �����������') = VIEW_ID;
      
-- ��� ������� �� ������
selectrdSystemName := null;      
else
-- 2. id-� �������, ������������� ������� � �������� Id = SYSID
select o.id BULK COLLECT into ids from 
SP.MODEL_OBJECTS o, SP.MODEL_OBJECT_PAR_S pd, SP.MODEL_OBJECT_PAR_S ii,
SP.V_MODEL_OBJECT_PAR_S si
where MODEL_ID = CurModelId
      and o.OBJ_ID = "TJ.singles.�������"

      and pd.OBJ_PAR_ID = "HP_Primary_divace"
      and pd.MOD_OBJ_ID = o.id 
      and pd.N = 1
      
      and ii.OBJ_PAR_ID = "�� �����������"
      and ii.MOD_OBJ_ID = o.id 
      and ii.N = VIEW_ID
      
      and si.OBJ_PAR_ID = "�������"
      and si.MOD_OBJ_ID = o.id 
      and si.N = SYSID;
      
-- �������� ��� �������� �������
select MOD_OBJ_NAME into selectrdSystemName from 
SP.V_MODEL_OBJECTS where id = SYSID;
end if; 


--*********************************************************************************
if ids.COUNT =0 then 
d('��� ������� � ������������ '||VIEW_ID,'get_Equipment');
return;
else d('���������� ������� � ������������ '||ids.COUNT,'get_Equipment');
end if;

FOR i IN ids.FIRST..ids.LAST
 loop  
    id := ids(i);
    rec.ID := id; 
    
    rec."ViewId" := GETMPAR_N(id,'�����');
    if rec."ViewId" is null then
     rec."Place" := ''; 
    else
     rec."Place" := GETMPAR_S(rec."ViewId",'NAME');
    end if;
    
    rec."KOD" :=  GETMPAR_S(id,'NAME'); 
    rec."NAME":=  GETMPAR_S(id,'����������');
    
    rec.X := nvl(TMPAR(id,'XYZ���').Val.X,0);
    rec.Y := nvl(TMPAR(id,'XYZ���').Val.Y,0);
    rec.Z := nvl(TMPAR(id,'XYZ���').Val.N /*- :ZCorrect* /,0);
    rec."Reserve" := 1500;
    
    rec."ViewId" := GETMPAR_N(id,'�������');
    if rec."ViewId" is null then
     rec."View" := 'NULL_ViewId'; 
    else
     rec."View" := GETMPAR_S(rec."ViewId",'NAME');
    end if;
    
    if SYSID is null then 
        rec."SystemId" := GETMPAR_N(id,'�������');
        rec."SystemName" := GETMPAR_S(rec."SystemId",'NAME');
    else
        rec."SystemId"  := SYSID;
        rec."SystemName" := selectrdSystemName;
    end if;    
    
    pipe row(rec);
 end loop;  
 exception
 when OTHERS then 
  d('������ '||SQLERRM||
      ' BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()||' '|| 'SYSID='||SYSID||' '||'VIEW_ID='||VIEW_ID,
      'Error SP.TJ_MANAGEMENT.get_Equipment');
    raise;     
end;
*/
--------------------------------------------------------------------------------
/*
FUNCTION get_AllSystemsEquipment(VIEW_ID in NUMBER) 
return Equipment_TABLE pipelined
is
id NUMBER;
deviceId NUMBER;
rec Equipment_REC;
systemName varchar2(256);
begin
for rec in
(
select ID, "Place", "KOD", NAME, X, Y, Z, 1500 as Reserve, "View", ViewId,
"SystemName", SystemId
from
(
select ID, KOD, NAME,
nvl(TMPAR(id,'XYZ���').Val.X,0) x,
nvl(TMPAR(id,'XYZ���').Val.Y,0) y,
nvl(TMPAR(id,'XYZ���').Val.N /*- :ZCorrect* /,0) z,
ViewId,

CASE WHEN ViewId is null THEN 'NULL_ViewId' 
ELSE GETMPAR_S(ViewId,'NAME')
END "View",           

TRIM
( LEADING '+' FROM  
  case when PlaceId is NULL then ''
  else GETMPAR_S(PlaceId,'NAME') 
  end
) "Place",

TMPAR(SystemId,'NAME').Val.S "SystemName",           
SystemId
from 
   (
    select id, MOD_OBJ_NAME KOD, GETMPAR_S(id,'����������') NAME,
    GETMPAR_N(id,'�� �����������') ViewId,
    GETMPAR_N(id,'�������') SystemId,
    GETMPAR_N(id,'�����') PlaceId,
    GETMPAR_N(id,'HP_Primary_divace') HP_Primary_divace
    from V_MODEL_OBJECTS 
    where -- PARENT_MOD_OBJ_ID = "�������" and CATALOG_NAME = '�������'
    OBJ_ID = deviceId and MODEL_ID = CurModelId    
   )
   where 
   -- ������ "Primary-�������" (�� ����, �� ��������, ...)
   HP_Primary_divace = 1 
   and  
   ViewId = VIEW_ID
 )                
)
loop  
    pipe row(rec);
 end loop;  
 exception
 when OTHERS then 
  d('������ '||SQLERRM||
      ' BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()||' '||'VIEW_ID='||VIEW_ID,
      'Error SP.TJ_MANAGEMENT.get_AllSystemsEquipment');
    raise;     
end;
-------------------------------------------------------------------------------- 
*/

-------------------------------------------------------------------------------- 

-- ���������� �������, ������������� ���� � ������� �������� �� �����������
FUNCTION get_Equipment(LAYER in VARCHAR, VIEW_ID in NUMBER) return Equipment_TABLE pipelined
is
begin
--d('��������� ������� id=' || "�������",'AZAROV get_Equipment');
for rec in
(
select ID, "Place", "KOD", NAME, X, Y, Z, 1500 as Reserve, "View", VIEW_ID,
"Layer", 0
from
  (
    select ID, KOD, NAME,
    nvl(TMPAR(id,'XYZ���').Val.X,0) x,
    nvl(TMPAR(id,'XYZ���').Val.Y,0) y,
    nvl(TMPAR(id,'XYZ���').Val.N /*- :ZCorrect*/,0) z,
    VIEW_ID,
    case when VIEW_ID is null then 'NULL_ViewId' 
    else GETMPAR_S(VIEW_ID,'NAME') end "View", 
    TRIM
    ( LEADING '+' FROM  
      case when PlaceId is NULL then ''
      else GETMPAR_S(PlaceId,'NAME') 
      end
    ) "Place",
    "Layer"
    from
       (
        select o.id, o.MOD_OBJ_NAME KOD, GETMPAR_S(o.id,'����������') NAME,
        --GETMPAR_S(id,'HP_Image_layer') "Layer", 
        -- � ��������� ����������� �������� HP_Image_layer, ������� TMPAR
        nvl(TMPAR(o.id,'HP_Image_layer').Val.S,'TMP_Layer') "Layer",
        GETMPAR_N(o.id,'�����') PlaceId
        from 
          SP.MODEL_OBJECTS o, 
          SP.MODEL_OBJECT_PAR_S pd, 
          SP.MODEL_OBJECT_PAR_S ii
          where o.OBJ_ID = "TJ.singles.�������"
          and o.MODEL_ID = CurModelId
          and 
              pd.OBJ_PAR_ID = "HP_Primary_divace"
          and pd.MOD_OBJ_ID = o.id 
          and pd.N=1
          and
              ii.OBJ_PAR_ID = "�� �����������"
          and ii.MOD_OBJ_ID = o.id 
          and ii.N = VIEW_ID
       )
       where 
       "Layer" = LAYER
  )     
/*
 select o.id, o.MOD_OBJ_NAME KOD, GETMPAR_S(o.id,'����������') NAME,
      ii.N, 
      SP.GETMPAR_S(ii.N,'NAME'), LAYER 
      from 
      SP.MODEL_OBJECTS o, 
      SP.MODEL_OBJECT_PAR_S pd, 
      SP.MODEL_OBJECT_PAR_S ii,
      SP.MODEL_OBJECT_PAR_S la
      where o.OBJ_ID = "TJ.singles.�������"
      and o.MODEL_ID = CurModelId
      and 
          pd.OBJ_PAR_ID = "HP_Primary_divace"
      and pd.MOD_OBJ_ID = o.id 
      and pd.N=1
      and
          ii.OBJ_PAR_ID = "�� �����������"
      and ii.MOD_OBJ_ID = o.id 
      and ii.N = VIEW_ID
      and
          la.OBJ_PAR_ID = "HP_Image_layer"
      and la.MOD_OBJ_ID = o.id 
      and la.S = LAYER
      order by name
*/                 
            
)
loop  
    pipe row(rec);
 end loop;        
end;
-------------------------------------------------------------------------------- 

-- ��������� �������� �������, 
-- ����������� � �������� �������������� �������,
-- � �����������, ���������� ��� ���������� �������.
-- ���� ������������� �� �����, �� ������ ������� ���� ������
FUNCTION get_EquipmentOfSystem(SYSID NUMBER, LengthParamName varchar2) return TJ_TABLE pipelined
is
begin
for rec in
(
select 
cid id,
--nvl(TMPAR(CID,'�').Val.N, RowNum) 
TMPAR(CID,'�').Val.N "�����_����������", 
'' "�������",
cname "�����",
DEVICE1 "������", 
'' "������_��������", 
DEVICE2 "����", 
'' "����_��������",
GETMPAR_S(CID,'���') "���������_�����",
GETMPAR_S(CID,'����� ��� � �������') "�����_���_�_�������",
GETMPAR_N(CID,'����������') "����������",
to_.STR(TMPAR(CID,'����� ����').Val)  "�����_����",

-- ����� ������, ����������� ��� ����� ���� ��������
--GETMPAR_N(CID,'�����') "�����", 
-- ����� ������, ����������� �������� E3
--CEIL(nvl(TMPAR(CID,'HP_Cable_length').Val.N,0)) "�����", 

-- ����� ������, ���������� �� ��������� :LengthParamName
CEIL(nvl(TMPAR(CID, LengthParamName).Val.N,0)) "�����", 

GETMPAR_N(CID,'�����������') "�����������",
GETMPAR_N(CID,'������') "������",
GETMPAR_N(CID,'�������') "�������",
GETMPAR_N(CID,'��������') "��������",
GETMPAR_N(CID,'����������') "����������",
GETMPAR_N(CID,'��������') "��������",
GETMPAR_N(CID,'�����������������5�') "�����������������5�",
GETMPAR_N(CID,'������������5�') "������������5�",
GETMPAR_N(CID,'�������������5�') "�������������5�",
GETMPAR_N(CID,'��������������5�') "��������������5�",
GETMPAR_N(CID,'����������������5�') "����������������5�",
GETMPAR_N(CID,'��������������5�') "��������������5�",
GETMPAR_N(CID,'�������') "�������",
GETMPAR_N(CID,'����������') "����������",
GETMPAR_N(CID,'������') "������"
from SP.TJ_CABLES 
where 
-- ���� ���������� ��� �������
 1 =
  CASE
   WHEN SYSID is null THEN 1
   ELSE  0
  END 
or 
-- ���� ������ ���������� �������
 SYSTEMID = SYSID 
ORDER BY "�����_����������"
)
loop  
    pipe row(rec);
 end loop;  
 exception
 when OTHERS then 
  d('������ '||SQLERRM||
      'Error SP.TJ_MANAGEMENT.get_EquipmentOfSystem');
    raise;     
end;

-------------------------------------------------------------------------------- 
-- ��������� �������� �������, ����������� � ����� �� �������� ������ 
-- �������������� ������ ��������� � ��������� selectedSystemIds
FUNCTION get_EquipmentOfSystemArray(LengthParamName varchar2) return TJ_TABLE pipelined
is 
begin
if selectedSystemIds.First is null then
  for rec in
  (
   select * from table(get_EquipmentOfSystem(null, LengthParamName))
  )
  LOOP
   pipe row(rec);
  END LOOP; 
else
for indx in selectedSystemIds.FIRST .. selectedSystemIds.LAST
loop 
  for rec in
  (
   select * from table(get_EquipmentOfSystem(selectedSystemIds(indx), LengthParamName))
  )
  LOOP
   pipe row(rec);
  END LOOP;
end loop;  
end if; 
 exception
 when OTHERS then 
  d('������ '||SQLERRM||'Error SP.TJ_MANAGEMENT.get_EquipmentOfSystemArray');
  raise;     
end;

-------------------------------------------------------------------------------- 
--�������� ������� ���� ����� ������� ModelObjectPID$, ���������� ���������� 
--DELETED. ���� ������� �������� ���������� �������-������� �� ������, 
--�� �������� �� ���� � ��� � ���������� ������ ������.
--���������� ���������� ����������� ��������.
Function TryDeleteDeletedObjects(ModelObjectPID$ In Number) 
Return BINARY_INTEGER
Is
  rv# BINARY_INTEGER;  
Begin
  rv#:=0;
  for r In (
    SELECT mo.ID As MOD_OBJ_ID, mo.MOD_OBJ_NAME 
    FROM SP.MODEL_OBJECTS mo
    WHERE mo.PARENT_MOD_OBJ_ID=ModelObjectPID$
    AND EXISTS (SELECT * FROM SP.MODEL_OBJECT_PAR_S mop
                WHERE mop.MOD_OBJ_ID=mo.ID
                AND mop.NAME='DELETED'
                AND mop.N=1
                AND mop.TYPE_ID=5 --Boolean
                )
  )Loop
    Begin
      
      DELETE FROM SP.MODEL_OBJECTS
      WHERE ID=r.MOD_OBJ_ID;
      
    Exception When OTHERS Then
      rv#:=rv#+1;
      D('������ �������� ������� ['||r.MOD_OBJ_NAME||'], ID='
      ||to_char(r.MOD_OBJ_ID)||': '||CHR(13)||CHR(10)||SQLERRM
      ,'ERROR In SP.TJ_MANAGEMENT.TryDeleteDeletedObjects');
    
    End;
  End Loop;
  
  Return rv#;
End TryDeleteDeletedObjects;
--==============================================================================


-- ��������� ��� �������
FUNCTION get_CableTrack(SYSID in NUMBER) return TJ_TABLE pipelined
is
rec TJ_REC;
begin
 pipe row(rec);
end;
 
BEGIN
 null;
END TJ_MANAGEMENT;

