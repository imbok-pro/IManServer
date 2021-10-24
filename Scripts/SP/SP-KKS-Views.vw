-- SP KKS Views 
-- by Sergey Azarov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 03.03.2016
-- update 
--        09.03.2016 28.03.2016

-- Представление .
CREATE OR REPLACE VIEW SP.V_KKS_CUR_MODEL_CODES 
as
select OID, FULL_NAME, REPLACE(FULL_NAME,'/') KKS 
from SP.V_CUR_MODEL_OBJECTS 
WHERE OID != '-1';


COMMENT ON TABLE SP.V_KKS_CUR_MODEL_CODES 
  IS 'Служебная. Словарь "Полное имя объекта - Код ККС объекта" для объектов текущей модели. (SP-KKS-Views.vw)';

GRANT SELECT ON SP.V_KKS_CUR_MODEL_CODES TO public;

BEGIN
 cc.fT:='V_CUR_MODEL_OBJECTS';
 cc.tT:='V_KKS_CUR_MODEL_CODES';
 cc.c('OID','OID'); 
 cc.c('FULL_NAME','FULL_NAME'); 
END; 
/

--select * from  "SP"."V_KKS_CUR_MODEL_Codes" 