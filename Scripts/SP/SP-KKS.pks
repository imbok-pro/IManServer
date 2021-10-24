CREATE OR REPLACE PACKAGE SP.KKS
-- Работа с кодами KKS
-- см. документ 
-- TJ.21.KKS-классификация изделий.Рабочие материалы.pdf
-- в папке ...\vm-polinom\Pln\07_IMan\07_Server\E3Server\docs\TJ\
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-09-04
-- update 2019-09-12 2020-12-04 2021-06-22:2021-06-26

AS

--номеру символа KKS кода ставит в соответствие совокупность допустимых
--символов KKS.
Type AA_KKSAllowedSymbols Is Table Of Varchar2(64) Index By BINARY_INTEGER;

--Kоличество символов, отведенных для кода агрегата (номера системы) 
-- в составе KKS 
kks_Agregate_Len CONSTANT BINARY_INTEGER:=2;
--Kоличество символов, отведенных для кода системы в составе KKS 
kks_System_Len  CONSTANT BINARY_INTEGER:=3;
--Kоличество символов, отведенных для номера подсистемы в составе KKS 
kks_SubSystem_Len CONSTANT BINARY_INTEGER:=2;


--Kоличество символов, отведенных для кода устройства в подсистеме в составе KKS 
kks_EqpClass_Len CONSTANT BINARY_INTEGER:=2;
-- Kоличество символов, отведенных для номера устройства в подсистеме 
-- в составе KKS 
kks_EqpNumber_Len CONSTANT BINARY_INTEGER:=3;
-- Kоличество символов, отведенных для дополнительного кода устройства в 
-- подсистеме в составе KKS 
kks_EqpAdd_Len CONSTANT BINARY_INTEGER:=1;


No_KKS CONSTANT Varchar2(20):='BHE KKS';

--Допустимые буквы в KKS: буквы латинского алфавита за исключением O и I
kks_ABC CONSTANT Varchar2(32):='ABCDEFGHJKLMNPQRSTUVWXYZ';

--==============================================================================
--Возвращает строку,в которой запрещённые KKS-символы заключены в {}
Function DetectDeprecatedSymbols(str$ In Out NoCopy Varchar2) Return Varchar2;

--==============================================================================
--Возвращает код агрегата по умолчанию 
Function Get_kks_defa_agregate Return Varchar2;
/*
--Implementation pattern

select SP.KKS.Get_kks_defa_agregate as ttt from dual
;

*/
--==============================================================================
--Возвращает код подсистемы по умолчанию ('00') 
Function Get_kks_defa_subsystem Return Varchar2;
--==============================================================================
--Возвращает значение индекса для неклассифицированных устройств и кабелей
-- '00BHE KKS00' 
Function Get_No_KKS_Idx Return Varchar2;
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
(kks$ In Varchar2, kks_rest$ In Out varchar2) Return Varchar2;

/*
--Implementation pattern

declare
  kks_rest# varchar2(400);
  part1# varchar2(20);
  str_in# varchar2(400);
begin
  str_in# := '==23BJC30';
  part1# := SP.KKS.Get_AgregatePart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

  str_in# := '==3BJC30';
  part1# := SP.KKS.Get_AgregatePart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

  str_in# := '==BJC30';
  part1# := SP.KKS.Get_AgregatePart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

  str_in# := '==';
  part1# := SP.KKS.Get_AgregatePart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

  str_in# := '';
  part1# := SP.KKS.Get_AgregatePart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

end;

*/
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
(kks$ In Varchar2, kks_rest$ In Out varchar2) Return Varchar2;

/*
--Implementation pattern

declare
  kks_rest# varchar2(400);
  part1# varchar2(20);
  str_in# varchar2(400);
begin
  str_in# := '==23BJC30';
  part1# := SP.KKS.Get_SystemPart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

  str_in# := 'BJC30';
  part1# := SP.KKS.Get_SystemPart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

  str_in# := '7JC30';
  part1# := SP.KKS.Get_SystemPart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

  str_in# := 'JC';
  part1# := SP.KKS.Get_SystemPart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

  str_in# := '';
  part1# := SP.KKS.Get_SystemPart(kks$ => str_in#, kks_rest$ => kks_rest#);
  o('str_in ['||str_in#||'], part1 ['||part1#||'], rest1 ['||kks_rest#||']');

end;

*/
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
, kks_system$ In Out Varchar2, kks_subsystem$ In Out varchar2) Return Boolean;

/*
--Implementation pattern

declare
  kks# varchar2(400);
  kks_agregate# varchar2(400);
  kks_system# varchar2(400);
  kks_subsystem# varchar2(400);
  bo# Boolean;
begin
  kks# := '==23BJC30';
  
  bo#:=SP.KKS.SplitKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := 'BJC30';
  bo#:=SP.KKS.SplitKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := 'BJC';
  bo#:=SP.KKS.SplitKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := 'BIC';
  bo#:=SP.KKS.SplitKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := '7JC30';
  bo#:=SP.KKS.SplitKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := '=JC';
  bo#:=SP.KKS.SplitKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := 'JC';
  bo#:=SP.KKS.SplitKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := '';
  bo#:=SP.KKS.SplitKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------
end;

*/
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
, sys_code$ In Out Varchar2, subsys_num$ In Out varchar2) Return Boolean;
/*
--Implementation pattern

declare
  kks# varchar2(400);
  kks_agregate# varchar2(400);
  kks_system# varchar2(400);
  kks_subsystem# varchar2(400);
  bo# Boolean;
begin
  kks# := '==23BJC30';
  
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := 'BJC30';
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := 'BJC';
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := 'BIC';
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := '7JC30';
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := '=JC';
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := 'JC';
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := '';
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------

  kks# := '=30PUL10СL001';
  bo#:=SP.KKS.SplitLongKKS(kks#, kks_agregate#,kks_system#, kks_subsystem#);

  o(SP.TO_.STR(bo#)||': kks ['||kks#||'], agregate ['||kks_agregate#
    ||'], sys ['||kks_system#||'], subsys ['||kks_subsystem#||']');
------------------------------------------------------------


end;

*/

--==============================================================================
--По коду KKS системы, вычсляет значение индекса.
Function GetKKSIndex(kks$ in varchar2) Return varchar2;
--==============================================================================
-- Замена кириллических букв на визуально похожие латинские буквы
 Function Cyr2Lat(str$ varchar2) Return varchar2;
--==============================================================================
--Возвращает допустимые символы для каждой позиции кода KKS формата
-- ЦЦБББЦЦББЦЦЦБ (ex: 00SBB03BR005A) 
Function GetKKSAlowedSysmbols(iBase$ In BINARY_INTEGER) 
Return SP.KKS.AA_KKSAllowedSymbols;
--==============================================================================
End KKS;