CREATE OR REPLACE TYPE BODY SP.TMPAR
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 20.08.2010
-- update 22.09.2010 13.10.2010 27.10.2010 24.11.2010 10.12.2010
--        11.11.2011 04.03.2013 22.08.2013 25.08.2013 29.08.2013
--        16.01.2014 14.06.2014 11.11.2013 10.03.2015 25.06.2015
--        05.07.2015 24.07.2015 22.07.2016 19.09.2016 07.10.2016
--        28.02.2017 28.01.2019 07.07.2021 21.07.2021
--****************************************************************************
-- SP-TMPAR.tpb SP-TPar.tps
as

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TMPAR(ModelParID in NUMBER)
return SELF AS RESULT
is
err BOOLEAN;
begin
  err:=true;
	for p in (select p.TYPE_ID, p.R_ONLY, p.E_VAL, p.N, p.D, p.S, p.X, p.Y,
                   p.MOD_OBJ_ID, nvl(cp.NAME,p.NAME) NAME, cp.ID CP_ID,
                   p.M_DATE, p.M_USER, cp.R_ONLY CR_ONLY, cp.GROUP_ID G_ID
	             from SP.MODEL_OBJECT_PAR_S p, SP.OBJECT_PAR_S cp
	               where p.ID=ModelParID 
                   and p.OBJ_PAR_ID=cp.ID(+))
	loop
    err:=false;
	  self.MO_ID:=p.MOD_OBJ_ID;
	  self.MP_ID:=ModelParID;
    self.CP_ID:=p.CP_ID;
    self.R_ONLY:=p.CR_ONLY;
    self.NAME:=p.NAME;
    self.MDATE:=p.M_DATE;
    self.MUSER:=p.M_USER;
    self.NEW_MDATE:=null;
    self.NEW_MUSER:=null;
    self.G_ID:=p.G_ID; 
    self.VAL:=SP.TVALUE(T=>p.TYPE_ID, COMMENTS=>null, R_ONLY =>p.R_ONLY,
                        E=>p.E_VAL, 
                        N=>p.N, D=>p.D, S=>p.S, X=>p.X, Y=>p.Y);
	end loop;
  if err then 
    RAISE_APPLICATION_ERROR(-20033,
      'SP.TMPAR. Параметр с идентификатором '||ModelParID||' не найден!');
  end if; 
  return;
end TMPAR;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TMPAR(ModelObjID IN NUMBER, Par IN VARCHAR2)
return SELF AS RESULT
is
NoFound BOOLEAN;
Obj SP.OBJECTS.NAME%type;
MO_Obj SP.V_MODEL_OBJECTS%rowtype;
v TValue;
begin
  NoFound:=true;
  -- Находим переопределённое значение параметра объекта.
  for p in (select p.TYPE_ID, p.R_ONLY, p.E_VAL, p.N, p.D, p.S, p.X, p.Y,
                   p.ID, cp.ID CP_ID,
                   p.M_DATE, p.M_USER, cp.R_ONLY CR_ONLY, cp.GROUP_ID G_ID
               from SP.MODEL_OBJECT_PAR_S p, SP.OBJECT_PAR_S cp 
                 where p.MOD_OBJ_ID=ModelObjID
                   and (G.S_UpEQ(cp.NAME,Par)+G.S_UpEQ(p.NAME,Par)>=1)
                   and p.OBJ_PAR_ID=cp.ID(+))
  loop
    NoFound:=false;
    self.MO_ID:=ModelObjID;
    self.MP_ID:=p.ID;
    self.CP_ID:=p.CP_ID;
    self.R_ONLY:=p.CR_ONLY;
    self.NAME:=Par;
    self.MDATE:=p.M_DATE;
    self.MUSER:=p.M_USER;
    self.NEW_MDATE:=null;
    self.NEW_MUSER:=null;
    self.G_ID:=p.G_ID; 
    self.VAL:=SP.TVALUE(T=>p.TYPE_ID, COMMENTS=>null, R_ONLY =>p.R_ONLY, 
                        E=>p.E_VAL, 
                        N=>p.N, D=>p.D, S=>p.S, X=>p.X, Y=>p.Y);
  end loop; 
  if NoFound then 
    -- Пытаемся найти непереопределённое значение параметра объекта.
    for p in (select cp.TYPE_ID,cp.E_VAL, cp.N, cp.D, cp.S, cp.X, cp.Y,
                     cp.ID CP_ID, cp.R_ONLY, cp.GROUP_ID G_ID
                 from SP.OBJECTS co, SP.MODEL_OBJECTS o,
                      SP.OBJECT_PAR_S cp 
                   where G.S_UpEQ(cp.NAME,Par)=1
                     and co.ID=o.OBJ_ID
                     and o.ID=ModelObjID
                     and cp.OBJ_ID=o.OBJ_ID
                     and CP.NAME not in ('NAME','PARENT','OID','POID',
                                         'ID','PID','USING_ROLE','EDIT_ROLE')
              )
    loop
      NoFound:=false;
      self.MO_ID:=ModelObjID;
      self.MP_ID:=null;
      self.CP_ID:=p.CP_ID;
      self.R_ONLY:=p.R_ONLY;
      self.NAME:=Par;
      self.G_ID:=p.G_ID; 
      self.VAL:=SP.TVALUE(T=>p.TYPE_ID, COMMENTS=>null, R_ONLY =>p.R_ONLY,
                          E=>p.E_VAL, 
                          N=>p.N, D=>p.D, S=>p.S, X=>p.X, Y=>p.Y);
    end loop;
  end if;   
  if NoFound then
    -- Проверяем, существует ли объект и выдаем сообщение об его отсутствии.  
    begin
      select * into MO_Obj from SP.V_MODEL_OBJECTS 
        where ID=ModelObjID;
      self.MO_ID:=ModelObjID;
      self.MP_ID:=null;
      self.CP_ID:=null;
      self.R_ONLY:=0;
      self.NAME:=Par;
      self.VAL:= SP.TVALUE(G.TNoValue);
    exception
      when no_data_found then
        RAISE_APPLICATION_ERROR(-20033,
          'SP.TMPAR. Объект '||to_char(ModelObjID)||' не найден!' );
    end;
    -- Псевдопараметры ищем в таблице объектов.
    self.G_ID:=12; 
    case Par
      when 'NAME' then
        self.VAL := S_(MO_obj.MOD_OBJ_NAME);
        --d('NAME'||SELF.VAL.S,'SP.TMPAR');
      when 'PARENT' then
        self.VAL := S_(MO_obj.PATH);
      when 'OID' then
        self.VAL := SP.TVALUE(G.TOID);
        self.VAL.S := MO_obj.OID;
      when 'POID' then
        self.VAL := SP.TVALUE(G.TOID);
        self.VAL.S := MO_obj.POID;
      when 'ID' then
        self.VAL := SP.TVALUE(G.TID);
        self.VAL.N := MO_obj.ID;
        self.R_ONLY:=1;
      when 'PID' then
        self.VAL := SP.TVALUE(G.TID);
        self.VAL.N := MO_obj.PARENT_MOD_OBJ_ID;
      when 'USING_ROLE' then
        self.VAL:= SP.TVALUE(G.TRole);
        self.VAL.N := MO_obj.USING_ROLE_ID;
      when 'EDIT_ROLE' then
        self.VAL:= SP.TVALUE(G.TRole);
        self.VAL.N := MO_obj.EDIT_ROLE_ID;
    else
      null;
    end case;  
  end if; 
  return;
end TMPAR;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TMPAR(ModelObjOID IN VARCHAR, Par IN VARCHAR2,
                           ModelID IN NUMBER DEFAULT NULL)
return SELF AS RESULT
is
NoFound BOOLEAN;
MO_Obj SP.V_MODEL_OBJECTS%rowtype;
v TValue;
begin
  NoFound:=true;
  -- Находим переопределённое значение объекта.
  for p in (select p.TYPE_ID, p.R_ONLY, p.E_VAL, p.N, p.D, p.S, p.X, p.Y,
                   p.ID parID, o.ID objID, cp.ID CP_ID, 
                   p.M_DATE, p.M_USER, cp.R_ONLY CR_ONLY, cp.GROUP_ID G_ID
               from SP.MODEL_OBJECT_PAR_S p, SP.OBJECT_PAR_S cp,
                    SP.MODEL_OBJECTS o 
                 where o.OID = ModelObjOID
                   and O.MODEL_ID = ModelID 
                   and P.MOD_OBJ_ID = o.ID
                   and (G.S_UpEQ(cp.NAME,Par)+G.S_UpEQ(p.NAME,Par)>=1)
                   and p.OBJ_PAR_ID=cp.ID(+))
  loop
    NoFound:=false;
    self.MO_ID:=p.objID;
    self.MP_ID:=p.parID;
    self.CP_ID:=p.CP_ID;
    self.R_ONLY:=p.CR_ONLY;
    self.NAME:=Par;
    self.MDATE:=p.M_DATE;
    self.MUSER:=p.M_USER;
    self.NEW_MDATE:=null;
    self.NEW_MUSER:=null;
    self.G_ID:=p.G_ID; 
    self.VAL:=SP.TVALUE(T=>p.TYPE_ID, COMMENTS=>null, R_ONLY =>p.R_ONLY, 
                        E=>p.E_VAL, 
                        N=>p.N, D=>p.D, S=>p.S, X=>p.X, Y=>p.Y);
  end loop; 
  if NoFound then 
    -- Пытаемся найти непереопределённое значение объекта.
    for p in (select cp.TYPE_ID,cp.E_VAL, cp.N, cp.D, cp.S, cp.X, cp.Y,
                     o.ID objID, cp.ID CP_ID, cp.R_ONLY, cp.GROUP_ID G_ID
                 from SP.OBJECTS co, SP.MODEL_OBJECTS o,
                      SP.OBJECT_PAR_S cp 
                   where G.S_UpEQ(cp.NAME,Par)=1
                     and co.ID=o.OBJ_ID
                     and o.OID=ModelObjOID
                     and cp.OBJ_ID=o.OBJ_ID
                     and CP.NAME not in ('NAME','PARENT','OID','POID',
                                         'ID','PID','USING_ROLE','EDIT_ROLE')
              )
    loop
      NoFound:=false;
      self.MO_ID:=p.objID;
      self.MP_ID:=null;
      self.CP_ID:=p.CP_ID;
      self.R_ONLY:=p.R_ONLY;
      self.NAME:=Par;
      self.G_ID:=p.G_ID; 
      self.VAL:=SP.TVALUE(T=>p.TYPE_ID, COMMENTS=>null, R_ONLY =>p.R_ONLY,
                          E=>p.E_VAL, 
                          N=>p.N, D=>p.D, S=>p.S, X=>p.X, Y=>p.Y);
    end loop;
  end if;   
  if NoFound then
    -- Проверяем, существует ли объект и выдаем сообщение об его отсутствии.  
    begin
      select * into MO_Obj from SP.V_MODEL_OBJECTS 
        where OID=ModelObjOID;
      self.MO_ID:=MO_Obj.ID;
      self.MP_ID:=null;
      self.CP_ID:=null;
      self.R_ONLY:=0;
      self.NAME:=Par;
    exception
      when no_data_found then
        RAISE_APPLICATION_ERROR(-20033,
          'SP.TMPAR. Объект '||ModelObjOID||' не найден!' );
    end;
    -- Псевдопараметры ищем в таблице объектов.
    self.G_ID:=12; 
    case Par
      when 'NAME' then
        self.VAL := S_(MO_obj.MOD_OBJ_NAME);
      when 'PARENT' then
        self.VAL := S_(MO_obj.PATH);
      when 'OID' then
        self.VAL := SP.TVALUE(G.TOID);
        self.VAL.S := MO_obj.OID;
      when 'POID' then
        self.VAL := SP.TVALUE(G.TOID);
        self.VAL.S := MO_obj.POID;
      when 'ID' then
        self.VAL := SP.TVALUE(G.TID);
        self.VAL.N := MO_obj.ID;
        self.R_ONLY:=1;
      when 'PID' then
        self.VAL := SP.TVALUE(G.TID);
        self.VAL.N := MO_obj.PARENT_MOD_OBJ_ID;
      when 'USING_ROLE' then
        self.VAL:= SP.TVALUE(G.TRole);
        self.VAL.N := MO_obj.USING_ROLE_ID;
      when 'EDIT_ROLE' then
        self.VAL:= SP.TVALUE(G.TRole);
        self.VAL.N := MO_obj.EDIT_ROLE_ID;
    else
      null;
    end case;  
  end if; 
  return;
end TMPAR;

-------------------------------------------------------------------------------
MEMBER FUNCTION OBJECT_NAME return VARCHAR2
is
ObjName SP.COMMANDS.COMMENTS%type;
begin
  select FULL_NAME into ObjName from SP.V_MODEL_OBJECTS where ID=self.MO_ID;
  return ObjName;
exception
  when no_data_found then
  RAISE_APPLICATION_ERROR(-20033,
    'SP.TMPAR. Объект  с идентификатором '||self.MO_ID||' не найден!' );
end;

-------------------------------------------------------------------------------
MEMBER FUNCTION GROUP_NAME return VARCHAR2
is
gName SP.COMMANDS.COMMENTS%type;
begin
  select NAME into GName from SP.V_PRIM_GROUPS where G_ID=self.g_ID;
  return gName;
exception
  when no_data_found then
  RAISE_APPLICATION_ERROR(-20033,
    'SP.TMPAR. группа  с идентификатором '||self.G_ID||' не найдена!' );
end;

-------------------------------------------------------------------------------
MEMBER PROCEDURE Save(self IN OUT NOCOPY SP.TMPAR,
                      BlockHistory in BOOLEAN default false)
is
tmpVar NUMBER;
begin
  --!!! Разобраться, нужно ли изменять при этом поле изменения объекта в ноль?
  self.MDATE := case 
                  when NEW_MDATE is null then sysdate
                  else NEW_MDATE
                end;  
  self.MUSER := case 
                  when NEW_MUSER is null then SP.TG.UserName
                  else NEW_MUSER
                end;  
  -- Если параметр определён в сторонней модели или это псевдопараметр. 
  if self.CP_ID is null then
    -- Обновляем параметр, существующий только в сторонней модели.
    if self.MP_ID is not null then
      -- то обновляем,
      update SP.MODEL_OBJECT_PAR_S p set
        NAME = self.NAME,
        TYPE_ID = self.VAL.T,
        E_VAL = self.VAL.E,
        N = self.VAL.N,
        D = self.VAL.D,
        S = self.VAL.S,
        X = self.VAL.X,
        Y = self.VAL.Y,
        M_DATE = self.MDATE,
        M_USER = self.MUSER
        where ID = self.MP_ID;
      if sql%rowcount=0 then  
        RAISE_APPLICATION_ERROR(-20033,
          'TMPAR.Save, Ошибка сохранения параметра '||self.NAME||
          ' объекта '||self.OBJECT_NAME||'!' );
      end if;
    else
      -- Для псевдопараметров обновляем представление объектов.
      case self.NAME
        when 'NAME' then
          update SP.MODEL_OBJECTS set
            MOD_OBJ_NAME = self.VAL.S,
            M_DATE = self.MDATE,
            M_USER = self.MUSER
          where self.MO_ID = ID;
        when 'PARENT' then
          update SP.V_MODEL_OBJECTS set
            PATH = self.VAL.S,
            M_DATE = self.MDATE,
            M_USER = self.MUSER
          where self.MO_ID = ID;
        when 'OID' then
          update SP.MODEL_OBJECTS set
            OID = self.VAL.S,
            M_DATE = self.MDATE,
            M_USER = self.MUSER
          where self.MO_ID = ID;
        when 'POID' then
          update SP.V_MODEL_OBJECTS set
            POID = self.VAL.S,
            M_DATE = self.MDATE,
            M_USER = self.MUSER
          where self.MO_ID = ID;
        when 'ID' then
          RAISE_APPLICATION_ERROR(-20033,
            'SP.TMPAR. Обновление уникального идентификатора запрещено!' );
        when 'PID' then
          update SP.MODEL_OBJECTS set
            PARENT_MOD_OBJ_ID = self.VAL.N,
            M_DATE = self.MDATE,
            M_USER = self.MUSER
          where self.MO_ID = ID;
        when 'USING_ROLE' then
          update SP.MODEL_OBJECTS set
            USING_ROLE = self.VAL.N,
            M_DATE = self.MDATE,
            M_USER = self.MUSER
          where self.MO_ID = ID;
        when 'EDIT_ROLE' then
          update SP.MODEL_OBJECTS set
            EDIT_ROLE = self.VAL.N,
            M_DATE = self.MDATE,
            M_USER = self.MUSER
          where self.MO_ID = ID;
      else
        -- иначе добавляем сторонний параметр.
        --d( self.MO_ID||self.NAME,'MP_Save');
        if self.VAL.T is null then
          RAISE_APPLICATION_ERROR(-20033,
            'SP.TMPAR. Попытка создания стороннего параметра ' ||self.NAME||
            ' без определения его типа!' );
        end if;
        insert into SP.MODEL_OBJECT_PAR_S 
          values(null, self.MO_ID, self.NAME, null, self.VAL.R_ONLY,
                 self.VAL.T, self.VAL.E, 
                 self.VAL.N, self.VAL.D, self.VAL.S, self.VAL.X, self.VAL.Y,
                 self.MDATE, self.MUSER)
        returning ID into self.MP_ID;
      end case;  
    end if;
  else
    -- Тип, имя и модификатор параметра определены в каталоге.
    -- Если параметр существует, то обновляем параметр,
    if self.MP_ID is not null then
      -- Если необходимо, то блокируем занесение старого значения в историю.
      begin
        SP.TG.ImportDATA := BlockHistory;
        update SP.MODEL_OBJECT_PAR_S p set
          E_VAL=self.VAL.E,
          N=self.VAL.N,
          D=self.VAL.D,
          S=self.VAL.S,
          X=self.VAL.X,
          Y=self.VAL.Y,
          M_DATE = self.MDATE,
          M_USER = self.MUSER
          where ID=self.MP_ID;
      exception
        when others then
          SP.TG.ImportDATA := false; 
          RAISE_APPLICATION_ERROR(-20033,
            'TMPAR.Save, Ошибка сохранения параметра '||self.NAME||
            ' объекта '||self.OBJECT_NAME||' '||SQLERRM||'!' );
      end;    
      if sql%rowcount=0 then 
        SP.TG.ImportDATA := false; 
        RAISE_APPLICATION_ERROR(-20033,
          'TMPAR.Save, Ошибка сохранения параметра '||self.NAME||
          ' объекта '||self.OBJECT_NAME||'!' );
      end if;
    -- иначе добавляем параметр.  
    else
      insert into SP.MODEL_OBJECT_PAR_S 
        values(null, self.MO_ID, null, self.CP_ID, self.R_ONLY,
               self.VAL.T, self.VAL.E, 
               self.VAL.N, self.VAL.D, self.VAL.S, self.VAL.X, self.VAL.Y,
               self.MDATE, self.MUSER)
      returning ID into self.MP_ID;
    end if;
  end if;       
end Save;

-------------------------------------------------------------------------------
MEMBER PROCEDURE Save(self IN OUT NOCOPY SP.TMPAR, V in SP.TVALUE)
is
begin
  if not g.Eq(self.Val, V) then 
    self.VAL := V;
    self.Save;
  end if;  
end Save;

end;
/

