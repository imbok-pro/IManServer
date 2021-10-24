CREATE OR REPLACE PACKAGE BODY SP.Func
-- Func package
-- by Gracheva Irina
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 08.10.2010
-- update 11.11.2011 
-- by Nikolay Krasilnikov
--        03.04.2013 25.08.2013 21.04.2015
AS

-- выбираем значения из рабочей таблицы макрокоманд
-- текущий уровень определён переменной в пакете TG
-------------------------------------------------------------------------------
FUNCTION GetTypeName(pID in NUMBER)
return VARCHAR2
is
  TmpVar SP.PAR_TYPES.NAME%TYPE;
begin
select NAME into TmpVar from SP.PAR_TYPES where ID = pID;
   return TmpVar;
   exception when no_data_found then 
     return '';
end;

-------------------------------------------------------------------------------
FUNCTION GetUserS_Value(pID in NUMBER,UsrName in VARCHAR2)
return VARCHAR2 
is
	tmpVar SP.COMMANDS.COMMENTS%type;
  RecG SP.GLOBAL_PAR_S%ROWTYPE;
  RecU SP.USERS_GLOBALS%ROWTYPE;
  n NUMBER;
  PName SP.GLOBAL_PAR_S.name%type;
  TypeID NUMBER;
begin
  select name,TYPE_ID into PName,TypeID from SP.GLOBAL_PAR_S 
       where ID = pID;
  select count(*) into n from SP.USERS_GLOBALS 
    where GL_PAR_ID = pID
      and upper(SP_USER) = upper(UsrName);
   if n = 1 then
    select * into RecU from SP.USERS_GLOBALS 
       where upper(SP_USER) = upper(UsrName)
         and GL_PAR_ID = pID;
           tmpVar := SP.Val_to_Str(SP.TVALUE(TypeID,null,0,
            				 RecU.E_VAL,RecU.N,RecU.D,RecU.S,RecU.X,RecU.Y)); 
   				return tmpVar;
    else      
     select * into RecG from SP.GLOBAL_PAR_S 
       where ID = pID;
          tmpVar := SP.Val_to_Str(SP.TVALUE(RecG.TYPE_ID,null,0,
          					RecG.E_VAL,RecG.N,RecG.D,RecG.S,RecG.X,RecG.Y)); 
  				return tmpVar;
    end if;
end;


-------------------------------------------------------------------------------
FUNCTION GetUserValueComments(pID in NUMBER,UsrName in VARCHAR2)
return VARCHAR2 
is
	tmpVar SP.COMMANDS.COMMENTS%type;
  RecG SP.GLOBAL_PAR_S%ROWTYPE;
  RecU SP.USERS_GLOBALS%ROWTYPE;
  n NUMBER;
  t NUMBER;
begin
  select TYPE_ID into t from SP.GLOBAL_PAR_S 
       where ID = pID;
  select count(*) into n from SP.USERS_GLOBALS 
    where GL_PAR_ID = pID
      and upper(SP_USER) = upper(UsrName);
   if n = 1 then
    select * into RecU from SP.USERS_GLOBALS 
       where upper(SP_USER) = upper(UsrName)
         and GL_PAR_ID = pID;
           tmpVar := SP.Val_Comments(SP.TVALUE(t,null,0,
            				 RecU.E_VAL,RecU.N,RecU.D,RecU.S,RecU.X,RecU.Y)); 
   				return tmpVar;
    else      
     select * into RecG from SP.GLOBAL_PAR_S 
       where ID = pID;
          tmpVar := SP.Val_Comments(SP.TVALUE(RecG.TYPE_ID,null,0,
          					RecG.E_VAL,RecG.N,RecG.D,RecG.S,RecG.X,RecG.Y)); 
  				return tmpVar;
    end if;
end;

End Func;
/
