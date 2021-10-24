CREATE OR REPLACE PACKAGE BODY SP.E3C
as
-- Работа с каталогом Zuken e3.Series
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2018-03-19
-- update 2018-03-21 2019-02-01 2019-03-13 2019-04-03 2021-02-12:2021-02-17
--        2021-04-20

TYPE T_STR_IDX Is TABLE OF Varchar2(128) INDEX BY Varchar2(128);
TYPE T_REF_CURSOR Is REF CURSOR;


NO_NAME# VARCHAR2(20):='Без имени';
NO_NAME_ID# VARCHAR(64);

--Индекс, позволяющий быстро находить имя класса по его OID;
OID2CLASS_IDX# T_STR_IDX;
--==============================================================================
--возвращает имя Link'а к БД Zuken e3.series
Function GetE3C_LINK Return Varchar2
Is
Begin
    return E3C_LINK;
End GetE3C_LINK;
--==============================================================================
--Из строки создает 40-символьную строку, используя алгоритм перемешивания SHA1
--
--Тупо содрано из 
-- https://stackoverflow.com/questions/
--                  1749753/making-a-sha1-hash-of-a-row-in-oracle
FUNCTION SHA1(STRING_TO_ENCRIPT VARCHAR2) RETURN VARCHAR2 
AS 
BEGIN 
RETURN LOWER(TO_CHAR(RAWTOHEX(SYS.DBMS_CRYPTO.HASH
    (UTL_RAW.CAST_TO_RAW(STRING_TO_ENCRIPT), SYS.DBMS_CRYPTO.HASH_SH1)
    )));
END SHA1;
--==============================================================================
--Из строки создает 32-символьную строку, используя алгоритм перемешивания MD5
--
--Тупо содрано из 
-- https://stackoverflow.com/questions/
--                  1749753/making-a-sha1-hash-of-a-row-in-oracle
FUNCTION MD5(STRING_TO_ENCRIPT VARCHAR2) RETURN VARCHAR2 
AS 
BEGIN 
RETURN LOWER(TO_CHAR(RAWTOHEX(SYS.DBMS_CRYPTO.HASH
    (UTL_RAW.CAST_TO_RAW(STRING_TO_ENCRIPT), SYS.DBMS_CRYPTO.HASH_MD5)
    )));
END MD5;
--==============================================================================
--Cоздает индекс OID по строке, используя алгоритм перемешивания SHA1
FUNCTION Str2OID(STRING_TO_ENCRIPT VARCHAR2) RETURN VARCHAR2 
AS 
BEGIN 
    If STRING_TO_ENCRIPT Is Null Then
        RETURN NO_NAME_ID#;
    Else
        RETURN SHA1(STRING_TO_ENCRIPT);
    End If;
END Str2OID;
--==============================================================================
--Возвращает набор всех классов каталога Zuken e3.series 
Function GetCatalogClasses Return  SP.G.TOBJECTS
Is
rv SP.G.TOBJECTS;
tp SP.G.TMACRO_PARS;
i Binary_integer;
idx Varchar2(128);
Begin
        
    i:=1;
    idx:=OID2CLASS_IDX#.First;
    Loop
      Exit When idx Is Null;
      tp('OID'):=SP.TVALUE(SP.G.TOID,idx);
      If idx=NO_NAME_ID# Then
         tp('NAME'):=S_(NO_NAME#);
      Else
         tp('NAME'):=S_(OID2CLASS_IDX#(idx));
      End If;
      tp('PARENT'):=S_('/');
      tp('IS_SYSTEM'):=B_(true);
      tp('IS_TINY'):=B_(false);
      tp('SP3DTYPE'):=SP.TVALUE(SP.G.TITYPE,'E3_SYSTEM');
      rv(i):=tp;
      idx:=OID2CLASS_IDX#.Next(idx);
      i:=i+1;
      
    End Loop;
    
    Return rv;
End GetCatalogClasses;
--==============================================================================
--Добавление атрибутов к параметрам объекта каталога
Procedure AddComponentAttributes(DeviceName$ In Varchar2,
pars$ In Out SP.G.TMACRO_PARS)
As
cv T_REF_CURSOR;
cv1 T_REF_CURSOR;
LastVersion# Varchar2(20);
AttrName# Varchar2(128);
Copy# Number;
AttrVal# Varchar2(4000);
Begin
    Open cv For
    'SELECT MAX(VERSION) as LAST_VERSION , "AttributeName" '||
    'FROM '||E3C_SCHEMA||'."ComponentAttribute"@'||E3C_LINK||
    ' WHERE ENTRY=:DeviceName$ '||
    ' GROUP BY ENTRY, "AttributeName" '
    USING DeviceName$
    ;
    Loop
      Fetch cv Into LastVersion#, AttrName#  ;
      
      Exit When cv%NOTFOUND;

        Open cv1 For
        'SELECT "Copy", "AttributeValue" '||
        'FROM '||E3C_SCHEMA||'."ComponentAttribute"@'||E3C_LINK||
        ' WHERE ENTRY=:DeviceName$ '||
        ' AND "AttributeName"=:AttrName# '||
        ' AND VERSION=:LastVersion# '
        USING DeviceName$, AttrName#, LastVersion#
        ;
        Loop 
            Fetch cv1 Into Copy#, AttrVal#;
            Exit When cv1%NOTFOUND;
            If Copy#>1 Then
              pars$(AttrName#||'#'||to_char(Copy#)):=S_(AttrVal#);
            Else
              pars$(AttrName#):=S_(AttrVal#);
            End If;
        End Loop;
        Close cv1;
    End Loop;
    Close cv;
End AddComponentAttributes;
--==============================================================================
--Возвращает объект каталога по его OID
Function GetCatalogObject(OID$ In Varchar2) Return SP.G.TMACRO_PARS
Is
rv SP.G.TMACRO_PARS ;
cv T_REF_CURSOR;
Name# SP.V_MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
Version# Varchar2(10);
DeviceLetterCode# Varchar2(10);
Class# Varchar2(4000);
Description# Varchar2(4000);
LPNTR# Varchar2(4000);
VStatus# Varchar2(10);
VersionText# Varchar2(4000);
MPNTR# Varchar2(4000);
ArticleNumber# Varchar2(4000);
Supplier# Varchar2(4000);
vN# Number;
Begin
  Open cv For
  'SELECT ENTRY, VERSION, "DeviceLetterCode", "Class", "Description", LPNTR '||
  ' ,VSTATUS, "VersionText", MPNTR, "ArticleNumber", "Supplier" '|| 
  ' FROM '||E3C_SCHEMA||'."ComponentData"@'||E3C_LINK||
  ' WHERE ID=:OID$ '
  USING OID$
  ;
  Loop
    Fetch cv Into Name#, Version#, DeviceLetterCode#,Class#,Description#,LPNTR#
    ,VStatus#,VersionText#,MPNTR#,ArticleNumber#,Supplier#
    ;
    
     
    rv('OID'):=SP.TVALUE(SP.G.TOID,OID$);
    rv('NAME'):=S_(Name#);
    
    If Class# Is Null Then
        Class#:=NO_NAME#;
    End If;
    rv('PARENT'):=S_('/'||Class#||'/');
    rv('IS_SYSTEM'):=B_(true);
    rv('IS_TINY'):=B_(false);
    rv('SP3DTYPE'):=SP.TVALUE(SP.G.TITYPE,'E3_SYSTEM');
    rv('POID'):=SP.TVALUE(SP.G.TOID,SP.E3C.Str2OID(Class#));
    
    If DeviceLetterCode# Is Not Null Then
      rv('DeviceLetterCode'):=S_(DeviceLetterCode#);
    End If;
    
    If Description# Is Not Null Then
      rv('Description'):=S_(Description#);
    End If;
    
    If LPNTR# Is Not Null Then
      rv('LPNTR'):=S_(LPNTR#);
    End If;
    
    If VStatus# Is Not Null Then
      rv('VStatus'):=S_(VStatus#);
    End If;
    
    If VersionText# Is Not Null Then
      rv('VersionText'):=S_(VersionText#);
    End If;
    
    If MPNTR# Is Not Null Then
      rv('MPNTR'):=S_(MPNTR#);
    End If;
    
    If ArticleNumber# Is Not Null Then
      rv('ArticleNumber'):=S_(ArticleNumber#);
    End If;
    
    If Supplier# Is Not Null Then
      rv('Supplier'):=S_(Supplier#);
    End If;
    
    If IsCable(LPNTR$=>LPNTR#) Then
      EXECUTE IMMEDIATE
      'SELECT "OuterDia" '||
      ' FROM '||E3C_SCHEMA||'."Cable"@'||E3C_LINK||
      ' WHERE ENTRY=:LPNTR# '||
      ' AND ParentID=0 '
      INTO vN#  USING LPNTR#
      ; 
      rv('OuterDiameter'):=N_(vN#);
    End If;
    
    Exit When True; 
  End Loop;
  Close cv;
  --добавляем атрибуты
  AddComponentAttributes(Name#, rv);
  Return rv;
End;
--==============================================================================
--Возвращает все объекты каталога, принадлежащие данному классу
Function GetCatalogObjects(ClassName$ In Varchar2) Return SP.G.TOBJECTS
Is
rv SP.G.TOBJECTS;
cv T_REF_CURSOR;
OID# Varchar2(128);
i binary_integer;
Begin
Open cv For
  'SELECT ID '||
  ' FROM '||E3C_SCHEMA||'."ComponentData"@'||E3C_LINK||
  ' WHERE "Class"=:ClassName$ '
  USING ClassName$
  ;
  i:=1;
  Loop
    Fetch cv Into OID#;  
    
    Exit When cv%NOTFOUND;
 
    rv(i):=GetCatalogObject(OID#);
    
    i:=i+1;
  End Loop;
  Close cv;
  Return rv;
End GetCatalogObjects;
--==============================================================================
-- Определяет, содержится ли выражение LPNTR$ в поле cable.Entry  
Function IsCable(LPNTR$ In Varchar2) Return Boolean
Is
    cv T_REF_CURSOR;
    rv Boolean;
    Copy# Number;
Begin

  Open cv For
  'SELECT COPY '||
  ' FROM '||E3C_SCHEMA||'."Cable"@'||E3C_LINK||
  ' WHERE ENTRY=:LPNTR$ '
  USING LPNTR$
  ;

  FETCH cv Into Copy#;
  
  rv:= not cv%NOTFOUND; 
  
  Close cv;

  Return rv;
End;
--==============================================================================
-- Определяет, содержится ли LPNTR, соответствующее COMPONENT_OID$  
--в поле cable.Entry  
Function IsCable(COMPONENT_OID$ In Varchar2) Return Boolean
Is
  LPNTR# Varchar2(128);
Begin
  
  EXECUTE IMMEDIATE
  'SELECT LPNTR '||
  ' FROM '||E3C_SCHEMA||'."ComponentData"@'||E3C_LINK||
  ' WHERE ID=:COMPONENT_OID$ '
  INTO LPNTR#  USING COMPONENT_OID$
  ; 

  return IsCable(LPNTR$ => LPNTR#);
  
Exception When No_Data_Found Then
  return false;
End;
--==============================================================================
--Возвращает информацию о проводах и пучках
Function GetWiresAndBundles(LPNTR$ In Varchar2) Return SP.G.TOBJECTS
Is
cv2 T_REF_CURSOR;
tp SP.G.TMACRO_PARS;
rv SP.G.TOBJECTS;
i binary_integer;
COPY# Number;
ParentID# Number;
BundleID# Number;
Name# Varchar2(128);
CrossSection# Number;
Color# Number;
BundCopy_idx T_STR_IDX;
Begin
  Open cv2 For
  ' SELECT COPY, "BundleID", "ParentID", "Name", "CrossSection", "Color" '||
  ' FROM '||E3C_SCHEMA||'."Cable"@'||E3C_LINK||
  ' WHERE ENTRY=:LPNTR$ '||
  ' AND "ParentID" <> 0 '||
  ' ORDER BY COPY '
  USING LPNTR$
  ;
  i:=1;
  Loop
    Fetch cv2 Into COPY#, BundleID#,ParentID#,Name#,CrossSection#,Color#;  
    
    Exit When cv2%NOTFOUND;
 
    If BundleID# <> 0 Then
      BundCopy_idx(to_char(BundleID#)):=to_char(COPY#);
    End If;
 
    tp.Delete();
    tp('OID'):=SP.TVALUE(SP.G.TOID,SHA1(LPNTR$||COPY#));
    tp('NAME'):=S_(Name#);
    If ParentID# > 1 Then
      tp('POID'):=SP.TVALUE
                (SP.G.TOID,SHA1(LPNTR$||BundCopy_idx(to_char(ParentID#))));
    End If;
    
    If BundleID#=0 Then  --провод

      tp('IsWire'):=B_(true);
      
      If CrossSection#>0 Then
        tp('CrossSection'):=N_(CrossSection#);
      End If;
      
      If Color#>0 Then
        tp('Color'):=N_(Color#);
      End If;
    Else
      tp('IsWire'):=B_(false);
    End If;
    
    rv(i):=tp;
    i:=i+1;
  End Loop;
  
  Close cv2;
  return rv;
End GetWiresAndBundles;
--==============================================================================
--Возвращает информацию о проводах и пучках
--Имеются параметры NAME, OID и POID. 
Function GetWiresAndBundles(COMPONENT_OID$ In Varchar2) Return SP.G.TOBJECTS
Is
  LPNTR# Varchar2(128);
  rv SP.G.TOBJECTS;
  i binary_integer;
Begin
  
  EXECUTE IMMEDIATE
  'SELECT LPNTR '||
  ' FROM '||E3C_SCHEMA||'."ComponentData"@'||E3C_LINK||
  ' WHERE ID=:COMPONENT_OID$ '
  INTO LPNTR#  USING COMPONENT_OID$
  ; 

  rv:= GetWiresAndBundles(LPNTR$ => LPNTR#);
  
  If rv Is Null Then Return rv; End If;
  
  If rv.Count<1 Then Return rv; End If;
  
  i:=rv.First;
  While i Is Not Null 
  Loop
    If Not rv(i).Exists('POID') Then
      rv(i)('POID'):=SP.TVALUE(SP.G.TOID,COMPONENT_OID$);
    End If;
    i:=rv.Next(i);
  End Loop;
  return rv;
Exception When No_Data_Found Then
  return rv;
End GetWiresAndBundles;
--==============================================================================
--заполнение индекса OID2CLASS_IDX
Procedure Fill_OID2CLASS_IDX
As
cv T_REF_CURSOR;
ClsName# Varchar2(128);
ClsID# Varchar2(128);
Begin
    Open cv For
     'SELECT DISTINCT "Class" '||
     ' ,SP.E3C.Str2OID("Class") as OID '||
     'FROM '||E3C_SCHEMA||'."ComponentData"@'||E3C_LINK
;    
    Loop
        Fetch cv Into ClsName#, ClsID#;
        Exit When cv%NOTFOUND;
        OID2CLASS_IDX#(ClsID#):=ClsName#;  
    End Loop;
    Close cv;
End;
--==============================================================================
--Параметр в строку
Function Par2StrDEBUG(ParID$ In Number) Return Varchar2
As
  rv# Varchar2(4000);
  r# SP.MODEL_OBJECT_PAR_S%ROWTYPE;
Begin
  Select * Into r# From SP.MODEL_OBJECT_PAR_S Where ID=ParID$;
  rv#:='ID => '||to_char(r#.ID)||chr(10)
  ||'NAME => '|| r#.NAME ||chr(10)
  ||'TYPE_ID => '|| to_char(r#.TYPE_ID) ||chr(10)
  ||'E_VAL => '|| r#.E_VAL ||chr(10)
  ||'N => '|| to_char(r#.N) ||chr(10)
  ||'S => '|| Substr(r#.S,1,3000) ||chr(10)
  ||'X => '|| to_char(r#.X) ||chr(10)
  ||'Y => '|| to_char(r#.Y) ||chr(10)  
  ;
  Return rv#;
  Exception When NO_DATA_FOUND Then
  rv#:='No parameter Found for SP.MODEL_OBJECT_PAR_S.ID = '
  ||to_char(ParID$)||'.';
  Return rv#;
End Par2StrDEBUG;

--==============================================================================
--Для всех потомков объекта ROOT_MOD_OBJ_ID
--ищет все параметры, последнее изменение которых было позже даты ModDate$
FUNCTION GetModifiedPars(
ROOT_MOD_OBJ_ID$ In Number  --корень поддерева объектов
, ModDate$ In DATE  --дата, после которой параметры были изменены
) 
return SP.E3C.T_MODEL_OBJECT_PAR_S pipelined
is
--p SP.MODEL_OBJECT_PAR_S%ROWTYPE;
Begin
--иерархический запрос параметров объектов, 
--расположенных строго ниже ROOT_MOD_OBJ_ID$
    For p In (
    Select  ps.* 
    From SP.V_MODEL_OBJECTS mo 
    Inner Join SP.MODEL_OBJECT_PAR_S ps
    On ps.MOD_OBJ_ID=mo.ID
    And ps.M_DATE>ModDate$
    Start With mo.PARENT_MOD_OBJ_ID=ROOT_MOD_OBJ_ID$
    Connect By Prior mo.ID=mo.PARENT_MOD_OBJ_ID 
    ORDER BY ps.MOD_OBJ_ID
    )Loop
        pipe row(p);
    End Loop;
End GetModifiedPars;

--==============================================================================
--В объект с номером ObjNum$ из ассоциативной коллекции объектов ObjSet$ 
--добавляет параметр OID объекта модели по его ModObjID$
Procedure AddOIDToObjSet(
ModObjID$ Number  --ID объекта модели
, ObjSet$ In Out SP.G.TOBJECTS  --коллекция объектов, упорядоченная по номерам
, ObjNum$ Binary_Integer  --номер объекта в коллекции
)
As
OID# SP.MODEL_OBJECTS.OID%TYPE;
Begin
  Select OID Into OID#
  From SP.MODEL_OBJECTS
  Where ID=ModObjID$
  ;
  
  ObjSet$(ObjNum$)('OID'):=SP.TVALUE(SP.G.TOID,OID#);  
End AddOIDToObjSet;
--==============================================================================
--устаревшая версия (новую версию см. ниже).
--Для всех потомков объекта ROOT_MOD_OBJ_ID
--ищет все параметры, последнее изменение которых было позже даты ModDate$
--
--данная функция употребляется для внесения изменений (дельты) из модели TJ
--в проект Zuken e3.Series
FUNCTION GetModifiedObjectPars(
ROOT_MOD_OBJ_ID$ In Number  --корень поддерева объектов
, ModDate$ In DATE  --дата, после которой параметры были изменены
) 
return SP.G.TOBJECTS
is
--p# SP.MODEL_OBJECT_PAR_S%ROWTYPE;
OldModObjID# Number;
ObjNum# Binary_integer;
rv# SP.G.TOBJECTS;
Begin
  ObjNum#:=-1;
--иерархический запрос параметров объектов, 
--расположенных строго ниже ROOT_MOD_OBJ_ID$
  For p In (
    Select  ps.* 
    From SP.MODEL_OBJECTS mo 
    Inner Join SP.V_MODEL_OBJECT_PARS ps
    On ps.MOD_OBJ_ID=mo.ID
    And ps.M_DATE>ModDate$
    Start With mo.PARENT_MOD_OBJ_ID=ROOT_MOD_OBJ_ID$
    Connect By Prior mo.ID=mo.PARENT_MOD_OBJ_ID 
    ORDER BY ps.MOD_OBJ_ID
  )Loop
    If OldModObjId# Is Null Then
      ObjNum#:=ObjNum#+1;
      OldModObjId#:=p.MOD_OBJ_ID;
    ElsIf OldModObjId#<>p.MOD_OBJ_ID Then
      -- Запрашиваем и вставляем параметр OID
      AddOIDToObjSet(OldModObjId#,rv#,ObjNum#);
--      D('ObjNum='||ObjNum#||', ObjId ='||OldModObjId#
--      ,'SP.E3C.GetModifiedObjectPars DEBUG');
      OldModObjId#:=p.MOD_OBJ_ID;
      ObjNum#:=ObjNum#+1;
    Else
      null;
    End If;
    If Not p.PARAM_NAME Is Null Then
      rv#(ObjNum#)(p.PARAM_NAME):=SP.TValue(ValueType=>p.TYPE_ID,
                            E=>p.E_VAL,
                            N=>p.N,
                            D=>p.D,
                            DisN=> 0,
                            S=>p.S,
                            X=>p.X,
                            Y=>p.Y);
    End If;
  End Loop;

  If Not OldModObjId# Is Null Then
    -- Маловероятно, что этот параметр OID был изменён, но он необходим всегда,
    -- поэтому запрашиваем его всегда и вставляем  
    AddOIDToObjSet(OldModObjId#,rv#,ObjNum#);
--      D('ObjNum='||ObjNum#||', ObjId ='||OldModObjId#
--      ,'SP.E3C.GetModifiedObjectPars DEBUG');
  End If;
  
  Return rv#;
End GetModifiedObjectPars;
--==============================================================================
-- Ищет все параметры, кроме встроенных, Rel и SymRel, 
-- последнее изменение которых было позже даты ModDate$
Function GetObjParamVals(ModObjID$ In Number, ModDate$ In DATE) 
Return SP.MO.TPars Pipelined
Is
  rv# SP.MO.TParRec;
Begin
  For r1 in 
    (SELECT mp.type_id, mp.e_val, mp.n, mp.d, 0, mp.s, mp.x, mp.y, mp.NAME
      FROM SP.MODEL_OBJECT_PAR_S mp
     WHERE mp.name IS NOT NULL     
       AND mp.MOD_OBJ_ID = ModObjID$
       AND mp.type_id NOT IN(SP.G.TBeep,SP.G.TRel, SP.G.TSymRel)
       AND mp.M_DATE>ModDate$
       
      UNION
      
     SELECT mp.type_id, mp.e_val, mp.n, mp.d, 0, mp.s, mp.x, mp.y, op.NAME
      FROM SP.MODEL_OBJECT_PAR_S mp, sp.object_par_s op
     WHERE mp.NAME IS NULL
       AND mp.obj_par_id = op.id
       AND mp.MOD_OBJ_ID = ModObjID$
       AND mp.type_id NOT IN(SP.G.TBeep,SP.G.TRel, SP.G.TSymRel)           
       AND mp.M_DATE>ModDate$
    )Loop
    
    rv#.VAL:=sp.tvalue(r1.type_id, r1.e_val, r1.n, r1.d, 0, r1.s, r1.x, r1.y);
    rv#.NAME :=r1.NAME;
    pipe row (rv#);
  End Loop;
End GetObjParamVals;
--==============================================================================
--Для всех потомков объекта ROOT_MOD_OBJ_ID
--ищет все параметры, последнее изменение которых было позже даты ModDate$
--
--данная функция употребляется для внесения изменений (дельты) из модели TJ
--в проект Zuken e3.Series
FUNCTION GetModifiedObjectPars(
ROOT_MOD_OBJ_ID$ In Number  --корень поддерева объектов
, ModDate$ In DATE  --дата, после которой параметры были изменены
, ObjectID$ In Number -- ID объекта каталога, для которого запрашиваются параметры
) 
return SP.G.TOBJECTS
is
ObjNum# Binary_integer;
rv# SP.G.TOBJECTS;
Begin
  ObjNum#:=0;
--иерархический запрос параметров объектов, 
--расположенных строго ниже ROOT_MOD_OBJ_ID$
  For p1 In (
      -- запрос всех объектов модели типа ObjectID$, потомков ROOT_MOD_OBJ_ID$
      Select *
      From SP.MODEL_OBJECTS mo 
      Where mo.OBJ_ID = ObjectID$
      Start With mo.PARENT_MOD_OBJ_ID = ROOT_MOD_OBJ_ID$
      Connect By Prior mo.ID = mo.PARENT_MOD_OBJ_ID
      Order by mo.ID
    )Loop
      ObjNum#:=ObjNum#+1;
      For p In( 
        Select ps.* From Table
        (SP.E3C.GetObjParamVals(ModObjID$ => p1.ID, ModDate$ => ModDate$)) ps
      )Loop
        If Not p.NAME Is Null Then
          rv#(ObjNum#)(p.NAME):=p.VAL;
      End If;
    End Loop;
    -- Запрашиваем и вставляем параметр OID 
    AddOIDToObjSet(p1.ID,rv#,ObjNum#);
  End Loop;
  Return rv#;
End GetModifiedObjectPars;
--==============================================================================
--
-- Процедура устарела, ничего не делает и непосредственного отношения к 
-- пакету E3 не имеет.
Procedure UpdateStartComositRef(From$ In Varchar2, To$ In Varchar2)
As
Begin
null;
End UpdateStartComositRef;

--==============================================================================
-- Для работы WorkID$ возвращает дату последней синхронизации из TJ в проект 
-- Zuken e3.series.
-- Если WorkID$ не есть ID работы, то исключение.
-- Усли у работы отсутвует параметр "SYNC_DATE_FROM_TJ_TO_E3", то создаёт
-- его со значением 2000-01-01 и возвращает его значение.
Function GetSyncDateFromTJ2E3(WorkID$ In Number) Return Date
Is
  rv# Date;
  P# SP.G.TMACRO_PARS;
  EM# Varchar2(4000); 
  WorkObjectID# Number;
  id# Number;
Begin

  SP.TJ_WORK.SetCurWork(WorkID$ => WorkID$);
  Begin
    SELECT D Into rv#      
    FROM SP.V_MODEL_OBJECT_PARS     
    WHERE MOD_OBJ_ID=WorkID$             
    AND PARAM_NAME='SYNC_DATE_FROM_TJ_TO_E3';
                                            
  Exception When NO_DATA_FOUND Then    
    WorkObjectID#:=SP.TJ_WORK.GetObjectID(SP.TJ_WORK.SINAME_WORK);
    rv#:=to_date('2000-01-01','yyyy-mm-dd');
    P#('ID'):= ID_(WorkID$);
    P#('SYNC_DATE_FROM_TJ_TO_E3'):=D_(rv#);
    EM#:=SP.M.TEST_PARAMS(P#, WorkObjectID#);
    if EM# is not null then 
      D(EM#, 'ERROR In SP.E3#TJ.GetOrCreateObject');
      raise_application_error(-20033, EM#);    
    end if;                      
    id# := SP.MO.MERGE_OBJECT(ModelObject => P#, CatalogID => WorkObjectID#);    
    
  End;
  Return rv#;
End GetSyncDateFromTJ2E3;
--==============================================================================
--приостанавливает процесс на сек.
Procedure sleep(sec$ In Number )
As
Begin
    sys.DBMS_LOCK.sleep(sec$);     
End;

BEGIN
  E3C_SCHEMA:='E3_ROSTOV'; 
  NO_NAME_ID#:=SHA1(NO_NAME#);

  begin
    SELECT DB_LINK INTO E3C_LINK FROM ALL_DB_LINKS
    WHERE OWNER='PUBLIC'
    AND (DB_LINK = 'E3ORA' OR DB_LINK LIKE 'E3ORA.%')
    ;
  Exception When NO_DATA_FOUND Then
    d('DB Link E3ORA не найден.','Error In E3C.Init');
    RAISE_Application_Error(-20343, 'DB Link E3ORA не найден.');
  When TOO_MANY_ROWS Then
    d('Невозможно однозначно идентифицировать DB Link E3ORA.',
    'Error In E3C.Init');
    RAISE_Application_Error(-20343, 
    'Невозможно однозначно идентифицировать DB Link E3ORA.');
  end;
  
  Fill_OID2CLASS_IDX;
  
END E3C;