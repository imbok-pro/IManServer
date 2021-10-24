-- SP Work Views 
-- by Nikolai Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 03.11.2010
-- update 06.12.2010 23.09.2011 10.11.2011 03.04.2013 09.04.2013

-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW SP.V_COMMAND_PAR_S
(NAME,
 COMMENTS,
 R_ONLY,
 R_ONLY_ID,
 MODIFIED,
 VALUE_TYPE,
 TYPE_ID,
 VALUE_ENUM,SET_OF_VALUES,
 TYPE_COMMENTS,
 V,
 Def_V,
 VALUE_COMMENTS,
 E,
 N, D, S, X, Y
)
AS 
select 
  p.NAME,
  p.COMMENTS,
  cast (SP.to_strR_ONLY(p.R_ONLY) as VARCHAR2(60) ) R_ONLY,
  cast(p.R_ONLY as NUMBER(3)) R_ONLY_ID,
  p.MODIFIED MODIFIED,
  t.NAME VALUE_TYPE,
  cast(p.TYPE_ID as NUMBER(9)) TYPE_ID,
  cast(nvl2(t.CHECK_VAL,0,1) as NUMBER(1)) VALUE_ENUM,
  cast(SP.S_TYPE_HAS_SET_OF_VALUES(TYPE_ID) as NUMBER(1)) SET_OF_VALUES,
  t.COMMENTS,
  SP.Val_to_Str(SP.TVALUE(p.TYPE_ID, null,0, p.E_VAL,p.N,p.D,p.S,p.X,p.Y)) "V",
  p.Def_V,
  SP.Val_Comments(SP.TVALUE(p.TYPE_ID,null,0, p.E_VAL,p.N,p.D,p.S,p.X,p.Y)),
  p.E_VAL, 
  p.N, p.D, p.S, p.X, p.Y
from SP.PAR_TYPES t, SP.WORK_COMMAND_PAR_S p 
where t.ID=p.TYPE_ID
order by NAME
;

grant all on SP.V_COMMAND_PAR_S to public;
Comment on table SP.V_COMMAND_PAR_S is 'ѕараметры команды. “аблица заполн€етс€ перед запуском макропроцедуры.';
Comment on column SP.V_COMMAND_PAR_S.SET_OF_VALUES is 'ѕризнак наличи€ у типа списка выбора дл€ значени€. 0 - значение не имеет списка выбора, 1 - значение имеет список выбора.';

begin
 cc.fT:='PAR_TYPES';
 cc.tT:='V_COMMAND_PAR_S';
 cc.c('COMMENTS','TYPE_COMMENTS');
 cc.c('ID','TYPE_ID');
 cc.c('NAME','VALUE_TYPE'); 

 cc.fT:='WORK_COMMAND_PAR_S';
 cc.tT:='V_COMMAND_PAR_S';
 cc.c('R_ONLY','R_ONLY_ID'); 
 cc.c('MODIFIED','MODIFIED'); 
 
 cc.fT:='OBJECT_PAR_S';
 cc.tT:='V_COMMAND_PAR_S';
 cc.c('E_VAL','E');  
 cc.c('N','N');  
 cc.c('D','D');  
 cc.c('S','S');  
 cc.c('X','X');  
 cc.c('Y','Y');  
end; 
/
Comment on column SP.V_COMMAND_PAR_S.R_ONLY 
 is '»м€ значени€ модификатора доступа R_ONLY_ID.';
Comment on column SP.V_COMMAND_PAR_S.V is 'ѕредставление значени€ в виде строки. Ёто значение можно отредактировать перед запуском макропроцедуры.';
Comment on column SP.V_COMMAND_PAR_S.Def_V is '«начение параметра по умолчанию в виде строки.';
Comment on column SP.V_COMMAND_PAR_S.NAME is '»м€ параметра.';
Comment on column SP.V_COMMAND_PAR_S.COMMENTS is 'ќписание параметра.';
Comment on column SP.V_COMMAND_PAR_S.VALUE_COMMENTS is ' омментарии к значению.';
Comment on column SP.V_COMMAND_PAR_S.VALUE_ENUM is 'ѕризнак именованного значени€. 0 - значение не имеет имени, 1 - значение именовано.';


--*****************************************************************************
@"SP-Work-Instead.trg"


-- end of file

