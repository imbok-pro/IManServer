CREATE OR REPLACE PACKAGE BODY SP.RGM
as
-- Грунты
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2018-03-01
-- update 2018-03-05 2018-03-14 2021-04-09
--==============================================================================
--Имена параметров показателей пробы грунта
SampleParNames SP.G.TSNAMES;
--==============================================================================
--Возвращает все нижележащие по отношению к узлу MODEL_OBJ_ID$ пробы грунта
Function GetAllGroundSamples(MODEL_OBJ_ID$ In Number) 
Return RGM.TGROUND_SAMPLES Pipelined
is
rv TGROUND_SAMPLE_REC;
pa SP.TMPAR;
Begin
    If Not HasUserRoleName('RGM_user') Then
        RAISE_APPLICATION_ERROR 
        (-20033,'Недостаточно прав. Пользователь не наделен ролью RGM_user'); 
    End If;
    
    For r IN
    (Select mo.ID
        ,mo.MOD_OBJ_NAME AS SAMPLE_NAME
        , mo2.ID As PIKET_ID
        , mo2.MOD_OBJ_NAME as PIKET_NAME
    From SP.V_MODEL_OBJECTS mo
    
    Inner Join SP.V_MODEL_OBJECTS mo1
    ON mo1.ID=mo.PARENT_MOD_OBJ_ID
    
    Inner Join SP.V_MODEL_OBJECTS mo2
    ON mo2.ID=mo1.PARENT_MOD_OBJ_ID
    
    Where mo.CATALOG_NAME='Проба'
    Start With mo.ID=MODEL_OBJ_ID$
    Connect By Prior mo.ID=mo.PARENT_MOD_OBJ_ID
    )
    Loop
        rv.SAMPLE_ID:=r.ID;
        rv.SAMPLE_NAME:=r.SAMPLE_NAME;
        rv.PIKET_ID:=r.PIKET_ID;
        rv.PIKET_NAME:=r.PIKET_NAME;

        rv.SAMPLE_DATE:=SP.C.getMPAR_D('Date', r.ID);

        rv.Location:=SP.C.getMPAR_S('Location');    
        
        pa:=SP.C.getMPAR('Координаты');
        rv.X:=pa.VAL.X;
        rv.Y:=pa.VAL.Y;
        rv.Z:=pa.VAL.N;
        
        rv."Вх_Номер":=SP.C.getMPAR_S('Вх_Номер');

        rv.Ro:=SP.C.getMPAR_N('Ro');
        rv.Rod:=SP.C.getMPAR_N('Rod');
        rv.W:=SP.C.getMPAR_N('W');
        rv.Ws:=SP.C.getMPAR_N('Ws');
        
        rv."Фракция_1":=SP.C.getMPAR_N('Сито_1');
        rv."Фракция_2":=SP.C.getMPAR_N('Сито_2');
        rv."Фракция_3":=SP.C.getMPAR_N('Сито_3');
        rv."Фракция_4":=SP.C.getMPAR_N('Сито_4');
        rv."Фракция_5":=SP.C.getMPAR_N('Сито_5');
        
        rv."Тип Грунта":=SP.C.getMPAR_E('Тип Грунта');

        rv.Remarks:=SP.C.getMPAR_S('Remarks');    

        pipe row (rv);
    End Loop;
    
End GetAllGroundSamples;
--==============================================================================
-- Среди потомков объекта ROOT_OBJ_ID$ находит первую попавшуюся пробу  
-- с именем MOD_OBJ_NAME$ и возвращает её Входящий номер.
-- Если не находит, возвращает Null. 
Function GetSampleInputNum(ROOT_OBJ_ID$ In Number, MOD_OBJ_NAME$ In Varchar2) 
Return Varchar2
Is
  rv Varchar2(128);
Begin
  For r IN
    (Select mo.ID
    From SP.V_MODEL_OBJECTS mo
    Where mo.CATALOG_NAME='Проба'
    AND mo.MOD_OBJ_NAME=MOD_OBJ_NAME$
    Start With mo.ID=ROOT_OBJ_ID$
    Connect By Prior mo.ID=mo.PARENT_MOD_OBJ_ID
    )
    Loop
        rv:=SP.C.getMPAR_S('Вх_Номер',r.ID);
        return rv;
    End Loop;
  Return null;
End GetSampleInputNum;

--==============================================================================
-- Среди потомков объекта ROOT_OBJ_ID$ находит первую попавшуюся пробу  
-- с именем MOD_OBJ_NAME$ и возвращает её ID.
-- Если не находит, возвращает Null. 
Function GetSampleID(ROOT_OBJ_ID$ In Number, MOD_OBJ_NAME$ In Varchar2) 
Return Number
Is
Begin
  For r IN
    (Select mo.ID
    From SP.V_MODEL_OBJECTS mo
    Where mo.CATALOG_NAME='Проба'
    AND mo.MOD_OBJ_NAME=MOD_OBJ_NAME$
    Start With mo.ID=ROOT_OBJ_ID$
    Connect By Prior mo.ID=mo.PARENT_MOD_OBJ_ID
    )
    Loop
        return r.ID;
    End Loop;
  Return null;
End GetSampleID;

--==============================================================================
--Возвращает имена параметров показателей пробы грунта
Function GetSampleParNames Return SP.G.TSNAMES
Is
Begin
  return SampleParNames;
End GetSampleParNames;

--==============================================================================
-- Среди потомков объекта ROOT_OBJ_ID$ находит первый попавшшийся объект  
-- с именем 'Брак' и возвращает его ID.
-- Если не находит, возвращает Null. 
Function GetTrashID(ROOT_OBJ_ID$ In Number) Return Number
Is
Begin
  For r IN
    (Select mo.ID
    From SP.V_MODEL_OBJECTS mo
    Where mo.CATALOG_NAME='GenSystem'
    AND mo.MOD_OBJ_NAME='Брак'
    Start With mo.ID=ROOT_OBJ_ID$
    Connect By Prior mo.ID=mo.PARENT_MOD_OBJ_ID
    )
    Loop
        return r.ID;
    End Loop;
  Return null;
End GetTrashID;



begin
  SampleParNames(1):='Date';
  SampleParNames(2):='Ro';
  SampleParNames(3):='Rod';
  SampleParNames(4):='W';
  SampleParNames(5):='Ws';
  SampleParNames(6):='Сито_1';
  SampleParNames(7):='Сито_2';
  SampleParNames(8):='Сито_3';
  SampleParNames(9):='Сито_4';
  SampleParNames(10):='Сито_5';
  SampleParNames(11):='Координаты';
end RGM;