CREATE OR REPLACE PACKAGE body WForms.Params 
-- Params PACKAGE body
-- by Irina Gracheva 
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 30.09.2010  
-- update 12.10.10 01.12.2010 10.12.2010 14.12.2010 
-- by Nikolay Krasilnikov
-- 08.02.2012 08.07.2015 20.08.2015 09.11.2017 13.12.2017 14.01.2021
-- 19.01.2021 27.01.2021 17.01.2021
 
AS
-- (Params.pkb )
-- Параметры текущей формы 
curAppName WForms.FORM_SIGN_S.APP_NAME%type;
curFormName WForms.FORM_SIGN_S.FORM_NAME%type;
curSingnature NUMBER;
curUser VARCHAR2(30);
curSignatureID NUMBER;

-------------------------------------------------------------------------------
FUNCTION S_UpEQ(a1 VARCHAR2, a2 VARCHAR2) return NUMBER
is
tmpVar BOOLEAN;
begin
tmpVar:=upper(a1)=upper(a2);
if tmpVar is not null then
  return case tmpVar when true then 1 else 0 end;
end if;
if a1 is null and a2 is null then return 1; end if;
return 0;
end S_UpEQ;

-------------------------------------------------------------------------------
FUNCTION S_EQ(a1 NUMBER, a2 NUMBER) return NUMBER
is
tmpVar BOOLEAN;
begin
tmpVar:=a1=a2;
if tmpVar is not null then
  return case tmpVar when true then 1 else 0 end;
end if;
if a1 is null and a2 is null then return 1; end if;
return 0;
end S_EQ;

-------------------------------------------------------------------------------
FUNCTION notEQ(a1 NUMBER, a2 NUMBER) return BOOLEAN
is
tmpVar BOOLEAN;
begin
tmpVar:=a1!=a2;
if tmpVar is not null then return tmpVar; end if;
if a1 is null and a2 is null then return false; end if;
return true;
end notEQ;

-------------------------------------------------------------------------------
FUNCTION notUpEQ(a1 VARCHAR2, a2 VARCHAR2) return BOOLEAN
is
tmpVar BOOLEAN;
begin
tmpVar:=upper(a1)!=upper(a2);
if tmpVar is not null then return tmpVar; end if;
if a1 is null and a2 is null then return false; end if;
return true;
end notUpEQ;

-------------------------------------------------------------------------------
function Get(
   pAppName VARCHAR2,
   pFormName VARCHAR2,
   pSingnature NUMBER) 
   return TFORM_PARAMS pipelined
is
  p TFORM_PARAM;
begin
  for param in(
               select OBJ_NAME,PROP_NAME,PROP_VALUE,ORD,PROP_CLOB 
               from WForms.FORM_PARAMS 
               where FS_ID = (
      select ID from
      (select ID,1 q
        from WForms.FORM_SIGN_S f
        where upper(APP_NAME) = upper(pAppName) 
          and upper(FORM_NAME) = upper(pFormName)
          and upper(USER_NAME) = upper(curUser)
          and upper(SIGNATURE) = upper(pSingnature)
      union all
      select ID,2 q
        from WForms.FORM_SIGN_S f
        where upper(APP_NAME) = upper(pAppName) 
          and upper(FORM_NAME) = upper(pFormName)
          and (USER_NAME is null)
          and upper(SIGNATURE) = upper(pSingnature)
      order by q 
      )   
      where rownum = 1           )
               order by OBJ_NAME,ORD
              )
  loop  
    p.OBJ_NAME := param.OBJ_NAME;
    p.PROP_NAME := param.PROP_NAME;
    p.PROP_VALUE := param.PROP_VALUE;
    p.ORD := param.ORD;
    p.PROP_CLOB := param.PROP_CLOB;
    pipe row(p);
  end loop;        
  return;
end; 

-------------------------------------------------------------------------------
procedure testSign(
  pAppName VARCHAR2,
  pFormName VARCHAR2,
  pSingnature NUMBER)
is
begin
  --  Если пришедшая и текущая сигнатура не совпадают,   
  if   notUpEQ(curAppName,pAppName) 
    or notUpEQ(curFormName,pFormName) 
    or notEQ(curSingnature,pSingnature)
  then
    -- Если пришедшая и текущая сигнатура не совпадают, а commit пропущен
     if curSignatureID is not null then
      rollback;
      d('Незавершенная транзакция: cur '
        ||curAppName||' '||curFormName||' '||s_user||' '||curSingnature
        ||' p '||pAppName||' '||pFormName||' '||pSingnature,
         ' ERROR in FormParams.testSign');
    end if;
    curAppName := pAppName; 
    curFormName := pFormName; 
    curSingnature := pSingnature;
    -- то ищем текущую сингатуру.
    begin
      select ID into curSignatureID
        from WForms.FORM_SIGN_S f
        where S_UpEQ(APP_NAME,pAppName)
            + S_UpEQ(FORM_NAME,pFormName)
            + S_EQ(curSingnature,pSingnature)
            + S_UpEQ(USER_NAME,curUser) = 4;
    exception when no_data_found then
      curSignatureID := null;
    end;
    if curSignatureID is null then
      -- Cоздаем новую сигнатуру
      select WForms.SEQ.nextval into curSignatureID from dual;
      curSignatureID:= curSignatureID + REPLICATION.Node_ID;
      insert into WForms.FORM_SIGN_S ( 
        ID, USER_NAME, APP_NAME, FORM_NAME, SIGNATURE ) 
        values (
        curSignatureID, curUser, pAppName, pFormName, pSingnature);
    end if;              
  end if;  
end testSign;
    
-------------------------------------------------------------------------------
procedure SetValue(
  pAppName VARCHAR2,
  pFormName VARCHAR2,
  pSingnature NUMBER,
  pObjName VARCHAR2,
  pPropName   VARCHAR2,
  pPropValue  VARCHAR2,
  pOrd NUMBER,
  pPropClob CLOB default null)
is
begin
  testSign( pAppName, pFormName, pSingnature ); 
  -- Записываем данные.  
  update WForms.FORM_PARAMS set
    PROP_VALUE = pPropValue,
    ORD = pOrd,
    PROP_CLOB = pPropClob
  where
      FS_ID = curSignatureID 
    and
      OBJ_NAME = pObjName 
    and
      PROP_NAME = pPropName;
  if sql%notfound then
    insert into WForms.FORM_PARAMS
      (FS_ID, OBJ_NAME, PROP_NAME, PROP_VALUE, ORD, PROP_CLOB)
      values(curSignatureID, pObjName, pPropName, pPropValue, pOrd, pPropClob);
  end if;
end;

-------------------------------------------------------------------------------
procedure DelObject(
  pAppName VARCHAR2,
  pFormName VARCHAR2,
  pSingnature NUMBER,
  pObjName VARCHAR2)
is
begin
  testSign( pAppName, pFormName, pSingnature ); 
  -- Удаляем данные.  
  delete from WForms.FORM_PARAMS
  where
      FS_ID = curSignatureID 
    and
      OBJ_NAME = pObjName;
end;

-------------------------------------------------------------------------------
procedure DelValue(
  pAppName VARCHAR2,
  pFormName VARCHAR2,
  pSingnature NUMBER,
  pObjName VARCHAR2,
  pPropName VARCHAR2)
is
begin
  testSign( pAppName, pFormName, pSingnature ); 
  -- Удаляем данные.  
  delete from WForms.FORM_PARAMS 
  where
      FS_ID = curSignatureID 
    and
      OBJ_NAME = pObjName 
    and
      PROP_NAME = pPropName;
end DelValue;

-------------------------------------------------------------------------------
procedure SetCommit(
  pAppName VARCHAR2,
  pFormName VARCHAR2,
 	pSingnature NUMBER)
is
begin
  --  Если пришедшая и текущая сигнатура не совпадают,   
  if   (upper(curAppName) != upper(pAppName)) 
    or (curAppName is null and pAppName is not null)
    or (curAppName is not null and pAppName is null)
    or (upper(curFormName) != upper(pFormName)) 
    or (curFormName is null and pFormName is not null)
    or (curFormName is not null and pFormName is null)
    or (upper(curSingnature) != upper(pSingnature))
    or (curSingnature is null and pSingnature is not null)
    or (curSingnature is not null and pSingnature is null)
  then
		-- то откатываем записанные данные, 
    rollback;
		-- записываем диагностическое сообщение, 
    d('Незавершенная транзакция: '
      ||pAppName||' '||pFormName||' '||s_user||' '||pSingnature||' '
      ||curAppName||' '||curFormName||' '||curSingnature,
     	' ERROR in FormParams.SetCommit!');
		-- иначе - commit;
    else  
      commit;
    end if;
  -- Сбрасываем значение текущей сигнатуры в null
  curAppName := null;
  curFormName := null;
  curSingnature := null;
  curSignatureID := null;
end;

-------------------------------------------------------------------------------
procedure SetDefault(
  pAppName VARCHAR2,
  pFormName VARCHAR2,
 	pSingnature NUMBER,
  pUser VARCHAR2 default null) 
is
  CurSign NUMBER;
  tmpVar NUMBER;
  s VARCHAR2(4000);
begin
  CurSign := null;
  if pUser is null then
    s := curUser;
  else
    s:=pUser;  
  end if;
  begin
    select ID into CurSign 
      from WForms.FORM_SIGN_S f
      where upper(APP_NAME) = upper(pAppName) 
        and upper(FORM_NAME) = upper(pFormName)
        and upper(USER_NAME) = upper(s)
        and (SIGNATURE = pSingnature);
     exception when no_data_found then
      s := 'Сигнатуры '||to_char(pSingnature)||
      	' формы  '||pAppName||' для приложения '||pFormName||
        ' не существует у заданного пользователя!';
      d(s,' ERROR in WForms.FormParams.SetDefault');
      raise_application_error(-20033,s);
  end;
  delete from WForms.FORM_SIGN_S
  where USER_NAME is null
    and (upper(APP_NAME) = upper(pAppName)) 
    and (upper(FORM_NAME) = upper(pFormName))
    and ( SIGNATURE = pSingnature);
  insert into WForms.FORM_SIGN_S ( 
    USER_NAME, APP_NAME, FORM_NAME, SIGNATURE ) 
  values (
    null,pAppName,pFormName,pSingnature)
  returning ID into tmpVar;
  d('CurSign = '||to_char(CurSign),'WForms.FormParams.SetDefault');
  d('tmpVar = '||to_char(tmpVar),'WForms.FormParams.SetDefault');
  insert into WForms.FORM_PARAMS(FS_ID,OBJ_NAME,PROP_NAME,PROP_VALUE,ORD)
    select tmpVar,OBJ_NAME,PROP_NAME,PROP_VALUE,ORD 
      from WForms.FORM_PARAMS 
      where FS_ID = CurSign;
  commit;
end;  

--
begin
  curAppName := null;
  curFormName := null;
  curSingnature := null;
  curUser := S_User;
  curSignatureID := null;
End Params;
/
