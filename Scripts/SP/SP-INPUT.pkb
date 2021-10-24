CREATE OR REPLACE PACKAGE BODY SP.INPUT
-- SP InPut packagebody
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 01.10.2010
-- update 19.10.2010 28.10.2010 22.11.2010 10.12.2010 15.12.2010 16.12.2010
--        21.12.2010 27.12.2010 12.01.2011 20.12.2011 16.01.2012 15.03.2012
--        03.06.2013 10.06.2013 13.06.2013 16.06.2013 22.08.2013 25.08.2013
--        28.08.2013 27.09.2013 04.10.2013 11.10.2013 25.10.2013 27.11.2013
--        13.02.2014 13.06.2013 14.06.2014 15.07.2014 30.08.2014 08.09.2014
--        27.10.2014 04.11.2014 06.11.2014 15.11.2014 26.11.2014 28.11.2014
--        03.01.2015 06.01.2014-07.01.2015 16.02.2015 01.03.2015 11.03.2015
--        22.03.2015 23.03.2015 25.03.2015 31.03.2015 20.04.2015-21.04.2015
--        16.05.2015 08.07.2015 10.07.2015 13.07.2015 25.08.2015 14.07.2016
--        21.07.2016 23.07.2015 08.08.2016 10.10.2016 17.10.2016 02.11.2016
--        10.04.2017 12.04.2017 17.01.2018-19.01.2018 04.12.2018 06.04.2021
--        07.04.2021 09.04.2021 12.04.2021-13.04.2021 18.04.2021-19.04.2021
--        08.09.2021
AS
CurSignatureID NUMBER;
imp_objects NUMBER;
-------------------------------------------------------------------------------
-- Внутренняя функция. Получаем идентификатор объекта по его имени и группе.
-- Если имя является полным, то группа игнорируется.
-- Если имя простое и группа нулл, то ищем только по простому имени для
-- совместимости с ранними версиями. 
-- Идентификатор группы в этом случае приравниваем 2.
-- Функция возбуждает исключение, если объект определён неоднозначно 
-- или группа не найдена.
-- Если объект не найден, то полю "ID" в возвращаемой записи присваиваем
-- значение "0". 
FUNCTION GetIDbyName(FName IN VARCHAR2, GName IN VARCHAR2,
                     CName IN VARCHAR2, -- имя вызвавшей процедуры
                     Ignore_Errors IN BOOLEAN DEFAULT false)
return TCatObject
is 
  o TCatObject;
  pos NUMBER;
  tmpName VARCHAR2(4000);
begin
  if instr(FName,'.')=0 then
    if GName is null then
      begin
		    select Name,ID,GROUP_ID into o from SP.OBJECTS 
		      where upper(NAME)=upper(FName);
	    exception
	      when too_many_rows then
          if Ignore_Errors then
            o.Name := FName;
            o.ID := 0;
            o.GID := 2;
            d('SP.INPUT.'||CName||' WARNING',
              'Объект определён неоднозначно!'||
              'Необходимо задать группу для объекта '||FName||'!');
          else
            raise_application_error(-20033,
              'SP.INPUT.'||CName||'.'||
              'Необходимо задать группу для объекта '||FName||'!');
          end if;
			  when no_data_found then
			    o.Name := FName;
          o.ID := 0;
          o.GID := 2;
			end;    
    else
      begin 
		    select SHORT_NAME, ID, GROUP_ID into o from SP.V_OBJECTS 
          where upper(FULL_NAME)=upper(GName)||'.'||upper(FName);
	    exception
			  when no_data_found then
			    o.Name := FName;
          o.ID := 0;
          begin
            select ID into o.GID from SP.GROUPS 
              where upper(NAME)=upper(GName);
          exception
            when no_data_found then  
              if Ignore_Errors then
                o.Name := FName;
                o.ID := 0;
                o.GID := 2;
                d('SP.INPUT.'||CName||' WARNING',
                  'Группа '||nvl(GName,'null')||' не существует!');
              else
                raise_application_error(-20033,
                  'SP.INPUT.'||CName||'. Группа '||nvl(GName,'null')||
                  ' не существует!');
              end if;  
          end;
			end;    
    end if;    
  else
    begin
    select SHORT_NAME, ID, GROUP_ID into o from SP.V_OBJECTS 
      where upper(FULL_NAME)=upper(FName);
		exception
		  when no_data_found then
        -- Выделяем короткое имя.
        pos := instr(FName,'.',-1);
		    o.Name := substr(FName,pos + 1);
        o.ID := 0;
        tmpName := substr(FName, 1, pos - 1);
        begin
          select ID into o.GID from SP.GROUPS 
            where upper(NAME)=upper(tmpName);
        exception
          when no_data_found then  
            if Ignore_Errors then
              o.Name := FName;
              o.ID := 0;
              o.GID := 2;
              d('SP.INPUT.'||CName||' WARNING',
                'Группа '||nvl(GName,'null')||' не существует!');
            else
  	          raise_application_error(-20033,
		            'SP.INPUT.'||CName||'. Группа '||nvl(tmpName,'null')||
                ' не существует!');
            end if;    
        end;
    end;  
  end if;    
  return o;
end GetIDbyName;  
-------------------------------------------------------------------------------
PROCEDURE RESET
IS
BEGIN
	-- 1
	FMT := NULL;
	-- 2
	NLS := NULL;
	-- 3
	CurType := NULL;
	-- 4
	CurObject := NULL;
	-- 5
	CurModelObject := NULL;
	-- 6
	CurDocGroupName := '';
	-- 7
	CurMacroCommand := NULL;
	-- 8
	CurMacroLine := NULL;
	-- 9
	CurMacroLineRef := NULL;
	-- 10
	CurUser := NULL;
	-- 11
	CurPOID := '';
	-- 12
	CurParent := '\';
	-- 13
	CurModel := NULL; 
	-- 14
	CurModelObjectParent := NULL;
	-- 15
	CurAppName := NULL;
	-- 16
	CurFormName := NULL;
	-- 17
	CurSignature := NULL;
	-- 18
	CurFormUserName := NULL;
	-- 19
	CurFormObjectName := NULL;
  -- 20
  CurParName := '';
  -- 21
  CurArrName  := '';
  -- 22
  CurArrGroup := '';
  -- Признак исправления ошибочных именованных значений.
  Safe := false;
END RESET;

-------------------------------------------------------------------------------
PROCEDURE SET_NLS(DFMT IN VARCHAR2, DNLS IN VARCHAR2)
IS
BEGIN
	FMT:=DFMT;
	NLS:=DNLS;
END SET_NLS;

-------------------------------------------------------------------------------
PROCEDURE ROLE(NAME IN VARCHAR2, Comments IN VARCHAR2, ORA in NUMBER)
IS
pName VARCHAR2(60);
EM VARCHAR2(4000);
pComments SP.COMMANDS.COMMENTS%type;
tmpVar NUMBER;
pOra NUMBER;
BEGIN
  pName:=NAME;
  pComments:=Comments;
  pORA := ORA;
  begin
    INSERT INTO SP.V_PRIM_Roles(NAME, COMMENTS, ORA) 
      VALUES(pName, pComments, pORA);
  exception
    when others then
      EM:= SQLERRM;
      -- Если не смогли создать роль, то обновляем её комментарий,
      -- предполагая, что она существует.
      begin
        select ID into tmpVar from SP.V_PRIM_Roles where NAME = pName;
        update SP.V_PRIM_Roles set
          COMMENTS = pCOMMENTS,
          ORA = pORA
        where ID = tmpVar;  
      exception
        -- Если же роль не существует, то показываем её первичную ошибку.
        when others then 
          raise_application_error(2033, 'SP.INPUT.ROLE '||SQLERRM);
      end;
  end;
END ROLE;

PROCEDURE ROLE_REL(NAME IN VARCHAR2, PARENT IN VARCHAR2)
IS
pName VARCHAR2(60);
pPARENT VARCHAR2(60);
BEGIN
  pName:=NAME;
  pPARENT:=PARENT;
  INSERT into SP.V_Roles (NAME, PARENT) values (pName, pPARENT);
END ROLE_REL;

-------------------------------------------------------------------------------
PROCEDURE USER(NAME IN VARCHAR2,PSW IN VARCHAR2)
IS
pName VARCHAR2(60);
BEGIN
  pName:=NAME;
  -- Если пользователь уже существует в системе, то изменяем его пароль.
  INSERT INTO SP.V_USERS_GLOBALS (SP_USER, NAME, S_VALUE) 
    VALUES(pName, 'USER_PWD', PSW);
END USER;

-------------------------------------------------------------------------------
PROCEDURE UserRole(NAME IN VARCHAR2, RoleName IN VARCHAR2)
is 
begin
  SP.GRANT_USER_ROLE(NAME, RoleName);
end UserRole;

-------------------------------------------------------------------------------
PROCEDURE SEQ(NAME IN VARCHAR2, LAST_NUM IN NUMBER)
IS
S VARCHAR2(4000);
BEGIN
  FOR SQ in (SELECT SEQUENCE_OWNER, SEQUENCE_NAME,
                    MIN_VALUE, MAX_VALUE, INCREMENT_BY, 
                    CYCLE_FLAG, ORDER_FLAG, CACHE_SIZE, LAST_NUMBER
               from SYS.DBA_SEQUENCES  
               where SEQUENCE_OWNER = 'SP_IM' and SEQUENCE_NAME = NAME)
  LOOP 
    IF SQ.LAST_NUMBER = LAST_NUM then
      return;
    END IF;            
    S:='DROP SEQUENCE SP_IM.'||SQ.SEQUENCE_NAME;
    d(s,'SP.INPUT.SEQ');
    execute immediate(S);
    S:= 'CREATE SEQUENCE SP_IM.'||SQ.SEQUENCE_NAME||
			  ' START WITH '||to_char(LAST_NUM + SQ.INCREMENT_BY*2 )||
			  ' INCREMENT BY '||SQ.INCREMENT_BY||
			  ' MAXVALUE '||SQ.MAX_VALUE||
			  ' MINVALUE '||SQ.MIN_VALUE;
	  IF SQ.CYCLE_FLAG = 'Y' then
	    S:= S||' CYCLE';
	  ELSE
	    S:= S||' NOCYCLE';
	  END IF;
	  IF SQ.CACHE_SIZE >= 2 then
	    S:= S||' CACHE '||SQ.CACHE_SIZE;
	  ELSE
	    S:= S||' NOCACHE';
	  END IF;
	  IF SQ.ORDER_FLAG = 'Y' then
	    S:= S||' ORDER';
	  ELSE
	    S:= S||' NOORDER';
    END IF;
    d(s,'SP.INPUT.SEQ');
    execute immediate(S);
    S := 'GRANT SELECT ON SP_IM.'||SQ.SEQUENCE_NAME||' TO PUBLIC';
    execute immediate(S);
  END LOOP;           
END SEQ;


-------------------------------------------------------------------------------
PROCEDURE "Type"(
  NAME IN VARCHAR2,
  ImageIndex IN NUMBER DEFAULT NULL,
	Comments IN VARCHAR2 DEFAULT NULL,
  -- Если блок проверки не определён, то значение именованное,
  -- и следующие поля несущественны.
  CheckVal IN VARCHAR2 DEFAULT NULL,
	StringToVal IN VARCHAR2 DEFAULT NULL,
	ValToString IN VARCHAR2 DEFAULT NULL,
	SetOfValues IN VARCHAR2 DEFAULT NULL,
  GROUP_NAME IN VARCHAR2 DEFAULT NULL, 
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL
  )
IS
  pName VARCHAR2(128);
  pComments SP.COMMANDS.COMMENTS%type;
  V_Type SP.V_TYPES%ROWTYPE;
  pDATE DATE;
  pUSER VARCHAR2(60);
  new_group_id NUMBER;
BEGIN
  pName:=NAME;
  pComments:=Comments;
  if MDATE is null then 
    pDATE := to_Date('05-01-2014','dd-mm-yyyy');
  else
	  pDATE:=CASE
		         WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
		           TO_DATE(MDATE,FMT,'NLS_DATE_LANGUAGE ='||NLS)
		         WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
		           TO_DATE(MDATE,FMT)
--		         WHEN (DFMT IS NULL) AND (NLS IS NULL) THEN
--		           TO_DATE(MDATE)
	         ELSE TO_DATE(MDATE)END;
  end if;
  if MUSER is null then
    pUser := 'PROG';
  else
    pUSER := MUSER;
  end if;        
  -- Если тип существует, то изменяем только те поля, значения которых не нулл.
  SELECT * INTO V_Type FROM SP.V_TYPES t
    WHERE UPPER(t.NAME)=UPPER(pName);
  -- Если имя группы не нулл, то
  if GROUP_NAME is not null then
    -- находим идентификатор группы, которой принадлежит данный тип,
    begin
      select ID into new_group_id from SP.GROUPS
        where upper(NAME) = upper (GROUP_NAME);
    exception
      when no_data_found then
        -- Если группа отсутствует, то добавляем группу 
        insert into SP.GROUPS (NAME) values(GROUP_NAME) 
        returning ID into new_group_id;
        -- и привязываем её к группе типов по умолчанию. 
        BGroup(NAME => GROUP_NAME, Parent_Name => 'Types'); 
    end;
  end if; 
  UPDATE SP.V_TYPES t SET
    COMMENTS=
      CASE
        WHEN pComments IS NOT NULL THEN pComments
      ELSE V_Type.COMMENTS
      END,
    IM_ID=
      CASE
        WHEN ImageIndex IS NOT NULL THEN ImageIndex
      ELSE V_Type.IM_ID
      END,
    CHECK_VAL=
      CASE
        WHEN CheckVal IS NOT NULL THEN CheckVal
      ELSE V_Type.CHECK_VAL
      END,
    VAL_TO_STRING=
      CASE
        WHEN ValToString IS NOT NULL THEN ValToString
      ELSE V_Type.VAL_TO_STRING
      END,
    STRING_TO_VAL=
      CASE
        WHEN StringToVal IS NOT NULL THEN StringToVal
      ELSE V_Type.STRING_TO_VAL
      END,
    SET_OF_VALUES=
      CASE
        WHEN SetOfValues IS NOT NULL THEN SetOfValues
      ELSE V_Type.SET_OF_VALUES
      END
    WHERE ID=V_Type.ID;
EXCEPTION
  -- Если тип не существует, то добавляем.
  WHEN NO_DATA_FOUND THEN
	  INSERT INTO SP.V_TYPES (NAME,IM_ID,COMMENTS,
      CHECK_VAL, VAL_TO_STRING, STRING_TO_VAL, SET_OF_VALUES,
      GROUP_ID, M_DATE, M_USER)
	  VALUES (pName,ImageIndex,pComments,
      CheckVal, ValToString, StringToVal, SetOfValues,
      new_group_id, pDATE, pUSER);
END "Type";

-------------------------------------------------------------------------------
PROCEDURE Enum(
  NAME IN VARCHAR2,
	Comments IN VARCHAR2,
  ImageIndex IN NUMBER DEFAULT NULL,
  EType IN VARCHAR2 DEFAULT NULL,
  EN IN NUMBER DEFAULT NULL,
  ED IN VARCHAR2 DEFAULT NULL,
  DFMT IN VARCHAR2 DEFAULT NULL,
  DNLS IN VARCHAR2 DEFAULT NULL,
  ES IN VARCHAR2 DEFAULT NULL,
	EX IN NUMBER DEFAULT NULL,
	EY IN NUMBER DEFAULT NULL,
  GROUP_NAME IN VARCHAR2 DEFAULT NULL, 
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL
  )
IS
  pComments SP.COMMANDS.COMMENTS%type;
  InD DATE;
  tmpVar NUMBER;
  i NUMBER;
  pDATE DATE;
  pUSER VARCHAR2(60);
  new_group_id NUMBER;
BEGIN
  dd('FMT '||nvl(FMT, 'null')||' NLS'||nvl(NLS, 'null'),'SP.INPUT.Enum');
  pComments:=Comments;
  -- Если тип не нулл, то находим его идентификатор.
  IF EType IS NOT NULL THEN CurType:=SP.to_type(EType); END IF;
  IF (DNLS IS NOT NULL) AND (DFMT IS NULL) THEN
    RAISE_APPLICATION_ERROR(-20033,
      'SP.INPUT.ENUM. Отсутствует формат даты!' );
  END IF;
  IF CurType IS NULL THEN
    RAISE_APPLICATION_ERROR(-20033,
      'SP.INPUT.ENUM. Не определён тип!' );
  END IF;
	IF DFMT IS NOT NULL THEN FMT:=DFMT; END IF;
	IF DNLS IS NOT NULL THEN NLS:=DNLS; END IF;
  InD:=CASE
         WHEN ED IS NULL THEN
           null
         WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
           TO_DATE(ED,FMT,'NLS_DATE_LANGUAGE ='||NLS)
         WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
           TO_DATE(ED,FMT)
         WHEN (DFMT IS NULL) AND (NLS IS NULL) THEN
           TO_DATE(ED)
       ELSE TO_DATE(ED)END;
  if MDATE is null then 
    pDATE := to_Date('05-01-2014','dd-mm-yyyy');
  else
	  pDATE:=CASE
		         WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
		           TO_DATE(MDATE,FMT,'NLS_DATE_LANGUAGE ='||NLS)
		         WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
		           TO_DATE(MDATE,FMT)
		         WHEN (DFMT IS NULL) AND (NLS IS NULL) THEN
		           TO_DATE(MDATE)
	         ELSE TO_DATE(MDATE)END;
  end if;
  if MUSER is null then
    pUser := 'PROG';
  else
    pUSER := MUSER;
  end if;        
  -- Если имя группы не нулл, то
  if GROUP_NAME is not null then
    -- находим идентификатор группы, которой принадлежит данный тип,
    begin
      select ID into new_group_id from SP.GROUPS
        where upper(NAME) = upper (GROUP_NAME);
    exception
      when no_data_found then
        -- Если группа отсутствует, то добавляем группу 
        insert into SP.GROUPS (NAME) values(GROUP_NAME) 
          returning ID into new_group_id;
        -- и привязываем её к группе имён значений по умолчанию. 
        BGroup(NAME => GROUP_NAME, Parent_Name => 'Enums'); 
    end;
  end if; 
  SELECT E_ID INTO tmpVar FROM V_ENUMS
    WHERE (UPPER(E_VAL)=UPPER(NAME)) AND (UPPER(TYPE_NAME)=UPPER(CurType));
  IF   (EN IS NOT NULL) OR (ED IS NOT NULL)
    OR (ES IS NOT NULL) OR (EX IS NOT NULL)OR (EY IS NOT NULL)
  THEN
	  UPDATE SP.V_ENUMS SET
	    N=EN,
      D=InD,
      S=ES,
      X=EX,
      Y=EY,
      M_DATE=pDATE,
      M_USER=pUSER
	    WHERE E_ID=tmpVar;
  END IF;
  IF ImageIndex IS NOT NULL THEN
	  UPDATE SP.V_ENUMS SET
	    E_IM_ID=ImageIndex
	    WHERE E_ID=tmpVar;
  END IF;
  IF GROUP_NAME IS NOT NULL THEN
	  UPDATE SP.V_ENUMS SET
      GROUP_ID = new_group_id
	    WHERE E_ID=tmpVar;
  END IF;
  IF pComments IS NOT NULL THEN
	  UPDATE SP.V_ENUMS SET
	    VAL_COMMENTS=pComments
	    WHERE E_ID=tmpVar;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
	  INSERT INTO SP.V_ENUMS
    (TYPE_ID, E_VAL, VAL_COMMENTS, E_IM_ID, N, D, S, X, Y,
     GROUP_ID, M_DATE, M_USER)
	  VALUES 
    (CurType, NAME, pComments, ImageIndex, EN, InD, ES, EX, EY,
     new_group_id, pDATE, pUSER);
END ENUM;

-------------------------------------------------------------------------------
PROCEDURE GlobalPar(
  NAME IN VARCHAR2,
  Comments IN VARCHAR2,
	ParType IN VARCHAR2,
  Reaction IN VARCHAR2 DEFAULT NULL,
  R_ONLY IN NUMBER DEFAULT NULL,
	V IN VARCHAR2 DEFAULT NULL,
  GROUP_NAME IN VARCHAR2 DEFAULT NULL 
  )
IS
  pName SP.GLOBAL_PAR_S.NAME%TYPE;
  pReaction SP.GLOBAL_PAR_S.REACTION%TYPE;
  pR_Only NUMBER;
  pComments SP.COMMANDS.COMMENTS%type;
  Val SP.TVALUE;
  TypeID NUMBER;
  new_group_id NUMBER;
BEGIN
  pName:=NAME;
  pReaction:=Reaction;
  pComments:=Comments;
  SELECT ID INTO TypeID FROM sp.par_types WHERE NAME = ParType;
  Val:=SP.TVALUE(TypeID,V);
  if R_ONLY is null then
    pR_Only:= SP.G.ReadWrite;
  else
    pR_Only:=R_Only;
  end if;
  -- Если имя группы не нулл, то
  if GROUP_NAME is not null then
    -- находим идентификатор группы, которой принадлежит данный тип,
    begin
      select ID into new_group_id from SP.GROUPS
        where upper(NAME) = upper (GROUP_NAME);
    exception
      when no_data_found then
        -- Если группа отсутствует, то добавляем группу 
        insert into SP.GROUPS (NAME) values(GROUP_NAME) 
          returning ID into new_group_id;
        -- и привязываем её к группе имён значений по умолчанию. 
        BGroup(NAME => GROUP_NAME, Parent_Name => 'Globals'); 
    end;
  end if; 
  
	INSERT INTO SP.GLOBAL_PAR_S (
		NAME,
		COMMENTS,
		TYPE_ID,
    E_VAL,N,D,S,X,Y,
    REACTION,
		R_ONLY,
    GROUP_ID)
	VALUES(
		pName,
		pComments,
		TypeID,
    Val.E,Val.N,Val.D,Val.S,Val.X,Val.Y,
    pReaction,
		pR_Only,
    new_group_id);
END GlobalPar;

-------------------------------------------------------------------------------
	PROCEDURE GlobalParValue(
  ParName IN VARCHAR2,
  V IN VARCHAR2,
  UserName IN VARCHAR2 DEFAULT NULL)
IS
BEGIN
  IF UserName IS NOT NULL THEN CurUser:=UserName; END IF;
  IF CurUser IS NULL THEN
    RAISE_APPLICATION_ERROR(-20033,
      'SP.GlobalParValue. Пользователь не определён!' );
  END IF;
  UPDATE V_USERS_GLOBALS SET S_VALUE=V
    WHERE (UPPER(NAME)=UPPER(ParName)) AND (UPPER(SP_USER)=UPPER(CurUser));
END GlobalParValue;

-------------------------------------------------------------------------------
PROCEDURE Node(
  NAME IN VARCHAR2,
  ImageIndex IN NUMBER DEFAULT NULL,
	Comments IN VARCHAR2 DEFAULT NULL,
  ParentNode IN VARCHAR2 DEFAULT NULL,
  GROUP_NAME IN VARCHAR2 DEFAULT NULL, 
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL)
IS
  pName SP.OBJECTS.NAME%TYPE;
  pComments SP.COMMANDS.COMMENTS%type;
  pDATE DATE;
  pUSER VARCHAR2(60);
  new_group_id NUMBER;
BEGIN
  pName:=NAME;
  pComments:=Comments;
  IF ParentNode IS NOT NULL THEN
    CurParent := ParentNode;
  END IF;
  if MDATE is null then 
    pDATE := to_Date('05-01-2014','dd-mm-yyyy');
  else
	  pDATE:=CASE
		         WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
		           TO_DATE(MDATE,FMT,'NLS_DATE_LANGUAGE ='||NLS)
		         WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
		           TO_DATE(MDATE,FMT)
--		         WHEN (DFMT IS NULL) AND (NLS IS NULL) THEN
--		           TO_DATE(MDATE)
	         ELSE TO_DATE(MDATE)END;
  end if;
  if MUSER is null then
    pUser := 'PROG';
  else
    pUSER := MUSER;
  end if;        
  -- Если имя группы не нулл, то
  if GROUP_NAME is not null then
    -- находим идентификатор группы, которой принадлежит данный тип,
    begin
      select ID into new_group_id from SP.GROUPS
        where upper(NAME) = upper (GROUP_NAME);
    exception
      when no_data_found then
        -- Если группа отсутствует, то добавляем группу 
        insert into SP.GROUPS (NAME) values(GROUP_NAME) 
          returning ID into new_group_id;
        -- и привязываем её к группе имён значений по умолчанию. 
        BGroup(NAME => GROUP_NAME, Parent_Name => 'CatalogItems'); 
    end;
  end if; 
  INSERT INTO SP.V_CATALOG_TREE 
    (IM_ID, NAME, COMMENTS, PARENT_NAME, GROUP_ID, M_DATE, M_USER)
    VALUES
    (ImageIndex, pName,  pComments, CurParent, new_group_id, pDATE, pUSER);
END  Node;

-------------------------------------------------------------------------------
PROCEDURE BGroup(
  NAME IN VARCHAR2,
  ImageIndex IN NUMBER default null,
  Line IN NUMBER default null,
	Comments IN VARCHAR2 default null,
  Parent_Name IN VARCHAR2 default null,
  RoleName IN VARCHAR2 default null,
	MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
  Q IN NUMBER default null)
is
  pLINE NUMBER;
  pDATE DATE;
  pUSER VARCHAR2(60);
  pComments VARCHAR2(4000);
  pName VARCHAR2(4000);
begin
  -- Если есть имя ссылки на объект, то
  TG.ImportDATA:=true;
  if MDATE is null then 
    pDATE := to_Date('05-01-2014','dd-mm-yyyy');
  else
	  pDATE:=CASE
		         WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
		           TO_DATE(MDATE,FMT,'NLS_DATE_LANGUAGE ='||NLS)
		         WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
		           TO_DATE(MDATE,FMT)
--		         WHEN (DFMT IS NULL) AND (NLS IS NULL) THEN
--		           TO_DATE(MDATE)
	         ELSE TO_DATE(MDATE)END;
  end if;
  if MUSER is null then
    pUser := 'PROG';
  else
    pUSER := MUSER;
  end if;        
  if (Parent_Name is null) then
    -- добавляем группу
	  insert into SP.V_GROUPS (NAME, COMMENTS, G_IM_ID, G_ROLE, M_DATE, M_USER)
	    values(Name, Comments, ImageIndex, RoleName, pDATE, pUSER);
  else
    -- или добавляем связь
    pLINE:=Line;  
	  insert into SP.V_GROUPS (NAME, PARENT_G, LINE, M_DATE, M_USER)
	    values(Name, Parent_Name, pLINE, pDATE, pUSER);
    -- Если при этом изменилось описание, то обновили.
    if Comments is not null then
      pComments := Comments;
      pName := Name;
      update SP.V_GROUPS set 
        Comments = pComments
        where NAME = pName;
    end if;
  end if;
  TG.ImportDATA:=false;  
end BGroup;


-------------------------------------------------------------------------------
PROCEDURE Alias(
  GroupName IN VARCHAR2,
  -- Имя модели => полное имя объекта
  ObjectName IN VARCHAR2)
is
begin
  null;  
end Alias;

-------------------------------------------------------------------------------
PROCEDURE DOC(
  GroupName IN VARCHAR2 default 'LOST_Paragraphs',
	Line IN NUMBER,
  Paragraph IN VARCHAR2,
  Format IN NUMBER default null,
  ImageIndex IN NUMBER default null,
  UsingRoleName IN VARCHAR2 default null,
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER default null)
is
  pLine NUMBER;
  pParagraph SP.DOCS.PARAGRAPH%type;
  pFormat NUMBER;
  pGroupName SP.GROUPS.NAME%type;
  pDATE DATE;
  pUSER VARCHAR2(60);
begin
  pLine:=Line;
  pParagraph:=Paragraph;
  pFormat:=Format;
  if GroupName is null then 
    pGroupName:= CurDocGroupName;
  else
    pGroupName:= utrim(GroupName);
    CurDocGroupName := pGroupName;
  end if;  
  if MDATE is null then 
    pDATE := to_Date('05-01-2014','dd-mm-yyyy');
  else
	  pDATE:=CASE
		         WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
		           TO_DATE(MDATE,FMT,'NLS_DATE_LANGUAGE ='||NLS)
		         WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
		           TO_DATE(MDATE,FMT)
--		         WHEN (DFMT IS NULL) AND (NLS IS NULL) THEN
--		           TO_DATE(MDATE)
	         ELSE TO_DATE(MDATE)END;
  end if;
  if MUSER is null then
    pUser := 'PROG';
  else
    pUSER := MUSER;
  end if;        
  insert into SP.V_DOCS 
    (GROUP_NAME, LINE, FORMAT,/* IMAGE,*/ PARAGRAPH, USING_ROLE,
     M_DATE, M_USER) 
    values
     (pGroupName, pLine, pFormat, /*ImageIndex,*/ pParagraph, UsingRoleName,
      pDate, pUser);
end DOC;

--!!!
-------------------------------------------------------------------------------
PROCEDURE DOCs(
  GroupName IN VARCHAR2 default 'LOST_Paragraphs',
	Line IN NUMBER,
  Paragraph IN VARCHAR2,
  Format IN NUMBER default null,
  ImageIndex IN NUMBER default null,
  UsingRoleName IN VARCHAR2 default null,
	Q IN NUMBER default null)
is
begin
  DOC( GroupName, Line, Paragraph, Format, ImageIndex, UsingRoleName,
       null,null,Q);
end DOCs; 
 
-------------------------------------------------------------------------------
PROCEDURE ArrValue(
  -- полное имя массива.
  NAME IN VARCHAR2 DEFAULT NULL,
  -- числовые индексы.
  indX in NUMBER DEFAULT NULL,
  indY in NUMBER DEFAULT NULL,
  indZ in NUMBER DEFAULT NULL,
  -- строковый индекс.
  indS in VARCHAR2 DEFAULT NULL,
  -- индекс по дате.
  indD in DATE DEFAULT NULL,
  -- строковое значение типа значения элемента массива.
  T IN VARCHAR2, 
  -- строковое значение элемента массива.  
  V IN VARCHAR2 DEFAULT NULL, 
  -- дата присвоения или изменения значения
  MDATE IN VARCHAR2 DEFAULT NULL,
  -- пользователь, изменивший или присвоивший значение.
  MUSER IN VARCHAR2 DEFAULT NULL
  )
is 
pos NUMBER;
--ArName SP.ARRAYS.NAME%type;
--ArGroup SP.GROUPS.NAME%type;
val SP.COMMANDS.COMMENTS%type;
begin
  val := V;
  if NAME is not null then
    pos := instr(NAME, '.', -1);
    CurArrName := substr(NAME,pos+1);
    CurArrGroup := substr(NAME,1,pos-1);
  end if;  
  insert into SP.V_ARRAYS
  (
    NAME,
    GROUP_NAME,
    IND_X,
    IND_Y,
    IND_Z,
    IND_D,
    IND_S,
    TYPE_NAME,
    V,
    M_DATE,
    M_USER
  )
  values
  (
    CurArrName,
    CurArrGroup,
    IndX,
    IndY,
    IndZ,
    IndD,
    IndS,
    T,
    Val,
    MDATE,
    MUSER
  );
end ArrValue;  

-------------------------------------------------------------------------------
PROCEDURE OBJECT(
  NAME IN VARCHAR2,
  OID IN VARCHAR2 DEFAULT NULL,
  Kind IN VARCHAR2 DEFAULT NULL,
  ImageIndex IN NUMBER DEFAULT NULL,
	Comments IN VARCHAR2 DEFAULT NULL,
	GroupName IN VARCHAR2 DEFAULT NULL,
  Pars IN VARCHAR2 DEFAULT NULL,
  ExceptPars IN VARCHAR2 DEFAULT NULL,
  UsingRole IN VARCHAR2 DEFAULT NULL,
  EditRole IN VARCHAR2 DEFAULT NULL,
  MDate IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
  DFMT IN VARCHAR2 DEFAULT NULL,
  DNLS IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL)
IS
  tmpVar NUMBER;
  i NUMBER;
  ids TNUMBERS.TNUMBERS;
  URole NUMBER;
  ERole NUMBER;
  pName SP.OBJECTS.NAME%TYPE;
  pComments SP.COMMANDS.COMMENTS%type;
  pGroup NUMBER;
  KindID NUMBER;
  pDate DATE;
  pUser VARCHAR2(60);
  o TCatObject;
BEGIN
  o := GetIDbyName(NAME,utrim(GroupName),'OBJECT');
  pName:=o.NAME;
  pGroup:=o.GID;
  pComments:=Comments;
  TG.ImportDATA:=true;
  if MUSER is null then pUser := 'PROG'; else pUser:=MUSER; end if;
  -- Находим идентификатор роли, дающий право использовать объект.
  IF UsingRole IS NOT NULL THEN
    BEGIN
      SELECT ID INTO URole FROM SP.SP_ROLES
        WHERE (UPPER(NAME)=UPPER(UsingRole));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        TG.ImportDATA:=false;  
        RAISE_APPLICATION_ERROR(-20033,
          'SP.INPUT.OBJECT. Отсутствует роль: '||UsingRole||'!' );
    END;
  ELSE
    URole:=NULL;
  END IF;
  -- Находим идентификатор роли, дающий право изменять объект.
  IF EditRole IS NOT NULL THEN
    BEGIN
      SELECT ID INTO ERole FROM SP.SP_ROLES
        WHERE (UPPER(NAME)=UPPER(EditRole));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        TG.ImportDATA:=false;  
        RAISE_APPLICATION_ERROR(-20033,
          'SP.INPUT.OBJECT. Отсутствует роль: '||EditRole||'!' );
    END;
  ELSE
    ERole:=NULL;
  END IF;
  -- Находим идентификатор типа объекта.
  IF Kind IS NOT NULL THEN
    KindID := SP.to_Obj_KIND(Kind);
  ELSE
    KindID:=NULL;
  END IF;
	IF DFMT IS NOT NULL THEN FMT:=DFMT; END IF;
	IF DNLS IS NOT NULL THEN NLS:=DNLS; END IF;
  IF (DNLS IS NOT NULL) AND (DFMT IS NULL) THEN
    TG.ImportDATA:=false;  
    RAISE_APPLICATION_ERROR(-20033,
      'SP.INPUT.OBJECTPAR. Отсутствует формат даты!' );
  END IF;
  pDate:=CASE
         WHEN MDate is null THEN
           null
         WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
           TO_DATE(MDate,FMT,'NLS_DATE_LANGUAGE ='||NLS)
         WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
           TO_DATE(MDate,FMT)
         WHEN (FMT IS NULL) AND (NLS IS NULL) THEN
           TO_DATE(MDate)
       ELSE TO_DATE(MDate)
       END;
  -- Если объект отсутствует, то добавляем объект.
  IF o.ID = 0 THEN
    INSERT INTO SP.OBJECTS
      (ID, OID, IM_ID, NAME, COMMENTS, OBJECT_KIND, GROUP_ID,
       USING_ROLE, EDIT_ROLE, MODIFIED, M_USER)
      VALUES(NULL, OID, ImageIndex, pName, pComments, KindID, pGroup,
             URole, ERole, pDATE, pUser)
      RETURNING ID INTO CurObject;
  ELSIF Q = -1 THEN
    CurObject := o.ID;
    -- Обновляем запись в таблице объектов.    
    UPDATE SP.OBJECTS
      SET
      IM_ID = ImageIndex,
      COMMENTS = pComments,
      OBJECT_KIND = KindID,
      GROUP_ID = pGroup,
      USING_ROLE = URole,
      EDIT_ROLE = ERole,
      MODIFIED = pDate,
      M_USER = pUser
      WHERE ID = CurObject;
	  -- Удаляем параметры и макрокоманды для текущего объекта.
    DELETE FROM SP.OBJECT_PAR_S WHERE OBJ_ID = CurObject;
    DELETE FROM SP.V_MACROS WHERE OBJECT_ID = CurObject;
  ELSE
    TG.ImportDATA:=false;  
    RAISE_APPLICATION_ERROR(-20033,'SP.INPUT.OBJECT. '||
        'Объект: '||Name||' уже существует!');
  END IF; 
  -- Добавляем параметры прообраза объекта, если необходимо.  
  IF Pars IS NULL THEN RETURN; END IF;
  BEGIN
    SELECT ID INTO tmpVar FROM SP.OBJECTS f WHERE UPPER(f.NAME)=UPPER(Pars);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      TG.ImportDATA:=false;  
      RAISE_APPLICATION_ERROR(-20033,'SP.INPUT.OBJECT. '||
        'Отсутствует объект: '||Pars||'!');
  END;
    i:=0;
    ids:=TNUMBERS();
    -- Заполняем таблицу идентификаторов исключаемых параметров.
    FOR p IN (SELECT COLUMN_VALUE NAME
               FROM TABLE(SP.SET_FROM_STRING(ExceptPars)))
    LOOP
      ids.EXTEND;
      i:=i+1;
      BEGIN
        SELECT ID INTO ids(i) FROM SP.OBJECT_PAR_S pp
          WHERE (pp.OBJ_ID=tmpVar) AND (UPPER(pp.NAME) =UPPER(p.NAME));
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        TG.ImportDATA:=false;  
          RAISE_APPLICATION_ERROR(-20033,'SP.INPUT.OBJECT. '||
            'Отсутствует параметр: '||p.NAME||' у объекта: '||Pars||'!' );
      END;
    END LOOP;
    -- Копируем параметры наследуемого объекта,
    -- исключая параметры, перечисленные в ids.
    FOR iii IN (SELECT COLUMN_VALUE FROM TABLE (ids))
    LOOP
      d(TO_CHAR(iii.COLUMN_VALUE),'SP.INPUT.OBJECT');
    END LOOP;
    FOR p IN (SELECT * FROM SP.OBJECT_PAR_S p
                WHERE (p.OBJ_ID=tmpVar)
                  AND (p.ID NOT IN(SELECT COLUMN_VALUE FROM TABLE (ids)))
              )
  LOOP
    p.OBJ_ID:=CurOBJECT;
    p.M_DATE:=pDate;
    p.M_USER:=pUser;
    INSERT INTO SP.OBJECT_PAR_S VALUES p;
  END LOOP;
  TG.ImportDATA:=false;  
END  OBJECT;

-------------------------------------------------------------------------------
PROCEDURE ObjectPar(
  NAME IN VARCHAR2,
  ObjectOID IN VARCHAR2 DEFAULT NULL,
  ObjectName IN VARCHAR2 DEFAULT NULL,
  ObjectGroup IN VARCHAR2 DEFAULT NULL,
	Comments IN VARCHAR2 DEFAULT NULL,
  ParType IN VARCHAR2,
  V IN VARCHAR2 DEFAULT NULL,
  N IN NUMBER DEFAULT NULL,
  D IN VARCHAR2 DEFAULT NULL,
  DFMT IN VARCHAR2 DEFAULT NULL,
  DNLS IN VARCHAR2 DEFAULT NULL,
  S IN VARCHAR2 DEFAULT NULL,
	X IN NUMBER DEFAULT NULL,
	Y IN NUMBER DEFAULT NULL,
  R_ONLY IN VARCHAR2 DEFAULT 'R/W',
  GROUP_NAME IN VARCHAR2 DEFAULT NULL, 
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL
  )
IS
  P SP.TCPAR;
  TypeID NUMBER;
  InD DATE;
  pDate DATE;
  pUser VARCHAR2(60);
  new_group_id NUMBER;
  GroupID NUMBER;
  o TCatObject;
  TGIMP boolean;
  EM VARCHAR2(4000);
BEGIN
  IF ObjectName IS NOT NULL THEN
    o := GetIDbyName(ObjectName,ObjectGroup,'ObjectPar');
    IF o.ID = 0 then
      CurObject := null;
    ELSE  
      CurObject := o.ID;
    END IF;  
  END IF;
  IF CurObject IS NULL THEN
    RAISE_APPLICATION_ERROR(-20033,
      'SP.INPUT.OBJECTPAR. Объект не определён!' );
  END IF;
	IF DFMT IS NOT NULL THEN FMT:=DFMT; END IF;
	IF DNLS IS NOT NULL THEN NLS:=DNLS; END IF;
  IF (DNLS IS NOT NULL) AND (DFMT IS NULL) THEN
    RAISE_APPLICATION_ERROR(-20033,
      'SP.INPUT.OBJECTPAR. Отсутствует формат даты!' );
  END IF;
  InD:=CASE
         WHEN D IS NULL THEN
           null
         WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
           TO_DATE(D,FMT,'NLS_DATE_LANGUAGE ='||NLS)
         WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
           TO_DATE(D,FMT)
         WHEN (FMT IS NULL) AND (NLS IS NULL) THEN
           TO_DATE(D)
       ELSE TO_DATE(D)
       END;
  dd('1  '||NAME||'   '||TO_CHAR(CurOBJECT),'SP.INPUT.OBJECTPAR');
  P:=SP.TCPAR(CurOBJECT,NAME);
  dd('2  ','SP.INPUT.OBJECTPAR');
  -- Присваиваем признак доступа.
  P.R_Only:=SP.to_R_ONLY(R_ONLY);
  -- Присваиваем тип.
  BEGIN
    SELECT ID INTO TypeID FROM SP.PAR_TYPES WHERE UPPER(NAME)=UPPER(ParType);
    P.VAL.T:=TypeID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20033,
      'SP.INPUT.OBJECTPAR. Отсутствует тип '||ParType||'!' );
  END;
  if MDATE is null then 
    pDATE := to_Date('05-01-2014','dd-mm-yyyy');
  else
	  pDATE:=CASE
		         WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
		           TO_DATE(MDATE,FMT,'NLS_DATE_LANGUAGE ='||NLS)
		         WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
		           TO_DATE(MDATE,FMT)
--		         WHEN (DFMT IS NULL) AND (NLS IS NULL) THEN
--		           TO_DATE(MDATE)
	         ELSE TO_DATE(MDATE)END;
  end if;
  if MUSER is null then
    pUser := 'PROG';
  else
    pUSER := MUSER;
  end if;        
  -- Если имя группы не нулл, то
  if GROUP_NAME is not null then
    -- находим идентификатор группы, которой принадлежит данный тип,
    begin
      select ID into new_group_id from SP.GROUPS
        where upper(NAME) = upper (GROUP_NAME);
    exception
      when no_data_found then
        -- Если группа отсутствует, то добавляем группу 
        insert into SP.GROUPS (NAME) values(GROUP_NAME) 
          returning ID into new_group_id;
        -- и привязываем её к группе имён значений по умолчанию. 
        BGroup(NAME => GROUP_NAME, Parent_Name => 'Object_Pars'); 
    end;
  end if;
  P.GROUP_ID:= new_group_id; 
  -- Присваиваем значение.
  -- Если значение можно представить в виде строки, то присваиваем значение,
  -- как строку,
  dd('3  '||V,'SP.INPUT.OBJECTPAR');
  IF V IS NOT NULL THEN
    begin
      P.VAL.Assign(V);
    exception
      when others then
        -- Если отсутствует связь и установлен признак игнорирования
        -- отсутствия части данных, то устанавливаем ссылку в нулл.
        if P.VAL.T = G.TRel and Safe then
          P.VAL := REL_(null);
        else  
          RAISE_APPLICATION_ERROR(-20033,'SP.INPUT.OBJECTPAR.'||EM||'!' );
        end if;  
    end;
  ELSE
    -- иначе производим присвоение по полям.
    P.VAL.N := N;
    P.VAL.D := InD;
    P.VAL.S := S;
    P.VAL.X := X;
    P.VAL.Y := Y;
  END IF;
  EM := SP.TValueTest(P.VAL);
  IF EM IS NOT NULL THEN
    -- Если отсутствует связь и установлен признак игнорирования
    -- отсутствия части данных, то устанавливаем ссылку в нулл.
    if P.VAL.T = G.TRel and Safe then
      P.VAL := REL_(null);
    else  
      RAISE_APPLICATION_ERROR(-20033,'SP.INPUT.OBJECTPAR.'||EM||'!' );
    end if;  
  END IF;
  -- Присваиваем комментарий.
  P.Val.Comments:=Comments;
  --Запоминаем значение параметра.
  TGIMP := Tg.ImportDATA;
  Tg.ImportDATA := true;
  P.Save(pDate,pUser);
  Tg.ImportDATA := false;
exception
  when others then
    Tg.ImportDATA := TGIMP;
    raise;
END  ObjectPar;

-------------------------------------------------------------------------------
PROCEDURE Macro(
  ObjectOID IN VARCHAR2 DEFAULT NULL,
  ObjectName IN VARCHAR2 DEFAULT NULL,
  ObjectGroup IN VARCHAR2 DEFAULT NULL,
  LineNum IN NUMBER DEFAULT NULL,
  Command IN VARCHAR2,
	Comments IN VARCHAR2 DEFAULT NULL,
  Alias IN VARCHAR2 DEFAULT NULL,
  UsedObject IN VARCHAR2 DEFAULT NULL,
  UsedObjectGroup IN VARCHAR2 DEFAULT NULL,
	MacroBlock IN VARCHAR2 DEFAULT NULL,
	Condition IN VARCHAR2 DEFAULT NULL,
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL
  )
IS
	pComments SP.MACROS.COMMENTS%TYPE;
  pAlias SP.MACROS.ALIAS%TYPE;
	pCondition SP.MACROS.CONDITION%TYPE;
  pCommand NUMBER;
  pDate DATE;
  pUser VARCHAR2(60);
  ObjectGroupID NUMBER;
  UsedObjectID NUMBER;
  UsedObjectGroupID NUMBER;
  o TCatObject;
  u TCatObject;
BEGIN
  pComments:=Comments;
  pAlias:=Alias;
  pCondition:=Condition;
  if MDATE is null then 
    pDATE := to_Date('05-01-2014','dd-mm-yyyy');
  else
	  pDATE:=CASE
		         WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
		           TO_DATE(MDATE,FMT,'NLS_DATE_LANGUAGE ='||NLS)
		         WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
		           TO_DATE(MDATE,FMT)
--		         WHEN (DFMT IS NULL) AND (NLS IS NULL) THEN
--		           TO_DATE(MDATE)
	         ELSE TO_DATE(MDATE)END;
  end if;
  if MUSER is null then
    pUser := 'PROG';
  else
    pUSER := MUSER;
  end if;        
  IF ObjectName IS NOT NULL THEN
    o := GetIDbyName(ObjectName,ObjectGroup,'Macro');
    IF o.ID = 0 then
      CurObject := null;
      IF ObjectGroup is null then
	      RAISE_APPLICATION_ERROR(-20033,
	        'SP.INPUT.Macro. Отсутствует объект '||ObjectName||'!' );
      ELSE
	      RAISE_APPLICATION_ERROR(-20033,
	        'SP.INPUT.Macro. Отсутствует объект '
          ||ObjectGroup||'.'||ObjectName||'!' );
      END IF;  
    ELSE  
      CurObject := o.ID;
    END IF;  
    CurMacroLine:=0;
    CurMacroLineRef:=null;
  END IF;
  IF CurObject IS NULL THEN
    RAISE_APPLICATION_ERROR(-20033,
      'SP.INPUT.MACRO. Объект не определён!' );
  END IF;
  CurMacroLine := CurMacroLine +1;
  IF CurMacroLine = LineNum then
    -- добавлено для обратной совместимости с предыдущими версиями.
    if Upper(Command) = 'CREATE_OBJECT' then 
      pCommand:=G.Cmd_Create_Object;
    elsif Upper(Command) = 'RENAME' then 
      pCommand:=G.Cmd_Rename;
    elsif Upper(Command) = 'EXECUTE_MACRO' then 
      pCommand:=G.Cmd_Execute;
    else  
	    begin 
	      select ID into pCommand from SP.COMMANDS where NAME = Command;
	    exception
	      when no_data_found then
			    RAISE_APPLICATION_ERROR(-20033,
			      'SP.INPUT.MACRO. Команда '||Command||' не найдена!' );
	    end;
    end if;
    UsedObjectID:=null;  
    IF UsedObject IS NOT NULL THEN
	    u := GetIDbyName(UsedObject,UsedObjectGroup,'Macro');
	    IF u.ID = 0 then
	      IF UsedObjectGroup is null then
		      RAISE_APPLICATION_ERROR(-20033,
		        'SP.INPUT.Macro. Отсутствует объект '||UsedObject||'!' );
	      ELSE
		      RAISE_APPLICATION_ERROR(-20033,
		        'SP.INPUT.Macro. Отсутствует объект '
	          ||UsedObjectGroup||'.'||UsedObject||'!' );
	      END IF;  
	    ELSE  
	      UsedObjectID := u.ID;
	    END IF;  
    END IF;   
	  INSERT INTO SP.MACROS
	    (OBJ_ID, ALIAS, COMMENTS, CMD_ID, USED_OBJ_ID, PREV_ID,
       MACRO, CONDITION, M_DATE, M_USER)
	  VALUES
	    (CurObject, pAlias, pComments, pCommand, UsedObjectID, CurMacroLineRef,
	     MacroBlock, pCondition, pDATE, pUSER)
    RETURNING ID into CurMacroLineRef;
  ELSE
    CurMacroLine := LineNum; 
    IF instr(UsedObject, '.') > 0 THEN
	    INSERT INTO SP.V_MACROS
		    (OBJECT_ID, ALIAS, COMMENTS, LINE, CMD_NAME,
	       USED_OBJECT_FULL_NAME, 
		     MACRO, CONDITION, MODIFIED)
		  VALUES
		    (CurObject, pAlias, pComments, LineNum, Command,
	       UsedObject, 
		     MacroBlock, pCondition, 0);
    ELSE
	    INSERT INTO SP.V_MACROS
		    (OBJECT_ID, ALIAS, COMMENTS, LINE, CMD_NAME,
	       USED_OBJECT_SHORT_NAME, USED_OBJECT_GROUP_NAME,
		     MACRO, CONDITION, MODIFIED)
		  VALUES
		    (CurObject, pAlias, pComments, LineNum, Command,
	       UsedObject, UsedObjectGroup,
		     MacroBlock, pCondition, 0);
    END IF;     
  END IF;
END Macro;

-------------------------------------------------------------------------------
PROCEDURE MODEL(
  NAME IN VARCHAR2,
  Comments IN VARCHAR2,
  PERSISTENT IN NUMBER DEFAULT 0,
  LOCAL IN NUMBER DEFAULT 0,
  USING_ROLE IN VARCHAR2 DEFAULT NULL,
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL
  )
IS
  pName SP.MODELS.NAME%TYPE;
  pComments SP.MODELS.Comments%TYPE;
  pDate DATE;
  pUser VARCHAR2(60);
  pPers NUMBER;
  pLoc NUMBER;
  pRole NUMBER;
BEGIN
  pName:=NAME;
  pComments:=Comments;
  pLoc := LOCAL;
  pPers := PERSISTENT;
  if MDATE is null then 
    pDATE := to_Date('05-01-2014','dd-mm-yyyy');
  else
	  pDATE:=CASE
		         WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
		           TO_DATE(MDATE,FMT,'NLS_DATE_LANGUAGE ='||NLS)
		         WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
		           TO_DATE(MDATE,FMT)
--		         WHEN (DFMT IS NULL) AND (NLS IS NULL) THEN
--		           TO_DATE(MDATE)
	         ELSE TO_DATE(MDATE)END;
  end if;
  if MUSER is null then
    pUser := 'PROG';
  else
    pUSER := MUSER;
  end if; 
  if USING_ROLE is not null then
    select ID into pRole from SP.SP_ROLES where NAME = USING_ROLE; 
  else
    pRole :=null;  
  end if;        
  INSERT INTO SP.MODELS 
    (ID, NAME, COMMENTS, PERSISTENT, LOCAL, USING_ROLE, M_DATE, M_USER)
    VALUES
    (NULL,pName,pComments, pPers, pLoc, pRole, pDate, pUser);
exception 
   when no_data_found then
     RAISE_APPLICATION_ERROR(-20033,
      'SP.INPUT.MODEL. Роль '||USING_ROLE||' не найдена!' );
      
END MODEL;

-------------------------------------------------------------------------------
PROCEDURE ModelObject(
  ModelName IN VARCHAR2,
  ObjectName IN VARCHAR2,
  OID IN VARCHAR2 DEFAULT NULL, 
  POID IN VARCHAR2 DEFAULT NULL,
  ObjectPath IN VARCHAR2 DEFAULT NULL,
  CatalogName IN VARCHAR2,
  CatalogGroupName IN VARCHAR2 DEFAULT NULL,
	CompositName IN VARCHAR2 DEFAULT NULL,
  CompositGroupName IN VARCHAR2 DEFAULT NULL,
  StartCompositName IN VARCHAR2 DEFAULT NULL,
	StartCompositGroupName IN VARCHAR2 DEFAULT NULL,
  Modified IN BOOLEAN  DEFAULT NULL,
  UsingRoleName IN VARCHAR2 DEFAULT NULL,
  EditRoleName IN VARCHAR2 DEFAULT NULL,
  MDate IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
	Q IN NUMBER DEFAULT NULL
  )
IS
  ModelID NUMBER;
  CatalogObjID NUMBER;
  ObjectID VARCHAR2(40);
  pDate DATE;
  pUser VARCHAR2(60);
  o TCatObject;
  URole NUMBER;
  ERole NUMBER;
BEGIN
  if MDATE is null then 
    pDATE := to_Date('05-01-2014','dd-mm-yyyy');
  else
	  pDATE:=CASE
		         WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
		           TO_DATE(MDATE,FMT,'NLS_DATE_LANGUAGE ='||NLS)
		         WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
		           TO_DATE(MDATE,FMT)
--		         WHEN (DFMT IS NULL) AND (NLS IS NULL) THEN
--		           TO_DATE(MDATE)
	         ELSE TO_DATE(MDATE)END;
  end if;
  if MUSER is null then
    pUser := 'PROG';
  else
    pUSER := MUSER;
  end if;        
  ObjectID := OID;
  -- Находим идентификатор модели.
  -- Если имя модели неопределено, то используем текущее значение.
  IF ModelName IS NOT NULL THEN
    BEGIN
      SELECT ID INTO CurModel FROM SP.MODELS
        WHERE (UPPER(NAME)=UPPER(ModelName));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20033,
          'SP.INPUT.MODELOBJECT. Отсутствует модель: '||ModelName||'!' );
    END;
  END IF;
  IF CurModel IS NULL THEN
    RAISE_APPLICATION_ERROR(-20033,
      'SP.INPUT.MODELOBJECT. Модель не определена!' );
  END IF;
  -- Находим идентификатор объекта родителя. 
  -- Если все параметры отсутствуют, то размещаем объект в корне модели.
  -- Если присутствует параметр "POID", то используем его, сохраняя на будущее,
  IF POID IS NOT NULL THEN
    CurModelObjectParent := SP.MO.MOD_OBJ_ID_BY_OID(CurModel, POID);
    -- Если объект не найден, то ошибка!
    if CurModelObjectParent is null then
      RAISE_APPLICATION_ERROR(-20033,
        'SP.INPUT.MODELOBJECT. Отсутствует родительский объект: '
        ||POID||'!' );
    end if;    
  -- Иначе, если присутствует параметр "ObjectPath",
  ELSIF ObjectPath IS NOT NULL THEN
    -- то используем его, отрезая последний правый "/".
    CurModelObjectParent:=
      SP.MO.MOD_OBJ_ID_BY_FULL_NAME(CurModel,rtrim(ObjectPath,'/ '));
    if (CurModelObjectParent is null) and (ObjectPath != '/') then
      RAISE_APPLICATION_ERROR(-20033,
        'SP.INPUT.MODELOBJECT. Отсутствует родительский объект: '
        ||ObjectPath||'!' );
    end if;    
  END IF;
  -- Иначе, используем сохранённое значение.
--  d('ObjectName=> '||ObjectName||' Path=> '||ObjectPath||
--    ' Parent_ID=> '||TO_CHAR(CurModelObjectParent)||
--    ' Model_ID=> '||TO_CHAR(CurModel)
--    ,'input Model');
  o := GetIDbyName(CatalogName,CatalogGroupName,'ModelObject');
  --!! Разобраться: что-то здесь не так!
  IF o.ID = 0 then
    IF CatalogGroupName is null then
      RAISE_APPLICATION_ERROR(-20033,
        'SP.INPUT.MODELOBJECT. Отсутствует объект: '||CatalogName||'!' );
    ELSE
      RAISE_APPLICATION_ERROR(-20033,
        'SP.INPUT.MODELOBJECT. Отсутствует объект: '||
        nvl(CatalogGroupName,'null')||'.'||
        nvl(CatalogName,'null')||'!');
    END IF;  
  ELSE  
    CatalogObjID := o.ID;
  END IF;
  -- Находим идентификаторы ролей.  
  IF UsingRoleName IS NOT NULL THEN
    BEGIN
      SELECT ID INTO URole FROM SP.SP_ROLES
        WHERE (UPPER(NAME)=UPPER(UsingRoleName));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        TG.ImportDATA:=false;  
        RAISE_APPLICATION_ERROR(-20033,
          'SP.INPUT.MODELOBJECT. Отсутствует роль: '||UsingRoleName||'!' );
    END;
  ELSE
    URole:=NULL;
  END IF;
  IF EditRoleName IS NOT NULL THEN
    BEGIN
      SELECT ID INTO ERole FROM SP.SP_ROLES
        WHERE (UPPER(NAME)=UPPER(EditRoleName));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        TG.ImportDATA:=false;  
        RAISE_APPLICATION_ERROR(-20033,
          'SP.INPUT.MODELOBJECT. Отсутствует роль: '||EditRoleName||'!' );
    END;
  ELSE
    ERole:=NULL;
  END IF;
  INSERT INTO SP.MODEL_OBJECTS
    VALUES( NULL, CurModel, ObjectName, ObjectID, 
            CatalogObjID, CurModelObjectParent,
					 	URole, ERole, pDate, pUser, 0)
    RETURNING ID INTO CurModelObject;
  if imp_objects > 10000 then
    imp_objects := 0; 
    SP.RENEW_MODEL_PATHS;
  else
    imp_objects := imp_objects + 1;
  end if;   
END ModelObject;

-------------------------------------------------------------------------------
PROCEDURE ModelObjectPar(
  ModelName IN VARCHAR2 DEFAULT NULL,
  OID VARCHAR2 DEFAULT NULL,
  FullName IN VARCHAR2 DEFAULT NULL,
  NAME IN VARCHAR2,
  T IN VARCHAR2 DEFAULT NULL,
  V IN VARCHAR2 DEFAULT NULL,
	E IN VARCHAR2 DEFAULT NULL,
  N IN NUMBER DEFAULT NULL,
  D IN VARCHAR2 DEFAULT NULL,
  DFMT IN VARCHAR2 DEFAULT NULL,
  DNLS IN VARCHAR2 DEFAULT NULL,
  S IN VARCHAR2 DEFAULT NULL,
	X IN NUMBER DEFAULT NULL,
	Y IN NUMBER DEFAULT NULL,
  MDate IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
  Q IN NUMBER DEFAULT NULL
  )
IS
  P SP.TMPAR;
  InD DATE;
  TypeID NUMBER;
  pDate DATE;
  pUser VARCHAR2(60);
  EM VARCHAR2(4000);
BEGIN
	IF DFMT IS NOT NULL THEN FMT:=DFMT; END IF;
	IF DNLS IS NOT NULL THEN NLS:=DNLS; END IF;
  IF (DNLS IS NOT NULL) AND (DFMT IS NULL) THEN
    RAISE_APPLICATION_ERROR(-20033,
      'SP.INPUT.MODELOBJECTPAR. Отсутствует формат даты!' );
  END IF;
  if MDATE is null then 
    pDATE := to_Date('05-01-2014','dd-mm-yyyy');
  else
	  pDATE:=CASE
		         WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
		           TO_DATE(MDATE,FMT,'NLS_DATE_LANGUAGE ='||NLS)
		         WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
		           TO_DATE(MDATE,FMT)
--		         WHEN (DFMT IS NULL) AND (NLS IS NULL) THEN
--		           TO_DATE(MDATE)
	         ELSE TO_DATE(MDATE)END;
  end if;
  if MUSER is null then
    pUser := 'SP';
  else
    pUSER := MUSER;
  end if;        
  -- Находим идентификатор модели.
  -- Если имя модели неопределено, то используем текущее значение.
  IF ModelName IS NOT NULL THEN
    BEGIN
      SELECT ID INTO CurModel FROM SP.MODELS
        WHERE (UPPER(NAME)=UPPER(ModelName));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20033,
          'SP.INPUT.MODELOBJECTPAR. Отсутствует модель: '||ModelName||'!' );
    END;
  END IF;
  IF CurModel IS NULL THEN
    RAISE_APPLICATION_ERROR(-20033,
      'SP.INPUT.MODELOBJECTPAR. Модель не определена!' );
  END IF;
  IF OID is not null THEN
    CurModelObject:=SP.MO.MOD_OBJ_ID_BY_OID(CurModel, OID);
    SELECT OBJ_ID INTO CurObject FROM SP.MODEL_OBJECTS 
      WHERE ID = CurModelObject;
  
  ELSIF FullName IS NOT NULL THEN
    CurModelObject:=SP.MO.MOD_OBJ_ID_BY_FULL_NAME(CurModel, FullName);
	  SELECT OBJ_ID INTO CurObject FROM SP.MODEL_OBJECTS 
      WHERE ID = CurModelObject;
  ELSE
	  IF CurObject IS NULL THEN
	    RAISE_APPLICATION_ERROR(-20033,
	      'SP.INPUT.MODELOBJECTPAR. Объект не определён!' );
	  END IF;
  END IF;
  P:=SP.TMPAR(CurModelObject,NAME);
  -- Мы не добавляем виртуальные параметры и не возбуждаем ошибку, чтобы
  -- обеспечить совместимость с более ранними версиями.
  if Name in ('NAME','OLD_NAME','PARENT','NEW_PARENT',
              'OID','POID','NEW_POID','ID','PID','NEW_PID',
              'DELETE','USING_ROLE','EDIT_ROLE')
  then
    dd('Параметр '||NAME||' был проигнорирован у объекта '||
        P.OBJECT_NAME||'!','SP.INPUT.ModelObjectPar');
    return;  
  end if;             
  InD:=CASE
         WHEN D IS NULL THEN 
           null
         WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
           TO_DATE(D,FMT,'NLS_DATE_LANGUAGE ='||NLS)
         WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
           TO_DATE(D,DFMT)
         WHEN (FMT IS NULL) AND (NLS IS NULL) THEN
           TO_DATE(D)
       ELSE TO_DATE(D)END;
  -- Для внекаталожных параметров присваиваем тип и создаём экземпляр значения.     
  IF P.CP_ID is null THEN
    IF T is null THEN
      if SP.INPUT.SAFE then
        dd('Внекаталожный параметр будет проигнорирован,'||
           ' так как отсутствует его тип!',
           'WARNING SP.INPUT.MODELOBJECTPAR');
        return;
      else
        RAISE_APPLICATION_ERROR(-20033,
          'SP.INPUT.MODELOBJECTPAR. Отсутствует тип внекаталожного параметра!');
      end if;     
    ELSE
      P.VAL := SP.TVALUE(T); 
    END IF;   
  END IF;     
  -- Присваиваем значение.
  -- Если значение можно представить в виде строки, то присваиваем значение,
  -- как строку,
  IF V IS NOT NULL THEN
    P.VAL.Assign(V,Safe);
  ELSE
    -- иначе производим присвоение по полям.
    P.VAL.N := N;
    P.VAL.D := InD;
    P.VAL.S := S;
    P.VAL.X := X;
    P.VAL.Y := Y;
  END IF;
  EM := SP.TValueTest(P.VAL);
  IF EM IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20033,
      'SP.INPUT.MODELOBJECTPAR.'||EM||'!' );
  END IF;
  --Запоминаем значение параметра.
  P.NEW_MDATE := pDate;
  P.NEW_MUSER := pUser;
  P.Save;
END ModelObjectPar;

-------------------------------------------------------------------------------
PROCEDURE ModelObjectRel(
  ModelName IN VARCHAR2 DEFAULT NULL,
  -- Уникальный идентификатор объекта.
  OID IN VARCHAR2 DEFAULT NULL,
  -- Абсолютное имя объекта модели. 
  -- Используется если опущен уникальный идентификатор.
  -- Если опущены оба, то используется предыдущее значение.
  FullName IN VARCHAR2 DEFAULT NULL,
  -- Имя параметра.
  NAME IN VARCHAR2,
  R_MODEL IN VARCHAR2 DEFAULT NULL,
  R_OID IN VARCHAR2 DEFAULT NULL,
  V IN VARCHAR2 DEFAULT NULL,
  MDATE IN VARCHAR2 DEFAULT NULL,
  MUSER IN VARCHAR2 DEFAULT NULL,
  Q IN NUMBER DEFAULT NULL
  )
IS
  P SP.TMPAR;
  InD DATE;
  TypeID NUMBER;
  pDate DATE;
  pUser VARCHAR2(60);
  modID NUMBER;
BEGIN
  if MDATE is null then 
    pDATE := to_Date('05-01-2014','dd-mm-yyyy');
  else
    BEGIN
      pDATE:=CASE
               WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
                 TO_DATE(MDATE,FMT,'NLS_DATE_LANGUAGE ='||NLS)
               WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
                 TO_DATE(MDATE,FMT)
             ELSE TO_DATE(MDATE)END;
    exception
      when others then
        pDATE := TO_DATE(MDATE);       
    END;       
  end if;
  if MUSER is null then
    pUser := 'SP';
  else
    pUSER := MUSER;
  end if;        
  -- Находим идентификатор модели.
  -- Если имя модели неопределено, то используем текущее значение.
  IF ModelName IS NOT NULL THEN
    BEGIN
      SELECT ID INTO CurModel FROM SP.MODELS
        WHERE (UPPER(NAME)=UPPER(ModelName));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20033,
          'SP.INPUT.ModelObjectRel. Отсутствует модель: '||ModelName||'!' );
    END;
  END IF;
  IF CurModel IS NULL THEN
    RAISE_APPLICATION_ERROR(-20033,
      'SP.INPUT.ModelObjectRel. Модель не определена!' );
  END IF;
  IF OID is not null THEN
    CurModelObject:=SP.MO.MOD_OBJ_ID_BY_OID(CurModel, OID);
    SELECT OBJ_ID INTO CurObject FROM SP.MODEL_OBJECTS 
      WHERE ID = CurModelObject;
  
  ELSIF FullName IS NOT NULL THEN
    CurModelObject:=SP.MO.MOD_OBJ_ID_BY_FULL_NAME(CurModel, FullName);
    SELECT OBJ_ID INTO CurObject FROM SP.MODEL_OBJECTS 
      WHERE ID = CurModelObject;
  ELSE
    IF CurObject IS NULL THEN
      RAISE_APPLICATION_ERROR(-20033,
        'SP.INPUT.ModelObjectRel. Объект не определён!' );
    END IF;
  END IF;
  P:=SP.TMPAR(CurModelObject,NAME);
  -- Присваиваем значение.
  -- Если определён идентификатор ссылки, то используем его,
  IF R_OID IS NOT NULL THEN
    P.VAL := SP.TVALUE(G.TRel);
    BEGIN
      SELECT ID INTO modID FROM SP.MODELS
        WHERE (UPPER(NAME)=UPPER(R_MODEL));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20033,
          'SP.INPUT.ModelObjectRel. Отсутствует модель: '||R_MODEL||'!' );
    END;
    P.VAL.N := SP.MO.MOD_OBJ_ID_BY_OID(modID, R_OID);
    -- иначе присваиваем значение как строку.
  ELSE
    P.VAL.Assign(V);
  END IF;
  --Запоминаем значение параметра.
  P.NEW_MDATE := pDate;
  P.NEW_MUSER := pUser;
  P.Save;
END ModelObjectRel;

-------------------------------------------------------------------------------
PROCEDURE ModelObjectParStory(
  ModelName IN VARCHAR2 DEFAULT NULL,
  -- Уникальный идентификатор объекта.
  OID VARCHAR2 DEFAULT NULL,
  -- Абсолютное имя объекта модели. 
  -- Используется если опущен уникальный идентификатор.
  -- Если опущены оба, то используется предыдущее значение.
  FullName IN VARCHAR2 DEFAULT NULL,
  -- Имя параметра. Если опущен берём предыдущее значение.
  NAME IN VARCHAR2 DEFAULT NULL,
  V IN VARCHAR2 DEFAULT NULL,
  E IN VARCHAR2 DEFAULT NULL,
  N IN NUMBER DEFAULT NULL,
  D IN VARCHAR2 DEFAULT NULL,
  DFMT IN VARCHAR2 DEFAULT NULL,
  DNLS IN VARCHAR2 DEFAULT NULL,
  S IN VARCHAR2 DEFAULT NULL,
  X IN NUMBER DEFAULT NULL,
  Y IN NUMBER DEFAULT NULL,
  MDATE IN VARCHAR2,
  MUSER IN VARCHAR2,
  Q IN NUMBER DEFAULT NULL
  )
is  
  P SP.TSPAR;
  InD DATE;
  TypeID NUMBER;
  pDate DATE;
  pUser VARCHAR2(60);
BEGIN
  IF DFMT IS NOT NULL THEN FMT:=DFMT; END IF;
  IF DNLS IS NOT NULL THEN NLS:=DNLS; END IF;
  IF (DNLS IS NOT NULL) AND (DFMT IS NULL) THEN
    RAISE_APPLICATION_ERROR(-20033,
      'SP.INPUT.ModelObjectParStory. Отсутствует формат даты!' );
  END IF;
  pDATE:=CASE
           WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
             TO_DATE(MDATE,FMT,'NLS_DATE_LANGUAGE ='||NLS)
           WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
             TO_DATE(MDATE,FMT)
         ELSE TO_DATE(MDATE)END;
  pUSER := MUSER;
  -- Находим идентификатор модели.
  -- Если имя модели неопределено, то используем текущее значение.
  IF ModelName IS NOT NULL THEN
    BEGIN
      SELECT ID INTO CurModel FROM SP.MODELS
        WHERE (UPPER(NAME)=UPPER(ModelName));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20033,
          'SP.INPUT.ModelObjectParStory. Отсутствует модель: '||ModelName||'!');
    END;
  END IF;
  IF CurModel IS NULL THEN
    RAISE_APPLICATION_ERROR(-20033,
      'SP.INPUT.ModelObjectParStory. Модель не определена!' );
  END IF;
  IF OID is not null THEN
    CurModelObject:=SP.MO.MOD_OBJ_ID_BY_OID(CurModel, OID);
    SELECT OBJ_ID INTO CurObject FROM SP.MODEL_OBJECTS 
      WHERE ID = CurModelObject;
  
  ELSIF FullName IS NOT NULL THEN
    CurModelObject:=SP.MO.MOD_OBJ_ID_BY_FULL_NAME(CurModel, FullName);
    SELECT OBJ_ID INTO CurObject FROM SP.MODEL_OBJECTS 
      WHERE ID = CurModelObject;
  ELSE
    IF CurObject IS NULL THEN
      RAISE_APPLICATION_ERROR(-20033,
        'SP.INPUT.ModelObjectParStory. Объект не определён!' );
    END IF;
  END IF;
  -- Если параметр NAME опущен, то берем предыдущее значение.
  IF NAME is not null THEN
    CurParName := NAME;
  END IF;
  P:=SP.TSPAR(CurModelObject,CurParName);
  InD:=CASE
         WHEN D IS NULL THEN 
           null
         WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
           TO_DATE(D,FMT,'NLS_DATE_LANGUAGE ='||NLS)
         WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
           TO_DATE(D,DFMT)
         WHEN (FMT IS NULL) AND (NLS IS NULL) THEN
           TO_DATE(D)
       ELSE TO_DATE(D)END;
  -- Присваиваем значение.
  -- Если значение можно представить в виде строки, то присваиваем значение,
  -- как строку,
  IF V IS NOT NULL THEN
    P.VAL.Assign(V,Safe);
  ELSE
    -- иначе производим присвоение по полям.
    P.VAL.N := N;
    P.VAL.D := InD;
    P.VAL.S := S;
    P.VAL.X := X;
    P.VAL.Y := Y;
  END IF;
  --Запоминаем значение параметра.
  P.MDATE := pDate;
  P.MUSER := pUser;
  P.Add_Value;
END ModelObjectParStory;  

PROCEDURE ModelObjectRelStory(
  ModelName IN VARCHAR2 DEFAULT NULL,
  -- Уникальный идентификатор объекта.
  OID VARCHAR2 DEFAULT NULL,
  -- Абсолютное имя объекта модели. 
  -- Используется если опущен уникальный идентификатор.
  -- Если опущены оба, то используется предыдущее значение.
  FullName IN VARCHAR2 DEFAULT NULL,
  -- Имя параметра. Если опущен берём предыдущее значение.
  NAME IN VARCHAR2 DEFAULT NULL,
  -- Ссылка по OID имеет приоритет.
  R_MODEL IN VARCHAR2 DEFAULT NULL,
  R_OID IN VARCHAR2 DEFAULT NULL,
  V IN VARCHAR2 DEFAULT NULL,
  MDATE IN VARCHAR2,
  MUSER IN VARCHAR2,
  Q IN NUMBER DEFAULT NULL
  )
is  
  P SP.TSPAR;
  InD DATE;
  TypeID NUMBER;
  pDate DATE;
  pUser VARCHAR2(60);
  modID NUMBER;
BEGIN
    BEGIN
      pDATE:=CASE
               WHEN (FMT IS NOT NULL) AND (NLS IS NOT NULL) THEN
                 TO_DATE(MDATE,FMT,'NLS_DATE_LANGUAGE ='||NLS)
               WHEN (FMT IS NOT NULL) AND (NLS IS NULL) THEN
                 TO_DATE(MDATE,FMT)
             ELSE TO_DATE(MDATE)END;
    exception
      when others then
        pDATE := TO_DATE(MDATE);       
    END;       
  pUSER := MUSER;
  -- Находим идентификатор модели.
  -- Если имя модели неопределено, то используем текущее значение.
  IF ModelName IS NOT NULL THEN
    BEGIN
      SELECT ID INTO CurModel FROM SP.MODELS
        WHERE (UPPER(NAME)=UPPER(ModelName));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20033,
          'SP.INPUT.ModelObjectRelStory. Отсутствует модель: '||ModelName||'!');
    END;
  END IF;
  IF CurModel IS NULL THEN
    RAISE_APPLICATION_ERROR(-20033,
      'SP.INPUT.ModelObjectRelStory. Модель не определена!' );
  END IF;
  IF OID is not null THEN
    CurModelObject:=SP.MO.MOD_OBJ_ID_BY_OID(CurModel, OID);
    SELECT OBJ_ID INTO CurObject FROM SP.MODEL_OBJECTS 
      WHERE ID = CurModelObject;
  
  ELSIF FullName IS NOT NULL THEN
    CurModelObject:=SP.MO.MOD_OBJ_ID_BY_FULL_NAME(CurModel, FullName);
    SELECT OBJ_ID INTO CurObject FROM SP.MODEL_OBJECTS 
      WHERE ID = CurModelObject;
  ELSE
    IF CurObject IS NULL THEN
      RAISE_APPLICATION_ERROR(-20033,
        'SP.INPUT.ModelObjectRelStory. Объект не определён!' );
    END IF;
  END IF;
  IF NAME is not null THEN
    CurParName := NAME;
  END IF;
  begin
    P:=SP.TSPAR(CurModelObject,CurParName);
  exception
    when others then
     dd(SQLERRM,'ERROR! in SP.INPUT.ModelObjectRelStory');
--     raise;
     return;
  end;    
  P:=SP.TSPAR(CurModelObject,CurParName);
  -- Присваиваем значение.
  -- Если определён идентификатор ссылки, то используем его,
  IF R_OID IS NOT NULL THEN
    P.VAL := SP.TVALUE(G.TRel);
    BEGIN
      SELECT ID INTO modID FROM SP.MODELS
        WHERE (UPPER(NAME)=UPPER(R_MODEL));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20033,
          'SP.INPUT.ModelObjectRelStory. Отсутствует модель: '||R_MODEL||'!' );
    END;
    P.VAL.N := SP.MO.MOD_OBJ_ID_BY_OID(modID, R_OID);
    -- иначе присваиваем значение как строку.
  ELSE
    P.VAL.Assign(V);
  END IF;
  --Запоминаем значение параметра.
  P.MDATE := pDate;
  P.MUSER := pUser;
  begin
    P.Add_Value;
  exception
    when others then
     dd(SQLERRM,'ERROR in SP.INPUT.ModelObjectRelStory');
     raise; 
  end;  
END ModelObjectRelStory;  

------------------------------------------------------------------------------
PROCEDURE FormPar(
  AppName IN VARCHAR2 DEFAULT NULL,
  FormName IN VARCHAR2 DEFAULT NULL,
  FormSignature IN NUMBER DEFAULT NULL,
  UserName IN VARCHAR2 DEFAULT NULL,
  ObjectName IN VARCHAR2 DEFAULT NULL,
  NAME IN VARCHAR2,
  V IN VARCHAR2,
  Ord IN NUMBER
  )
IS
  CurSign NUMBER;
BEGIN
--	-- При изменении любого параметра, идентифицирующего форму,
--	-- производится фиксация параметров,
--  -- добавленных в предыдущих вызовах этой процедуры.
--	IF (CurAppName IS NOT NULL)
--    AND
--	   (    SP.G.notEQ(AppName,CurAppName)
--		  OR SP.G.notEQ(FormName,CurFormName)
--		  OR SP.G.notEQ(FormSignature,CurSignature)
--		  OR SP.G.notEQ(UserName,CurFormUserName)
--	    )
--	THEN
--	  CurSignatureID:=0;
--	END IF;
--  -- Если имя приложения, имя формы, её сигнатура, имя пользователя
--  -- или имя объекта равны нулл,
--  -- то используем сохранённое значение.
--  IF AppName IS NOT NULL THEN
--    CurAppName:=AppName;
--  END IF;
--  IF FormName IS NOT NULL THEN
--    CurFormName:=FormName;
--  END IF;
--  IF FormSignature IS NOT NULL THEN
--    CurSignature:=FormSignature;
--  END IF;
--  IF UserName IS NOT NULL THEN
--    CurFormUserName:=UserName;
--  END IF;
--  IF ObjectName IS NOT NULL THEN
--    CurFormObjectName:=ObjectName;
--  END IF;
--
--  BEGIN
--    SELECT ID INTO CurSign
--      FROM SP.FORM_SIGN_S f
--      WHERE sp.g.S_UpEQ(APP_NAME,CurAppName)
--        + sp.g.S_UpEQ(FORM_NAME,CurFormName)
--        + sp.g.S_UpEQ(USER_NAME,CurFormUserName)=3
--        AND SIGNATURE = CurSignature;
--  EXCEPTION WHEN NO_DATA_FOUND THEN
--    CurSign := 0;
--  END;
--  IF CurSignatureID = 0 THEN
--    IF CurSign = 0 THEN
--      SELECT SP.FORM_SEQ.NEXTVAL INTO CurSign FROM DUAL;
--    	CurSignatureID:= CurSign+REPLICATION.Node_ID;
--      INSERT INTO SP.FORM_SIGN_S (
--           ID, USER_NAME, APP_NAME, FORM_NAME, SIGNATURE )
--         VALUES (
--           CurSignatureID,CurFormUserName,CurAppName,CurFormName,CurSignature);
--     ELSE
--       CurSignatureID:= CurSign;
--     END IF;
--   END IF;
--   INSERT INTO SP.FORM_PARAMS(FS_ID,
-- 			  OBJ_NAME,PROP_NAME,PROP_VALUE,ORD)
--     VALUES(CurSignatureID,
--         CurFormObjectName,NAME,V,Ord);
null;
END FormPar;

BEGIN
  CurSignatureID :=0;
  imp_objects := 0;
END INPUT;
/
