-- SP ARR Views 
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 18.01.2018
-- update 19.01.2018

-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW SP.V_ARRAYS
(
  ID,
  NAME,
  GROUP_ID,
  GROUP_NAME,
  IND_X,
  IND_Y,
  IND_Z,
  IND_D,
  IND_S,
  TYPE_ID,
  TYPE_NAME,
  V,
  E_VAL,
  N,
  D, 
  S, 
  X, 
  Y,
  M_DATE,
  M_USER
)
AS 
select 
  a.ID,
  a.NAME,
  a.GROUP_ID,
  g.NAME GROUP_NAME,
  a.IND_X,
  a.IND_Y,
  a.IND_Z,
  a.IND_D,
  a.IND_S,
  a.TYPE_ID,
  t.NAME TYPE_NAME,
  SP.Val_to_Str(SP.TVALUE(a.TYPE_ID,null,0,a.E_VAL,a.N,a.D,a.S,a.X,a.Y)) V,
  a.E_VAL,
  a.N,
  a.D, 
  a.S, 
  a.X, 
  a.Y,
  a.M_DATE,
  a.M_USER
  from SP.PAR_TYPES t, SP.ARRAYS a, SP.GROUPS g 
    where t.ID = a.TYPE_ID
      and g.ID = A.GROUP_ID
    order by GROUP_NAME, NAME, IND_D,  IND_S, IND_X, IND_Y, IND_Z
;

grant all on SP.V_ARRAYS to public;
Comment on table SP.V_ARRAYS is 'Таблица массивов.(SP-ARR_Views.vw)';
Comment on column SP.V_ARRAYS.V is 'Значение элемента массива в виде строки.';

begin
 cc.fT:='PAR_TYPES';
 cc.tT:='V_ARRAYS';
 cc.c('NAME','TYPE_NAME'); 

 cc.fT:='GROUPS';
 cc.tT:='V_ARRAYS';
 cc.c('NAME','GROUP_NAME'); 
 
 cc.fT:='ARRAYS';
 cc.tT:='V_ARRAYS';
 CC.ALL_AV; 
end; 
/

--*****************************************************************************
@"SP-ARR-Instead.trg"


-- end of file

