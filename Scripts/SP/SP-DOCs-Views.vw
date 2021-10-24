-- SP DOCs Views 
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 08.10.2013
-- update 10.10.2013 11.10.2013 22.10.2013 14.06.2014
--  
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW SP.V_DOCS
/* SP-DOCs-Views.vw */
(ID,
 PREV_ID,
 GROUP_ID,
 GROUP_NAME,
 LINE,
 FORMAT,
/* IMAGE,*/
 PARAGRAPH,
 EDIT_ROLE,
 USING_ROLE,
 EDIT_ROLE_ID,
 USING_ROLE_ID,
 M_DATE,
 M_USER)
AS 
select 
  d.ID,
  d.PREV_ID,
  g.G_ID,
  g.NAME,
  cast(d.LINE as NUMBER(9)) LINE,
  d.FORMAT_ID FORMAT,
  d.PARAGRAPH,
  g.G_ROLE EDIT_ROLE,
  r.NAME USING_ROLE,
  g.G_ER_ID EDIT_ROLE_ID,
  d.USING_ROLE USING_ROLE_ID,
  case when g.M_DATE > d.M_DATE then g.M_DATE else d.M_DATE end M_DATE,
  case when g.M_DATE > d.M_DATE then g.M_USER else d.M_USER end M_USER
from 
  (select LEVEL LINE, ds.* from SP.DOCS ds 
     start with PREV_ID is null
     connect by PREV_ID = prior ID) d,
  SP.V_GROUPS g, SP.SP_ROLES r
where d.GROUP_ID = g.G_ID
  and d.USING_ROLE = r.ID(+) 
  and (   (d.USING_ROLE is null)
       or (SP.S_isUserAdmin=1)
       or (d.USING_ROLE in (select ROLE_ID from SP.USER_ROLES))
       or (g.G_ROLE in (select ROLE_ID from SP.USER_ROLES)))  
;

grant all on SP.V_DOCS to public;
Comment on table SP.V_DOCS is 'Документы. SP-DOCs-Views.vw';

begin
 cc.fT:='DOCS';
 cc.tT:='V_DOCS';
 cc.c('ID','ID'); 
 cc.c('PREV_ID','PREV_ID');
 cc.c('GROUP_ID','GROUP_ID'); 
 cc.c('FORMAT_ID','FORMAT');
 cc.c('PARAGRAPH','PARAGRAPH'); 
 cc.c('USING_ROLE','USING_ROLE_ID');  
end; 
/
Comment on column SP.V_DOCS.GROUP_NAME 
  is 'Имя группы в котой состоит данный абзац.';
Comment on column SP.V_DOCS.LINE 
  is 'Порядковый номер абзаца среди всех абзацев принадлежаших группе.';
Comment on column SP.V_DOCS.EDIT_ROLE 
  is 'Имя роли, дающей право редактировать данный абзац. Роль редактирования абзаца - есть роль позволяющая редактировать группу, в который даннный абзац состоит.';
Comment on column SP.V_DOCS.EDIT_ROLE_ID 
  is 'Идентификатор роли, дающей право редактировать данный абзац. Роль редактирования абзаца - есть роль позволяющая редактировать группу, в который даннный абзац состоит.';
Comment on column SP.V_DOCS.USING_ROLE is 'Имя роли, позволяющей просматривать данный абзац.';
COMMENT ON COLUMN SP.V_GROUPS.M_DATE 
  IS 'Дата создания или изменения абзаца или группы, включающей данный абзац (последняя).';
COMMENT ON COLUMN SP.V_GROUPS.M_USER 
  IS 'Пользователь создавший или изменивший абзац или группу, включающую данный абзац (последний).';


--*****************************************************************************
@"SP-DOCs-Instead.trg"

-- end of file

