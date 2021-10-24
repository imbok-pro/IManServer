CREATE OR REPLACE PACKAGE BODY SP.OUTPUT
-- SP OUTPUT packagebody
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 01.10.2010
-- update 27.10.2010 29.10.2010 19.11.2010 23.11.2010 29.11.2010 09.12.2010
--        20.12.2010 23.12.2010 12.01.2010 11.02.2011 01.03.2011 15.03.2011
--				10.05.2011 07.10.2011 11.11.2011 19.12.2011 16.03.2012 20.03.2012
--        03.04.2013 04.06.2013 10.06.2013 13.06.2013 16.06.2013 22.08.2013
--        10.10.2013 16.10.2013 27.11.2013 13.02.2014 23.05.2014 15.06.2014
--        11.07.2014 16.07.2014 01.09.2014 09.09.2014 25.09.2014 27.10.2014
--        04.11.2014 15.11.2014 26.11.2014 28.11.2014 06.01.2015 22.03.2015
--        23.03.2015 25.03.2015 31.03.2015 01.04.2015 21.04.2015 05.05.2015
--        22.05.2015 08.07.2015 10.07.2015 13.07.2015 11.07.2016 08.07.2016
--        10.10.2016 19.10.2016 31.10.2016 21.11.2016 12.04.2017 17.01.2018
--        19.01.2018 06.08.2018 02.04.2021 21.04.2021 27.04.2021 09.09.2021
IS
TYPE rc IS REF CURSOR;

-------------------------------------------------------------------------------
PROCEDURE RESET
IS
BEGIN
--SELECT VALUE INTO FMT FROM V$NLS_PARAMETERS
--  WHERE PARAMETER = 'NLS_DATE_FORMAT';
  FMT := 'dd-mm-yyyy hh24:mi:ss';
--SELECT VALUE INTO NLS FROM V$NLS_PARAMETERS
--  WHERE PARAMETER = 'NLS_DATE_LANGUAGE';
  NLS := 'AMERICAN';
END RESET;
-------------------------------------------------------------------------------
-- Функция получает на вход дату изменения и пользователя, а на выход передаёт
-- фрагмент строки скрипта.
FUNCTION D_U(MD IN DATE, MU IN VARCHAR2)return VARCHAR2
is
begin
return 'MDATE=>'''||TO_CHAR(MD,FMT,'NLS_DATE_LANGUAGE ='||NLS)||''', '||
       'MUSER=>'''||MU||''' ';
end D_U; 
-------------------------------------------------------------------------------
-- Функция выводит строку скрипта и прибавляет номер строки.
PROCEDURE OUT_S(ScriptName IN VARCHAR2, LineNum IN OUT NUMBER, Val IN VARCHAR2)
is
begin
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(ScriptName, LineNum, Val);
  LineNum:=LineNum+1;
end OUT_S; 
-------------------------------------------------------------------------------
-- Функция очищает скрипт.
PROCEDURE CLS(ScriptName IN VARCHAR2)
is
begin
  if Not_Truncated then
    DELETE FROM SP_IO.CLIENT_SCRIPTS WHERE UPPER(SCRIPT)=ScriptName;
  end if;
end CLS; 
-------------------------------------------------------------------------------
PROCEDURE TYPES
IS
  tmpVar NUMBER;
  S SP.COMMANDS.COMMENTS%type;
  I BOOLEAN;
  DU VARCHAR2(500);
  PROCEDURE insRecord(s IN VARCHAR2,r IN VARCHAR2)
  IS
    str SP.COMMANDS.COMMENTS%type;
  BEGIN
    IF r IS NOT NULL THEN
      str := replace(Q_QQ(r),chr(10),'''||to_.str||''');
      str :=RTRIM(str,' ='||CHR(13)||CHR(10));
	    IF I THEN
        -- Добавляем кавычку и запятую перед записью.
		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_TYPES,tmpVar,''', '||s||'=>''');
		    tmpVar:=tmpVar+1;
	    ELSE
		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_TYPES,tmpVar,', '||s||'=>''');
		    tmpVar:=tmpVar+1;
	    END IF;
		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_TYPES,tmpVar,str);
		    tmpVar:=tmpVar+1;
	    I:=TRUE;
    END IF;
  END;
BEGIN
  tmpVar:=1;
  I:=FALSE;
  if Not_Truncated then
    DELETE FROM SP_IO.CLIENT_SCRIPTS WHERE UPPER(SCRIPT)=C_TYPES;
  end if;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_TYPES,tmpVar,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  tmpVar:=tmpVar+1;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_TYPES,tmpVar,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  tmpVar:=tmpVar+1;
  FOR T IN (
    SELECT DISTINCT
      ID,
      NAME,
      COMMENTS,
      IM_ID,
      CHECK_VAL,
      VAL_TO_STRING,
      STRING_TO_VAL,
      SET_OF_VALUES,
      M_DATE,
      M_USER
      FROM SP.V_TYPES vt WHERE vt.ID>=1000)
  LOOP
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
      C_TYPES,tmpVar,
      'SP.INPUT."Type"( NAME=>'''||T.NAME||'''');
    tmpVar:=tmpVar+1;
    I:=FALSE;
    insRecord('ImageIndex',T.IM_ID);
    insRecord('Comments',T.COMMENTS);
    insRecord('CheckVal',T.CHECK_VAL);
    insRecord('ValToString',T.VAL_TO_STRING);
    insRecord('StringToVal',T.STRING_TO_VAL);
    insRecord('SetOfValues',T.SET_OF_VALUES);
    DU := D_U(T.M_DATE, T.M_USER);
    IF I THEN
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
        C_TYPES,tmpVar,
        ''', '||DU||', Q=>0);');
      tmpVar:=tmpVar+1;
    ELSE
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
        C_TYPES,tmpVar,
        ', '||DU||', Q=>0);');
      tmpVar:=tmpVar+1;
    END IF;
  END LOOP;
END TYPES;
----------------------------------------------------------------------------
PROCEDURE Enums
IS
  tmpVar NUMBER;
  S SP.COMMANDS.COMMENTS%type;
  CurType NUMBER;
  qq BOOLEAN;
  DU VARCHAR2(500);
BEGIN
  CurType:=NULL;
  tmpVar:=1;
  if Not_Truncated then
    DELETE FROM SP_IO.CLIENT_SCRIPTS WHERE UPPER(SCRIPT)=C_ENUMS;
  end if;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_ENUMS,tmpVar,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  tmpVar:=tmpVar+1;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_ENUMS,tmpVar,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  tmpVar:=tmpVar+1;
  FOR E IN (SELECT * FROM SP.V_ENUMS ve 
              WHERE ve.E_ID >= 1000
                AND TYPE_ID >= 1000  
              ORDER BY TYPE_ID )
  LOOP
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
      C_ENUMS,tmpVar,'SP.INPUT.ENUM(Name=>'''||E.E_VAL||''',');
    tmpVar:=tmpVar+1;
-- добаление новых строк в скрипт следуующее,
-- если поле не пустое,
-- добавляется в скрипт ранее сформированная строка  вместе с запятой
-- и заполняем следующую строку
-- есле нет ранее заполненной строки, просто создаем новую строку для скрипта
    IF SP.G.notEQ(CurType,E.TYPE_ID) THEN
	    s := 'EType=>'''||E.TYPE_NAME||'''';
      CurType:=E.TYPE_ID;
    END IF;
    IF E.E_IM_ID IS NOT NULL THEN
      IF s IS NOT NULL THEN
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	        C_ENUMS,tmpVar,S||',');
		    tmpVar:=tmpVar+1;
      END IF;
      S := 'ImageIndex=>'||to_.str(E.E_IM_ID);
    END IF;
    IF E.N IS NOT NULL THEN
		  IF s IS NOT NULL THEN
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	        C_ENUMS,tmpVar,S||',');
		    tmpVar:=tmpVar+1;
      END IF;
      S := 'EN=>'||to_.str(E.N);
    END IF;
    IF E.x IS NOT NULL THEN
		  IF s IS NOT NULL THEN
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	        C_ENUMS,tmpVar,S||',');
		    tmpVar:=tmpVar+1;
      END IF;
      S := 'EX=>'||to_.str(E.X);
    END IF;
    IF E.Y IS NOT NULL THEN
		  IF s IS NOT NULL THEN
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	        C_ENUMS,tmpVar,S||',');
		    tmpVar:=tmpVar+1;
      END IF;
      S := 'EY=>'||to_.str(E.Y);
    END IF;
    IF E.D IS NOT NULL THEN
		  IF s IS NOT NULL THEN
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_ENUMS,tmpVar,S||',');
		    tmpVar:=tmpVar+1;
      END IF;
      S:='ED=>'''||TO_CHAR(E.D,FMT,'NLS_DATE_LANGUAGE ='||NLS)||'''';
    END IF;
    IF E.VAL_COMMENTS IS NOT NULL THEN
		  IF s IS NOT NULL THEN
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_ENUMS,tmpVar,S||',');
		    tmpVar:=tmpVar+1;
      END IF;
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	      C_ENUMS,tmpVar,'Comments=>''');
		  tmpVar:=tmpVar+1;
		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_ENUMS,tmpVar,Q_QQ(E.VAL_COMMENTS));
		  tmpVar:=tmpVar+1;
  		S := '''';
    END IF;
    IF E.S IS NOT NULL THEN
		  IF s IS NOT NULL THEN
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_ENUMS,tmpVar,S||',');
		    tmpVar:=tmpVar+1;
      END IF;
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	      C_ENUMS,tmpVar,'ES=>''');
		  tmpVar:=tmpVar+1;
		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_ENUMS,tmpVar,Q_QQ(E.S));
		  tmpVar:=tmpVar+1;
  		S := '''';
    END IF;
    DU := D_U(E.M_DATE, E.M_USER);
		IF s IS NOT NULL THEN
      --если в скрипт были добавлены строки кроме обязательных
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_ENUMS,tmpVar,s||','||DU||');');
		    tmpVar:=tmpVar+1;
		ELSE
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_ENUMS,tmpVar,','||DU||', Q=>0);');
		    tmpVar:=tmpVar+1;
    END IF;
    s:= NULL;
  END LOOP;
END ENUMS;
-------------------------------------------------------------------------------
PROCEDURE ROLES
IS
  tmpVar NUMBER;
  relVar NUMBER;
BEGIN
  tmpVar:=1;
  relVar:=1;
  if Not_Truncated then
    DELETE FROM SP_IO.CLIENT_SCRIPTS WHERE UPPER(SCRIPT)=C_ROLES;
    DELETE FROM SP_IO.CLIENT_SCRIPTS WHERE UPPER(SCRIPT)=C_ROLES_RELS;
  end if;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_ROLES,tmpVar,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  tmpVar:=tmpVar+1;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_ROLES_RELS,relVar,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  relVar:=relVar+1;
  -- Экспортируем роли. Для всех не встроенных ролей.
  FOR R IN (SELECT r.NAME, r.COMMENTS, r.ORA
              FROM SP.V_PRIM_ROLES r 
              WHERE r.ID >= 100
           )
  LOOP
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
      C_ROLES,tmpVar,
      'SP.INPUT.Role('''||R.NAME||''', '''||
                          Q_QQ(R.COMMENTS)||''', '||r.ORA||');');
    tmpVar:=tmpVar+1;
  END LOOP;
  -- Экспортируем иерархию ролей.
  FOR R IN (SELECT r.NAME, r.PARENT 
              FROM SP.V_ROLES r 
              WHERE R.PARENT is not null
           )
  LOOP
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
      C_ROLES_RELS,relVar,
      'SP.INPUT.Role_Rel('''||R.NAME||''', '''||R.PARENT||''');');
    relVar:=relVar+1;
  END LOOP;

END ROLES;
-------------------------------------------------------------------------------
PROCEDURE Users
IS
  tmpVar NUMBER;
  urLine NUMBER;
BEGIN
  tmpVar:=1;
  urLine:=1;
  if Not_Truncated then
    DELETE FROM SP_IO.CLIENT_SCRIPTS WHERE UPPER(SCRIPT)=C_USERS;
    DELETE FROM SP_IO.CLIENT_SCRIPTS WHERE UPPER(SCRIPT)=C_USER_ROLES;
  end if;
  OUT_S(C_USERS, tmpVar,
        '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  OUT_S(C_USER_ROLES, urLine,
        '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  -- Для всех пользователей.
  FOR U IN (SELECT u.SP_USER, u.S_VALUE PSW
              FROM SP.V_USERS_GLOBALS u
              WHERE NAME = 'USER_PWD'
            ORDER BY SP_USER  
           )
  LOOP
    -- Если у пользователя нет пароля, то он был введён в систему помимо
    -- фреимворка IMan и следовательно, я таких пользователей не экспортирую,
    -- как и их роли.
    if U.PSW is null then continue; end if; 
      OUT_S(C_USERS, tmpVar,
	      'SP.INPUT.User('''||U.SP_USER||''','''||U.PSW||''');');
    -- Для всех ролей пользователя.
    FOR R IN (SELECT r.ROLE_NAME
                FROM SP.V_USER_ROLES r 
                WHERE r.USER_NAME = U.SP_USER
                  AND r.USER_NAME != 'SP_USER_ROLE'
              ORDER BY ROLE_NAME    
             )
    LOOP
      OUT_S(C_USER_ROLES, urLine,
        'SP.INPUT.UserRole('''||U.SP_USER||''','''||r.ROLE_NAME||''');');
    END LOOP;
  END LOOP;
END Users;
-------------------------------------------------------------------------------
PROCEDURE Globals
IS
  tmpVar NUMBER;
  S SP.COMMANDS.COMMENTS%type;
BEGIN
  tmpVar:=1;
  if Not_Truncated then
    DELETE FROM SP_IO.CLIENT_SCRIPTS WHERE UPPER(SCRIPT)=C_GLOBALS;
  end if;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_GLOBALS,tmpVar,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  tmpVar:=tmpVar+1;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_GLOBALS,tmpVar,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  tmpVar:=tmpVar+1;
  -- Для всех параметров по умолчанию.
  FOR p IN (SELECT * FROM SP.V_GLOBAL_PAR_S WHERE ID >= 100)
  LOOP
    -- Name + Type
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	    C_GLOBALS,tmpVar,
	    'SP.INPUT.GlobalPar(Name=>'''||p.NAME||
      ''', ParType=> '''||SP.TO_STRTYPE(p.TYPE_ID)||''',');
    tmpVar:=tmpVar+1;
    -- Comments
    S:=NULL;
    IF p.COMMENTS IS NOT NULL THEN
		  IF s IS NOT NULL THEN
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_GLOBALS,tmpVar,s||',');
		    tmpVar:=tmpVar+1;
      END IF;
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	      C_GLOBALS,tmpVar,'Comments=>''');
		  tmpVar:=tmpVar+1;
		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_GLOBALS,tmpVar,Q_QQ(p.COMMENTS));
		  tmpVar:=tmpVar+1;
  		s := '''';
    END IF;
    -- GREACTION
    IF p.reaction IS NOT NULL THEN
		  IF s IS NOT NULL THEN
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_GLOBALS,tmpVar,s||',');
		    tmpVar:=tmpVar+1;
      END IF;
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	      C_GLOBALS,tmpVar,'Reaction=>''');
		  tmpVar:=tmpVar+1;
		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_GLOBALS,tmpVar,Q_QQ(p.reaction));
		  tmpVar:=tmpVar+1;
  		S := '''';
    END IF;
    -- R_ONLY
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
      C_GLOBALS,tmpVar,S||',');
    tmpVar:=tmpVar+1;
    S:='R_ONLY=>'||to_.str(p.R_ONLY_ID)||'';
    -- V
    IF p.S_VALUE IS NOT NULL THEN
		  IF s IS NOT NULL THEN
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_GLOBALS,tmpVar,s||',');
		    tmpVar:=tmpVar+1;
      END IF;
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	      C_GLOBALS,tmpVar,'V=>''');
		  tmpVar:=tmpVar+1;
		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_GLOBALS,tmpVar,Q_QQ(p.S_VALUE));
		  tmpVar:=tmpVar+1;
  		S := '''';
    END IF;
		IF s IS NOT NULL THEN
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_GLOBALS,tmpVar,s||');');
		    tmpVar:=tmpVar+1;
		ELSE
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_GLOBALS,tmpVar,',Q=>0);');
		    tmpVar:=tmpVar+1;
    END IF;
    s:= NULL;
  END LOOP;
END Globals;
-------------------------------------------------------------------------------
PROCEDURE GlobalValues
IS
  tmpVar NUMBER;
  SValue SP.COMMANDS.COMMENTS%type;
BEGIN
  tmpVar:=1;
  if Not_Truncated then
    DELETE FROM SP_IO.CLIENT_SCRIPTS WHERE UPPER(SCRIPT)=C_USERS_GLOBALS;
  end if;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_USERS_GLOBALS,tmpVar,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  tmpVar:=tmpVar+1;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_USERS_GLOBALS,tmpVar,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  tmpVar:=tmpVar+1;
  -- Сохраняем переопределённые параметры пользователей.
  FOR p IN (SELECT U.*,G.NAME,G.TYPE_ID
  						FROM SP.USERS_GLOBALS U, SP.GLOBAL_PAR_S G
      					WHERE GL_PAR_ID = G.ID
      						AND G.NAME != 'USER_PWD')
  LOOP
    SValue := SP.Val_to_Str(SP.TVALUE(p.TYPE_ID,null, 0,
            				                  p.E_VAL,p.N,p.D,p.S,p.X,p.Y));
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	    C_USERS_GLOBALS,tmpVar,
	    'SP.INPUT.GlobalParValue(parName=>'''||p.NAME||
      ''', UserName=>'''||p.SP_USER||
      ''', V=>''');
    tmpVar:=tmpVar+1;
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	    C_USERS_GLOBALS,tmpVar,Q_QQ(SValue));
    tmpVar:=tmpVar+1;
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	    C_USERS_GLOBALS,tmpVar,''');');
    tmpVar:=tmpVar+1;
  END LOOP;
END GlobalValues;
-------------------------------------------------------------------------------
PROCEDURE DOCs
IS
  DocLine NUMBER;
  CurGroup SP.GROUPS.NAME%type;
  tmpRole VARCHAR2(4000);
  DU VARCHAR2(500);
BEGIN
  DocLine:=1;
  CurGroup:=NULL;
  if Not_Truncated then
    DELETE FROM SP_IO.CLIENT_SCRIPTS
      WHERE UPPER(SCRIPT)=C_DOCS;
  end if;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_DOCS,DocLine,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  DocLine:=DocLine+1;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_DOCS,DocLine,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  DocLine:=DocLine+1;
  -- Сохраняем параграфы документов.
  FOR p IN (SELECT * FROM SP.V_DOCS order by GROUP_NAME, LINE)
  LOOP
    if p.USING_ROLE is not null then 
      tmpRole:=''', UsingRoleName=>'''||p.USING_ROLE;
    else
      tmpRole:='';  
    end if;  
    if G.notUpEQ(CurGroup, p.GROUP_NAME) then
      CurGroup := p.GROUP_NAME;
	    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_DOCS,DocLine,
		    'SP.INPUT.DOC(Line=>'''||p.LINE||
	      ''', FORMAT=>'''||p.FORMAT||
	      ''', GroupName=>'''||p.GROUP_NAME||
	      tmpROLE||
	--      ''', IMAGE=>'''||p.IMAGE||
	      ''', Paragraph=>''');
    else
	    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_DOCS,DocLine,
		    'SP.INPUT.DOC(Line=>'''||p.LINE||
	      ''', FORMAT=>'''||p.FORMAT||
	      tmpROLE||
	--      ''', IMAGE=>'''||p.IMAGE||
	      ''', Paragraph=>''');
    end if;
	  DocLine:=DocLine+1;
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	    C_DOCS,DocLine,p.PARAGRAPH);
    DocLine:=DocLine+1;
    DU := D_U(p.M_DATE, p.M_USER);
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	    C_DOCS,DocLine,''', '||DU||');');
    DocLine:=DocLine+1;
  END LOOP;
END DOCs;
-------------------------------------------------------------------------------
PROCEDURE CatalogTree
IS
  TreeLine NUMBER;
  CurParent NUMBER;
  NewParent BOOLEAN;
  DU VARCHAR2(500);
BEGIN
  TreeLine:=1;
  NewParent:=TRUE;
  CurParent:=NULL;
  if Not_Truncated then
    DELETE FROM SP_IO.CLIENT_SCRIPTS
      WHERE UPPER(SCRIPT)=C_CATALOG_TREE;
  end if;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_CATALOG_TREE,TreeLine,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  TreeLine:=TreeLine+1;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_CATALOG_TREE,TreeLine,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  TreeLine:=TreeLine+1;
  FOR t IN (SELECT * FROM SP.V_CATALOG_TREE WHERE ID>=100)
  LOOP
    IF G.notEQ(t.PARENT_ID,CurParent) THEN
      CurParent:=t.PARENT_ID;
      NewParent:=TRUE;
    END IF;
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
      C_CATALOG_TREE,TreeLine,
      'SP.INPUT.Node(NAME=>'''||t.NAME||''',');
    TreeLine:=TreeLine+1;
    DU := D_U(t.M_DATE, t.M_USER);
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
      C_CATALOG_TREE,TreeLine,
      DU||',');
    TreeLine:=TreeLine+1;
    IF t.IM_ID IS NOT NULL THEN
	    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	      C_CATALOG_TREE,TreeLine,
	      'ImageIndex=>'||TO_CHAR(t.IM_ID)||',');
	    TreeLine:=TreeLine+1;
    END IF;
    -- COMMENTS
    CASE
      WHEN (t.COMMENTS IS NULL) AND NOT NewParent THEN
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
          C_CATALOG_TREE,TreeLine,
          'Q=>0);');
        TreeLine:=TreeLine+1;
      WHEN (LENGTH(t.COMMENTS)>3500) AND NOT NewParent  THEN
  		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
  		    C_CATALOG_TREE,TreeLine,'Comments=>''');
  		  TreeLine:=TreeLine+1;
		  	INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    	C_CATALOG_TREE,TreeLine,Q_QQ(t.COMMENTS));
		  	TreeLine:=TreeLine+1;
  		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
  		    C_CATALOG_TREE,TreeLine,''');');
  		  TreeLine:=TreeLine+1;
      WHEN (LENGTH(t.COMMENTS)>3500) AND NewParent  THEN
  		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
  		    C_CATALOG_TREE,TreeLine,'Comments=>''');
  		  TreeLine:=TreeLine+1;
		  	INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    	C_CATALOG_TREE,TreeLine,Q_QQ(t.COMMENTS));
		  	TreeLine:=TreeLine+1;
  		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
  		    C_CATALOG_TREE,TreeLine,''',');
  		  TreeLine:=TreeLine+1;
      WHEN (LENGTH(t.COMMENTS)<3500) AND NewParent  THEN
		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_CATALOG_TREE,TreeLine,
		      'Comments=>'''||Q_QQ(t.COMMENTS)||''',');
		    TreeLine:=TreeLine+1;
      WHEN (LENGTH(t.COMMENTS)<3500) AND NOT NewParent  THEN
		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_CATALOG_TREE,TreeLine,
		      'Comments=>'''||Q_QQ(t.COMMENTS)||''');');
		    TreeLine:=TreeLine+1;
    END CASE;
    -- NEW PARENT_ID
    IF NewParent THEN
      NewParent:=FALSE;
      CASE
        WHEN (LENGTH(nvl(t.PARENT_NAME,' '))<3500) THEN
  		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
  		      C_CATALOG_TREE,TreeLine,
						'ParentNode=>'''||Q_QQ(t.PARENT_NAME)||''');');
  		    TreeLine:=TreeLine+1;
        WHEN (LENGTH(t.PARENT_NAME)>3500) THEN
 		      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
  		      C_CATALOG_TREE,TreeLine,
            'ParentNode=>''');
  		    TreeLine:=TreeLine+1;
		  	  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    	  C_CATALOG_TREE,TreeLine,Q_QQ(t.PARENT_NAME));
		  	  TreeLine:=TreeLine+1;
  		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
  		      C_CATALOG_TREE,TreeLine,''');');
  		    TreeLine:=TreeLine+1;
      END CASE;
    END IF;
  END LOOP;
END CatalogTree;
-------------------------------------------------------------------------------
-- Экспорт Групп.
PROCEDURE Groups
is
  tmpVar NUMBER;
  A_Line NUMBER;
  S SP.COMMANDS.COMMENTS%type;
  DU VARCHAR2(500);
begin
  tmpVar := 1;
  A_Line := 1;
  CLS(C_GROUPS);
  CLS(C_ALIASES);
  OUT_S(C_GROUPS,tmpVar,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  OUT_S(C_ALIASES,A_Line,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  OUT_S(C_GROUPS,tmpVar,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  OUT_S(C_ALIASES,A_Line,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  -- Вставляем группы.
  for G in (select g.ID G_ID,g.IM_ID, g.NAME NAME, g.COMMENTS COMMENTS,
	                 g_er.NAME G_ROLE, g.EDIT_ROLE G_ER_ID,
                   g.M_DATE, g.M_USER, g.ALIAS ALIAS
              from SP.GROUPS g, SP.SP_ROLES g_er
	            where g.EDIT_ROLE=g_er.ID(+)
                and g.ID >= 100)
  loop
    DU := D_U(G.M_DATE, G.M_USER);
    if G.G_ROLE is null then
      S:='SP.INPUT.BGroup( NAME=>'''||G.Name||''', '||DU||
                          ', COMMENTS =>'''||G.COMMENTS||''');';
    else
      S:='SP.INPUT.BGroup( NAME=>'''||G.Name||''', '||DU||
                           ', COMMENTS =>'''||G.COMMENTS||
                           ''', RoleName=>'''||G.G_ROLE||''');';
    end if;  
    OUT_S(C_GROUPS,tmpVar,S);
    -- Если группа является прозвищем, то добавляем ссылку на объект модели.
    if G.ALIAS is not null then
	    OUT_S(C_ALIASES,A_Line,
	      'SP.INPUT.Alias( GroupName=>'''||G.Name||''','||
	      ' ObjectName=>'''||SP.MO.REL_NAME(G.ALIAS)||''');');
    end if;
  end loop;
  -- Вставляем связи.
  for G in (select * from SP.V_GROUPS vg where (vg.R_ID>=100)
              order by PARENT_G, LINE)
  loop
    OUT_S(C_GROUPS,tmpVar,
      'SP.INPUT.BGroup( NAME=>'''||G.Name||''','||
      ' Parent_NAME=>'''||G.PARENT_G||''', '||
      ' Line=>'''||G.LINE||''');');
  end loop;
end Groups;
-------------------------------------------------------------------------------
PROCEDURE CATALOG(SetOfID TNUMBERS DEFAULT NULL)
IS
  ParameterLine NUMBER;
  RelLine NUMBER;
  ObjectLine NUMBER;
  MacroLine NUMBER;
  S SP.COMMANDS.COMMENTS%type;
  I BOOLEAN;
  NewObject BOOLEAN;
  STAGE VARCHAR2(60);
  l_cursor rc;
  O SP.V_Objects%ROWTYPE;
  MS SP.TSTRINGS;
  DU VARCHAR2(500);
BEGIN
  ObjectLine:=1;
  RelLine:=1;
  ParameterLine:=1;
  MacroLine:=1;
  NewObject:=TRUE;
  STAGE:='BEGIN';
	-- Экспортируем каталог.
  if Not_Truncated then
    DELETE FROM SP_IO.CLIENT_SCRIPTS
    WHERE UPPER(SCRIPT)=C_OBJECTS
      OR  UPPER(SCRIPT)=C_OBJECT_PARS
      OR  UPPER(SCRIPT)=C_OBJECT_RELS
      OR  UPPER(SCRIPT)=C_MACROS;
  end if;
  -- C_OBJECTS 
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_OBJECTS,ObjectLine,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  ObjectLine:=ObjectLine+1;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_OBJECTS,ObjectLine,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  ObjectLine:=ObjectLine+1;
  -- C_OBJECT_PARS
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_OBJECT_PARS,ParameterLine,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  ParameterLine:=ParameterLine+1;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_OBJECT_PARS,ParameterLine,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  ParameterLine:=ParameterLine+1;
  -- C_OBJECT_RELS
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_OBJECT_RELS,RelLine,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  RelLine:=RelLine+1;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_OBJECT_RELS,RelLine,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  RelLine:=RelLine+1;
  --
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_MACROS,MacroLine,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  MacroLine:=MacroLine+1;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_MACROS,MacroLine,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  MacroLine:=MacroLine+1;
  IF SetOfID IS NULL THEN
    OPEN l_cursor FOR SELECT *
              FROM SP.V_Objects
              WHERE ID>=100;
  ELSE
    OPEN l_cursor FOR SELECT o.*
              FROM SP.V_Objects o,
                 (SELECT COLUMN_VALUE AS ID
    								FROM TABLE( SetOfID) ) s
              WHERE O.ID>=100 AND O.ID = S.ID;
  END IF;
  STAGE:='OBJECTS';
  LOOP
    FETCH l_cursor INTO O;
    EXIT WHEN l_cursor%NOTFOUND;
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
      C_OBJECTS,ObjectLine,
      'SP.INPUT.Object(NAME=>'''||o.FULL_NAME||''',');
    ObjectLine:=ObjectLine+1;
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
      C_OBJECTS,ObjectLine,
      'OID=>'''||o.OID||''',');
    ObjectLine:=ObjectLine+1;
    IF o.IM_ID IS NOT NULL THEN
	    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	      C_OBJECTS,ObjectLine,
	      'ImageIndex=>'||TO_CHAR(o.IM_ID)||',');
	    ObjectLine:=ObjectLine+1;
    END IF;
    IF o.COMMENTS IS NOT NULL THEN
	    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	      C_OBJECTS,ObjectLine,
	      'Comments=>'''||Q_QQ(o.COMMENTS)||''',');
	    ObjectLine:=ObjectLine+1;
    END IF;
    IF o.KIND IS NOT NULL THEN
	    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	      C_OBJECTS,ObjectLine,
	      'Kind=>'''||o.KIND||''',');
	    ObjectLine:=ObjectLine+1;
    END IF;
    IF o.USING_ROLE IS NOT NULL THEN
	    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	      C_OBJECTS,ObjectLine,
	      'UsingRole=>'''||o.USING_ROLE||''',');
	    ObjectLine:=ObjectLine+1;
    END IF;
    IF o.EDIT_ROLE IS NOT NULL THEN
		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	      C_OBJECTS,ObjectLine,
	      'EditRole=>'''||o.EDIT_ROLE||''',');
	    ObjectLine:=ObjectLine+1;
    END IF;
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
      C_OBJECTS,ObjectLine,
      'MDate=>'''||TO_CHAR(o.MODIFIED, FMT, 'NLS_DATE_LANGUAGE ='||NLS)||
      ''', MUser=>'''||o.M_USER||''',');
    ObjectLine:=ObjectLine+1;
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
      C_OBJECTS,ObjectLine,
      'Q=>0);');
    ObjectLine:=ObjectLine+1;
    NewObject:=TRUE;
    STAGE:='PARAMETERS';
    -- Экспортируем параметры объекта.
 	  FOR P IN (SELECT p.NAME, p.COMMENTS, p.TYPE_ID,t.NAME TYPE_NAME, p.R_ONLY,
	                   p.E_VAL, p.N, p.D, p.S, p.X, p.Y, p.M_DATE, p.M_USER,
                     SP.Val_to_Str( SP.TVALUE(
                       p.TYPE_ID,null,0,p.E_VAL,p.N,p.D,p.S,p.x,p.y)) S_VALUE,
                     t.CHECK_VAL, t.VAL_TO_STRING, t.STRING_TO_VAL,
                     GG.NAME GROUP_NAME
	              FROM SP.OBJECT_PAR_S p, SP.PAR_TYPES t, SP.GROUPS gg
                  WHERE p.OBJ_ID = o.ID
                    AND t.ID = p.TYPE_ID
                    AND p.TYPE_ID != G.TRel
                    AND GG.ID = P.GROUP_ID
	            )
	  LOOP
		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_OBJECT_PARS,ParameterLine,
		    'SP.INPUT.ObjectPar(Name=>'''||P.NAME||''',');
		  ParameterLine:=ParameterLine+1;
      IF NewObject THEN
		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_OBJECT_PARS,ParameterLine,
          'ObjectName=>'''||o.FULL_NAME||''',');
		    ParameterLine:=ParameterLine+1;
        NewObject:=FALSE;
      END IF;
      IF LENGTH(p.COMMENTS)>3500 THEN
  		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
  		    C_OBJECT_PARS,ParameterLine,'Comments=>''');
  		  ParameterLine:=ParameterLine+1;
		  	INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    	C_OBJECT_PARS,ParameterLine,Q_QQ(p.COMMENTS));
		  	ParameterLine:=ParameterLine+1;
  		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
  		    C_OBJECT_PARS,ParameterLine,''',');
  		  ParameterLine:=ParameterLine+1;
      ELSE
  		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
  		    C_OBJECT_PARS,ParameterLine,
							'Comments=>'''||Q_QQ(p.COMMENTS)||''',');
  		  ParameterLine:=ParameterLine+1;
      END IF;
      DU := D_U(p.M_DATE, p.M_USER);
		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_OBJECT_PARS,ParameterLine,
		     DU||',');
		  ParameterLine:=ParameterLine+1;
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
        C_OBJECT_PARS,ParameterLine,
         'ParType=>'''||P.TYPE_NAME||
        ''', R_ONLY=>'''||SP.to_strR_ONLY(P.R_ONLY)||''',');
      ParameterLine:=ParameterLine+1;
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
        C_OBJECT_PARS,ParameterLine,
         'GROUP_NAME=>'''||P.GROUP_NAME||''',');
      ParameterLine:=ParameterLine+1;
      -- Отдельно обрабатываем параметры у которых дата не нулл
      -- или определение типа может допускать неверное преобразование значения
      -- в строку. А именно, тип имеет не именованное значение,
      -- и блок преобразования в строку или обратно неопределён.
      -- В этом случае экспортируем значение по полям.
      IF   (P.D IS NOT NULL)
        OR (    (P.CHECK_VAL IS NOT NULL)
            AND
                ((P.VAL_TO_STRING IS NULL) OR (P.STRING_TO_VAL IS NULL))
           )
      THEN
		    IF P.N IS NOT NULL THEN
			    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
			      C_OBJECT_PARS,ParameterLine,
			      'N=>'||to_.str(P.N)||',');
			    ParameterLine:=ParameterLine+1;
		    END IF;
		   IF P.D IS NOT NULL THEN
	         S:='D=>'''||TO_CHAR(P.D,FMT,'NLS_DATE_LANGUAGE ='||NLS)||''',';
			    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
			      C_OBJECT_PARS,ParameterLine,S);
			    ParameterLine:=ParameterLine+1;
		    END IF;
		    S:=P.S;
		    I:=FALSE;
		    IF P.S IS NOT NULL THEN
		      I:=TRUE;
			    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
			      C_OBJECT_PARS,ParameterLine,'S=>''');
			    ParameterLine:=ParameterLine+1;
			    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
			      C_OBJECT_PARS,ParameterLine,Q_QQ(P.S));
		      ParameterLine:=ParameterLine+1;
		    END IF;
         CASE
		      WHEN P.X IS NULL AND P.Y IS NULL THEN
		        S:='Q=>0);';
		      WHEN P.X IS NOT NULL AND P.Y IS NOT NULL THEN
		        S:='X=>'||to_.str(P.X)||', Y=>'||to_.str(P.Y)||');';
  	      WHEN P.X IS NOT NULL AND P.Y IS NULL THEN
		      S:='X=>'||to_.str(P.X)||');';
		      WHEN P.X IS NULL AND P.Y IS NOT NULL THEN
		      S:='Y=>'||to_.str(P.Y)||');';
		    END CASE;
		    IF I THEN
			    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
			      C_OBJECT_PARS,ParameterLine,''', '||S);
		    ELSE
			    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
			      C_OBJECT_PARS,ParameterLine,S);
		    END IF;
		    ParameterLine:=ParameterLine+1;
      ELSE
        -- Экспортируем значение как строку.
      CASE
        WHEN P.S_VALUE IS NOT NULL AND LENGTH(P.S_VALUE)>3500 THEN
		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_OBJECT_PARS,ParameterLine,'V=>''');
		    ParameterLine:=ParameterLine+1;
		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_OBJECT_PARS,ParameterLine,Q_QQ(P.S_VALUE));
	      ParameterLine:=ParameterLine+1;
	      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	        C_OBJECT_PARS,ParameterLine,''');');
		    ParameterLine:=ParameterLine+1;
        WHEN P.S_VALUE IS NOT NULL  THEN
	      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	        C_OBJECT_PARS,ParameterLine,
	        'V=>'''||Q_QQ(P.S_VALUE)||''');');
	      ParameterLine:=ParameterLine+1;
        ELSE
			    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
			      C_OBJECT_PARS,ParameterLine,
			      'Q=>0);');
			    ParameterLine:=ParameterLine+1;
		    END CASE;
      END IF;
	  END LOOP;
    NewObject:=TRUE;
    STAGE:='RELS';
    -- Экспортируем связи объекта.
 	  FOR P IN (SELECT p.NAME, p.COMMENTS, p.TYPE_ID,t.NAME TYPE_NAME, p.R_ONLY,
	                   p.E_VAL, p.N, p.D, p.S, p.X, p.Y, p.M_DATE, p.M_USER,
                     SP.Val_to_Str( SP.TVALUE(
                       p.TYPE_ID,null,0,p.E_VAL,p.N,p.D,p.S,p.x,p.y)) S_VALUE,
                     t.CHECK_VAL, t.VAL_TO_STRING, t.STRING_TO_VAL,
                     GG.NAME GROUP_NAME
                FROM SP.OBJECT_PAR_S p, SP.PAR_TYPES t, SP.GROUPS gg
                  WHERE p.OBJ_ID=o.ID
                    AND t.ID=p.TYPE_ID
                    AND p.TYPE_ID = G.TRel
                    AND GG.ID = P.GROUP_ID
              )
	  LOOP
		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_OBJECT_RELS,RelLine,
		    'SP.INPUT.ObjectPar(Name=>'''||P.NAME||''',');
		  RelLine:=RelLine+1;
      IF NewObject THEN
		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_OBJECT_RELS,RelLine,
          'ObjectName=>'''||o.FULL_NAME||''',');
		    RelLine:=RelLine+1;
        NewObject:=FALSE;
      END IF;
      IF LENGTH(p.COMMENTS)>3500 THEN
  		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
  		    C_OBJECT_RELS,RelLine,'Comments=>''');
  		  RelLine:=RelLine+1;
		  	INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    	C_OBJECT_RELS,RelLine,Q_QQ(p.COMMENTS));
		  	RelLine:=RelLine+1;
  		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
  		    C_OBJECT_RELS,RelLine,''',');
  		  RelLine:=RelLine+1;
      ELSE
  		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
  		    C_OBJECT_RELS,RelLine,
							'Comments=>'''||Q_QQ(p.COMMENTS)||''',');
  		  RelLine:=RelLine+1;
      END IF;
      DU := D_U(p.M_DATE, p.M_USER);
		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_OBJECT_RELS,RelLine,
		     DU||',');
		  RelLine:=RelLine+1;
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
        C_OBJECT_RELS,RelLine,
         'ParType=>'''||P.TYPE_NAME||
        ''', R_ONLY=>'''||SP.to_strR_ONLY(P.R_ONLY)||''',');
      RelLine:=RelLine+1;
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
        C_OBJECT_RELS,RelLine,
         'GROUP_NAME=>'''||P.GROUP_NAME||''',');
      RelLine:=RelLine+1;
        -- Экспортируем значение как строку.
      CASE
        WHEN P.S_VALUE IS NOT NULL AND LENGTH(P.S_VALUE)>3500 THEN
		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_OBJECT_RELS,RelLine,'V=>''');
		    RelLine:=RelLine+1;
		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_OBJECT_RELS,RelLine,Q_QQ(P.S_VALUE));
	      RelLine:=RelLine+1;
	      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	        C_OBJECT_RELS,RelLine,''');');
		    RelLine:=RelLine+1;
        WHEN P.S_VALUE IS NOT NULL  THEN
	      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	        C_OBJECT_RELS,RelLine,
	        'V=>'''||Q_QQ(P.S_VALUE)||''');');
	      RelLine:=RelLine+1;
        ELSE
			    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
			      C_OBJECT_RELS,RelLine,
			      'Q=>0);');
			    RelLine:=RelLine+1;
		  END CASE;
	  END LOOP;
    STAGE:='MACROS';
    -- Экспортируем макрокоманды
    NewObject:=TRUE;
 	  FOR M IN (SELECT LINE, ALIAS, COMMENTS, CMD_NAME,
                     USED_OBJECT_FULL_NAME, 
                     MACRO, CONDITION, M_DATE, M_USER
	              FROM SP.V_MACROS
                  WHERE OBJECT_ID=o.ID
                ORDER BY LINE  
	            )
	  LOOP
      IF NewObject THEN
		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_MACROS,MacroLine,
          'SP.INPUT.Macro(ObjectName=>'''||o.FULL_NAME||''',');
		    MacroLine:=MacroLine+1;
		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_MACROS,MacroLine,
		      'LineNum=>'''||M.LINE||''', Command=>'''||M.CMD_NAME||''',');
		    MacroLine:=MacroLine+1;
        NewObject:=FALSE;
      ELSE
		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_MACROS,MacroLine,
		      'SP.INPUT.Macro(LineNum=>'''||M.LINE||
          ''', Command=>'''||M.CMD_NAME||''',');
		    MacroLine:=MacroLine+1;
      END IF;
      IF M.ALIAS IS NOT NULL THEN
		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_MACROS,MacroLine,
		      'Alias=>'''||M.ALIAS||''',');
		      MacroLine:=MacroLine+1;
      END IF;
      IF M.USED_OBJECT_FULL_NAME IS NOT NULL THEN
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
          C_MACROS,MacroLine,
          'UsedObject=>'''||M.USED_OBJECT_FULL_NAME||''',');
        MacroLine:=MacroLine+1;
      END IF;
      -- Comments
      CASE
        WHEN M.COMMENTS IS NOT NULL AND LENGTH(M.COMMENTS)>3500 THEN
			    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
			      C_MACROS,MacroLine,'Comments=>''');
			    MacroLine:=MacroLine+1;
			    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
			      C_MACROS,MacroLine,Q_QQ(M.COMMENTS));
			    MacroLine:=MacroLine+1;
			    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
			      C_MACROS,MacroLine,''',');
			    MacroLine:=MacroLine+1;
        WHEN m.COMMENTS IS NOT NULL  THEN
			    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
			      C_MACROS,MacroLine,
			      'Comments=>'''||Q_QQ(M.COMMENTS)||''',');
			    MacroLine:=MacroLine+1;
        ELSE
			    NULL;
		  END CASE;
      -- MacroBlock
      -- Вывод макро блока делаем по строкам,
      -- если его длина более 500 символов.
      -- Добавляем в конец каждой строки символы вызова процедуры
      -- переноса строки.
      CASE
        WHEN M.MACRO IS NOT NULL AND LENGTH(M.MACRO)>500 THEN
			    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
			    C_MACROS,MacroLine,'MacroBlock=>''');
			    MacroLine:=MacroLine+1;
          S:=Q_QQ(M.MACRO);
          --d(LENGTH(s),'SP.OUTPUT.CATALOG');
          -- L => false - сохраняет структуру форматирования блоков.
          MS:=SP.STRINGS_FROM_STRING(S=>S,Delim=>chr(10),L=>false);
          --d(MS.COUNT,'SP.OUTPUT.CATALOG');
          for i in MS.first..MS.last
          loop
			      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
			        C_MACROS,MacroLine,
              MS(i)||'''||to_.str||''');
		        MacroLine:=MacroLine+1;
          end loop;
		      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		        C_MACROS,MacroLine,''',');
		      MacroLine:=MacroLine+1;
        WHEN M.MACRO IS NOT NULL  THEN
		      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		        C_MACROS,MacroLine,
		        'MacroBlock=>'''||
             replace(Q_QQ(M.MACRO),chr(10),'''||to_.str||''')
             ||''',');
		      MacroLine:=MacroLine+1;
      ELSE
		    NULL;
      END CASE;
      -- Дата изменения и пользователь. 
      DU := D_U(M.M_DATE, M.M_USER);
	    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	      C_MACROS,MacroLine,
	      DU||',');
	    MacroLine:=MacroLine+1;
      --Condition
      CASE
        WHEN M.CONDITION IS NOT NULL AND LENGTH(M.CONDITION)>3500 THEN
			    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
			      C_MACROS,MacroLine,'Condition=>''');
			    MacroLine:=MacroLine+1;
			    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
			      C_MACROS,MacroLine,
            replace(Q_QQ(M.CONDITION),chr(10),'''||to_.str||'''));
		      MacroLine:=MacroLine+1;
		      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		        C_MACROS,MacroLine,''');');
		      MacroLine:=MacroLine+1;
        WHEN M.CONDITION IS NOT NULL  THEN
		      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		        C_MACROS,MacroLine,
		        'Condition=>'''||
            replace(Q_QQ(M.CONDITION),chr(10),'''||to_.str||''')
            ||''');');
		      MacroLine:=MacroLine+1;
      ELSE
		    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_MACROS,MacroLine,
		      'Q=>0);');
		    MacroLine:=MacroLine+1;
      END CASE;
	  END LOOP;
  END LOOP;
EXCEPTION
  when others then 
    raise_application_Error(-20000,
      'Ошибка экспорта данных каталога на стадии '||STAGE||'  '||SQLERRM||'!');
END CATALOG;

-------------------------------------------------------------------------------
PROCEDURE ARRAYS(SetOfGroupID TNUMBERS DEFAULT NULL)
is
  Line NUMBER;
  S SP.COMMANDS.COMMENTS%type;
--  I BOOLEAN;
--  ovr BOOLEAN;
  FullName SP.COMMANDS.COMMENTS%type;
  OLD_FullName SP.COMMANDS.COMMENTS%type;
  l_cursor rc;
  ar SP.V_ARRAYS%ROWTYPE;
  --MS SP.TSTRINGS;
  DU VARCHAR2(500);
begin
  Line := 1;
  FullName := ' ';
  OLD_FullName := ' ';
  if Not_Truncated then
    DELETE FROM SP_IO.CLIENT_SCRIPTS
    WHERE UPPER(SCRIPT)=C_ARRS;
  end if;
  -- 
  OUT_S(C_ARRS, Line,
        '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  OUT_S(C_ARRS, Line, 'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  IF SetOfGroupID IS NULL THEN
    OPEN l_cursor FOR SELECT * FROM SP.V_ARRAYS;
  ELSE
    OPEN l_cursor FOR 
      SELECT o.*
        FROM SP.V_Objects o,
            (SELECT COLUMN_VALUE AS ID FROM TABLE(SetOfGroupID) ) s
        WHERE O.ID = S.ID;
  END IF;
  LOOP
    FETCH l_cursor INTO ar;
    EXIT WHEN l_cursor%NOTFOUND;
    -- Выводим имя и тип значения.
    FullName := ar.GROUP_NAME||'.'||ar.NAME;
    if FullName != OLD_FullName then
      OLD_FullName := FullName;
      S := '';
      OUT_S(C_ARRS, Line,
      'SP.INPUT.ArrValue(NAME=>'''||FullName||''',T=>'''||ar.TYPE_NAME||''',');
    else
      S := 'SP.INPUT.ArrValue(T=>'''||ar.TYPE_NAME||''',';
    end if;
    -- Выводим индекс элемента. 
    if ar.IND_X is not null then
      S := S||'IndX=> '|| ar.IND_X||',';
    end if;  
    if ar.IND_Y is not null then
      S := S||'IndY=> '|| ar.IND_Y||',';
    end if;  
    if ar.IND_Z is not null then
      S := S||'IndZ=> '|| ar.IND_Z||',';
    end if;  
    if ar.IND_D is not null then
      S := S||'IndD=> '''||
           TO_CHAR(ar.IND_D, FMT, 'NLS_DATE_LANGUAGE ='||NLS)||''',';
    end if; 
    if ar.IND_S is not null then
      if length(ar.IND_S) > 1000 then
          OUT_S(C_ARRS, Line, S||'IndS=>''');
          OUT_S(C_ARRS, Line, Q_QQ(ar.IND_S));
          OUT_S(C_ARRS, Line, ''',');
      else
        OUT_S(C_ARRS, Line, S||'IndS=>'''||Q_QQ(ar.IND_S)||''',');
      end if;
    else
      OUT_S(C_ARRS, Line, S);  
    end if;  
    S:= '';
    -- Выводим значение, дату изменения и пользователя.
    DU := D_U(ar.M_DATE, ar. M_USER);
    if ar.V is null then
      OUT_S(C_ARRS, Line, DU||');');
    else  
      if length(ar.V) > 3500 then
        OUT_S(C_ARRS, Line, 'V=>''');
        OUT_S(C_ARRS, Line, Q_QQ(ar.V));
        OUT_S(C_ARRS, Line, ''','||DU||');');
      else
        OUT_S(C_ARRS, Line, 'V=>'''||Q_QQ(ar.V)||''','||DU||');');
      end if;
    end if;
  END LOOP; 
END ARRAYS;

-------------------------------------------------------------------------------
PROCEDURE MODEL
IS
  ModelLine NUMBER;
  SeqLine NUMBER;
  ModObjLine NUMBER;
  ModObjParLine NUMBER;
  ModObjRelLine NUMBER;
  ModObjSParLine NUMBER;
  ModObjSRelLine NUMBER;
  S SP.COMMANDS.COMMENTS%type;
  I BOOLEAN;
  ovr BOOLEAN;
  FPAR SP.TMPAR;
  NewModel BOOLEAN;
  NewObject BOOLEAN;
  DU VARCHAR2(500);
  PAR_NAME VARCHAR2(128); 
  REL_OID VARCHAR2(40);
  REL_MODEL SP.MODELS.NAME%type;
BEGIN
  SeqLine:=1;
  ModelLine:=1;
  ModObjLine:=1;
  ModObjParLine:=1;
  ModObjRelLine:=1;
  ModObjSParLine:=1;
  ModObjSRelLine:=1;
  NewModel:=TRUE;
  NewObject:=TRUE;
  if Not_Truncated then
    DELETE FROM SP_IO.CLIENT_SCRIPTS
      WHERE UPPER(SCRIPT)=C_MODELS
        OR  UPPER(SCRIPT)=C_MODEL_OBJECTS
        OR  UPPER(SCRIPT)=C_MODEL_OBJECT_PARS
        OR  UPPER(SCRIPT)=C_MODEL_OBJECT_RELS
        OR  UPPER(SCRIPT)=C_MODEL_OBJECT_STORIES
        OR  UPPER(SCRIPT)=C_MODEL_OBJECT_REL_STORIES
        OR  UPPER(SCRIPT)=C_SEQUENCES;
  end if;
  -- Экспортируем последовательности.  
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_SEQUENCES,SeqLine,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  SeqLine:=SeqLine+1;
  FOR Sq IN(SELECT ds.SEQUENCE_NAME, ds.LAST_NUMBER 
           from SYS.DBA_SEQUENCES ds where ds.SEQUENCE_OWNER = 'SP_IM')
  LOOP
    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
      C_SEQUENCES,SeqLine,
      'SP.INPUT.SEQ(NAME=>'''||Sq.SEQUENCE_NAME||
      ''', LAST_NUM=>'||Sq.LAST_NUMBER||');');
    SeqLine:=SeqLine+1;
  END LOOP;
  -- C_MODELS
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_MODELS,ModelLine,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  ModelLine:=ModelLine+1;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_MODELS,ModelLine,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  ModelLine:=ModelLine+1;
  -- C_MODEL_OBJECTS
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_MODEL_OBJECTS,ModObjLine,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  ModObjLine:=ModObjLine+1;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_MODEL_OBJECTS,ModObjLine,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  ModObjLine:=ModObjLine+1;
  -- C_MODEL_OBJECT_PARS
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_MODEL_OBJECT_PARS,ModObjParLine,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  ModObjParLine:=ModObjParLine+1;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_MODEL_OBJECT_PARS,ModObjParLine,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  ModObjParLine:=ModObjParLine+1;
  -- C_MODEL_OBJECT_RELS
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_MODEL_OBJECT_RELS,ModObjRelLine,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  ModObjRelLine:=ModObjRelLine+1;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_MODEL_OBJECT_RELS,ModObjRelLine,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  ModObjRelLine:=ModObjRelLine+1;
  -- C_MODEL_OBJECT_STORIES
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_MODEL_OBJECT_STORIES,ModObjSParLine,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  ModObjSParLine:=ModObjSParLine+1;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_MODEL_OBJECT_STORIES,ModObjSParLine,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  ModObjSParLine:=ModObjSParLine+1;
  -- C_MODEL_OBJECT_REL_STORIES
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_MODEL_OBJECT_REL_STORIES,ModObjSRelLine,
    '-- upload date '||to_char(sysdate, 'dd-mm-yyyy hh24:mi'));
  ModObjSRelLine:=ModObjSRelLine+1;
  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
    C_MODEL_OBJECT_REL_STORIES,ModObjSRelLine,
    'SP.INPUT.SET_NLS('''||FMT||''','''||NLS||''');');
  ModObjSRelLine:=ModObjSRelLine+1;
  -- Экспортируем Модели.
  FOR M IN (SELECT * FROM SP.V_MODELS)
  LOOP
    if M.ID > 99 then
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
        C_MODELS,ModelLine,
        'SP.INPUT.Model(NAME=>'''||M.MODEL_NAME||''',');
      ModelLine:=ModelLine+1;
      IF M.MODEL_COMMENTS IS NOT NULL THEN
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
          C_MODELS,ModelLine,
          'Comments=>'''||Q_QQ(M.MODEL_COMMENTS)||''',');
        ModelLine:=ModelLine+1;
      END IF;
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
        C_MODELS,ModelLine,
        'Persistent=> '||m.Persistent||',');
      ModelLine:=ModelLine+1;
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
        C_MODELS,ModelLine,
        'Local=> '||m.Local||',');
      ModelLine:=ModelLine+1;
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
        C_MODELS,ModelLine,
        'USING_ROLE=> '||m.USING_ROLE_NAME||',');
      ModelLine:=ModelLine+1;
      DU := D_U(m.M_DATE, m.M_USER);
      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
        C_MODELS,ModelLine,
        DU||');');
      ModelLine:=ModelLine+1;
    end if;  
    NewModel:=TRUE;
	  -- Экспортируем объекты модели.
	  FOR O IN (SELECT * FROM SP.V_MODEL_OBJECTS WHERE MODEL_ID=M.ID
--                ORDER BY OBJ_LEVEL
                ORDER BY FULL_NAME
              )
	  LOOP
	    S:='SP.INPUT.ModelObject(ObjectName=>'''||O.MOD_OBJ_NAME||''',';
      IF NewModel THEN
        S:=S||' ModelName=>'''||O.MODEL_NAME||''',';
        NewModel:=FALSE;
      END IF;
      IF O.OID is not null THEN
        S:=S||' OID=>'''||O.OID||''',';
      END IF;
		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_MODEL_OBJECTS,ModObjLine,S);
			ModObjLine:=ModObjLine+1;
      -- Роли доступа.
      IF O.USING_ROLE_NAME IS NOT NULL THEN
        S:='UsingRoleName=>'''||O.USING_ROLE_NAME||''', ';
        OUT_S(C_MODEL_OBJECTS,ModObjLine,S);
      END IF;
      IF O.EDIT_ROLE_NAME IS NOT NULL THEN
        S:='EditRoleName=>'''||O.Edit_ROLE_NAME||''', ';
        OUT_S(C_MODEL_OBJECTS,ModObjLine,S);
      END IF;
--      OUT_S(C_MODEL_OBJECTS,ModObjLine,S);
      -- Дата изменения и пользователь.
      DU := D_U(O.M_DATE, O.M_USER);
		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_MODEL_OBJECTS,ModObjLine,DU||',');
			ModObjLine:=ModObjLine+1;
      -- Если присутствует сторонний идентификатор родительского объекта,
      -- используем его.
      IF O.POID IS NOT NULL THEN
	      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
	        C_MODEL_OBJECTS,ModObjLine,
	        'POID=>'''||O.POID||''',');
	      ModObjLine:=ModObjLine+1;
      END IF;
      -- Всегда добавляем ObjectPath, но Input будет использовать OID.
      CASE
        WHEN O.PATH IS NOT NULL AND LENGTH(O.PATH)>3500 THEN
          INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
            C_MODEL_OBJECTS,ModObjLine,'ObjectPath=>''');
          ModObjLine:=ModObjLine+1;
          INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
            C_MODEL_OBJECTS,ModObjLine,O.PATH);
          ModObjLine:=ModObjLine+1;
          INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
            C_MODEL_OBJECTS,ModObjLine,''',');
          ModObjLine:=ModObjLine+1;
        WHEN O.PATH IS NOT NULL  THEN
          INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
            C_MODEL_OBJECTS,ModObjLine,
            'ObjectPath=>'''||O.PATH||''',');
          ModObjLine:=ModObjLine+1;
      ELSE
        d('!Path для ID '|| O.ID,'SP.OUTPUT.MODEL');
      END CASE;
      S:=' CatalogName=>'''||O.CATALOG_NAME||''''||
         ', CatalogGroupName=>'''||O.CATALOG_GROUP_NAME||''''||');';
		  INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		    C_MODEL_OBJECTS,ModObjLine,S);
			ModObjLine:=ModObjLine+1;
	    NewObject:=TRUE;
		  -- Экспортируем параметры объекта,
      SP.C.addObject(O.ID,'output');
      -- игнорируя связи и виртуальные параметры.
	    FOR P IN 
      (
        SELECT  op.*,
                SP.VAL_to_STR(SP.TVALUE(op.TYPE_ID, op.E_VAL,
                                        op.N, op.D, 0, op.S, op.X, op.Y)) VAL,
                t.CHECK_VAL,t.COMMENTS,t.IM_ID,
                t.STRING_TO_VAL,t.VAL_TO_STRING, t.Name TYPE_NAME
          FROM SP.MOD_OBJ_PARS_CACHE op, SP.V_TYPES t
            WHERE t.ID=op.TYPE_ID
              AND op.ID is not null
              AND op.TYPE_ID != G.TRel
              AND op.SET_KEY = 'output'
              AND UPPER(op.NAME) not in 
              (
                'NAME','OLD_NAME','PARENT','NEW_PARENT',
                'OID','POID','NEW_POID','ID','PID','NEW_PID','DELETE',
                'EDIT_ROLE','USING_ROLE'
              )
            ORDER BY op.NAME
      )
		  LOOP
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_MODEL_OBJECT_PARS,ModObjParLine,
		      'SP.INPUT.ModelObjectPar(Name=>'''||P.NAME||''',');
		    ModObjParLine:=ModObjParLine+1;
        DU := D_U(P.M_DATE, P.M_USER);
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_MODEL_OBJECT_PARS,ModObjParLine,
		      DU||',');
		    ModObjParLine:=ModObjParLine+1;
        IF NewObject THEN
		      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		        C_MODEL_OBJECT_PARS,ModObjParLine,
		        'ModelName=>'''||M.MODEL_NAME||''',');
		      ModObjParLine:=ModObjParLine+1;
          NewObject:=FALSE;
          -- Если доступен OID объекта, то экспортируем его
          -- иначе полное имя объекта
          IF O.OID is not null THEN
            INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
              C_MODEL_OBJECT_PARS,ModObjParLine,
              'OID=>'''||O.OID||''',');
            ModObjParLine:=ModObjParLine+1;
          ELSE
            CASE
              WHEN O.FULL_NAME IS NOT NULL AND LENGTH(O.FULL_NAME)>3500 THEN
                INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                  C_MODEL_OBJECT_PARS,ModObjParLine,'FullName=>''');
                ModObjParLine:=ModObjParLine+1;
                INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                  C_MODEL_OBJECT_PARS,ModObjParLine,O.FULL_NAME);
                ModObjParLine:=ModObjParLine+1;
                INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                  C_MODEL_OBJECT_PARS,ModObjParLine,''',');
                ModObjParLine:=ModObjParLine+1;
              WHEN O.FULL_NAME IS NOT NULL  THEN
                INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                  C_MODEL_OBJECT_PARS,ModObjParLine,
                  'FullName=>'''||O.FULL_NAME||''',');
                ModObjParLine:=ModObjParLine+1;
            ELSE
              NULL;
            END CASE;
          END IF;
        END IF;
        -- Если параметр внешний, и не определён в каталоге объектов,
        -- то экспортируем тип параметра.
        IF P.OBJ_PAR_ID is null THEN
		      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		        C_MODEL_OBJECT_PARS,ModObjParLine,
		        'T=>'''||P.TYPE_NAME||''',');
		      ModObjParLine:=ModObjParLine+1;
        END IF;
	      -- Отдельно обрабатываем параметры у которых дата не нулл
	      -- или определение типа может допускать неверное преобразование
        -- значения в строку. А именно, тип имеет не именованное значение,
	      -- и блок преобразования в строку или обратно неопределён.
	      -- В этом случае экспортируем значение по полям.
	      IF   (P.D IS NOT NULL)
	        OR (    (P.CHECK_VAL IS NOT NULL)
	            AND
	                ((P.VAL_TO_STRING IS NULL) OR (P.STRING_TO_VAL IS NULL))
	           )
	      THEN
			    IF P.N IS NOT NULL THEN
				    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
				      C_MODEL_OBJECT_PARS,ModObjParLine,
				      'N=>'||to_.str(P.N)||',');
				    ModObjParLine:=ModObjParLine+1;
			    END IF;
			    IF P.D IS NOT NULL THEN
		         S:='D=>'''||TO_CHAR(P.D,FMT,'NLS_DATE_LANGUAGE ='||NLS)||''',';
				    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
				      C_MODEL_OBJECT_PARS,ModObjParLine,S);
				    ModObjParLine:=ModObjParLine+1;
			    END IF;
			    S:=P.S;
			    I:=FALSE;
			    IF P.S IS NOT NULL THEN
			      I:=TRUE;
				    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
				      C_MODEL_OBJECT_PARS,ModObjParLine,'S=>''');
				    ModObjParLine:=ModObjParLine+1;
				    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
				      C_MODEL_OBJECT_PARS,ModObjParLine,Q_QQ(P.S));
			      ModObjParLine:=ModObjParLine+1;
			    END IF;
	        CASE
			      WHEN P.X IS NULL AND P.Y IS NULL THEN
			        S:='Q=>0);';
			      WHEN P.X IS NOT NULL AND P.Y IS NOT NULL THEN
			        S:='X=>'||to_.str(P.X)||', Y=>'||to_.str(P.Y)||');';
	  	      WHEN P.X IS NOT NULL AND P.Y IS NULL THEN
			      S:='X=>'||to_.str(P.X)||');';
			      WHEN P.X IS NULL AND P.Y IS NOT NULL THEN
			      S:='Y=>'||to_.str(P.Y)||');';
			    END CASE;
			    IF I THEN
				    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
				      C_MODEL_OBJECT_PARS,ModObjParLine,''', '||S);
			    ELSE
				    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
				      C_MODEL_OBJECT_PARS,ModObjParLine,S);
			    END IF;
			    ModObjParLine:=ModObjParLine+1;
	      ELSE
	        -- Экспортируем значение как строку.
          
	        CASE
	          WHEN P.VAL IS NOT NULL AND LENGTH(P.VAL)>3500 THEN
					    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
					      C_MODEL_OBJECT_PARS,ModObjParLine,'V=>''');
					    ModObjParLine:=ModObjParLine+1;
					    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
					      C_MODEL_OBJECT_PARS,ModObjParLine,Q_QQ(P.VAL));
				      ModObjParLine:=ModObjParLine+1;
				      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
				        C_MODEL_OBJECT_PARS,ModObjParLine,''');');
				      ModObjParLine:=ModObjParLine+1;
	          WHEN P.VAL IS NOT NULL  THEN
				      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
				        C_MODEL_OBJECT_PARS,ModObjParLine,
				        'V=>'''||Q_QQ(P.VAL)||''');');
				      ModObjParLine:=ModObjParLine+1;
	        ELSE
				    INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
				      C_MODEL_OBJECT_PARS,ModObjParLine,
				      'Q=>0);');
				    ModObjParLine:=ModObjParLine+1;
			    END CASE;
	      END IF;
--      <<NEXT_PAR>> null; 
      END LOOP;
	    NewObject:=TRUE;
		  -- Экспортируем связи.
	    FOR P IN (SELECT  op.*,t.CHECK_VAL,t.COMMENTS,t.IM_ID,
												t.STRING_TO_VAL,t.VAL_TO_STRING
                  FROM SP.V_MODEL_OBJECT_PARS op, SP.V_TYPES t
                    WHERE t.ID=op.TYPE_ID
                      AND op.ISREDEFINE=1
                      AND MOD_OBJ_ID=O.ID
                      AND op.TYPE_ID = G.TRel
	                  ORDER BY op.PARAM_NAME)
		  LOOP
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_MODEL_OBJECT_RELS,ModObjRelLine,
		      'SP.INPUT.ModelObjectRel(Name=>'''||P.PARAM_NAME||''',');
		    ModObjRelLine:=ModObjRelLine+1;
        DU := D_U(P.M_DATE, P.M_USER);
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		      C_MODEL_OBJECT_RELS,ModObjRelLine,
		      DU||',');
		    ModObjRelLine:=ModObjRelLine+1;
        IF NewObject THEN
		      INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
		        C_MODEL_OBJECT_RELS,ModObjRelLine,
		        'ModelName=>'''||M.MODEL_NAME||''',');
		      ModObjRelLine:=ModObjRelLine+1;
          NewObject:=FALSE;
          -- Если доступен OID объекта, то экспортируем его
          -- иначе полное имя объекта
          IF O.OID is not null THEN
            INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
              C_MODEL_OBJECT_RELS,ModObjRelLine,
              'OID=>'''||O.OID||''',');
            ModObjRelLine:=ModObjRelLine+1;
          ELSE
            CASE
              WHEN O.FULL_NAME IS NOT NULL AND LENGTH(O.FULL_NAME)>3500 THEN
                INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                  C_MODEL_OBJECT_RELS,ModObjRelLine,'FullName=>''');
                ModObjRelLine:=ModObjRelLine+1;
                INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                  C_MODEL_OBJECT_RELS,ModObjRelLine,O.FULL_NAME);
                ModObjRelLine:=ModObjRelLine+1;
                INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                  C_MODEL_OBJECT_RELS,ModObjRelLine,''',');
                ModObjRelLine:=ModObjRelLine+1;
              WHEN O.FULL_NAME IS NOT NULL  THEN
                INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                  C_MODEL_OBJECT_RELS,ModObjRelLine,
                  'FullName=>'''||O.FULL_NAME||''',');
                ModObjRelLine:=ModObjRelLine+1;
            ELSE
              NULL;
            END CASE;
          END IF;
        END IF;
        -- Если доступен OID значения, то экспортируем его и имя ЕГО модели.
        begin
          select OID, OO.MODEL_NAME into REL_OID, REL_MODEL 
            from SP.V_MODEL_OBJECTS oo
            where oo.ID = p.N;
        exception
          when no_data_found then
            REL_OID := '';  
        end;  
        IF REL_OID is not null THEN
          INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
            C_MODEL_OBJECT_RELS,ModObjRelLine,
            'R_MODEL=>'''||REL_MODEL||''', R_OID=>'''||REL_OID||''');');
          ModObjRelLine:=ModObjRelLine+1;
        ELSE  
          -- Экспортируем значение как строку.
          CASE
            WHEN P.VAL IS NOT NULL AND LENGTH(P.VAL)>3500 THEN
              INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                C_MODEL_OBJECT_RELS,ModObjRelLine,'V=>''');
              ModObjRelLine:=ModObjRelLine+1;
              INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                C_MODEL_OBJECT_RELS,ModObjRelLine,Q_QQ(P.VAL));
              ModObjRelLine:=ModObjRelLine+1;
              INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                C_MODEL_OBJECT_RELS,ModObjRelLine,''');');
              ModObjRelLine:=ModObjRelLine+1;
            WHEN P.VAL IS NOT NULL  THEN
              INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                C_MODEL_OBJECT_RELS,ModObjRelLine,
                'V=>'''||Q_QQ(P.VAL)||''');');
              ModObjRelLine:=ModObjRelLine+1;
          ELSE
            INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
              C_MODEL_OBJECT_RELS,ModObjRelLine,
              'Q=>0);');
            ModObjRelLine:=ModObjRelLine+1;
          END CASE;
        END IF;
      END LOOP;
      NewObject:=TRUE;
      PAR_NAME := '';
      -- Экспортируем историю, игнорируя историю связей. 
      FOR P IN (SELECT  p.*, OP.NAME PARAM_NAME, 
                        SP.Val_to_str(SP.TVALUE(p.TYPE_ID, null, 0,
                           p.E_VAL,p.N,p.D,p.S,p.X,p.Y)) VAL,
                        T.CHECK_VAL, t.STRING_TO_VAL, t.VAL_TO_STRING
                  FROM SP.MODEL_OBJECTS oo,SP.MODEL_OBJECT_PAR_STORIES p,
                       SP.PAR_TYPES t, SP.OBJECT_PAR_S op
                    WHERE t.ID=op.TYPE_ID
                      AND P.OBJ_PAR_ID = op.ID
                      AND OO.ID = P.MOD_OBJ_ID
                      AND p.MOD_OBJ_ID = O.ID
                      AND p.TYPE_ID != G.TRel
                    ORDER BY OBJ_PAR_ID)
      LOOP
        -- Экспортируем имя параметра, если оно изменилось.
        IF G.notUpEQ(PAR_NAME, p.PARAM_NAME) THEN
          PAR_NAME := p.PARAM_NAME;
          INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
            C_MODEL_OBJECT_STORIES,ModObjSParLine,
            'SP.INPUT.ModelObjectParStory(Name=>'''||PAR_NAME||''',');
          ModObjSParLine:=ModObjSParLine+1;
        ELSE  
          INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
            C_MODEL_OBJECT_STORIES,ModObjSParLine,
            'SP.INPUT.ModelObjectParStory(');
          ModObjSParLine:=ModObjSParLine+1;
        END IF;
        DU := D_U(P.M_DATE, P.M_USER);
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
          C_MODEL_OBJECT_STORIES,ModObjSParLine,
          DU||',');
        ModObjSParLine:=ModObjSParLine+1;
        IF NewObject THEN
          INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
            C_MODEL_OBJECT_STORIES,ModObjSParLine,
            'ModelName=>'''||M.MODEL_NAME||''',');
          ModObjSParLine:=ModObjSParLine+1;
          NewObject:=FALSE;
          -- Если определён OID, то используем его,
          -- иначе находим полное имя объекта.
          IF O.OID is not null then
            INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
              C_MODEL_OBJECT_STORIES,ModObjSParLine,
              'OID=>'''||O.OID||''',');
            ModObjSParLine:=ModObjSParLine+1;
          ELSE
            CASE
              WHEN O.FULL_NAME IS NOT NULL AND LENGTH(O.FULL_NAME)>3500 THEN
                INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                  C_MODEL_OBJECT_STORIES,ModObjSParLine,'FullName=>''');
                ModObjSParLine:=ModObjSParLine+1;
                INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                  C_MODEL_OBJECT_STORIES,ModObjSParLine,o.FULL_NAME);
                ModObjSParLine:=ModObjSParLine+1;
                INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                  C_MODEL_OBJECT_STORIES,ModObjSParLine,''',');
                ModObjSParLine:=ModObjSParLine+1;
              WHEN O.FULL_NAME IS NOT NULL  THEN
                INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                  C_MODEL_OBJECT_STORIES,ModObjSParLine,
                  'FullName=>'''||o.FULL_NAME||''',');
                ModObjSParLine:=ModObjSParLine+1;
            ELSE
              NULL;
            END CASE;
          END IF;
        END IF;
        -- Отдельно обрабатываем параметры у которых дата не нулл
        -- или определение типа может допускать неверное преобразование
        -- значения в строку. А именно, тип имеет не именованное значение,
        -- и блок преобразования в строку или обратно неопределён.
        -- В этом случае экспортируем значение по полям.
        IF   (P.D IS NOT NULL)
          OR (    (P.CHECK_VAL IS NOT NULL)
              AND
                  ((P.VAL_TO_STRING IS NULL) OR (P.STRING_TO_VAL IS NULL))
             )
        THEN
          IF P.N IS NOT NULL THEN
            INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
              C_MODEL_OBJECT_STORIES,ModObjSParLine,
              'N=>'||to_.str(P.N)||',');
            ModObjSParLine:=ModObjSParLine+1;
          END IF;
          IF P.D IS NOT NULL THEN
             S:='D=>'''||TO_CHAR(P.D,FMT,'NLS_DATE_LANGUAGE ='||NLS)||''',';
            INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
              C_MODEL_OBJECT_STORIES,ModObjSParLine,S);
            ModObjSParLine:=ModObjSParLine+1;
          END IF;
          S:=P.S;
          I:=FALSE;
          IF P.S IS NOT NULL THEN
            I:=TRUE;
            INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
              C_MODEL_OBJECT_STORIES,ModObjSParLine,'S=>''');
            ModObjSParLine:=ModObjSParLine+1;
            INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
              C_MODEL_OBJECT_STORIES,ModObjSParLine,Q_QQ(P.S));
            ModObjSParLine:=ModObjSParLine+1;
          END IF;
          CASE
            WHEN P.X IS NULL AND P.Y IS NULL THEN
              S:='Q=>0);';
            WHEN P.X IS NOT NULL AND P.Y IS NOT NULL THEN
              S:='X=>'||to_.str(P.X)||', Y=>'||to_.str(P.Y)||');';
            WHEN P.X IS NOT NULL AND P.Y IS NULL THEN
            S:='X=>'||to_.str(P.X)||');';
            WHEN P.X IS NULL AND P.Y IS NOT NULL THEN
            S:='Y=>'||to_.str(P.Y)||');';
          END CASE;
          IF I THEN
            INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
              C_MODEL_OBJECT_STORIES,ModObjSParLine,''', '||S);
          ELSE
            INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
              C_MODEL_OBJECT_STORIES,ModObjSParLine,S);
          END IF;
          ModObjSParLine:=ModObjSParLine+1;
        ELSE
          -- Экспортируем значение как строку.
          CASE
            WHEN P.VAL IS NOT NULL AND LENGTH(P.VAL)>3500 THEN
              INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                C_MODEL_OBJECT_STORIES,ModObjSParLine,'V=>''');
              ModObjSParLine:=ModObjSParLine+1;
              INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                C_MODEL_OBJECT_STORIES,ModObjSParLine,Q_QQ(P.VAL));
              ModObjSParLine:=ModObjSParLine+1;
              INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                C_MODEL_OBJECT_STORIES,ModObjSParLine,''');');
              ModObjSParLine:=ModObjSParLine+1;
            WHEN P.VAL IS NOT NULL  THEN
              INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                C_MODEL_OBJECT_STORIES,ModObjSParLine,
                'V=>'''||Q_QQ(P.VAL)||''');');
              ModObjSParLine:=ModObjSParLine+1;
          ELSE
            INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
              C_MODEL_OBJECT_STORIES,ModObjSParLine,
              'Q=>0);');
            ModObjSParLine:=ModObjSParLine+1;
          END CASE;
        END IF;
--      <<NEXT_PAR>> null; 
      END LOOP;
      NewObject := TRUE;
      PAR_NAME := '';
      -- Экспортируем историю связей. 
      FOR P IN (SELECT p.*, OP.NAME PARAM_NAME, 
                        SP.Val_to_str(SP.TVALUE(p.TYPE_ID, null, 0,
                           p.E_VAL,p.N,p.D,p.S,p.X,p.Y)) VAL,
                        T.CHECK_VAL, t.STRING_TO_VAL, t.VAL_TO_STRING
                  FROM SP.MODEL_OBJECTS oo,SP.MODEL_OBJECT_PAR_STORIES p,
                       SP.PAR_TYPES t, SP.OBJECT_PAR_S op
                    WHERE t.ID=op.TYPE_ID
                      AND P.OBJ_PAR_ID = op.ID
                      AND OO.ID = P.MOD_OBJ_ID
                      AND P.MOD_OBJ_ID = O.ID
                      AND p.TYPE_ID = G.TRel
                    ORDER BY OBJ_PAR_ID)
      LOOP
        -- Экспортируем имя параметра, если оно изменилось.
        IF G.notUpEQ(PAR_NAME, p.PARAM_NAME) THEN
          PAR_NAME := p.PARAM_NAME;
          INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
            C_MODEL_OBJECT_REL_STORIES,ModObjSRelLine,
            'SP.INPUT.ModelObjectRelStory(Name=>'''||PAR_NAME||''',');
          ModObjSRelLine:=ModObjSRelLine+1;
        ELSE  
          INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
            C_MODEL_OBJECT_REL_STORIES,ModObjSRelLine,
            'SP.INPUT.ModelObjectRelStory(');
          ModObjSRelLine:=ModObjSRelLine+1;
        END IF;
        DU := D_U(P.M_DATE, P.M_USER);
        INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
          C_MODEL_OBJECT_REL_STORIES,ModObjSRelLine,
          DU||',');
        ModObjSRelLine:=ModObjSRelLine+1;
        --dd('O.ID '||O.ID||', O.OID'||O.OID,'SP.OUTPUT.MODEL');
        IF NewObject THEN
          INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
            C_MODEL_OBJECT_REL_STORIES,ModObjSRelLine,
            'ModelName=>'''||M.MODEL_NAME||''',');
          ModObjSRelLine:=ModObjSRelLine+1;
          NewObject:=FALSE;
          --dd('1 ','SP.OUTPUT.MODEL');
          -- Если определён OID, то используем его,
          -- иначе находим полное имя объекта.
          IF O.OID is not null then
            INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
              C_MODEL_OBJECT_REL_STORIES,ModObjSRelLine,
              'OID=>'''||O.OID||''',');
            ModObjSRelLine:=ModObjSRelLine+1;
          --dd('2 ','SP.OUTPUT.MODEL');
          ELSE
            CASE
              WHEN O.FULL_NAME IS NOT NULL AND LENGTH(O.FULL_NAME)>3500 THEN
                INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                  C_MODEL_OBJECT_REL_STORIES,ModObjSRelLine,'FullName=>''');
                ModObjSRelLine:=ModObjSRelLine+1;
                INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                  C_MODEL_OBJECT_REL_STORIES,ModObjSRelLine,O.FULL_NAME);
                ModObjSRelLine:=ModObjSRelLine+1;
                INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                  C_MODEL_OBJECT_REL_STORIES,ModObjSRelLine,''',');
                ModObjSRelLine:=ModObjSRelLine+1;
              WHEN O.FULL_NAME IS NOT NULL  THEN
                INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                  C_MODEL_OBJECT_REL_STORIES,ModObjSRelLine,
                  'FullName=>'''||O.FULL_NAME||''',');
                ModObjSRelLine:=ModObjSRelLine+1;
            ELSE
              NULL;
            END CASE;
          END IF;  
        END IF;
        -- Если доступен OID значения, то экспортируем его и имя ЕГО модели.
        begin
          select OID, OO.MODEL_NAME into REL_OID, REL_MODEL 
            from SP.V_MODEL_OBJECTS oo
            where oo.ID = p.N;
        exception
          when no_data_found then
            REL_OID := '';  
        end;  
        IF REL_OID is not null THEN
          INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
            C_MODEL_OBJECT_REL_STORIES,ModObjSRelLine,
            'R_MODEL=>'''||REL_MODEL||''', R_OID=>'''||REL_OID||''');');
          ModObjSRelLine:=ModObjSRelLine+1;
        ELSE  
          -- Экспортируем значение как строку.
          CASE
            WHEN P.VAL IS NOT NULL AND LENGTH(P.VAL)>3500 THEN
              INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                C_MODEL_OBJECT_REL_STORIES,ModObjSRelLine,'V=>''');
              ModObjSRelLine:=ModObjSRelLine+1;
              INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                C_MODEL_OBJECT_REL_STORIES,ModObjSRelLine,Q_QQ(P.VAL));
              ModObjSRelLine:=ModObjSRelLine+1;
              INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                C_MODEL_OBJECT_REL_STORIES,ModObjSRelLine,''');');
              ModObjSRelLine:=ModObjSRelLine+1;
            WHEN P.VAL IS NOT NULL  THEN
              INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
                C_MODEL_OBJECT_REL_STORIES,ModObjSRelLine,
                'V=>'''||Q_QQ(P.VAL)||''');');
              ModObjSRelLine:=ModObjSRelLine+1;
          ELSE
            INSERT INTO SP_IO.CLIENT_SCRIPTS VALUES(
              C_MODEL_OBJECT_REL_STORIES,ModObjSRelLine,
              'Q=>0);');
            ModObjSRelLine:=ModObjSRelLine+1;
          END CASE;
        END IF;
      END LOOP;
    END LOOP;
  END LOOP;
exception
  when others then
    d('SeqLine '||SeqLine||
      ', ModelLine '||ModelLine||
      ', ModObjLine '||ModObjLine||
      ', ModObjParLine '||ModObjParLine||
      ', ModObjRelLine '||ModObjRelLine||
      ', ModObjSParLine '||ModObjSRelLine,
      'SP.OUTPUT.MODEL');
     commit; 
     raise; 
END MODEL;

-------------------------------------------------------------------------------
BEGIN
  RESET;
END OUTPUT;
/
