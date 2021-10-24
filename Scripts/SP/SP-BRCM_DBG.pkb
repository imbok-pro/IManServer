create or replace PACKAGE BODY    SP.BRCM_DBG
-- Отладочные процедуры для работы с пакетами семейства BRCM
-- File: SP-BRCM_DBG.pkb
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-09-26
-- update 2019-09-27
As

--==============================================================================
--По имени кабеля возвращает упорядоченную по ORDINAL последовательность RLIne, 
--входящих в кабель
--Если имя кабеля указано неверно, то не возвращает ничего
Function V_CABLE_RLINES(CableNo$ In Varchar2) 
Return  T_CABLE_WAY_RLINE Pipelined
Is
Begin
  For r In (
    Select 
      cf.ORDINAL
    , cf.RL_RID 
    , rl.RL_EID 
    , rl.RL_DESIGN_FILE
    , rl.X1
    , rl.Y1
    , rl.Z1
    , rl.X2
    , rl.Y2
    , rl.Z2
    , rl.LENGTH
    , rl.HP_RWID 
    , rl.COURSE_NAME
    From SP.BRCM_CABLE ca
    Inner Join SP.BRCM_CFC cf
    ON cf.CBL_RID=ca.CBL_RID
    Inner Join SP.BRCM_RLINE rl
    ON rl.RL_RID=cf.RL_RID
    Where ca."HP_CableNo"=CableNo$
    Order By cf.ORDINAL
  )Loop
    Pipe Row(r);
  End Loop;
End;
--==============================================================================
--Возвращает 1, если RLINE входит в состав тройника (разветвителя).
--В противном случае возвращает 0.
Function IsTee(RL_RID$ In Number) Return Number
Is
  rli# SP.BRCM_RLINE%ROWTYPE;
Begin

  SELECT * Into rli#
  FROM SP.BRCM_RLINE
  WHERE RL_RID=RL_RID$
  ;
  
  Return SP.BRCM#DUMP.IsTee(rli$ => rli#);
Exception When NO_DATA_FOUND Then
  Return 0;
End;


BEGIN
  Null;
END BRCM_DBG;