CREATE OR REPLACE PACKAGE BODY SP.KKS
AS
-- Работа с кодами KKS 
-- см. документ 
-- TJ.21.KKS-классификация изделий.Рабочие материалы.pdf
-- в папке ...\vm-polinom\Pln\07_IMan\07_Server\E3Server\docs\TJ\
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-09-04
-- update 2019-09-12 2020-12-04 2021-06-22:2021-06-27

kks_defa_agregate SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
kks_defa_subsystem SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
--==============================================================================
--Определяет, является ли входящий символ цифрой
Function IsDigit(v$ in Varchar2) Return Boolean
Is
Begin
    Return v$>='0' And v$<='9';
End;

--==============================================================================
--Возвращает строку,в которой запрещённые KKS-символы заключены в {}
Function DetectDeprecatedSymbols(str$ In Out NoCopy Varchar2) Return Varchar2
Is
  rv# varchar2(4000):=Null;
  i# BINARY_INTEGER;
  ch# Varchar2(1);
Begin

  If LENGTH(str$)<1 Then
    Return rv#;
  End If;
  For i In 1..LENGTH(str$) Loop
    ch#:=SUBSTR(str$,i,1);
    If IsDigit(ch#) Then
      rv#:=rv#||ch#;
    ElsIf INSTR(kks_ABC,ch#)>0 Then
      rv#:=rv#||ch#;
    Else
      rv#:=rv#||'{'||ch#||'}';
    End If;
  End Loop;
  return REPLACE(rv#,'}{','');
End;
--==============================================================================
--Возвращает код агрегата по умолчанию ('00') 
Function Get_kks_defa_agregate Return Varchar2
As
Begin
  If kks_defa_agregate Is Null Then
    kks_defa_agregate := LPAD('0',kks_Agregate_Len,'0');
  End If;
  Return  kks_defa_agregate;
End Get_kks_defa_agregate;
--==============================================================================
--Возвращает код подсистемы по умолчанию ('00') 
Function Get_kks_defa_subsystem Return Varchar2
As
Begin
  If kks_defa_subsystem Is Null Then
    kks_defa_subsystem := LPAD('0',kks_SubSystem_Len,'0');
  End If;
  Return  kks_defa_subsystem;
End Get_kks_defa_subsystem;
--==============================================================================
--Возвращает значение индекса для неклассифицированных устройств и кабелей
-- '00BHE KKS00' 
Function Get_No_KKS_Idx Return Varchar2
As
Begin
  Return  Get_kks_defa_agregate||No_KKS||Get_kks_defa_subsystem;
End Get_No_KKS_Idx;
--==============================================================================
-- Для входной строки kks$ возвращает двухсимвольный код агрегата и 
-- остаток kks_rest$ входной строки, за вычетом кода агрегата по следующим 
-- правилам:
-- 0. Стираем начальные знаки '=', если они есть
-- 1. Если первые kks_Agregate_Len = 2 символов строки kks$ суть цифры 
--    '00BJC30', то отделяем их и возвращаем результат '00' и 
--    остаток kks_rest$='BJC30'.
-- 2. Если в начале строки цифр меньше, чем kks_Agregate_Len символов, то 
--    приписываем к ним слева нужное количество нулей.
--    а. '3BJC30' => результат '03', kks_rest$='BJC30'
--    b. 'BJC30' => результат '00', kks_rest$='BJC30'
Function Get_AgregatePart
(kks$ In Varchar2, kks_rest$ In Out varchar2) Return Varchar2
As
  rv# Varchar2(20);
  pattern# varchar2(40);
Begin
  --стираем начальные знаки =, если они есть
  kks_rest$ := REGEXP_REPLACE(kks$,'^=*','');
  --строка начинается с цифр в количестве ровно kks_Agregate_Len штук
  pattern#:='^\d{'||kks_Agregate_Len||'}';
  If REGEXP_LIKE(kks_rest$,pattern#) Then
    rv#:=SUBSTR(kks_rest$,1,kks_Agregate_Len);
    kks_rest$:=SUBSTR(kks_rest$,kks_Agregate_Len+1);
    Return rv#;
  End If;
  
  While REGEXP_LIKE(kks_rest$,'^\d') Loop
    rv#:=rv#||SUBSTR(kks_rest$,1,1);
    kks_rest$:=SUBSTR(kks_rest$,2);
  End Loop;
  rv#:=LPAD('0'||rv#,kks_Agregate_Len,'0');
  rv#:=SUBSTR(rv#,-kks_Agregate_Len);
  Return rv#;
End Get_AgregatePart;

--==============================================================================
-- Для входной строки kks$ возвращает трёхсимвольный код системы и 
-- остаток kks_rest$ входной строки, за вычетом кода системы по следующим 
-- правилам:
-- 1. Если первые kks_System_Len = 3 символов строки kks$ суть допустимые буквы 
--    'BJC30', то отделяем их и возвращаем результат 'BJC' и 
--    остаток kks_rest$='30'.
-- 2 B противном случае '7JC30' возвращаем результат No_KKS='BHE KKS' и 
--    остаток kks_rest$='7JC30'.
Function Get_SystemPart
(kks$ In Varchar2, kks_rest$ In Out varchar2) Return Varchar2
As
  rv# Varchar2(20);
  pattern# varchar2(64);
Begin
  --Буквы латинского алфавита за исключением O и I, в количестве   
  pattern#:='^['||SP.KKS.kks_ABC||']{'||kks_System_Len||'}';
  If REGEXP_LIKE(kks$,pattern#) Then
    rv#:=SUBSTR(kks$,1,kks_System_Len);
    kks_rest$:=SUBSTR(kks$,kks_System_Len+1);
    Return rv#;
  End If;
  
  kks_rest$:=kks$;
  rv#:=No_KKS;
  Return rv#;
  
End;
--=============================================================================
--Анализирует входную строку и, если она корректная, то разбивает на три части:
-- 1. kks_agregate$ - код агрегата
-- 2. kks_system$ -код системы
-- 3. kks_subsystem$ - код подсистемы
--    так, что при конкатенации этих частей 
--    (kks_agregate$||kks_system$||kks_subsystem$) 
--    получается полный код, 
-- и возвращает истину.
--
-- Корректная входная строка определяется следующим образом:
-- 1. Начинается с нескольких символов '=' или не содержит символов '='
-- 2. далее идут две цифры номера системы (если цифр меньше двух, то 
--    они дополняются нулями слева)
-- 3. далее идут три буквы кода системы
-- 4. далее идут две цифры номера подсистемы (если цифр меньше двух, то 
--    они дополняются нулями справа)
--
--Если входная строка пустая, то возвращает ложь и выходные параметры заполняет
-- следующим образом:
-- kks_agregate$ <- '00'
-- kks_system$ <- SP.KKS.No_KKS
-- kks_subsystem$ <- kks$ 
--
--В остальных случаях возвращает ложь и выходные параметры заполняет следующим 
-- kks_agregate$ <- '00'
-- kks_system$ <- SP.KKS.No_KKS
-- kks_subsystem$ <- kks$ 
Function SplitShortKKS(
kks$ In Varchar2, kks_agregate$ In Out varchar2
, kks_system$ In Out Varchar2, kks_subsystem$ In Out varchar2) Return Boolean
As
  kks_rest1# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  le# BINARY_INTEGER;
  --kks_rest2# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
Begin
  kks_agregate$ := Get_AgregatePart(kks$ =>kks$, kks_rest$ => kks_rest1#);
  kks_system$:= Get_SystemPart(kks$ => kks_rest1#, kks_rest$ =>kks_subsystem$);
  
  If kks_system$ = No_KKS Then
    kks_agregate$:=Get_kks_defa_agregate;
    If kks$ Is Null Then
      kks_subsystem$:=Get_kks_defa_subsystem;
    Else
      kks_subsystem$:=kks$;
    End If;
    Return false;
  End If;
  
  le#:=NVL(LENGTH(kks_subsystem$),0);
  If le#>kks_SubSystem_Len Or Not REGEXP_LIKE(kks_subsystem$,'^\d*$') 
  Then
    kks_agregate$:=Get_kks_defa_agregate;
    kks_system$:=No_KKS;
    kks_subsystem$:=kks$;
    Return false;
  End If;

  If le#<kks_SubSystem_Len Then
    -- ЕСЛИ 
    --    длина строки kks_rest# < kks_SubSystem_Len и она заполнена цифрами
    -- ТО
    --    дополняем нулями справа строку kks_rest#, 
    --    пока длина не станет равной kks_SubSystem_Len
    kks_subsystem$  :=
        SUBSTR(kks_subsystem$||Get_kks_defa_subsystem,1,kks_SubSystem_Len);
  End If;
  
  Return true;
End SplitShortKKS;
--==============================================================================
--Анализирует входную строку kks$ и, если она корректная, 
-- то выделяет из неё три части:
-- 1. sys_num$ - номер системы
-- 2. sys_code$ -код системы
-- 3. subsys_num$ - номер подсистемы
--    так, что при конкатенации этих частей 
--    (sys_num$||sys_code$||subsys_num$) 
--    получается полный код системы, 
-- и возвращает истину.
--
-- Корректная входная строка определяется следующим образом:
-- 1. Начинается с нескольких символов '=' или не содержит символов '='
-- 2. далее идут две цифры номера системы (если цифр меньше двух, то 
--    они дополняются нулями слева)
-- 3. далее идут три буквы кода системы
-- 4. далее идут две цифры номера подсистемы
-- 5. далее может идти буквенно-цифорврой код любой (в том числе нулевой) длины
--
--Если входная строка пустая, то возвращает ложь и выходные параметры заполняет
-- следующим образом:
-- sys_num$ <- '00'
-- sys_code$ <- SP.KKS.No_KKS
-- subsys_num$ <- kks$ 
--
--В остальных случаях для некрорректной строки функция возвращает ложь и 
-- выходные параметры заполняет следующим 
-- sys_num$ <- '00'
-- sys_code$ <- SP.KKS.No_KKS
-- subsys_num$ <- kks$ 
Function SplitLongKKS(
kks$ In Varchar2, sys_num$ In Out varchar2
, sys_code$ In Out Varchar2, subsys_num$ In Out varchar2) Return Boolean
As
  kks_rest# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  le# BINARY_INTEGER;
  pattern# Varchar2(64);
  --kks_rest2# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
Begin
  sys_num$ := Get_AgregatePart(kks$ =>kks$, kks_rest$ => kks_rest#);
  sys_code$:= Get_SystemPart(kks$ => kks_rest#, kks_rest$ =>subsys_num$);
  
  If sys_code$ = No_KKS Then
    sys_num$:=Get_kks_defa_agregate;
    If kks$ Is Null Then
      subsys_num$:=Get_kks_defa_subsystem;
    Else
      subsys_num$:=kks$;
    End If;
    Return false;
  End If;
  
  le#:=NVL(LENGTH(subsys_num$),0);
  If le# <= kks_SubSystem_Len Then
  --короткая строка
    If le# = 0 Or REGEXP_LIKE(subsys_num$,'^\d*$') Then
      -- ЕСЛИ 
      --    длина строки kks_rest# <= kks_SubSystem_Len и она заполнена цифрами
      -- ТО
      --    дополняем нулями справа строку kks_rest#, 
      --    пока длина не станет равной kks_SubSystem_Len
    subsys_num$  :=
        SUBSTR(subsys_num$||Get_kks_defa_subsystem,1,kks_SubSystem_Len);
      Return true;
    Else
      sys_num$:=Get_kks_defa_agregate;
      sys_code$:=No_KKS;
      subsys_num$:=kks$;
      Return false;
    End If;
  End If;
  
  --длинная строка
  kks_rest#:=subsys_num$;
  subsys_num$ := SUBSTR(kks_rest#,1,kks_SubSystem_Len);
  If Not REGEXP_LIKE(subsys_num$,'^\d*$') 
  Then
    sys_num$:=Get_kks_defa_agregate;
    sys_code$:=No_KKS;
    subsys_num$:=kks$;
    Return false;
  End If;
  
  --Далее проверка остатка строки KKS на корректность: точнее, что в остаток
  --строки входят тоько разрешенные символы
  kks_rest#:=SUBSTR(kks_rest#,kks_SubSystem_Len+1);
  --строка разрешенных букв KKS и цифр
  pattern#:='^(\d|['||SP.KKS.kks_ABC||'])*$';
  If Not REGEXP_LIKE(kks_rest#,pattern#) Then
    
    sys_num$:=Get_kks_defa_agregate;
    sys_code$:=No_KKS;
    subsys_num$:=kks$;
    
    D('Агрегатная часть ['||kks_rest#||'] кода ['||kks$
    ||'] содержит недопустимые (возможно кириллические) символы.'
    ,'Warning In SP.KKS.SplitLongKKS');
    
    Return false;
  End If;  

  Return true;
End SplitLongKKS;
--==============================================================================
--По коду KKS системы, вычсляет значение индекса.
Function GetKKSIndex(kks$ in varchar2) Return varchar2
As
  rv# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  sys_num# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  sys_code# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  subsys_num# SP.MODEL_OBJECTS.MOD_OBJ_NAME%TYPE;
  bo# Boolean;
Begin
  bo#:=SplitLongKKS(kks$ => kks$, sys_num$ => sys_num#
        , sys_code$ => sys_code#, subsys_num$ => subsys_num#);

  rv#:= sys_num#||sys_code#||subsys_num#;
  
  Return rv#;
End;
--==============================================================================
-- Замена кириллических букв на визуально похожие латинские буквы
Function Cyr2Lat(str$ varchar2) Return varchar2
As
Begin
  Return translate(str$,
    'АВСЕНКМОРТХасеоху', -- кириллическиe буквы, которые выглядят как латинские
    'ABCEHKMOPTXaceoxy'  -- латинские буквы, которые выглядят как кириллическиe
    );
End;   
--==============================================================================
--Возвращает допустимые символы для каждой позиции кода KKS формата
-- ЦЦБББЦЦББЦЦЦБ (ex: 00SBB03BR005A) 
Function GetKKSAlowedSysmbols(iBase$ In BINARY_INTEGER) 
Return SP.KKS.AA_KKSAllowedSymbols
Is
  rv AA_KKSAllowedSymbols;
  i# BINARY_INTEGER;
  iMax# BINARY_INTEGER;
Begin
  i#:=0;
  iMax#:=kks_Agregate_Len+ kks_System_Len + kks_SubSystem_Len 
        + kks_EqpClass_Len + kks_EqpNumber_Len + kks_EqpAdd_Len;
        
  While (i# < iMax#) Loop
    If i# < kks_Agregate_Len Then
      rv(iBase$+i#):='0123456789';
    Elsif i# < kks_Agregate_Len+kks_System_Len Then
      rv(iBase$+i#):=kks_ABC;
    Elsif i# < kks_Agregate_Len+ kks_System_Len + kks_SubSystem_Len Then
      rv(iBase$+i#):='0123456789';
    Elsif i# < kks_Agregate_Len+ kks_System_Len + kks_SubSystem_Len 
        + kks_EqpClass_Len Then
      rv(iBase$+i#):=kks_ABC;
    Elsif i# < kks_Agregate_Len+ kks_System_Len + kks_SubSystem_Len 
        + kks_EqpClass_Len + kks_EqpNumber_Len Then
      rv(iBase$+i#):='0123456789';
    Else
      rv(iBase$+i#):=kks_ABC;
    End If;  
    i#:=i#+1;
  End Loop;
  Return rv;
End;
--==============================================================================
BEGIN
  null;
END KKS;