-- SP GROUPS views 
-- by Nikolay Krasilnikov
-- create 03.06.2013
-- update 04.06.2013 10.10.2013 16.10.2013
--
--*****************************************************************************

-- Группы.
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW SP.V_GROUPS
(G_ID,G_IM_ID, NAME, COMMENTS,
 PARENT_G, P_ID, R_ID,
 PREV_ID, LINE,
 G_ROLE, G_ER_ID, P_ROLE, P_ER_ID)
AS
select 
  g.ID G_ID, g.IM_ID, g.NAME NAME, g.COMMENTS COMMENTS,
	null PARENT_G, null P_ID, null R_ID,
  null PREV_ID, cast(-1 as NUMBER(9)) LINE,	
  g_er.NAME G_ROLE, g.EDIT_ROLE G_ER_ID, null, null
  from (select * from SP.GROUPS 
          where ID not in (select distinct inc from SP.REL_S 
                             where inc is not null)) g,
        SP.SP_ROLES g_er
	where g.EDIT_ROLE=g_er.ID(+)
union	
select 
  g.ID G_ID, g.IM_ID, g.NAME NAME, g.COMMENTS COMMENTS,
	p.NAME PARENT_G, p.ID P_ID, rel.ID R_ID,
  rel.prev_ID PREV_ID, cast(rel.LINE as NUMBER(9)) LINE,
	g_er.NAME G_ROLE, g.EDIT_ROLE G_ER_ID, p_er.NAME P_ROLE, p.EDIT_ROLE P_ER_ID
  from ( select LEVEL LINE, r.* from SP.REL_S r
           start with PREV_ID is null
           connect by PREV_ID = prior ID) rel,
       SP.GROUPS g, SP.GROUPS p,
       SP.SP_ROLES g_er, SP.SP_ROLES p_er
		where (rel.INC is not NULL)
		  and (g.ID=rel.INC)
		  and (p.ID=rel.GR)
      and (g.EDIT_ROLE=g_er.ID(+))
      and (rel.GR=p_er.ID(+));
	

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

-- Группы без учёта иерархии.
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW SP.V_PRIM_GROUPS
(G_ID, G_IM_ID, NAME, COMMENTS, G_ROLE, G_ER_ID)
AS
select g.ID G_ID,g.IM_ID, g.NAME NAME, g.COMMENTS COMMENTS,
	g_er.NAME G_ROLE, g.EDIT_ROLE G_ER_ID 
  from SP.GROUPS g, SP.SP_ROLES g_er
	where g.EDIT_ROLE=g_er.ID(+)
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
end;
/
Comment on column SP.V_PRIM_GROUPS.G_ROLE 
  is 'Роль, необходимая для изменения имени, роли или комментария, а так же для изменения состава группы.';
Comment on column SP.V_PRIM_GROUPS.G_ER_ID is 'Идентификатор роли группы.';


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
