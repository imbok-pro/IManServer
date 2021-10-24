-- GUsedObjects views triggers
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 20.06.2013
-- update 06.01.2015
--
-- Объекты каталога.
--INSTEAD_OF_INSERT-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.VG_USED_OBJECTS_ii
INSTEAD OF INSERT ON SP.VG_USED_OBJECTS
-- (SP-GUsedObjects-Instead.trg)
DECLARE
BEGIN
  RAISE_APPLICATION_ERROR(-20033,'SP.VG_USED_OBJECTS_ii. '||
    'Для добавления объекта необходимо использовать V_Objects!');
END;
/	
--
-- INSTEAD_OF_UPDATE-----------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.VG_USED_OBJECTS_iu
INSTEAD OF UPDATE ON SP.VG_USED_OBJECTS
-- (SP-GUsedObjects-Instead.trg)
BEGIN
  RAISE_APPLICATION_ERROR(-20033,'SP.VG_USED_OBJECTS_iu. '||
    'Для изменения объекта необходимо использовать V_Objects!');
END;
/	
--INSTEAD_OF_DELETE------------------------------------------------------------
CREATE OR REPLACE TRIGGER SP.VG_USED_OBJECTS_id
INSTEAD OF DELETE ON SP.VG_USED_OBJECTS
-- (SP-GUsedObjects-Instead.trg)
BEGIN
  RAISE_APPLICATION_ERROR(-20033,'SP.VG_USED_OBJECTS_id. '||
    'Для удаления объекта необходимо использовать V_Objects!');
END;
/	
--*****************************************************************************

-- end of File 