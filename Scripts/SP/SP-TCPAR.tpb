CREATE OR REPLACE TYPE BODY SP.TCPAR
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 20.08.2010
-- update 22.09.2010 13.10.2010 19.10.2010 28.10.2010 18.10.2010 10.12.2010
--        11.11.2011 04.03.2013 13.06.2014 14.06.2014 26.06.2014 25.04.2017
--        03.05.2017 19.04.2021
--****************************************************************************
as

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TCPAR(ParID in NUMBER)
return SELF AS RESULT
is
--  Role NUMBER;
err BOOLEAN;
begin
  err:=true;
	for p in (select p.ID, p.NAME,o.NAME OBJECT_NAME, p.COMMENTS, p.TYPE_ID, 
                   p.E_VAL, p.N, p.D, p.S, p.X, p.Y, p.R_ONLY, 
                   p.OBJ_ID, p.GROUP_ID
	             from SP.OBJECT_PAR_S p, SP.OBJECTS o
	               where p.ID=ParID
                   and p.OBJ_ID=o.ID)
	loop
    -- Необходимо иметь роль объекта или быть администратором
--     if not(SP.HasUserRoleID(FRole) or SP.TG.SP_Admin) then
--       RAISE_APPLICATION_ERROR(-20033,'TCPAR, Недостаточно привилегий!' );
--     end if; 
    err:=false;
	  self.O_ID:=p.OBJ_ID;
	  self.P_ID:=ParID;
	  self.NAME:=p.NAME;
	  self.OBJECT_NAME:=p.OBJECT_NAME;
    self.VAL:=SP.TVALUE(T=>p.TYPE_ID, COMMENTS=>null, R_ONLY =>p.R_ONLY,
                        E=>p.E_VAL, 
                        N=>p.N, D=>p.D, S=>p.S, X=>p.X, Y=>p.Y);
	  self.VAL.COMMENTS:=p.COMMENTS;
    self.GROUP_ID:=p.GROUP_ID;
	  self.R_ONLY:=p.R_ONLY;
	end loop;
  if err then 
    RAISE_APPLICATION_ERROR(-20033,
      'SP.TCPAR. Параметр с идентификатором '||ParID||' не найден!' );
  end if; 
  return;
end TCPAR;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TCPAR(OBJ in NUMBER,Par in VARCHAR2)
return SELF AS RESULT
is
--  Role NUMBER;
err BOOLEAN;
ObjName SP.OBJECTS.NAME%type;
pType NUMBER;
begin
  err:=true;
	for p in (select p.ID, p.NAME, o.NAME OBJECT_NAME, p.COMMENTS, p.TYPE_ID, 
                   p.E_VAL, p.N, p.D, p.S, p.X, p.Y, p.R_ONLY, 
                   p.OBJ_ID, p.GROUP_ID
	             from SP.OBJECT_PAR_S p, SP.OBJECTS o
	               where p.OBJ_ID = OBJ
                   and G.S_UpEQ(p.NAME,Par)=1
                   and p.OBJ_ID=o.ID)
	loop
-- Необходимо иметь роль объекта или быть администратором
--     if not(SP.HasUserRoleID(FRole) or SP.TG.SP_Admin) then
--       RAISE_APPLICATION_ERROR(-20033,'TCPAR, Недостаточно привилегий!' );
--     end if; 
    err:=false;
	  self.O_ID:=p.OBJ_ID;
	  self.P_ID:=p.ID;
	  self.NAME:=p.NAME;
	  self.OBJECT_NAME:=p.OBJECT_NAME;
    self.VAL:=SP.TVALUE(T=>p.TYPE_ID, COMMENTS=>null, R_ONLY =>p.R_ONLY,
                        E=>p.E_VAL, 
                        N=>p.N, D=>p.D, S=>p.S, X=>p.X, Y=>p.Y);
	  self.VAL.COMMENTS:=p.COMMENTS;
	  self.R_ONLY:=p.R_ONLY;
    self.GROUP_ID:= p.GROUP_ID;
	end loop; 
  if err then 
    begin
      select OBJECT_NAME into ObjName from SP.OBJECTS 
        where ID=OBJ;
      err:=false; 
    exception
      when no_data_found then
        RAISE_APPLICATION_ERROR(-20033,
          'SP.TCPAR. Объект с идентификатором '||OBJ||' не найден!' );
    end;      
    -- Если у объекта(ов) модели уже существует параметр с таким именем, 
    -- то тип для нового параметра берём из модели.
    begin
      select distinct TYPE_ID into pType 
        from SP.MODEL_OBJECT_PAR_S mp, SP.MODEL_OBJECTS mo
        where mp.MOD_OBJ_ID = mo.ID
          and mo.OBJ_ID = OBJ
          and upper(NAME) = upper(Par);
    exception
      when too_many_rows then
        RAISE_APPLICATION_ERROR(-20033,
          'SP.TCPAR. У объектов модели '||OBJ||
          ' присутствуют сторонние параметры с различными типами'||'
           и одинаковым именем '||Par||'!' );
      when others then
        --d('2  '||OBJ||' '||Par||' '||SQLERRM,'SP.TCPAR');
        pType := G.TNoValue;
    end;
    insert into SP.OBJECT_PAR_S 
      values(null,Par,null,
             pType,null,null,null,null,null,null,0,OBJ,null,null,null)
      returning ID into self.P_ID;
    self.O_ID:=OBJ;
    self.NAME:=Par;
    self.OBJECT_NAME:=ObjName;
    self.VAL:=SP.TVALUE(pType);
    self.R_ONLY:=0;
    self.GROUP_ID:=null;
  end if; 
  return;
end TCPAR;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TCPAR(OBJ in VARCHAR2,Par in VARCHAR2)
return SELF AS RESULT
is
--  Role NUMBER;
err BOOLEAN;
tmpVar NUMBER;
pType NUMBER;
begin
  err:=true;
	for p in (select p.ID, p.NAME, o.NAME OBJECT_NAME, p.COMMENTS, p.TYPE_ID, 
                   p.E_VAL, p.N, p.D, p.S, p.X, p.Y, p.R_ONLY,
                   p.OBJ_ID, p.GROUP_ID
	             from SP.OBJECT_PAR_S p, SP.OBJECTS o
	               where p.OBJ_ID=o.ID
                   and G.S_UpEQ(p.NAME,Par)=1
                   and G.S_UpEQ(o.NAME,OBJ)=1)
	loop
    -- Необходимо иметь роль объекта или быть администратором
--     if not(SP.HasUserRoleID(FRole) or SP.TG.SP_Admin) then
--       RAISE_APPLICATION_ERROR(-20033,'TCPAR, Недостаточно привилегий!' );
--     end if; 
    err:=false;
	  self.O_ID:=p.OBJ_ID;
	  self.P_ID:=p.ID;
	  self.NAME:=p.NAME;
	  self.OBJECT_NAME:=p.OBJECT_NAME;
    self.VAL:=SP.TVALUE(T=>p.TYPE_ID, COMMENTS=>null,  R_ONLY =>p.R_ONLY,
                        E=>p.E_VAL, 
                        N=>p.N, D=>p.D, S=>p.S, X=>p.X, Y=>p.Y);
	  self.VAL.COMMENTS:=p.COMMENTS;
	  self.R_ONLY:=p.R_ONLY;
    self.GROUP_ID:=p.GROUP_ID;
	end loop; 
  if err then 
    begin
      select ID into tmpVar from SP.OBJECTS 
        where G.S_UpEQ(NAME,OBJ)=1;
      err:=false; 
    exception
      when no_data_found then
        RAISE_APPLICATION_ERROR(-20033,
          'SP.TCPAR. Объект '||OBJ||' не найден!' );
    end;
    -- Если у объекта(ов) модели уже существует параметр с таким именем, 
    -- то тип для нового параметра берём из модели.
    begin
      select distinct TYPE_ID into pType 
        from SP.MODEL_OBJECT_PAR_S mp, SP.MODEL_OBJECTS mo
        where mp.MOD_OBJ_ID = mo.ID
          and mo.OBJ_ID = OBJ
          and upper(NAME) = upper(Par);
    exception
      when too_many_rows then
        RAISE_APPLICATION_ERROR(-20033,
          'SP.TCPAR. У объектов модели '||OBJ||
          ' присутствуют сторонние параметры с различными типами'||'
           и одинаковым именем '||Par||'!' );
      when others then
        --d('2  '||OBJ||' '||Par||' '||SQLERRM,'SP.TCPAR');
        pType := G.TNoValue;
    end;
    insert into SP.OBJECT_PAR_S 
      values(null,Par,null,
             pType,null,null,null,null,null,null,0,tmpVar,null,
             null,null)
      returning ID into self.P_ID;
    self.O_ID:=tmpVar;
    self.NAME:=Par;
    self.OBJECT_NAME:=OBJ;
    self.VAL:=SP.TVALUE(pType);
    self.R_ONLY:=0;
    self.GROUP_ID:=null;
  end if; 
  return;
end TCPAR;

-------------------------------------------------------------------------------
MEMBER PROCEDURE Save 
is
begin
  update SP.OBJECT_PAR_S p set
	  NAME=self.NAME,
	  COMMENTS=self.VAL.COMMENTS,
    TYPE_ID=self.VAL.T,
    E_VAL=self.VAL.E,
    N=self.VAL.N,
    D=self.VAL.D,
    S=self.VAL.S,
    X=self.VAL.X,
    Y=self.VAL.Y,
	  R_ONLY=self.R_ONLY,
    GROUP_ID=self.GROUP_ID,
    M_DATE=null,
    M_USER=null
    where ID=self.P_ID and OBJ_ID=self.O_ID;
  if sql%rowcount=0 then  
    RAISE_APPLICATION_ERROR(-20033,
      'SP.TCPAR.Save. Ошибка сохранения параметра '||self.NAME||
      ' объекта '||self.OBJECT_NAME||'!' );
  end if;        
end Save;

-------------------------------------------------------------------------------
MEMBER PROCEDURE Save(MDATE IN DATE, MUSER IN VARCHAR) 
is
begin
  update SP.OBJECT_PAR_S p set
	  NAME=self.NAME,
	  COMMENTS=self.VAL.COMMENTS,
    TYPE_ID=self.VAL.T,
    E_VAL=self.VAL.E,
    N=self.VAL.N,
    D=self.VAL.D,
    S=self.VAL.S,
    X=self.VAL.X,
    Y=self.VAL.Y,
	  R_ONLY=self.R_ONLY,
    M_DATE=MDATE,
    M_USER=MUSER,
    GROUP_ID=self.GROUP_ID
    where ID=self.P_ID and OBJ_ID=self.O_ID;
  if sql%rowcount=0 then  
    RAISE_APPLICATION_ERROR(-20033,
      'SP.TCPAR.Save. Ошибка сохранения параметра '||self.NAME||
      ' объекта '||self.OBJECT_NAME||'!' );
  end if;        
end Save;

end;
/
