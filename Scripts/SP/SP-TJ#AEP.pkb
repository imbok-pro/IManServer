CREATE OR REPLACE PACKAGE BODY SP.TJ#AEP
-- TJ Отчеты по электрической части для АЭП
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
-- Главное предствление кабельного журнала
-- Для работы WorkID$ возвращает таблицу кабельного журнала
-- Замечания:
-- Вместо ID работы может стоять ID любого другого объекта, потомком которого в 
-- иерархии является кабель 

Type AA_Dict_64 Is Table Of Varchar2(64) Index By Varchar2(64);

TwistedCable_AA AA_Dict_64;
EquipmentCable_AA AA_Dict_64;


-- Функция для формирования номера кабеля в кабельном журнале на основе класса безопасности и группы раскладки кабеля
-- Точные указания по формированию шифра кабеля см. в "Общие указания по кабельному хозяйству" (R01.KK34.0.0.ET.PZ.WD001)
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


-- Функция для определения канала безопасности устройства по его KKS коду
-- Канал безопасности равен второй цифре KKS кода, если вторая цифра 0, то канал безопасности оставляем пустым
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


-- Функция для проверки является ли кабель витой парой, если да то возвращаем true, если нет то false
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


-- Функция для составления обозначения сечения кабеля в виде "число жил"х"сечение жилы"
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


-- Функция для транслитерации марки кабеля. Если кабель относится к комплектным вместе с оборудованием,
-- то берется перевод из словаря
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


-- Функция для анализа содержит ли считываемое (с Excel) значение длины кабеля символ примечания '*'
-- Если да, то возвращается истина, длина перезаписывается без '*', а '*' записывается в атрибут кабеля "Примечание" в макре
-- Если нет, то возвращается ложь, длина не изменяется
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


-- Процедура для обновления расчетных атрибутов в модели TJ, выполняется в макре AEP2Access (печать КЖ в Access)
-- Заполняются следующие атрибуты кабелей: номер в кабельном журнале и канал безопасности кабеля
-- Заполняются следующие атрибуты шкафов: канал безопасности шкафа
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
    
    -- Класс безопасности
    rv."CLASS" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Safety_class_of_cable');
    -- Группа раскладки
    rv."GROUP R" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Group_of_laiment');
    -- Номер в кабельном журнале, определяется по "CLASS" и "GROUP"
    rv."CABLE NUMBER" := GetCableNumber(i#, rv."CLASS", rv."GROUP R");
    -- Канал безопасности начала
    rv."FROM SYS" := GetSecurityChannel(rc.FROM_LOCATION_NAME);
    -- Канал безопасности конца
    rv."TO SYS" := GetSecurityChannel(rc.TO_LOCATION_NAME);
    -- Канал безопасности кабеля
    rv."CABLE SYS" := GetSecurityChannel(rc.CABLE_NAME);
    
    P := SP.TMPAR(rc.CABLE_ID, 'HP_Line_marking_in_cable_connections');
    P.VAL := S_(rv."CABLE NUMBER");
    P.SAVE;
    
    if rc.FROM_LOCPROP_ID is NULL then 
      D('Для кабеля ['||rc.CABLE_NAME||'] не определен ID места начала ['||rc.FROM_LOCATION_NAME||
      '] не определен псевдообъект (квадратик).', 'Error SP.TJ#AEP.UPDATE_TJ');
      ierr := ierr + 1;
    else
      P := SP.TMPAR(rc.FROM_LOCPROP_ID, 'AEP_Safety_system_of_board');
      P.VAL := S_(rv."FROM SYS");
      P.SAVE;
    end if;
    
    if rc.TO_LOCPROP_ID is NULL then 
      D('Для кабеля ['||rc.CABLE_NAME||'] не определен ID места конца ['||rc.TO_LOCATION_NAME||
      '] не определен псевдообъект (квадратик).', 'Error SP.TJ#AEP.UPDATE_TJ');
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
    raise_application_error(-20033, 'В процедуре SP.TJ#AEP.UPDATE_TJ обнаружены ошибки проектирования, смотрите DebugLog
    с тэгом "Error SP.TJ#AEP.UPDATE_TJ".');
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
    -- Номер кабельного журнала
    rv."CABLE LOG" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Cable_log');
    -- KKS (маркировка) кабеля
    rv."CABLE MARK" := rc.CABLE_NAME;
    -- Тип (марка) кабеля
    rv."TYPE" := sp.getMPar_S(rc.CABLE_ID, 'HP_Cable_type');
    -- Число жил кабеля
    rv."CORE NUMBER" := sp.getMPar_N(rc.CABLE_ID, 'HP_Number_cable_cores');
    -- Сечение жилы кабеля
    rv."CORE SECTION" := sp.getMPar_N(rc.CABLE_ID, 'HP_Cable_cross_section');
    -- Номинальное напряжение кабеля
    rv."VOLTAGE" := sp.getMPar_N(rc.CABLE_ID, 'HP_Rated_voltage_cable');
    -- Номер технических условий
    rv."TU" := sp.getMPar_S(rc.CABLE_ID, 'AEP_TU');
    -- Класс безопасности
    rv."CLASS" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Safety_class_of_cable');
    -- Группа раскладки
    rv."GROUP R" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Group_of_laiment');
    -- Номер в кабельном журнале, определяется по "CLASS" и "GROUP"
    rv."CABLE NUMBER" := GetCableNumber(i#, rv."CLASS", rv."GROUP R");
    -- Диаметр кабеля
    rv."DIAMETER" := sp.getMPar_N(rc.CABLE_ID, 'HP_Diametr_of_cable');
    -- KKS начала
    rv."FROM KKS" := rc.FROM_LOCATION_NAME;
    -- Координата X начала
    rv."FROM X" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Installation_equipment_on_the_x');
    -- Координата Y начала
    rv."FROM Y" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Installation_equipment_on_the_y');
    -- Координата Z начала
    rv."FROM Z" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Elevation');
    -- Запас на разделку с начала
    rv."FROM LAdd" := sp.getMPar_N(rc.CABLE_ID, 'AEP_From_Ladd');
    -- Канал безопасности начала
    rv."FROM SYS" := GetSecurityChannel(rc.FROM_LOCATION_NAME);
    -- KKS здания начала
    rv."FROM BUILDING" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Building_name');
    -- KKS помещения начала
    rv."FROM ROOM" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Room_number_and_name');
    -- Наименование оборудования начала
    rv."FROM NAME" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Equipment_name');
    -- Наименование оборудования начала по английски
    rv."FROM NAME ENG" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'AEP_Name_of_equipment_eng');
    -- KKS конца
    rv."TO KKS" := rc.TO_LOCATION_NAME;
    -- Координата X конца
    rv."TO X" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Installation_equipment_on_the_x');
    -- Координата Y конца
    rv."TO Y" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Installation_equipment_on_the_y');
    -- Координата Z конца
    rv."TO Z" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Elevation');
    -- Запас на разделку с конца
    rv."TO LAdd" := sp.getMPar_N(rc.CABLE_ID, 'AEP_To_Ladd');
    -- Канал безопасности конца
    rv."TO SYS" := GetSecurityChannel(rc.TO_LOCATION_NAME);
    -- KKS здания конца
    rv."TO BUILDING" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Building_name');
    -- KKS помещения конца
    rv."TO ROOM" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Room_number_and_name');
    -- Наименование оборудования конца
    rv."TO NAME" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Equipment_name');
    -- Наименование оборудования конца по английски
    rv."TO NAME ENG" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'AEP_Name_of_equipment_eng');
    -- Длина кабеля
    rv."LENGTH" := sp.getMPar_N(rc.CABLE_ID, 'HP_Cable_length');
    -- Трасса
    rv."ROUTE" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Route');
    -- Канал безопасности кабеля
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
    -- Номер кабельного журнала
    rv."CABLE LOG" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Cable_log');
    -- KKS (маркировка) кабеля
    rv."CABLE MARK" := REPLACE(rc.CABLE_NAME, '=', '');
    -- Тип (марка) кабеля
    rv."TYPE" := sp.getMPar_S(rc.CABLE_ID, 'HP_Cable_type');
    -- Число жил и сечение кабеля
    rv."CROSS-SECTION" := GetCableCrossSection
      (rv."TYPE", 
       sp.getMPar_N(rc.CABLE_ID, 'HP_Number_cable_cores'),
       sp.getMPar_N(rc.CABLE_ID, 'HP_Cable_cross_section'));
    -- Номинальное напряжение кабеля
    rv."VOLTAGE" := sp.getMPar_N(rc.CABLE_ID, 'HP_Rated_voltage_cable');
    -- Номер технических условий
    rv."TU" := sp.getMPar_S(rc.CABLE_ID, 'AEP_TU');
    -- Класс безопасности
    rv."CLASS" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Safety_class_of_cable');
    -- Группа раскладки
    rv."GROUP R" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Group_of_laiment');
    -- Номер в кабельном журнале, определяется по "CLASS" и "GROUP R"
    rv."CABLE NUMBER" := GetCableNumber(i#, rv."CLASS", rv."GROUP R");
    -- Диаметр кабеля
    rv."DIAMETER" := sp.getMPar_N(rc.CABLE_ID, 'HP_Diametr_of_cable');
    -- KKS начала
    rv."FROM KKS" := REPLACE(rc.FROM_LOCATION_NAME, '+', '');
    -- Координата X начала
    rv."FROM X" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Installation_equipment_on_the_x');
    -- Координата Y начала
    rv."FROM Y" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Installation_equipment_on_the_y');
    -- Координата Z начала
    rv."FROM Z" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Elevation');
    -- Запас на разделку с начала
    rv."FROM LAdd" := sp.getMPar_N(rc.CABLE_ID, 'AEP_From_Ladd');
    -- Канал безопасности начала
    rv."FROM SYS" := GetSecurityChannel(rc.FROM_LOCATION_NAME);
    -- KKS здания начала
    rv."FROM BUILDING" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Building_name');
    -- KKS помещения начала
    rv."FROM ROOM" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Room_number_and_name');
    -- Наименование оборудования начала
    rv."FROM NAME" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Equipment_name');
    -- Наименование оборудования начала по английски
    rv."FROM NAME ENG" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'AEP_Name_of_equipment_eng');
    -- KKS конца
    rv."TO KKS" := REPLACE(rc.TO_LOCATION_NAME, '+', '');
    -- Координата X конца
    rv."TO X" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Installation_equipment_on_the_x');
    -- Координата Y конца
    rv."TO Y" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Installation_equipment_on_the_y');
    -- Координата Z конца
    rv."TO Z" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Elevation');
    -- Запас на разделку с конца
    rv."TO LAdd" := sp.getMPar_N(rc.CABLE_ID, 'AEP_To_Ladd');
    -- Канал безопасности конца
    rv."TO SYS" := GetSecurityChannel(rc.TO_LOCATION_NAME);
    -- KKS здания конца
    rv."TO BUILDING" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Building_name');
    -- KKS помещения конца
    rv."TO ROOM" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Room_number_and_name');
    -- Наименование оборудования конца
    rv."TO NAME" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Equipment_name');
    -- Наименование оборудования конца по английски
    rv."TO NAME ENG" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'AEP_Name_of_equipment_eng');
    -- Длина кабеля
    rv."LENGTH" := sp.getMPar_N(rc.CABLE_ID, 'HP_Cable_length');
    -- Трасса
    rv."ROUTE" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Route');
    -- Канал безопасности кабеля
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
    -- KKS (маркировка) кабеля
    rv."CABLE MARK" := REPLACE(rc.CABLE_NAME, '=', '');
    -- Тип (марка) кабеля
    rv."TYPE" := sp.getMPar_S(rc.CABLE_ID, 'HP_Cable_type');
    -- Тип (марка) кабеля транслитом
    rv."TYPE TRANS" := GetTypeTrans(rv."TYPE");
    -- Число жил и сечение кабеля
    rv."CROSS-SECTION" := GetCableCrossSection
      (rv."TYPE", sp.getMPar_N(rc.CABLE_ID, 'HP_Number_cable_cores'),
       sp.getMPar_N(rc.CABLE_ID, 'HP_Cable_cross_section'));
     -- Группа раскладки
    rv."GROUP R" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Group_of_laiment');
    -- Класс безопасности
    rv."CLASS" := sp.getMPar_S
      (rc.CABLE_ID, 'AEP_Safety_class_of_cable');
    -- Номер в кабельном журнале, определяется по "CLASS" и "GROUP R"
    rv."CABLE NUMBER" := GetCableNumber(i#, rv."CLASS", rv."GROUP R");
    -- KKS начала
    rv."FROM KKS" := REPLACE(rc.FROM_LOCATION_NAME, '+', '');
    -- Координата X начала
    rv."FROM X" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Installation_equipment_on_the_x');
    -- Координата Y начала
    rv."FROM Y" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Installation_equipment_on_the_y');
    -- Координата Z начала
    rv."FROM Z" := sp.getMPar_N(rc.FROM_LOCPROP_ID, 'HP_Elevation');
    -- KKS здания начала
    rv."FROM BUILDING" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Building_name');
    -- KKS помещения начала
    rv."FROM ROOM" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Room_number_and_name');
    -- Наименование оборудования начала
    rv."FROM NAME" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'HP_Equipment_name');
    -- Наименование оборудования начала по английски
    rv."FROM NAME ENG" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'AEP_Name_of_equipment_eng');
    -- KKS конца
    rv."TO KKS" := REPLACE(rc.TO_LOCATION_NAME, '+', '');
    -- Координата X конца
    rv."TO X" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Installation_equipment_on_the_x');
    -- Координата Y конца
    rv."TO Y" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Installation_equipment_on_the_y');
    -- Координата Z конца
    rv."TO Z" := sp.getMPar_N(rc.TO_LOCPROP_ID, 'HP_Elevation');
    -- KKS здания конца
    rv."TO BUILDING" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Building_name');
    -- KKS помещения конца
    rv."TO ROOM" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Room_number_and_name');
    -- Наименование оборудования конца
    rv."TO NAME" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'HP_Equipment_name');
    -- Наименование оборудования конца по английски
    rv."TO NAME ENG" := sp.getMPar_S(rc.TO_LOCPROP_ID, 'AEP_Name_of_equipment_eng');
    -- Длина кабеля
    rv."LENGTH" := sp.getMPar_N(rc.CABLE_ID, 'HP_Cable_length');
    -- Трасса
    rv."ROUTE" := sp.getMPar_S(rc.CABLE_ID, 'AEP_Route');
    -- Имя общего щита
    rv."COMMON BOARD" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'AEP_Name_of_common_board');
    -- Имя общего щита ENG
    rv."COMMON BOARD ENG" := sp.getMPar_S(rc.FROM_LOCPROP_ID, 'AEP_Name_of_common_board_eng');
    -- Примечания
    rv."NOTE" := sp.getMPar_S(rc.CABLE_ID, 'Примечание');
    
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
    -- Тип (марка) кабеля
    rv."TYPE" := rc."TYPE";
    -- Тип (марка) кабеля транслитом
    rv."TYPE TRANS" := GetTypeTrans(rv."TYPE");
    -- Число жил и сечение кабеля
    rv."CROSS-SECTION" := GetCableCrossSection(rv."TYPE", rc."CORE NUMBER", rc."CORE SECTION");
    -- Номинальное напряжение кабеля
    if TRUNC(rc."VOLTAGE") = rc."VOLTAGE" then
      rv."VOLTAGE" := TO_CHAR(rc."VOLTAGE");
    else
      rv."VOLTAGE" := REPLACE(TO_CHAR(rc."VOLTAGE", 'FM0.99'), '.', ',');
    end if;
    -- Суммарная длина кабелей данной марки, сечения и напряжения
    rv."LENGTH" := rc."LENGTH";
    -- Количество кабелей данной марки, сечения и напряжения
    rv."CABLE COUNT" := rc."CABLE COUNT";
    -- Количество кабельных разделок
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
      cj."FROM_LOCPROP_ID" as "ID устройства",
      cj."FROM_LOCATION_NAME" as "KKS устройства",
      sp.getMPar_S(cj.FROM_LOCPROP_ID, 'HP_Room_number_and_name') as "Помещение",
      sp.getMPar_S(cj.FROM_LOCPROP_ID, 'HP_Equipment_name') as "Наименование устройства"
      FROM TABLE(SP.TJ#ELECTRO.V_CAB_JOURNAL(WorkID$)) cj
      UNION ALL
      SELECT 
      cj."TO_LOCPROP_ID" as "ID устройства",
      cj."TO_LOCATION_NAME" as "KKS устройства",
      sp.getMPar_S(cj.TO_LOCPROP_ID, 'HP_Room_number_and_name') as "Помещение",
      sp.getMPar_S(cj.TO_LOCPROP_ID, 'HP_Equipment_name') as "Наименование устройства"
      FROM TABLE(SP.TJ#ELECTRO.V_CAB_JOURNAL(WorkID$)) cj
    )
  ) 
  Loop
    rv."ID устройства" := rc."ID устройства";
    rv."KKS устройства" := REPLACE(rc."KKS устройства", '+', '');
    rv."Помещение" := rc."Помещение";
    rv."Наименование устройства" := rc."Наименование устройства";
    
    pipe row (rv);
  End Loop;
End V_DEVICE_XYZ;


Function V_CAB_LENGTH(WorkID$ In Number default null) 
Return  T_CAB_LENGTH Pipelined
Is
  rv R_CAB_LENGTH;

Begin
  rv."Длина" := NULL;
  rv."Трасса" := '';
  
  if WorkID$ is null then
    return;
  end if;
  
  for rc in
  (
    SELECT DISTINCT * FROM
    (
      SELECT 
      cj."CABLE_ID" as "ID кабеля",
      cj."CABLE_NAME" as "KKS кабеля", 
      sp.getMPar_S(cj."CABLE_ID", 'HP_Cable_type') as "Марка кабеля", 
      sp.getMPar_N(cj.CABLE_ID, 'HP_Diametr_of_cable') as "Диаметр кабеля",
      cj."FROM_LOCATION_NAME" as "Откуда KKS",
      sp.getMPar_S(cj.FROM_LOCPROP_ID, 'HP_Room_number_and_name') as "Откуда Пом.",
      sp.getMPar_S(cj.FROM_LOCPROP_ID, 'HP_Equipment_name') as "Откуда Наименование",
      sp.getMPar_N(cj.FROM_LOCPROP_ID, 'HP_Installation_equipment_on_the_x') as "Откуда X",
      sp.getMPar_N(cj.FROM_LOCPROP_ID, 'HP_Installation_equipment_on_the_y') as "Откуда Y",
      sp.getMPar_N(cj.FROM_LOCPROP_ID, 'HP_Elevation') as "Откуда Z",
      cj."TO_LOCATION_NAME" as "Куда KKS",
      sp.getMPar_S(cj.TO_LOCPROP_ID, 'HP_Room_number_and_name') as "Куда Пом.",
      sp.getMPar_S(cj.TO_LOCPROP_ID, 'HP_Equipment_name') as "Куда Наименование",
      sp.getMPar_N(cj.TO_LOCPROP_ID, 'HP_Installation_equipment_on_the_x') as "Куда X",
      sp.getMPar_N(cj.TO_LOCPROP_ID, 'HP_Installation_equipment_on_the_y') as "Куда Y",
      sp.getMPar_N(cj.TO_LOCPROP_ID, 'HP_Elevation') as "Куда Z"
      FROM TABLE(SP.TJ#ELECTRO.V_CAB_JOURNAL(WorkID$)) cj
    )
  ) 
  Loop
    rv."ID кабеля" := rc."ID кабеля";
    rv."KKS кабеля" := REPLACE(rc."KKS кабеля", '=', '');
    rv."Марка кабеля" := rc."Марка кабеля";
    rv."Диаметр кабеля" := rc."Диаметр кабеля";
    rv."Откуда KKS" := REPLACE(rc."Откуда KKS", '+', '');
    rv."Откуда Пом." := rc."Откуда Пом.";
    rv."Откуда Наименование" := rc."Откуда Наименование";
    rv."Откуда X" := rc."Откуда X";
    rv."Откуда Y" := rc."Откуда Y";
    rv."Откуда Z" := rc."Откуда Z";
    rv."Куда KKS" := REPLACE(rc."Куда KKS", '+', '');
    rv."Куда Пом." := rc."Куда Пом.";
    rv."Куда Наименование" := rc."Куда Наименование";
    rv."Куда X" := rc."Куда X";
    rv."Куда Y" := rc."Куда Y";
    rv."Куда Z" := rc."Куда Z";
    
    pipe row (rv);
  End Loop;
End V_CAB_LENGTH;

Begin

  TwistedCable_AA('КУППмнг') := 'Twisted';
  TwistedCable_AA('КУППмнг(А)') := 'Twisted';
  TwistedCable_AA('КУППмнг(А)-LS') := 'Twisted';
  TwistedCable_AA('КУППмнг(А)-FRLS') := 'Twisted';
  TwistedCable_AA('КУППмнг(А)-HF') := 'Twisted';
  TwistedCable_AA('КУППмнг(А)-FRHF') := 'Twisted';
  
  EquipmentCable_AA('Кабель датчика') := 'Cable of sensor';
  EquipmentCable_AA('Кабель насоса') := 'Cable of pump';
  EquipmentCable_AA('Кабель двигателя') := 'Cable of motor';
  EquipmentCable_AA('Кабель оборудования') := 'Equipment cable';

End TJ#AEP;
/
