CREATE OR REPLACE TYPE BODY SP.TSPAR
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 10.07.2015
-- update 30.03.2016 09.02.2017 10.02.2017 06.03.2017 15.09.2021
--****************************************************************************
as

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TSPAR(ModelParID IN NUMBER)
return SELF AS RESULT
is
err BOOLEAN;
begin
  err := true;
	for p in (select p.TYPE_ID, p.R_ONLY, 
                   p.MOD_OBJ_ID, cp.NAME, cp.ID CP_ID
	             from SP.MODEL_OBJECT_PAR_S p, SP.OBJECT_PAR_S cp
	             where p.ID = ModelParID 
                 and p.OBJ_PAR_ID = cp.ID
                 and p.R_ONLY in (-1,0))
	loop
    err := false;
	  self.MO_ID := p.MOD_OBJ_ID;
    self.CP_ID := p.CP_ID;
    self.NAME := p.NAME;
    self.defVAL := null;
    self.curVAL := null;
    self.CurDate := null;
    self.CurUser := null;
    self.CDATE := null;
    self.VAL := SP.TVALUE(p.TYPE_ID);
    self.VAL.R_ONLY := p.R_ONLY;
    self.MDate := null;
    self.MUser := null;
  end loop;
  if err then 
    RAISE_APPLICATION_ERROR(-20033,
      'SP.TSPAR. Параметр с идентификатором '
      ||nvl(ModelParID,null)||' не найден или его история не записывается!');
  end if; 
  return;
end TSPAR;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TSPAR(ModelObjID IN NUMBER, Par IN VARCHAR2)
return SELF AS RESULT
is
begin
  self := SP.TSPAR(ModelObjID, Par, SYSDATE());
  return;
end TSPAR;

CONSTRUCTOR FUNCTION TSPAR(ModelObjPar IN SP.TMPAR)
return SELF AS RESULT
is
begin
    self.MO_ID := ModelObjPar.MO_ID;
    self.CP_ID := ModelObjPar.CP_ID;
    self.NAME := ModelObjPar.NAME;
    self.defVAL := SP.TVALUE();
    if ModelObjPar.MDate is null then
      self.curVAL := null;
      self.defVAL := ModelObjPar.VAL; 
    else
      select   TYPE_ID, E_VAL, N, D, S, X, Y 
        into  self.defVAL.T, self.defVAL.E,
              self.defVAL.N, self.defVAL.D, self.defVAL.S,
              self.defVAL.X, self.defVAL.Y
        from SP.OBJECT_PAR_S 
        where ID = self.CP_ID; 
      self.curVAL := ModelObjPar.VAL; 
    end if;
    self.CurDate := ModelObjPar.MDate;
    self.CurUser := ModelObjPar.MUser;
    self.CDATE := null;
    self.VAL := ModelObjPar.VAL;
    self.MDate := ModelObjPar.MDate;
    self.MUser := ModelObjPar.MUser;
  return;
end TSPAR;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TSPAR(ModelObjID IN NUMBER, Par IN VARCHAR2, D IN DATE)
return SELF AS RESULT
is
NoFound BOOLEAN;
MO_Obj SP.MODEL_OBJECTS%rowtype;
V SP.TVALUE;
begin
  NoFound:=true;
  -- Находим текущее значение идентификаторов объекта и параметра.
  for p in (select p.TYPE_ID, p.R_ONLY, 
                   o.ID, p.NAME, p.ID CP_ID
              from SP.MODEL_OBJECTS o, SP.OBJECTS cp, SP.OBJECT_PAR_S p 
              where o.ID = ModelObjID
                and (G.S_UpEQ(p.NAME,Par)>0)
                and o.OBJ_ID = cp.ID
                and cp.ID = P.OBJ_ID
           )
  loop
    NoFound := false;
    self.MO_ID := ModelObjID;
    self.CP_ID := p.CP_ID;
    self.NAME := Par;
    self.VAL := SP.TVALUE(p.TYPE_ID);
    self.VAL.R_ONLY := p.R_ONLY;
  end loop; 
  if NoFound then
    -- Псевдопараметры ищем в таблице объектов.
    -- Проверяем, существует ли объект и выдаем сообщение об его отсутствии.  
    begin
      select * into MO_Obj from SP.MODEL_OBJECTS 
        where ID = ModelObjID;
      self.MO_ID := ModelObjID;
      self.NAME := Par;
    exception
      when no_data_found then
        RAISE_APPLICATION_ERROR(-20033,
          'SP.TSPAR. Объект '||to_char(nvl(ModelObjID,null))||' не найден!' );
    end;
    case Par
      when 'NAME' then
        self.CP_ID := -1;
        self.VAL := S_('');
        --d('NAME'||SELF.VAL.S,'SP.TSPAR');
      when 'PARENT' then
        self.CP_ID := -2;
        self.VAL := SP.TVALUE(G.TRel);
      when 'USING_ROLE' then
        self.CP_ID := -3;
        self.VAL:= SP.TVALUE(G.TRole);
      when 'EDIT_ROLE' then
        self.CP_ID := -4;
        self.VAL:= SP.TVALUE(G.TRole);
    else
      RAISE_APPLICATION_ERROR(-20033,
        'SP.TSPAR. Параметр '||nvl(Par, 'null')||' у объекта '||
        to_char(ModelObjID)||' не найден или для него не ведётся история!' );
    end case;  
    self.VAL.R_ONLY := 0;
  end if;
  self.CDATE := null;
  self.defVAL := null;
  self.curVAL := null;
  self.CurDate := null;
  self.CurUser := null;
  self.CDATE := null;
  self.MDate := null;
  self.MUser := null;
  V := Get_Value(D);
  return;
end TSPAR;

-------------------------------------------------------------------------------
MEMBER FUNCTION OBJECT_NAME return VARCHAR2
is
  ObjName SP.COMMANDS.COMMENTS%type;
begin
  select FULL_NAME into ObjName from SP.V_MODEL_OBJECTS where ID = self.MO_ID;
  return ObjName;
exception
  when no_data_found then
  RAISE_APPLICATION_ERROR(-20033,
    'SP.TSPAR. Объект с идентификатором '||nvl(self.MO_ID,null)||
    ' не найден!' );
end OBJECT_NAME;

-------------------------------------------------------------------------------
MEMBER FUNCTION Get_Value(self IN OUT NOCOPY SP.TSPAR, D IN DATE) 
RETURN SP.TVALUE
is
  r SP.MODEL_OBJECT_PAR_STORIES%rowtype;
  MO_Obj SP.V_MODEL_OBJECTS%rowtype;
  NoFound BOOLEAN;
begin
  self.CDATE := D;
  -- Заполняем значение по умолчанию и текущее значение.
  if self.defVal is null then
    NoFound:=true;
    -- Находим переопределённое значение объекта.
    for p in (select p.TYPE_ID, p.R_ONLY, p.E_VAL, p.N, p.D, p.S, p.X, p.Y,
                     p.M_DATE, p.M_USER
                 from SP.MODEL_OBJECT_PAR_S p
                 where p.MOD_OBJ_ID = self.MO_ID 
                   and P.OBJ_PAR_ID = self.CP_ID
              )       
    loop
      NoFound:=false;
      self.CurDate := p.M_DATE;
      self.CurUSER := p.M_USER;
      self.curVAL := SP.TVALUE(T=>p.TYPE_ID, COMMENTS=>null, R_ONLY =>p.R_ONLY, 
                               E=>p.E_VAL, 
                               N=>p.N, D=>p.D, S=>p.S, X=>p.X, Y=>p.Y);
    end loop; 
    -- Находим непереопределённое значение объекта.
    if self.NAME not in ('NAME', 'PARENT', 'OID', 'POID',
                         'ID', 'PID', 'USING_ROLE', 'EDIT_ROLE')
    then 
      for p in (select cp.TYPE_ID,cp.E_VAL, cp.N, cp.D, cp.S, cp.X, cp.Y,
                       cp.ID CP_ID, cp.R_ONLY
                  from SP.OBJECT_PAR_S cp 
                  where cp.ID=self.CP_ID
                )
      loop
        self.defVAL:=SP.TVALUE(T=>p.TYPE_ID, COMMENTS=>null, R_ONLY =>p.R_ONLY,
                               E=>p.E_VAL, 
                               N=>p.N, D=>p.D, S=>p.S, X=>p.X, Y=>p.Y);
      end loop;
      if self.defVAL is null then
        RAISE_APPLICATION_ERROR(-20033, 'SP.TSPAR. '||
        'Параметр каталога '||nvl(to_char(self.CP_ID), 'null')||' не найден!');
      end if;
    else 
      -- Находим объект или выдаем сообщение об его отсутствии.  
      begin
        select * into MO_Obj from SP.V_MODEL_OBJECTS 
          where ID = self.MO_ID;
          self.curDATE := MO_Obj.M_DATE;
          self.curUSER := MO_Obj.M_USER;
        exception
          when no_data_found then
            RAISE_APPLICATION_ERROR(-20033, 'SP.TSPAR. '||
              'Объект '||nvl(to_char(self.MO_ID), 'null')||' не найден!' );
        end;
      -- Псевдопараметры ищем в таблице объектов.
      NoFound:=false;
      case self.NAME
        when 'NAME' then
          self.defVal := S_('');
          self.curVAL := S_(MO_obj.MOD_OBJ_NAME);
          --d('NAME'||SELF.curVAL.S,'SP.TSPAR');
        when 'PARENT' then
          self.defVal := S_('');
          self.curVAL := S_(MO_obj.PATH);
        when 'OID' then
          self.defVal := SP.TVALUE(G.TOID);
          self.curVAL := SP.TVALUE(G.TOID);
          self.curVAL.S := MO_obj.OID;
        when 'POID' then
          self.defVal := SP.TVALUE(G.TOID);
          self.curVAL := SP.TVALUE(G.TOID);
          self.curVAL.S := MO_obj.POID;
        when 'ID' then
          self.defVal := SP.TVALUE(G.TID);
          self.curVAL := SP.TVALUE(G.TID);
          self.curVAL.N := MO_obj.ID;
        when 'PID' then
          self.defVal := SP.TVALUE(G.TID);
          self.curVAL := SP.TVALUE(G.TID);
          self.curVAL.N := MO_obj.PARENT_MOD_OBJ_ID;
        when 'USING_ROLE' then
          self.defVal := SP.TVALUE(G.TRole);
          self.curVAL:= SP.TVALUE(G.TRole);
          self.curVAL.N := MO_obj.USING_ROLE_ID;
        when 'EDIT_ROLE' then
          self.defVal := SP.TVALUE(G.TRole);
          self.curVAL:= SP.TVALUE(G.TRole);
          self.curVAL.N := MO_obj.EDIT_ROLE_ID;
      else
        null;
      end case;
      self.curVAL.R_ONLY := 0; 
      self.defVAL.R_ONLY := 0; 
    end if;   
  end if;
  -- Ищем наиболее близкое значение значение на дату запроса,
  if self.CDATE >= self.curDate then
    self.Val.Assign(curVal);
    self.MDATE := self.curDate;
    self.MUSER := self.curUser;
  else 
    begin
      select * into r from SP.MODEL_OBJECT_PAR_STORIES s
        where S.MOD_OBJ_ID = self.MO_ID
          and S.OBJ_PAR_ID = self.CP_ID
          and S.M_DATE = (select max(M_DATE) from SP.MODEL_OBJECT_PAR_STORIES s
                            where S.MOD_OBJ_ID = self.MO_ID
                              and S.OBJ_PAR_ID = self.CP_ID
                              and M_DATE <= self.CDATE
                         )
-- !!Если есть два значения на одну дату, то берём случайное!!!
-- Пока не запрещу создавать такие значения в триггере!
          and rownum < 2
      ;                        
      self.VAL.E := r.E_VAL;
      self.VAL.N := r.N;
      self.VAL.D := r.D;
      self.VAL.S := r.S;
      self.VAL.X := r.X;
      self.VAL.Y := r.Y;
      self.MDATE := r.M_DATE;
      self.MUSER := r.M_USER;
    -- если не нашли, то используем известные.
    exception 
      when no_data_found then
--        dd('не нашли '||to_char(self.CDATE), 'SP.TSPAR');
        self.Val.Assign(defVal);  
        self.MDATE := null;
        self.MUSER := null;
    end;
  end if;
  return self.VAL;
exception
  when others then
  RAISE_APPLICATION_ERROR(-20033,
    'SP.TSPAR. Ошибка получения значения на дату '||to_.str(D)||
    ' Для объекта '||self.MO_ID||' и его параметра в каталоге '||self.CP_ID||
    ' '||SQLERRM );
end Get_Value;

-------------------------------------------------------------------------------
MEMBER FUNCTION Get_Values RETURN SP.TPAR_STORY pipelined
is
v SP.TPAR_STORY_REC;
begin
  v := SP.TPAR_STORY_REC(null,null,null,null,null,null,null,null,null);
    v.ID := null;
    v.E := nvl(self.CurVal.E, self.defVal.E);
    v.N := nvl(self.CurVal.N, self.defVal.N);
    v.D := nvl(self.CurVal.D, self.defVal.D);
    v.S := nvl(self.CurVal.S, self.defVal.S);
    v.X := nvl(self.CurVal.X, self.defVal.X);
    v.Y := nvl(self.CurVal.Y, self.defVal.Y);
    v.MDATE := self.CurDATE;
    v.MUSER := self.CurUSER;
    pipe row(v);
  for rec in (
    select * from SP.MODEL_OBJECT_PAR_STORIES s
      where S.MOD_OBJ_ID = self.MO_ID
        and S.OBJ_PAR_ID = self.CP_ID
              )
  loop
    v.ID := rec.ID;
    v.E := rec.E_VAL;
    v.N := rec.N;
    v.D := rec.D;
    v.S := rec.S;
    v.X := rec.X;
    v.Y := rec.Y;
    v.MDATE := rec.M_DATE;
    v.MUSER := rec.M_USER;
    pipe row(v);
  end loop;            
end Get_Values;

-------------------------------------------------------------------------------
MEMBER PROCEDURE Add_Value
is
tmpVar NUMBER;
begin
  if self.MO_ID is null then
    RAISE_APPLICATION_ERROR(-20033,
      'SP.TSPAR.Add_Value. Объект не определён!');
  end if;
  if self.CP_ID is null then
    RAISE_APPLICATION_ERROR(-20033,
      'SP.TSPAR.Add_Value. Параметр не определён!');
  end if;
  insert into SP.MODEL_OBJECT_PAR_STORIES 
  (
  MOD_OBJ_ID,
  OBJ_PAR_ID,
  TYPE_ID,
  E_VAL,
  N,
  D,
  S,
  X,
  Y,
  M_DATE,
  M_USER
  )
  values
  (  
  self.MO_ID,
  self.CP_ID,
  self.VAL.T,
  self.VAL.E,
  self.VAL.N,
  self.VAL.D,
  self.VAL.S,
  self.VAL.X,
  self.VAL.Y,
  self.MDATE,
  self.MUSER
  );
  self.CDATE := self.MDATE;
end Add_Value;

end;
/

