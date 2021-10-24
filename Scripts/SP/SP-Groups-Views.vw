-- SP GROUPS views 
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 03.06.2013
-- update 04.06.2013 10.10.2013 17.10.2013 13.06.2014 26.08.2014 30.08.2014
--        10.10.2014 01.02.2021
--
--*****************************************************************************

-- Группы.
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW SP.V_GROUPS
(G_ID,G_IM_ID, NAME, COMMENTS,
 PARENT_G, P_ID, R_ID,
 PREV_ID, LINE, ALIAS, ALIAS_NAME,
 G_ROLE, G_ER_ID, P_ROLE, P_ER_ID, M_DATE, M_USER)
AS
select
  g.ID G_ID, g.IM_ID, g.NAME NAME, g.COMMENTS COMMENTS,
	p.NAME PARENT_G, p.ID P_ID, rel.ID R_ID,
  rel.prev_ID PREV_ID, cast(nvl(rel.LINE, g.LINE) as NUMBER(9)) LINE,
  g.ALIAS, o.MOD_OBJ_NAME,
	g_er.NAME G_ROLE, g.EDIT_ROLE G_ER_ID, p_er.NAME P_ROLE, p.EDIT_ROLE P_ER_ID,
  /*case when rel.M_DATE > g.M_DATE then rel.M_DATE else g.M_DATE end M_DATE,
  case when rel.M_DATE > g.M_DATE then rel.M_USER else g.M_USER end M_USER*/
  nvl(rel.M_DATE, g.M_DATE) M_DATE,
  nvl (rel.M_USER, g.M_USER) M_USER
  from ( select LEVEL LINE, r.* from SP.REL_S r
           start with PREV_ID is null
           connect by PREV_ID = prior ID) rel,
       (select rownum LINE, p.* 
         from (select * from SP.GROUPS order by name) p) g,
       SP.GROUPS p, SP.SP_ROLES g_er, SP.SP_ROLES p_er, SP.MODEL_OBJECTS o
		where (g.ID=rel.INC(+))
		  and (p.ID(+)=rel.GR)
      and (g.EDIT_ROLE=g_er.ID(+))
      and (rel.GR=p_er.ID(+))
      and (o.ID(+) = g.ALIAS);
	

grant all on SP.V_GROUPS to "SP_USER_ROLE";
Comment on table SP.V_GROUPS 
  is 'Все группы и их связи. (SP-Groups-Views.vw)';

begin
 cc.fT:='GROUPS';
 cc.tT:='V_GROUPS';
 cc.c('ID','G_ID');
 cc.c('IM_ID','G_IM_ID');
 cc.c('NAME','NAME');
 cc.c('COMMENTS','COMMENTS');
 cc.c('ALIAS','ALIAS');
 cc.fT:='REL_S';
 cc.tT:='V_GROUPS';
 cc.c('PREV_ID','PREV_ID');
end;
/

Comment on column SP.V_GROUPS.PARENT_G 
  is 'Имя группы в которую включена данная группа (родителя).';
Comment on column SP.V_GROUPS.P_ID is 'Идентификатор группы родителя.';
Comment on column SP.V_GROUPS.R_ID 
  is 'Идентификатор записи из таблицы связей.';
Comment on column SP.V_GROUPS.G_ROLE 
  is 'Роль, необходимая для изменения имени, роли или комментария, а так же для изменения состава группы.';
Comment on column SP.V_GROUPS.G_ER_ID is 'Идентификатор роли группы.';
Comment on column SP.V_GROUPS.P_ROLE is 'Роль родителя, необходима для присоединения дочерней группы.';
Comment on column SP.V_GROUPS.P_ER_ID is 'Идентификатор роли родителя.';
Comment on column SP.V_GROUPS.LINE is 'Порядковый номер подгруппы в группе.';
Comment on column SP.V_GROUPS.ALIAS_NAME is 'Короткое имя объекта, прозвищем которого является группа.';
COMMENT ON COLUMN SP.V_GROUPS.M_DATE 
  IS 'Дата создания или изменения группы или связи (последняя).';
COMMENT ON COLUMN SP.V_GROUPS.M_USER 
  IS 'Пользователь создавший или изменивший группу или связь (последний).';

-- Группы без учёта иерархии и прозвищ.
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW SP.V_PRIM_GROUPS
(G_ID, G_IM_ID, NAME, COMMENTS, G_ROLE, G_ER_ID, M_DATE, M_USER)
AS
select g.ID G_ID,g.IM_ID, g.NAME NAME, g.COMMENTS COMMENTS,
	g_er.NAME G_ROLE, g.EDIT_ROLE G_ER_ID,
  g.M_DATE, g.M_USER 
  from SP.GROUPS g, SP.SP_ROLES g_er
	where g.EDIT_ROLE=g_er.ID(+)
    and g.ALIAS is null
;
	
grant all on SP.V_PRIM_GROUPS to  "SP_USER_ROLE";
Comment on table SP.V_PRIM_GROUPS 
  is 'Все группы без иерархии. (SP-Groups-Views.vw)';

begin
 cc.fT:='GROUPS';
 cc.tT:='V_PRIM_GROUPS';
 cc.c('ID','G_ID');
 cc.c('IM_ID','G_IM_ID');
 cc.c('NAME','NAME');
 cc.c('COMMENTS','COMMENTS');
 cc.c('M_DATE','M_DATE');
 cc.c('M_USER','M_USER');
end;
/
Comment on column SP.V_PRIM_GROUPS.G_ROLE 
  is 'Роль, необходимая для изменения имени, роли или комментария, а так же для изменения состава группы.';
Comment on column SP.V_PRIM_GROUPS.G_ER_ID is 'Идентификатор роли группы.';

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.GROUPSofGROUP_ID(GID in NUMBER) 
return TNUMBERS
pipelined
-- Группы входящие в группу GID (SP-Groups-Views.vw).
as
begin
  for g in (select INC as GR from SP.REL_S 
              start with (GR=GID)
              connect by (prior INC =  GR)
            union
            select GID from dual)
  loop
    pipe row(g.GR);
  end loop;
  return;
exception
  when no_data_found then return;  
end;
/  
grant execute on SP.GROUPSofGROUP_ID to public; 

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.GROUPSofGROUP(GName in VARCHAR2) 
return TNUMBERS
pipelined
-- Группы входящие в группу GName (SP-Groups-Views.vw).
as
  GID NUMBER;
begin
  select ID into GID from SP.GROUPS where upper(NAME)=upper(GName);
  for g in (select INC as GR from SP.REL_S 
              start with (GR=GID)
              connect by (prior INC =  GR)
            union
            select GID from dual)
  loop
    pipe row(g.GR);
  end loop;
  return;
exception
  when no_data_found then return;  
end;
/  
grant execute on SP.GROUPSofGROUP to public; 

--*****************************************************************************
@"SP-GROUPS-Instead.trg"

-- end of file
