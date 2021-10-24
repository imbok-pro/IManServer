CREATE OR REPLACE TYPE BODY SP.TValue
-- SP-TVALUE.tpb
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 20.08.2010
-- update 22.09.2010 13.10.2010 20.10.2010 27.10.2010 19.11.2010 10.12.2010
--        07.02.2011 11.05.2011 17.10.2011 10.11.2011 30.11.2010 27.01.2012
--        06.02.2011 04.04.2013 09.04.2013 25.08.2013 02.07.2014 03.07.2014
--        21.04.2015 21.09.2015 17.01.2018 12.03.2018 25.01.2019 01.07.2021

--****************************************************************************
as

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TValue return SELF AS RESULT
is
begin
  --dd('TValue','TValue');
	self.T:=null;
	self.E:=null;
	self.N:=null;
	self.D:=null;
	self.S:=null;
	self.X:=null;
	self.Y:=null;
	self.COMMENTS:=null;
  self.R_ONLY:=0;
  return;
end TValue;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TValue(ValueType in VARCHAR2) return SELF AS RESULT
is
tmpVar NUMBER;
begin
--  dd('TValue(ValueType in VARCHAR2)','TValue');
  select ID into tmpVar from SP.PAR_TYPES p
    where upper(p.NAME)=upper(ValueType);
	self:=SP.TVALUE(tmpVar);
  return;
exception
  when no_data_found then
		raise_application_error(-20033,
      'SP.TVALUE. Missing TYPE '||ValueType||'!');
end TValue;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TValue(ValueType in NUMBER) return SELF AS RESULT
is
TmpVar NUMBER;
begin
  --dd('TValue(ValueType in NUMBER)','TValue');
	if SP.TG.Check_ValEnabled then
    begin
      select ID into TmpVar from SP.PAR_TYPES where ID = ValueType;
    exception when no_data_found then
      raise_application_error(-20033,'Тип не найден!');
    end;
  end if;
  self.T:=ValueType;
	self.E:=null;
	self.N:=null;
	self.D:=null;
	self.S:=null;
	self.X:=null;
	self.Y:=null;
	self.COMMENTS:=null;
  self.R_ONLY:=0;
--  SP.Str_to_Val(null,self,true);
  return;
end TValue;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TValue(ValueType in VARCHAR2,StrValue in VARCHAR2,
                            Safe in NUMBER default 0)
return SELF AS RESULT
is
tmpVar NUMBER;
begin
	-- Если это строка, то значение равно входному.
	if upper(ValueType)='STR4000' then
	  self:=SP.TValue;
    self.T:=SP.G.TStr4000;
    self.S:=StrValue;
    self.R_ONLY:=0;
		return;
	end if;
	begin
    select ID into tmpVar from SP.PAR_TYPES p
		  where upper(p.NAME)=upper(ValueType);
	exception
	  when no_data_found then
			raise_application_error(-20033,
        'SP.TVALUE. Missing TYPE '||ValueType||'!');
	end;
	self:=SP.TValue(tmpVar,StrValue,Safe);
	return;
end TValue;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TValue(ValueType in NUMBER,StrValue in VARCHAR2,
                            Safe in NUMBER default 0)
return SELF AS RESULT
is
begin
	-- Если это строка, то значение равно входному.
	if ValueType=SP.G.TStr4000 then
	   self:=SP.TValue;
     self.T:=ValueType;
     self.S:=StrValue;
     self.R_ONLY:=0;
		 return;
	end if;
  self:=SP.TValue;
  self.T:=ValueType;
  SP.Str_to_Val(StrValue,self,case Safe when 0 then false else true end);
  self.R_ONLY:=0;
	return;
end TValue;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TValue(ValueType in VARCHAR2,NumValue in NUMBER)
return SELF AS RESULT
is
tmpVar NUMBER;
begin
  --dd('TValue(ValueType in VARCHAR2,NumValue in NUMBER)','TValue');
	begin
    select ID into tmpVar from SP.PAR_TYPES p
		  where upper(p.NAME)=upper(ValueType);
	exception
	  when no_data_found then
			raise_application_error(-20033,
        'SP.TVALUE. Missing TYPE '||ValueType||'!');
	end;
	self:=SP.TValue(tmpVar,NumValue);
	return;
end TValue;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TValue(ValueType in NUMBER,NumValue in NUMBER)
return SELF AS RESULT
is
TmpCheckVal SP.PAR_TYPES.CHECK_VAL%TYPE;
begin
	self:=SP.TValue(ValueType);
  -- Если значение типа примечание, то вызываем строковый конструктор.
  if ValueType = SP.G.TNote then
    self:=SP.TValue(ValueType,to_char(NumValue));
    return;  
  end if;
  self.N:=NumValue;
  begin
    -- Запрашиваем блок проверки для данного типа.
    select CHECK_VAL into TmpCheckVal from SP.PAR_TYPES
      where id = ValueType;
	  if TmpCheckVal is null then
      -- Если блок проверки нулл, то значение именованное.
      -- проверяем существование значения и заполняем все поля значения
      -- на основании значения поля N и типа значения.
		  begin
	      select E_VAL, D, S, X, Y into self.E, self.D, self.S, self.X, self.Y 
          from SP.ENUM_VAL_S
			    where TYPE_ID=ValueType
	          and G.S_EQ(N,self.N)=1;
	      -- Если данные были найдены,
	      -- то значение верно и можно покинуть конструктор.        
	      return;
		  exception
		    when no_data_found then
			  	RAISE_APPLICATION_ERROR(-20033,
				    'Конструктор TValue. Именованное значение не найдено, '||
				    ' Type = '||SP.TO_StrType(ValueType)||
				    ' N = '||TO_Char(self.N));
		    when too_many_rows then
			  	RAISE_APPLICATION_ERROR(-20033,
				    'Конструктор TValue. Именованное значение не однозначно, '||
				    ' Type = '||SP.TO_StrType(ValueType)||
				    ' N = '||TO_Char(self.N));
      end;    
    else
      -- Если не установлен флаг проверки значения,
      -- то принимаем значение и выходим из конструктора.
      if not SP.TG.Check_ValEnabled then return; end if;
      -- Проверяем значение.
      SP.CheckVal(TmpCheckVal,self);
      return;
    end if;  
  exception
    when others then 
      RAISE_APPLICATION_ERROR(-20033,
        'Конструктор TValue. Ошибка CheckVal, '||
        ' Type = '||SP.TO_StrType(ValueType)||
        ' E = '||self.E||
        ' N = '||TO_Char(self.N)||
        ' D = '||TO_Char(self.D)||
        ' S = '||self.S||
        ' X = '||TO_Char(self.X)||
        ' Y = '||TO_Char(self.Y)||
				' '||SQLERRM);
  end;
	return;
end TValue;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TValue(ValueType in NUMBER,
                            N in NUMBER,
                            D in DATE default null,
                            DisN in NUMBER default 1,
                            S in VARCHAR2,
                            X in NUMBER,
                            Y in NUMBER,
                            Safe in NUMBER default 0)
return SELF AS RESULT
is
TmpCheckVal SP.PAR_TYPES.CHECK_VAL%TYPE;
begin
	self:= SP.TValue;
  self.T:=ValueType;
	self.N:=N;
  if (DisN is null) or (DisN = 1) then
    self.D:=null;
  else
	  self.D:=D;
  end if;
	self.S:=S;
	self.X:=X;
	self.Y:=Y;
  -- Если это ссылка на объект модели, 
  if ValueType = SP.G.TRel then
    -- то при наличии OID пробуем восстановить ID.
    if (S is not null) and (N is null) then
      begin
        select ID into self.N from SP.MODEL_OBJECTS 
          where OID = trim(S)
            and Model_ID =  SP.TG.Cur_MODEL_ID;
        self.S := null;    
      exception
        -- Если не получилось, то ошибка.
    	  when no_data_found then
					RAISE_APPLICATION_ERROR(-20033,
					  'Конструктор TValue. Ссылка не действительна, '||
					  ' Type = '||SP.TO_StrType(ValueType)||
					  ' N = '||TO_Char(self.N)||
					  ' S = '||self.S||	'!');
      end;
    end if;    
  end if;
  -- Если тип имеет именованные значения, то присваиваем поле E.
	begin
    select E_VAL into self.E from SP.ENUM_VAL_S
		  where TYPE_ID=ValueType
        and G.S_EQ(N,self.N)+
            G.S_EQ(D,self.D)+
            G.S_EQ(S,self.S)+
            G.S_EQ(X,self.X)+
            G.S_EQ(Y,self.Y)=5;
    -- Если данные были найдены,
    -- то значение верно и можно покинуть конструктор.        
    return;
	exception
	  when no_data_found then
      -- Если не установлен флаг проверки значения и параметр Safe = false,
      -- то принимаем значение и выходим из конструктора.
	    if (not SP.TG.Check_ValEnabled) and (Safe <= 0) then
	      self.E:=null;
        return;
      end if;
      begin
        -- Запрашиваем блок проверки для данного типа.
        select CHECK_VAL into TmpCheckVal from SP.PAR_TYPES
          where id = ValueType;
				if TmpCheckVal is null then
          -- Если блок проверки нулл, то значение именованное.
          -- Если в конструктор передан параметр Safe = true,
          -- то находим любое подходящее именованное значение.
	        if Safe >0 then
	          SP.Str_to_Val(null, self, true);
            return;
          else
						RAISE_APPLICATION_ERROR(-20033,
						  'Конструктор TValue. Именованное значение не найдено, '||
						  ' Type = '||SP.TO_StrType(ValueType)||
						  ' E = '||self.E||
						  ' N = '||TO_Char(self.N)||
						  ' D = '||TO_Char(self.D)||
						  ' S = '||self.S||
						  ' X = '||TO_Char(self.X)||
						  ' Y = '||TO_Char(self.Y)||'!');
          end if;    
	      else
			    -- Проверяем значение.
	        SP.CheckVal(TmpCheckVal,self);
          return;
        end if;  
	    exception
	      when others then 
          -- Если не прошли проверку, но параметр Safe = true,
          -- то находим любое подходящее именованное значение.
	        if Safe > 0 then
	          SP.Str_to_Val(null, self, true);
            return;
          else  
		        RAISE_APPLICATION_ERROR(-20033,
		          'Конструктор TValue. Ошибка CheckVal, '||
		          ' Type = '||SP.TO_StrType(ValueType)||
		          ' E = '||self.E||
		          ' N = '||TO_Char(self.N)||
		          ' D = '||TO_Char(self.D)||
		          ' S = '||self.S||
		          ' X = '||TO_Char(self.X)||
		          ' Y = '||TO_Char(self.Y)||
		 					' '||SQLERRM);
          end if;    
      end;
  end;    
end TValue;

-------------------------------------------------------------------------------
CONSTRUCTOR FUNCTION TValue(ValueType in NUMBER,
                            E    in VARCHAR2,
                            N in NUMBER,
                            D in DATE default null,
                            DisN in NUMBER default 1,
                            S in VARCHAR2,
                            X in NUMBER,
                            Y in NUMBER)
return SELF AS RESULT
is
TmpCheckVal SP.PAR_TYPES.CHECK_VAL%TYPE;
tmpE SP.COMMANDS.COMMENTS%type;
begin
	self:= SP.TValue;
  self.T:=ValueType;
	self.E:=E;
	self.N:=N;
  if (DisN is null) or (DisN = 1) then
    self.D:=null;
  else
	  self.D:=D;
  end if;
	self.S:=S;
	self.X:=X;
	self.Y:=Y;
  -- Если это ссылка на объект модели, 
  if ValueType = SP.G.TRel then
    -- то при наличии OID пробуем восстановить ID.
    if (S is not null) and (N is null) then
      begin
        select ID into self.N from SP.MODEL_OBJECTS 
          where OID = trim(S)
            and MODEL_ID = SP.TG.Cur_MODEL_ID;
        self.S := null;    
      exception
        -- Если не получилось, то ошибка.
    	  when no_data_found then
					RAISE_APPLICATION_ERROR(-20033,
					  'Конструктор TValue. Ссылка не действительна, '||
					  ' Type = '||SP.TO_StrType(ValueType)||
					  ' N = '||TO_Char(self.N)||
					  ' S = '||self.S||	'!');
      end;
    end if;    
  end if;
  -- Если не установлен флаг проверки значения,
  -- то принимаем значение и выходим из конструктора.
  if not SP.TG.Check_ValEnabled then return; end if;
  begin
    -- Запрашиваем блок проверки для данного типа.
    select CHECK_VAL into TmpCheckVal from SP.PAR_TYPES
      where id = ValueType;
	  if TmpCheckVal is null then
      -- Если блок проверки нулл, то значение именованное.
      -- проверяем существование значения.
		  begin
	      select E_VAL into tmpE from SP.ENUM_VAL_S
			    where TYPE_ID=ValueType
	          and G.S_EQ(N,self.N)+
	              G.S_EQ(D,self.D)+
	              G.S_EQ(S,self.S)+
	              G.S_EQ(X,self.X)+
	              G.S_EQ(Y,self.Y)=5;
	      -- Если данные были найдены,
	      -- то значение верно и можно покинуть конструктор.        
	      return;
		  exception
		    when no_data_found then
			  	RAISE_APPLICATION_ERROR(-20033,
				    'Конструктор TValue. Именованное значение не найдено, '||
				    ' Type = '||SP.TO_StrType(ValueType)||
				    ' E = '||self.E||
				    ' N = '||TO_Char(self.N)||
				    ' D = '||TO_Char(self.D)||
				    ' S = '||self.S||
				    ' X = '||TO_Char(self.X)||
				    ' Y = '||TO_Char(self.Y)||'!');
      end;    
    else
      -- Проверяем значение.
      SP.CheckVal(TmpCheckVal,self);
      return;
    end if;  
  exception
    when others then 
      RAISE_APPLICATION_ERROR(-20033,
        'Конструктор TValue. Ошибка CheckVal, '||
        ' Type = '||SP.TO_StrType(ValueType)||
        ' E = '||self.E||
        ' N = '||TO_Char(self.N)||
        ' D = '||TO_Char(self.D)||
        ' S = '||self.S||
        ' X = '||TO_Char(self.X)||
        ' Y = '||TO_Char(self.Y)||
				' '||SQLERRM);
  end;
  return;
end TValue;

-------------------------------------------------------------------------------
MAP MEMBER FUNCTION map_values(self IN OUT NOCOPY SP.TVALUE) return VARCHAR2
is
begin
  return to_char(T)||self.asString;
end map_values;

-------------------------------------------------------------------------------
MEMBER FUNCTION TypeName return VARCHAR2
is
tmpVar VARCHAR2(128); -- SP.PAR_TYPES.NAME%type
begin
  select NAME into tmpVar from SP.PAR_TYPES where ID=self.T;
  return tmpVar;
end TypeName;

-------------------------------------------------------------------------------
MEMBER FUNCTION asString(self IN OUT NOCOPY SP.TVALUE) return VARCHAR2
is
begin
	return SP.Val_to_Str(self);
end asString;

-------------------------------------------------------------------------------
MEMBER FUNCTION asBoolean return BOOLEAN
is
begin
  if SP.G.notEQ(self.T,SP.G.TBoolean) or (self.N=0) then
	  return false;
	else
	  return true;
	end if;
end asBoolean;

-------------------------------------------------------------------------------
MEMBER FUNCTION B return BOOLEAN
is
begin
  return self.asBoolean;
end B;

-------------------------------------------------------------------------------
MEMBER PROCEDURE Assign(self IN OUT NOCOPY SP.TVALUE, StrValue in VARCHAR2,
                        Safe in BOOLEAN default false)
is
begin
	-- Если это строка, то значение равно входному.
	if self.T=SP.G.TStr4000 then
	  self.S:=StrValue;
	  return;
	end if;
	SP.Str_to_Val(StrValue,self,Safe);
	return;
end Assign;

-------------------------------------------------------------------------------
MEMBER PROCEDURE Assign(self IN OUT NOCOPY SP.TVALUE, BoolValue in BOOLEAN)
is
begin
  if SP.G.notEQ(self.T,SP.G.TBoolean)  then
		raise_application_error(-20033,
		  'SP.TVALUE. TYPE '||to_char(self.T)||' is not boolean!');
	else
	  case BoolValue
		  when true then self.N:=1; self.E:='true'; self.S:='true';
			else self.N:=0; self.E:='false'; self.S:='false';
		end case;
	end if;
end Assign;

-------------------------------------------------------------------------------
MEMBER PROCEDURE Assign(self IN OUT NOCOPY SP.TVALUE, Val in SP.TVALUE)
is
begin
  self:=Val;
end Assign;

-------------------------------------------------------------------------------
MEMBER PROCEDURE Assign(self IN OUT NOCOPY SP.TVALUE, NumValue IN NUMBER)
is
TmpCheckVal SP.PAR_TYPES.CHECK_VAL%TYPE;
begin
  -- Для встроенных числовых типов просто устанавливаем поле N
  -- и выполняем проверку, если разрешена.
  if self.T in(g.TNumber, g.TInteger, g.TNullShort, g.TNullInteger,
               g.TNullDouble, g.TNullFloat, g.TDouble) 
  then
    self.N := NumValue;
    -- Если не установлен флаг проверки значения,
    -- то принимаем значение и выходим.
    if not SP.TG.Check_ValEnabled then return; end if;
  elsif self.T in(g.TRole, g.TRel, g.TGroup)
  then  
    -- Для Роли и Ссылки заполняем поле N и всегда проверяем ссылку.
    self.N := NumValue;
  else 
    -- Запрашиваем блок проверки для данного типа.
    select CHECK_VAL into TmpCheckVal from SP.PAR_TYPES
      where id = self.T;
    if TmpCheckVal is null then
      -- Для перечислимых типов - устанавливаем поле N и ищем имя значения.
      begin
        select E_VAL into self.E from SP.ENUM_VAL_S
          where TYPE_ID = self.T
            and ((N = NumValue) or (N is null and NumValue is null));
        -- Если данные были найдены, то значение верно.        
          return;
      exception
        when no_data_found then
          RAISE_APPLICATION_ERROR(-20033,
            'ERROR in TValue.Assign. Именованное значение не найдено, '||
            ' Type = '||SP.TO_StrType(self.T)||
            ' N = '||TO_Char(self.N));
        when too_many_rows then
          RAISE_APPLICATION_ERROR(-20033,
            'ERROR in TValue.Assign. Именованное значение не однозначно, '||
            ' Type = '||SP.TO_StrType(self.T)||
            ' N = '||TO_Char(self.N));
      end;
    else      
      -- Для всех остальных возбуждаем ошибку.
      raise_application_error(-20033,
        'ERROR in TValue.Assign. TYPE '||to_char(self.T)||' is not decimal!');
    end if;
  end if;
  -- Проверяем значение.
  SP.CheckVal(TmpCheckVal,self);
  exception
    when others then 
      RAISE_APPLICATION_ERROR(-20033,
        'ERROR in TValue.Assign. Ошибка CheckVal, '||
        ' Type = '||SP.TO_StrType(self.T)||
        ' N = '||TO_Char(self.N)||
        ' '||SQLERRM);
end Assign;

MEMBER PROCEDURE READ_ONLY(self IN OUT NOCOPY SP.TVALUE)
is
begin
  self.R_ONLY := 1;
end READ_ONLY;

MEMBER PROCEDURE READ_WRITE(self IN OUT NOCOPY SP.TVALUE)
is
begin
  self.R_ONLY := 0;
end READ_WRITE;
 
MEMBER PROCEDURE REQUIRED(self IN OUT NOCOPY SP.TVALUE)
is
begin
  self.R_ONLY := -1;
end REQUIRED;

end;
/
