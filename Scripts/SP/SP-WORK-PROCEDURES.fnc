-- SP WORK procedures
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 20.08.2010
-- update 22.09.2010 03.11.2010 17.11.2010 25.08.2013 01.10.2013 20.06.2014
--        22.06.2014 24.06.2014 15.11.2014 18.11.2014 21.09.2106 10.10.2016
--        04.12.2016 12.02.2017 28.03.2017 15.12.2020 18.04.2021 31.07.2021 
---
------------------------------------------------------------------------------- 
CREATE OR REPLACE PROCEDURE SP.CheckVal(SQLStr in VARCHAR2,
                                              Val in SP.TVALUE)
authid current_user
is
-- Проверка значения параметра. 
-- Процедура вызывается так же из триггеров парамектров.
-- Для проверки значения нужно сохранить блок pl/sql в таблице SP.PAR_TYPES.
-- Внутри блока можно пользоваться записью V.<...> (SP.TVALUE), чтобы получить
-- сведения о значении. 
-- (begin) и (end;) можно не писать.
-- В случае отрицательного результата вызвать raise_application_error, при этом
-- измененить параметр из процедуры проверки нельзя, если это разрешить, то
-- придётся повторять проверки, уже сделанные  тригерами перед вызовом блока.
-- (SP-WORK-PROCEDURES.fnc)
begin
  execute immediate('DECLARE V SP.TVALUE;'||
                    'BEGIN V:=:1; '||
									   SQLStr ||
									  'END;')
  using Val;	
exception								
  when others then
	  d('(E,N,D,S,X,Y =>'||Val.E||':'||Val.N||':'||Val.D||':'||Val.S||':'||
       Val.X||':'||Val.Y||
      ') DECLARE V SP.TVALUE;'||
      'BEGIN V:=:1; '||
			 SQLStr ||
			'END; SQLERRM => '||SQLERRM||
      'BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE(),
			'ERROR CheckVal');
		raise;							
end;
/
--
grant EXECUTE on SP.CheckVal to PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP.GPAR_REACTION(Reaction in VARCHAR2,
                                                   Par in SP.TGPAR)
-- Можно провести настройку билдера после изменения его параметра.
-- Для этого нужно сохранить блок pl/sql в таблице SP.GLOBAL_PAR_S внутри блока
-- доступна переменная p типа SP.TGPAR, содержащая значение параметра.
-- (begin) и (end;) можно не писать. (SP-WORK-PROCEDURES.fnc).
is
begin
  execute immediate('DECLARE p SP.TGPAR; BEGIN p:=:1;'||Reaction||'END;')
  using Par;
exception
  when others then
	  d('ParName=>'||Par.Name||' Reaction=>'||Reaction||' '||
    ' E=>'||Par.Val.E||
    ' N=>'||to_.str(Par.Val.N)||' D=>'||to_.str(Par.Val.D)||
    ' S=>'||Par.Val.S||' X=>'||to_.str(Par.Val.X)||
    ' Y=>'||to_.str(Par.Val.Y)||
    SQLERRM,
		'ERROR GPAR_REACTION');
    rollback;
		raise;							
end;
/
--
grant EXECUTE on SP.GPAR_REACTION to PUBLIC;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.getROOT return SP.G.TMACRO_PARS
-- Получение текущего корневого объекта модели. (SP-WORK-PROCEDURES.fnc).
is
begin
  return SP.M.ROOT;
end;
/
--
grant EXECUTE on SP.getROOT to PUBLIC;
create or replace public synonym getROOT for SP.getROOT;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.getROOT_NAME return VARCHAR2
-- Получение имени текущего корневого объекта модели. (SP-WORK-PROCEDURES.fnc).
is
begin
  return SP.Paths.Name(SP.M.ROOT('PARENT').asString, 
                       SP.M.ROOT('NAME').asString);
end;
/
--
grant EXECUTE on SP.getROOT_NAME to PUBLIC;
create or replace public synonym getROOT_NAME for SP.getROOT_NAME;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.getROOT_ID return VARCHAR2
-- Получение идентификатора текущего корневого объекта модели. 
-- Если текущий корневой объект отсутствует во внутренней модели,
-- то функция вернёт -1.
-- При построении такого объекта могло быть отключено протоколирование.
-- Если отсутствующий объект является корнем иерархии, то функция вернёт нулл.
-- (SP-WORK-PROCEDURES.fnc).
is
begin
  return SP.M.ROOT('ID').N;
end;
/
--
grant EXECUTE on SP.getROOT_ID to PUBLIC;
create or replace public synonym getROOT_ID for SP.getROOT_ID;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.getMPar_S(ModObjID in NUMBER, 
                                        ParName in VARCHAR2) return VARCHAR2
-- Получение значения параметра объекта модели в виде строки.
-- Входные параметры - идентификатор объекта и имя параметра.
-- Если идентификатор объекта нулл, то возвращаем пустую строку.
-- (SP-WORK-PROCEDURES.fnc).
is
res VARCHAR2(4000);
MO_Obj SP.V_MODEL_OBJECTS%rowtype;
begin
  if ModObjID is null then return ''; end if;
  select mp.S into res
    from SP.MODEL_OBJECT_PAR_S mp, SP.OBJECT_PAR_S cp 
    where mp.MOD_OBJ_ID = ModObjID
      and (G.S_UpEQ(cp.NAME, ParName)+G.S_UpEQ(mp.NAME, ParName)!=0)
      and mp.OBJ_PAR_ID=cp.ID(+);
  return res;       
exception
  when no_data_found then
    begin
      select cp.S into res
        from SP.OBJECTS co, SP.MODEL_OBJECTS mo, SP.OBJECT_PAR_S cp           
        where cp.NAME not in ('NAME','PARENT','OID','POID',
                              'ID','PID','USING_ROLE','EDIT_ROLE')
          and G.S_UpEQ(cp.NAME, ParName)=1
          and co.ID = mo.OBJ_ID
          and mo.ID = ModObjID
          and cp.OBJ_ID = mo.OBJ_ID;
      return res;  
    exception
      when no_data_found then  
        begin
          select * into MO_Obj from SP.V_MODEL_OBJECTS 
            where ID = ModObjID;
          -- Псевдопараметры ищем в таблице объектов.
          case ParName
            when 'NAME' then
              res := MO_obj.MOD_OBJ_NAME;
              --d('NAME '||res,'SP.TMPAR_S');
            when 'PARENT' then
              res := MO_obj.PATH;
            when 'OID' then
              res := MO_obj.OID;
            when 'POID' then
              res := MO_obj.POID;
            when 'ID' then
              res := '';
            when 'PID' then
              res := '';
            when 'USING_ROLE' then
              res := MO_obj.USING_ROLE_NAME;
            when 'EDIT_ROLE' then
              res := MO_obj.EDIT_ROLE_NAME;
          else
            RAISE_APPLICATION_ERROR(-20033,'SP.getMPar_S.'||
            ' У объекта '||MO_obj.FULL_NAME||'Отсутствует параметр '||
            nvl(ParName, 'null')||'!');
          end case;
          return res;  
        exception
         when no_data_found then  
           RAISE_APPLICATION_ERROR(-20033,'SP.getMPar_S.'||
           ' Отсутствует объект с ID = '||nvl(to_char(ModObjID),'null')||'!'); 
        end;
    end;    
end;     
/
--
grant EXECUTE on SP.getMPar_S to PUBLIC;
create or replace public synonym getMPar_S for SP.getMPar_S;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.getMPar_N(ModObjID in NUMBER, 
                                        ParName in VARCHAR2) return NUMBER
-- Получение значения параметра объекта модели в виде числа 
-- (процедура возвращает поле N).
-- Входные параметры - идентификатор объекта и имя параметра.
-- Если идентификатор объекта нулл, то возвращаем null.
-- (SP-WORK-PROCEDURES.fnc).
is
res NUMBER;
MO_Obj SP.V_MODEL_OBJECTS%rowtype;
begin
  if ModObjID is null then return null; end if;
  select mp.N into res
    from SP.MODEL_OBJECT_PAR_S mp, SP.OBJECT_PAR_S cp 
    where mp.MOD_OBJ_ID = ModObjID
      and (G.S_UpEQ(cp.NAME, ParName)+G.S_UpEQ(mp.NAME, ParName)!=0)
      and mp.OBJ_PAR_ID=cp.ID(+);
  return res;       
exception
  when no_data_found then
    begin
      select cp.N into res
        from SP.OBJECTS co, SP.MODEL_OBJECTS mo, SP.OBJECT_PAR_S cp           
        where cp.NAME not in ('NAME','PARENT','OID','POID',
                              'ID','PID','USING_ROLE','EDIT_ROLE')
          and G.S_UpEQ(cp.NAME, ParName)=1
          and co.ID = mo.OBJ_ID
          and mo.ID = ModObjID
          and cp.OBJ_ID = mo.OBJ_ID;
      return res;  
    exception
      when no_data_found then  
        begin
          select * into MO_Obj from SP.V_MODEL_OBJECTS 
            where ID = ModObjID;
          -- Псевдопараметры ищем в таблице объектов.
          case ParName
            when 'NAME' then
              res := null;
              --d('NAME '||res,'SP.TMPAR_N');
            when 'PARENT' then
              res := null;
            when 'OID' then
              res := null;
            when 'POID' then
              res := null;
            when 'ID' then
              res := MO_obj.ID;
            when 'PID' then
              res := MO_obj.PARENT_MOD_OBJ_ID;
            when 'USING_ROLE' then
              res := MO_obj.USING_ROLE_ID;
            when 'EDIT_ROLE' then
              res := MO_obj.EDIT_ROLE_ID;
          else
            RAISE_APPLICATION_ERROR(-20033,'SP.getMPar_N.'||
            ' У объекта '||MO_obj.FULL_NAME||'Отсутствует параметр '||
            nvl(ParName, 'null')||'!');
          end case;  
          return res;  
        exception
         when no_data_found then  
           RAISE_APPLICATION_ERROR(-20033,'SP.getMPar_N.'||
           ' Отсутствует объект с ID = '||nvl(to_char(ModObjID),'null')||'!'); 
        end;
    end;    
end;     
/
--
grant EXECUTE on SP.getMPar_N to PUBLIC;
create or replace public synonym getMPar_N for SP.getMPar_N;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.getMPar_D(ModObjID in NUMBER, 
                                        ParName in VARCHAR2) return DATE
-- Получение значения параметра объекта модели в виде числа (процедура возвращает поле N).
-- Входные параметры - идентификатор объекта и имя параметра.
-- Если идентификатор объекта нулл, то возвращаем null.
-- (SP-WORK-PROCEDURES.fnc).
is
res DATE;
MO_Obj SP.V_MODEL_OBJECTS%rowtype;
begin
  if ModObjID is null then return null; end if;
  select mp.D into res
    from SP.MODEL_OBJECT_PAR_S mp, SP.OBJECT_PAR_S cp 
    where mp.MOD_OBJ_ID = ModObjID
      and (G.S_UpEQ(cp.NAME, ParName)+G.S_UpEQ(mp.NAME, ParName)!=0)
      and mp.OBJ_PAR_ID=cp.ID(+);
  return res;       
exception
  when no_data_found then
    begin
      select cp.D into res
        from SP.OBJECTS co, SP.MODEL_OBJECTS mo, SP.OBJECT_PAR_S cp           
        where G.S_UpEQ(cp.NAME, ParName)=1
          and co.ID = mo.OBJ_ID
          and mo.ID = ModObjID
          and cp.OBJ_ID = mo.OBJ_ID;
      return res;  
    exception
      when no_data_found then  
        begin
          select * into MO_Obj from SP.V_MODEL_OBJECTS 
            where ID = ModObjID;
          RAISE_APPLICATION_ERROR(-20033,'SP.getMPar_D.'||
          ' У объекта '||MO_obj.FULL_NAME||'Отсутствует параметр '||
          nvl(ParName, 'null')||'!');
        exception
         when no_data_found then  
           RAISE_APPLICATION_ERROR(-20033,'SP.getMPar_D.'||
           ' Отсутствует объект с ID = '||nvl(to_char(ModObjID),'null')||'!'); 
        end;
    end;    
end;     
/
--
grant EXECUTE on SP.getMPar_D to PUBLIC;
create or replace public synonym getMPar_D for SP.getMPar_D;
--
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.getMPar_E(ModObjID in NUMBER, 
                                        ParName in VARCHAR2) return VARCHAR
-- Получение имени значения параметра объекта модели.
-- (Функция возвращает поле E_VAL).
-- Входные параметры - идентификатор объекта и имя параметра.
-- Если идентификатор объекта нулл, то возвращаем пустую строку.
-- (SP-WORK-PROCEDURES.fnc).
is
res VARCHAR2(4000);
MO_Obj SP.V_MODEL_OBJECTS%rowtype;
begin
  if ModObjID is null then return ''; end if;
  select mp.E_VAL into res
    from SP.MODEL_OBJECT_PAR_S mp, SP.OBJECT_PAR_S cp 
    where mp.MOD_OBJ_ID = ModObjID
      and (G.S_UpEQ(cp.NAME, ParName)+G.S_UpEQ(mp.NAME, ParName)!=0)
      and mp.OBJ_PAR_ID=cp.ID(+);
  return res;       
exception
  when no_data_found then
    begin
      select cp.E_VAL into res
        from SP.OBJECTS co, SP.MODEL_OBJECTS mo, SP.OBJECT_PAR_S cp           
        where G.S_UpEQ(cp.NAME, ParName)=1
          and co.ID = mo.OBJ_ID
          and mo.ID = ModObjID
          and cp.OBJ_ID = mo.OBJ_ID;
      return res;  
    exception
      when no_data_found then  
        begin
          select * into MO_Obj from SP.V_MODEL_OBJECTS 
            where ID = ModObjID;
          RAISE_APPLICATION_ERROR(-20033,'SP.getMPar_E.'||
          ' У объекта '||MO_obj.FULL_NAME||'Отсутствует параметр '||
          nvl(ParName, 'null')||'!');
        exception
         when no_data_found then  
           RAISE_APPLICATION_ERROR(-20033,'SP.getMPar_E.'||
           ' Отсутствует объект с ID = '||nvl(to_char(ModObjID),'null')||'!'); 
        end;
    end;    
end;     
/
--
grant EXECUTE on SP.getMPar_E to PUBLIC;
create or replace public synonym getMPar_E for SP.getMPar_E;

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION SP.TValueTest(V in out NOCOPY SP.TVALUE, 
                                         Correct in BOOLEAN Default true) 
return VARCHAR2
-- Проверка и если установлен параметр Correct,
-- то корректировка до допустимого значения V.
-- Функция возвращает пустую строку, если проверка или корректировка удалась,
-- иначе функция возвращает сообщение об ошибке.
-- Значение V==null - правильное/
-- (SP-WORK-PROCEDURES.fnc).
is
  result VARCHAR2(4000);
  CheckVal SP.PAR_TYPES.CHECK_VAL%TYPE;
  tmpVar NUMBER;
begin
  if V is null then return ''; end if;
  BEGIN
    SELECT pt.CHECK_VAL INTO CheckVal 
      FROM SP.PAR_TYPES pt 
      WHERE pt.ID = V.T;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN 
      result :=  ' Тип с идентификатором '||nvl(to_char(V.t), 'null')||
                 ' не найден!';
      return result;           
  END;
  IF CheckVal IS NOT NULL THEN 
    BEGIN
      SP.CheckVal(CheckVal,V);
    EXCEPTION
      WHEN OTHERS THEN 
        result :=  ' Ошибка проверки значения '||
                   ' : '||SQLERRM||'!';
        return result;           
    END;   
  ELSE    
    SELECT count(*) INTO tmpVar FROM SP.ENUM_VAL_S e
      WHERE e.TYPE_ID = V.t 
         AND (G.S_UpEQ(e.E_VAL, V.E)
           + G.S_EQ(e.N, V.N)
           + G.S_EQ(e.D, V.D)
           + G.S_UpEQ(e.S, V.S)
           + G.S_EQ(e.X, V.X)
           + G.S_EQ(e.Y, V.Y)=6);
     IF tmpVar =0 THEN
       if Correct then  
         select E_VAL,N,D,S,X,Y into V.E,V.N,V.D,V.S,V.X,V.Y 
           from
           (
             select E_VAL,N,D,S,X,Y from SP.ENUM_VAL_S 
               where TYPE_ID=V.T
               order by N
           )
           where rownum=1;
         return '';
       else   
         result := 'Значение '||V.E||' не найдено для типа'||to_char(V.T)||'!';
         return result;
       end if;   
    END IF;         
  END IF;
  return '';
end;     
/
--
grant EXECUTE on SP.TValueTest to PUBLIC;
--
-- end of file

