-- SP Views 
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 19.10.2010
-- update 19.10.2010 03.11.2010 18.11.2010 22.11.2010 30.11.2010 10.12.2010 
-- 				27.12.2010 06.05.2011 23.08.2011 10.11.2011 04.03.2013 25.08.2013
--        13.06.2014 30.08.2014 11.11.2014 19.03.2015 22.03.2015 25.03.2015
--        20.04.2015 23.04.2015 08.10.2016 17.10.2016 31.01.2021 09.09.2021
--        12.09.2021

-------------------------------------------------------------------------------
-- ���������. 
CREATE OR REPLACE VIEW SP.V_SYS 
("Admin",
 "USER",
 CurValue,
 CurModel,
 CurModelName, 
 CurBuh,
 CurBuhName,
 Root, 
 RootName)
AS
SELECT DECODE(SP.S_isUserAdmin,1,'Admin','Not'),
       SP.TG.Get_UserName,
       SP.Get_CurValue,
       to_.STR(SP.TG.Get_CurModel),
       SP.TG.Get_CurModel_NAME, 
       to_.STR(SP.TG.Get_CurBuh),
       SP.TG.Get_CurBuh_NAME, 
       SP.getRoot_ID,
       SP.getRoot_NAME
  FROM DUAL; 

GRANT SELECT ON SP.V_SYS TO PUBLIC;
COMMENT ON TABLE SP.V_SYS IS '��������� ����������. SP-Views.vw';

COMMENT ON COLUMN SP.V_SYS."Admin" 
  IS '�������, ��� ������� ������������ �������� ���������������.';
COMMENT ON COLUMN SP.V_SYS."USER" IS '��� �������� ������������';
COMMENT ON COLUMN SP.V_SYS.CurValue IS '�������� ����������� �������� �������� � ���� ������.';
COMMENT ON COLUMN SP.V_SYS.CurModel IS '������������� ������� ������.';
COMMENT ON COLUMN SP.V_SYS.CurModelName IS '��� ������� ������.';
COMMENT ON COLUMN SP.V_SYS.CurBuh IS '������������� ������� �����������.';
COMMENT ON COLUMN SP.V_SYS.CurBuhName IS '��� ������� �����������.';
COMMENT ON COLUMN SP.V_SYS.Root IS '������������� �������� ������� ������. �������� 0 �������������� ��� ��������� ������� ������. �������� -1 ��������, ��� ������ ���������� ������ �� ������� ������.';
COMMENT ON COLUMN SP.V_SYS.Root IS '��� �������� ������� ������.';

-------------------------------------------------------------------------------
-- T��� ����������. 
CREATE OR REPLACE VIEW SP.V_TYPES 
(ID,
 NAME,
 IM_ID, 
 COMMENTS,
 CHECK_VAL, STRING_TO_VAL, VAL_TO_STRING, SET_OF_VALUES,
 GROUP_ID, GROUP_NAME,
 M_DATE, M_USER)
AS
SELECT CAST(t.ID AS NUMBER(9)) ID,
       t.NAME, 
       t.IM_ID, 
       t.COMMENTS,
       CHECK_VAL, STRING_TO_VAL, VAL_TO_STRING, SET_OF_VALUES, 
       t.GROUP_ID, g.NAME GROUP_NAME,
       t.M_DATE, t.M_USER
 FROM SP.PAR_TYPES t, SP.GROUPS g
 WHERE t.GROUP_ID = g.ID(+)
 ORDER BY GROUP_NAME, NAME; 

GRANT ALL ON SP.V_TYPES TO "SP_ADMIN_ROLE";
--grant select on SP.V_TYPES to "SP_APP_DEVELOPING_ROLE";
GRANT SELECT ON SP.V_TYPES TO PUBLIC;

COMMENT ON TABLE SP.V_TYPES IS '���� ����������. SP-Views.vw';

BEGIN
 cc.fT:='PAR_TYPES';
 cc.tT:='V_TYPES';
 cc.c('ID','ID');
 cc.c('IM_ID','IM_ID');
 cc.c('NAME','NAME');
 cc.c('COMMENTS','COMMENTS');
 cc.c('CHECK_VAL','CHECK_VAL');
 cc.c('VAL_TO_STRING','VAL_TO_STRING');
 cc.c('STRING_TO_VAL','STRING_TO_VAL');
 cc.c('SET_OF_VALUES','SET_OF_VALUES');
 cc.c('GROUP_ID','GROUP_ID');
 cc.c('M_DATE','M_DATE');
 cc.c('M_USER','M_USER');
END; 
/
COMMENT ON COLUMN SP.V_TYPES.GROUP_NAME IS '��� ������, ������� ����������� ���.';


-------------------------------------------------------------------------------
-- ��������� �������������� ����.
CREATE OR REPLACE VIEW SP.V_ENUMS
(TYPE_ID,
 TYPE_IM_ID,
 TYPE_NAME,
 TYPE_COMMENTS,
 E_ID,
 E_IM_ID,
 E_VAL,
 VAL_COMMENTS,
 N, D, S, X, Y, STR,
 GROUP_ID, GROUP_NAME,
 M_DATE, M_USER)
AS
  SELECT 
    CAST(pt.ID AS NUMBER(9)) TYPE_ID, 
    pt.IM_ID TYPE_IM_ID,
    pt.NAME TYPE_NAME,
	  pt.COMMENTS TYPE_COMMENTS,
    e.ID E_ID,e.IM_ID E_IM_ID,e.E_VAL E_VAL,
    e.COMMENTS VAL_COMMENTS,
		e.N,e.D,e.S,e.X,e.Y, e.COMMENTS STR,
    pt.GROUP_ID, g.NAME,
    e.M_DATE, e.M_USER
  FROM SP.PAR_TYPES pt, SP.ENUM_VAL_S e, SP.GROUPS g
	WHERE pt.ID=e.TYPE_ID
    and e.GROUP_ID = g.ID(+);

GRANT ALL ON SP.V_ENUMS TO "SP_ADMIN_ROLE";
--grant select on SP.V_ENUMS to "SP_APP_DEVELOPING_ROLE";
GRANT SELECT ON SP.V_ENUMS TO PUBLIC;
COMMENT ON TABLE SP.V_ENUMS IS '�������� ����������� ��������. SP-Views.vw';

BEGIN
 cc.fT:='PAR_TYPES';
 cc.tT:='V_ENUMS';
 cc.c('ID','TYPE_ID');
 cc.c('IM_ID','TYPE_IM_ID');
 cc.c('NAME','TYPE_NAME');
 cc.c('COMMENTS','TYPE_COMMENTS');

 cc.fT:='ENUM_VAL_S';
 cc.tT:='V_ENUMS';
 cc.c('ID','E_ID');
 cc.c('IM_ID','E_IM_ID');
 cc.c('E_VAL','E_VAL');
 cc.c('COMMENTS','VAL_COMMENTS');
 cc.c('N','N');
 cc.c('D','D');
 cc.c('S','S');
 cc.c('X','X');
 cc.c('Y','Y');
 cc.c('GROUP_ID','GROUP_ID');
 cc.c('M_DATE','M_DATE');
 cc.c('M_USER','M_USER');
END; 
/

COMMENT ON COLUMN SP.V_ENUMS.STR IS '������������� ����������� � ������� �������������� �����.';
COMMENT ON COLUMN SP.V_ENUMS.GROUP_NAME IS '��� ������, ������� ����������� ��������.';

-------------------------------------------------------------------------------
-- K������.
CREATE OR REPLACE VIEW SP.V_COMMANDS
(ID,NAME,COMMENTS)
AS
  SELECT CAST(ID AS NUMBER(9)) ID, NAME, COMMENTS
  FROM SP.COMMANDS
	WITH READ ONLY;

GRANT SELECT ON SP.V_COMMANDS TO PUBLIC;
COMMENT ON TABLE SP.V_COMMANDS IS '�������� ������ �������. SP-Views.vw';

BEGIN
 cc.fT:='COMMANDS';
 cc.tT:='V_COMMANDS';
 cc.c('ID','ID');
 cc.c('NAME','NAME');
 cc.c('COMMENTS','COMMENTS');
END; 
/

-----------------------------------------------------------------------------
-- ���������� ��������� � �� �������� �� ��������� ��� ������ ������������.
CREATE OR REPLACE VIEW sp.V_GLOBAL_PAR_S
(ID, NAME, TYPE_ID, TYPE_NAME,
 VALUE_ENUM, SET_OF_VALUES, S_VALUE, VALUE_COMMENTS, 
 REACTION, R_ONLY, R_ONLY_ID, 
 COMMENTS, 
 GROUP_ID, GROUP_NAME)
AS 
SELECT p.ID,p.NAME, CAST(p.TYPE_ID AS NUMBER(9)) TYPE_ID , 
    CAST (SP.to_strTYPE(p.TYPE_ID)AS VARCHAR2(128) )TYPE_NAME,
    CAST(SP.S_IS_ENUM_TYPE(p.TYPE_ID) AS NUMBER(1)) VALUE_ENUM,
    CAST(SP.S_TYPE_HAS_SET_OF_VALUES(p.TYPE_ID) AS NUMBER(1)) SET_OF_VALUES,
    SP.Val_to_Str(SP.TVALUE(p.TYPE_ID,null,0,p.E_VAL,p.N,p.D,p.S,p.x,p.y))
      S_VALUE, 
    SP.Val_Comments(SP.TVALUE(p.TYPE_ID,null,0,p.E_VAL,p.N,p.D,p.S,p.x,p.y))
      VALUE_COMMENTS, 
    p.REACTION, CAST(SP.to_StrR_Only(p.R_ONLY) AS VARCHAR2(30)) R_ONLY,
    CAST(p.R_ONLY AS NUMBER(3)) R_ONLY_ID, 
    p.COMMENTS,
    p.GROUP_ID, g.NAME GROUP_NAME 
  FROM SP.GLOBAL_PAR_S p, SP.GROUPS g
  WHERE p.GROUP_ID = g.ID(+);


GRANT ALL ON SP.V_GLOBAL_PAR_S TO "SP_ADMIN_ROLE";

 COMMENT ON TABLE SP.V_GLOBAL_PAR_S IS '���������� ���������. �������� �� ��������� ��� ������ ������������. ������������� ����� ���������, ������� � �������� ��������� �� ���������. ��� ��������� ������� �������� ����� ���������� ���������� ������������ SP.V_GLOBALS. ������������� ����� �������� ������� �������� ���������� ������ ������������ ����� SP.V_USERS_GLOBALS. ������������ ������ ����������������, ����� ������������� ��������� ��������������. ����� ������� ����� ������� �������� �������� ����������� ���������. SP-Views.vw';

BEGIN
 cc.fT:='PAR_TYPES';
 cc.tT:='V_GLOBAL_PAR_S';
 cc.c('ID','TYPE_ID');
 cc.c('NAME','TYPE_NAME');
 
 cc.fT:='GLOBAL_PAR_S';
 cc.c('ID','ID');
 cc.c('NAME','NAME');
 cc.c('REACTION','REACTION');
 cc.c('GROUP_ID','GROUP_ID');
 cc.c('R_ONLY','R_ONLY');
 cc.c('COMMENTS','COMMENTS');
END;
/
COMMENT ON COLUMN SP.V_GLOBAL_PAR_S.S_VALUE IS '������������� �������� ��������� � ���� ���������� ������.';
COMMENT ON COLUMN SP.V_GLOBAL_PAR_S.VALUE_COMMENTS IS '����������� � �������� ���������.';
COMMENT ON COLUMN SP.V_GLOBAL_PAR_S.VALUE_ENUM IS '������� ������������ ��������. 0 - �������� �� ����� �����, 1 - �������� ���������.';
COMMENT ON COLUMN SP.V_GLOBAL_PAR_S.SET_OF_VALUES IS '������� ������� � ���� ������ ������ ��� ��������. 0 - �������� �� ����� ������ ������, 1 - �������� ����� ������ ������.';
COMMENT ON COLUMN SP.V_GLOBAL_PAR_S.GROUP_NAME IS '��� ������, ������� ����������� ������ ��������.';


-----------------------------------------------------------------------------
-- �������� ���������� ���������� ��� �������� ������������.

CREATE OR REPLACE VIEW SP.V_GLOBALS
(NAME, TYPE_ID, TYPE_NAME, VALUE_ENUM, SET_OF_VALUES, 
 S_VALUE, COMMENTS, REACTION, R_ONLY, E, N, D, S, X, Y)
AS 
SELECT
  p.NAME, 
  CAST(p.TYPE_ID AS NUMBER(9)) TYPE_ID,
  CAST (to_StrType(p.TYPE_ID)AS VARCHAR2(128) ) TYPE_NAME,
  CAST(SP.S_IS_ENUM_TYPE(p.TYPE_ID) AS NUMBER(1)) VALUE_ENUM,
  CAST(SP.S_TYPE_HAS_SET_OF_VALUES(p.TYPE_ID) AS NUMBER(1)) SET_OF_VALUES,
	SP.Val_to_Str(SP.TVALUE(p.TYPE_ID,null,0,p.E_VAL,p.N,p.D,p.S,p.X,p.Y)) S_VALUE, 
  g.COMMENTS||' Value=> '||
    SP.Val_Comments(SP.TVALUE(p.TYPE_ID,null,0,p.E_VAL,p.N,p.D,p.S,p.x,p.y))
    COMMENTS, 
  p.REACTION, SP.to_StrR_Only(p.R_ONLY) R_ONLY,
  p.E_VAL E, p.N, p.D, p.S, p.X, p.Y
  FROM SP.WORK_GLOBAL_PAR_S p, SP.GLOBAL_PAR_S g 
  WHERE UPPER(p.NAME)=UPPER(g.NAME); 


GRANT ALL ON SP.V_GLOBALS TO PUBLIC;


COMMENT ON TABLE SP.V_GLOBALS IS '�������� ���������� ���������� ��� �������� ������������. ����� �������� ������ �������� ����������, ��� ���� ����������� ������� �� ��������� ��������. ������������� ����� �������� ���������� ��������� ������ ������������, ��������� SP.V_USERS_GLOBALS ��� ������� ������� �����. ���� ��������: E, N, D, S, X, Y ������������� ��� ������ � �� ��������� �� �������������� ��������� �������������. ��� ��������� �������� ����������� ��������� ����� ������������, ���� S_Value, ���� ��� TGPAR. SP-Views.vw';

BEGIN
 cc.fT:='PAR_TYPES';
 cc.tT:='V_GLOBALS';
 cc.c('ID','TYPE_ID');
 cc.c('NAME','TYPE_NAME');
 cc.fT:='WORK_GLOBAL_PAR_S';
 cc.tT:='V_GLOBALS';
 cc.c('NAME','NAME');
 cc.c('REACTION','REACTION'); 
 cc.c('R_ONLY','R_ONLY');
 cc.c('E_VAL','E');
 cc.c('N','N');
 cc.c('D','D');
 cc.c('S','S');
 cc.c('X','X');
 cc.c('Y','Y');
END;
/
 
 COMMENT ON COLUMN SP.V_GLOBALS.S_VALUE IS '������������� �������� ��������� � ���� ���������� ������';

 COMMENT ON COLUMN SP.V_GLOBALS.COMMENTS IS '����������� � ����������� ��������� � ��� ����, � ��� ����������� ����� ��� � � �������� ���������.';
COMMENT ON COLUMN SP.V_GLOBALS.VALUE_ENUM IS '������� ������������ ��������. 0 - �������� �� ����� �����, 1 - �������� ���������.';
COMMENT ON COLUMN SP.V_GLOBALS.SET_OF_VALUES IS '������� ������� � ���� ������ ������ ��� ��������. 0 - �������� �� ����� ������ ������, 1 - �������� ����� ������ ������.';

-------------------------------------------------------------------------------
-- �������� ���������� ���������� ��� ���� �������������.
CREATE OR REPLACE VIEW SP.V_USERS_GLOBALS
(
SP_USER,
GL_PAR_ID,
NAME,
TYPE_ID,
TYPE_NAME,
VALUE_ENUM,
SET_OF_VALUES,
S_VALUE,
VALUE_COMMENTS,
R_ONLY,
REACTION,
COMMENTS
)
AS
SELECT 
  u.SP_USER,
  p.ID GL_PAR_ID,
  p.NAME,
  CAST(p.TYPE_ID AS NUMBER(9)) TYPE_ID, 
  CAST (to_StrType(p.TYPE_ID)AS VARCHAR2(128) ) TYPE_NAME,
  CAST(SP.S_IS_ENUM_TYPE(p.TYPE_ID) AS NUMBER(1)) VALUE_ENUM,
  CAST(SP.S_TYPE_HAS_SET_OF_VALUES(p.TYPE_ID) AS NUMBER(1)) SET_OF_VALUES,
	SP.FUNC.GetUserS_Value(ID,u.SP_USER) S_VALUE,
	SP.FUNC.GetUserValueComments(ID,u.SP_USER) VALUE_COMMENTS,
	p.R_ONLY,p.REACTION,p.COMMENTS  
  FROM SP.GLOBAL_PAR_S p,
  (SELECT DISTINCT SP_USER FROM SP.USERS_GLOBALS) u;

GRANT SELECT ON SP.V_USERS_GLOBALS TO "SP_ADMIN_ROLE";
GRANT UPDATE ON SP.V_USERS_GLOBALS TO "SP_ADMIN_ROLE";

COMMENT ON TABLE SP.V_USERS_GLOBALS IS '�������� ���������� ���������� ��� ���� �������������. ������������� ����� �������� ���������� ��������� ������ ������������, ��� ���� ������������ ������ ���������������, ����� ��������� �������� � ����. ���� ������������ � ������������� ������� ���� � ��� �� ��������, �� �������� ��� ����� ���������� ������ ��������� ��������. ��� ���������� ����� ������ � ��� ������������� ����� ������ ����� ������������. ���������� ��������� ��������� � ���� ������������� � ����������� ����� ������������� V_GLOBAL_PARS. SP-Views.vw';

BEGIN
 cc.fT:='GLOBAL_PAR_S';
 cc.tT:='V_USERS_GLOBALS';
 cc.c('NAME','NAME');
 cc.c('REACTION','REACTION');
 cc.c('R_ONLY','R_ONLY');
 cc.c('COMMENTS','COMMENTS');
 
 cc.fT:='USERS_GLOBALS';
 cc.tT:='V_USERS_GLOBALS';
 cc.c('SP_USER','SP_USER');
 
 cc.fT:='PAR_TYPES';
 cc.tT:='V_USERS_GLOBALS';
 cc.c('ID','TYPE_ID');
 cc.c('NAME','TYPE_NAME');

END;
/

COMMENT ON COLUMN SP.V_USERS_GLOBALS.S_VALUE IS '������������� �������� ��������� � ���� ���������� ������. ��� ���������� ������ ������ ��������� ������������� ������ ������������ ������������, � ���� "NAME" ���� ����� "USER_PWD".';
COMMENT ON COLUMN SP.V_USERS_GLOBALS.GL_PAR_ID IS '������������� ����������� ���������. �� ������ � ��������������� ���������������� ����������� ��������� ��� ����������� ������������.';
COMMENT ON COLUMN SP.V_USERS_GLOBALS.VALUE_COMMENTS IS '����������� � �������� ���������.';
COMMENT ON COLUMN SP.V_USERS_GLOBALS.VALUE_ENUM IS '������� ������������ ��������. 0 - �������� �� ����� �����, 1 - �������� ���������.';
COMMENT ON COLUMN SP.V_USERS_GLOBALS.SET_OF_VALUES IS '������� ������� � ���� ������ ������ ��� ��������. 0 - �������� �� ����� ������ ������, 1 - �������� ����� ������ ������.';

-------------------------------------------------------------------------------
-- ����, ������������ � �������.
CREATE OR REPLACE VIEW SP.V_PRIM_ROLES
(ID, NAME, COMMENTS, ORA)
AS
  SELECT ID, NAME, COMMENTS, ORA
    FROM SP.SP_ROLES;

GRANT ALL ON SP.V_PRIM_ROLES TO "SP_ADMIN_ROLE";
GRANT SELECT ON SP.V_PRIM_ROLES TO PUBLIC ;
COMMENT ON TABLE SP.V_PRIM_ROLES 
  IS '�������� ����� SP. ����� �������� ��� ��������� ���� ����������� ������� ���� � ������� ������. ����� ���� ������������ �������� �����. SP-Views.vw';
BEGIN
 cc.fT:='SP_ROLES';
 cc.tT:='V_PRIM_ROLES';
 cc.c('ID','ID');
 cc.c('NAME','NAME');
 cc.c('COMMENTS','COMMENTS');
 cc.c('ORA','ORA');
END;
/

-------------------------------------------------------------------------------
-- ����, ������������ � ������� � �� ��������.
CREATE OR REPLACE VIEW SP.V_ROLES
(ID, NAME, PARENT, PID, REL_ID)
AS
select r.ID, r.NAME, PARENT, PID, REL_ID  
  from SP.SP_ROLES r 
  left join ( select g.NAME PARENT, g.ID PID, rr.ID REL_ID, rr.GRANTED_ID 
              from SP.SP_ROLES g, SP.SP_ROLES_RELS rr
              where rr.ROLE_ID = g.ID
             )rr 
  on  rr.GRANTED_ID = r.ID 
;
 
GRANT ALL ON SP.V_ROLES TO "SP_ADMIN_ROLE";
GRANT SELECT ON SP.V_ROLES TO PUBLIC ;
COMMENT ON TABLE SP.V_ROLES 
  IS '�������� ����� � �� ��������. ��������������� ����� �����������, ����� ��� ��� ����������� ����. ���� ���� ���������, �� ��������������� � ��� ������ - ����� ������� ���� � �������� �����, ����� ���� ������������ ��������. ��� ���������� ������, ����� ��������� ���� ��� (�) �����. ��� �������� ������, ���� ���� �����, �� ����� ������� �����, � ���� ������ �� ��������, �� ����� ������� ����. ��� ��������� �������������� ���� � ������� ���������� ������������ �������������� SP.V_PRIM_ROLES.   SP-Views.vw';
BEGIN
 cc.fT:='SP_ROLES';
 cc.tT:='V_ROLES';
 cc.c('ID','ID');
 cc.c('NAME','NAME');
END;
/
COMMENT ON COLUMN SP.V_ROLES.PARENT IS 'GRANTEE. ��� ����, ������� ������������� ���������� ���� "NAME". ����� ������� ��� ���������� ���� "NAME" ������ � ������ ���������� �������� "PARENT". ';
COMMENT ON COLUMN SP.V_ROLES.PID IS 'GRANTEE. ������������� ����, ���������� ����� �� ���� � "ID".';
COMMENT ON COLUMN SP.V_ROLES.REL_ID IS '������������� �����.';


-------------------------------------------------------------------------------
-- ������������ �������.
CREATE OR REPLACE VIEW SP.V_USERS
(SP_USER, PSW, SP_ROLE, COMMENTS, USER_GROUP)
AS
  SELECT u.SP_USER, SP.DPSW(u.s) PSW, SP.UserRole(u.SP_USER) SP_ROLE, 
         UC.S COMMENTS,
         (select NAME from SP.Groups where ID = UG.N) USER_GROUP
    FROM (select * from SP.USERS_GLOBALS 
            where GL_PAR_ID = (SELECT ID FROM SP.GLOBAL_PAR_S 
                                 WHERE UPPER(NAME) = 'USER_PWD') ) U, 
         (select * from SP.USERS_GLOBALS 
            where GL_PAR_ID = (SELECT ID FROM SP.GLOBAL_PAR_S 
                                 WHERE UPPER(NAME) = 'USER_COMMENTS') ) UC,
         (select * from SP.USERS_GLOBALS 
            where GL_PAR_ID = (SELECT ID FROM SP.GLOBAL_PAR_S 
                                 WHERE UPPER(NAME) = 'USER_GROUP') ) UG
    WHERE U.SP_USER = UC.SP_USER(+)
      and U.SP_USER = UG.SP_USER(+);
    
GRANT ALL ON SP.V_USERS TO "SP_ADMIN_ROLE";

COMMENT ON TABLE SP.V_USERS IS '������ �������������. ������������� ��� ����������, ��������� ��� �������� ������������� SP, � ����� ��� ��������� �������� ���� ������������ SP. SP-Views.vw';
COMMENT ON COLUMN SP.V_USERS.SP_USER IS '������������.';
COMMENT ON COLUMN SP.V_USERS.PSW IS '������.';
COMMENT ON COLUMN SP.V_USERS.SP_ROLE IS '�������� ���� ������������. ���� � ������������ ����� ��� �������� ����, �� ��� ����� �������� � ����� ������ ����� ����������� � ���� ���������������� �����. ��� ���������� ������ � ������������ ����� ������� ��� ���� (�� ������� SP.ROLES) �� ����������� ����� �����������. ���� ����� ���� - "����", �� ������������ ����� ��������� ������ ���� "SP_USER_ROLE." ';
COMMENT ON COLUMN SP.V_USERS.COMMENTS IS '�������� ������������.';
COMMENT ON COLUMN SP.V_USERS.USER_GROUP IS '������ � ������� ����������� ������������. ���������� �������� ����� �������������� ��� ���������� ��� ���� �����.';

-------------------------------------------------------------------------------
-- ���� �������, ����������� ��������� �������������.
CREATE OR REPLACE VIEW SP.V_USER_ROLES
(USER_NAME, ROLE_NAME, COMMENTS)
AS
  SELECT U.SP_USER USER_NAME, R.NAME ROLE_NAME, R.COMMENTS 
    FROM DBA_ROLE_PRIVS D, SP.USERS_GLOBALS U, SP.SP_ROLES R
    WHERE upper(U.SP_USER) = upper(D.GRANTEE) 
      AND R.NAME = D.GRANTED_ROLE
	    AND GL_PAR_ID = (SELECT ID FROM SP.GLOBAL_PAR_S 
                         WHERE UPPER(NAME) = 'USER_PWD');
    
GRANT ALL ON SP.V_USER_ROLES TO "SP_ADMIN_ROLE";

COMMENT ON TABLE SP.V_USER_ROLES IS '������ ����� �������������. SP-Views.vw';  

BEGIN
 cc.fT:='SP_ROLES';
 cc.tT:='V_USER_ROLES';
 cc.c('NAME','ROLE_NAME');
 cc.c('COMMENTS','COMMENTS');
END;
/

BEGIN
 cc.fT:='USERS_GLOBALS';
 cc.tT:='V_USER_ROLES';
 cc.c('SP_USER','USER_NAME');
END;
/
--*****************************************************************************
@"SP-Instead.trg"


-- end of file

