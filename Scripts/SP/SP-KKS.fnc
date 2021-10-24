-- SP KKS procedures
-- by Sergey Azarov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 03.03.2016
-- update 
--        09.03.2016 28.03.2016


-------------------------------------------------------------------------------
create or replace FUNCTION SP.GetJSONbyObjectOID(objOID IN VARCHAR2)
RETURN CLOB
-- ������� ����������� ������ ������� ������, ���������� �� ��������������,
-- � ������ JSON;
-- OID - ���������� ������������� ������� �� ������� ������.
-- � ������ JSON ������������� ��� ��������� ������� 
-- � ��������� ��������� ����� ��������� ������� (���, ���������� ��������).
/* SP.KKS.fnc*/
is
tmpstr varchar2(4000);
objid  NUMBER;
comments varchar2(4000);
result CLOB;
begin
  DBMS_LOB.createtemporary(result,true,12);
  -- ��������� �����, ID � ����������� ����������� �������
  select 
    -- ����������� ������ ������ + ��� ������� + ID     
    '{ NAME: {TYPE:"VARCHAR2(4000)", VALUE: "' || FULL_NAME || '"}, ' , 
    ID,
    --  ����������� � ������� � ����������� ������ ������      
    'CATALOG_COMMENTS:{TYPE:"VARCHAR2(4000)", VALUE: "' ||
      CATALOG_COMMENTS || '"}  }'
    into tmpstr, objid, comments 
    from SP.V_cur_MODEL_OBJECTS where OID = objOID AND ROWNUM <=1;       
  --o(tmpstr);
  --o('id =' || objid);
  DBMS_LOB.WRITEAPPEND (result,length(tmpstr),tmpstr);
  -- ���� ��������� ���������� �������
  for r in
  (
   SELECT 
     PARAM_NAME || ':{TYPE:"' || TYPE_NAME || '", VALUE:"' || VAL  || '"},' p
     FROM SP.V_MODEL_OBJECT_PARS 
     WHERE MOD_OBJ_ID  = objid
  )
  LOOP
    --o(r.p);
    DBMS_LOB.WRITEAPPEND (result,length(r.p),r.p);
  END LOOP;
  -- ����������� � ������� � ����������� ������ ������
  --o(comments);
  DBMS_LOB.WRITEAPPEND (result,length(comments),comments);
  RETURN result;
EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN NULL;
end;
/
GRANT EXECUTE ON SP.GetJSONbyObjectOID TO public;

-------------------------------------------------------------------------------
create or replace FUNCTION SP.GetJSONbyObjectFullName(objFullName IN VARCHAR2)
RETURN CLOB
-- ������� ����������� ������ ������� ������, ���������� �� �����,
-- � ������ JSON;
-- FullName - ������ (���������� ���� �� �����) ��� �������.
-- � ������ JSON ������������� ��� ��������� ������� 
-- � ��������� ����� ��������� ������� (���, ���������� ��������).
/* SP.KKS.fnc*/
is
objOID varchar2(4000);
begin
  select OID into objOID from SP.V_cur_MODEL_OBJECTS 
    where FULL_NAME = objFullName AND ROWNUM <=1;   
  --o(objOID);
  RETURN SP.GetJSONbyObjectOID(objOID);
EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN NULL;
end;
/
GRANT EXECUTE ON SP.GetJSONbyObjectFullName TO public;

-------------------------------------------------------------------------------
create or replace FUNCTION SP.GetJSONbyKKSCode(objCoge IN VARCHAR2)
RETURN CLOB
-- ������� ����������� ������ ������� ������, ���������� �� ����, � ������ JSON;
-- Coge - ��� ��C ������� (��������� �� ������� �����).
-- � ������ JSON ������������� ��� ��������� ������� 
-- � ��������� ����� ��������� ������� (���, ���������� ��������).
/* SP.KKS.fnc*/
is
objOID varchar2(4000);
begin
  select OID into objOID from SP.V_KKS_CUR_MODEL_Codes 
    where KKS = objCoge AND ROWNUM <=1;   
  --o(objOID);
  RETURN SP.GetJSONbyObjectOID(objOID);
EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN NULL;
end;
/
GRANT EXECUTE ON SP.GetJSONbyKKSCode TO public;

-- end of file
