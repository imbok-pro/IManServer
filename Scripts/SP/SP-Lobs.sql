-- LOBS tables
-- by Nikolay Krasilnikov 
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 07.03.2021  
-- update 01.07.2021
--*****************************************************************************

-- Данные файлов, сохранённые в базе.

-------------------------------------------------------------------------------
CREATE TABLE SP.LOB_S
(
  ID NUMBER,
  GUID VARCHAR2(40),
  TAG NUMBER Default NULL,
  F_TYPE NUMBER Default NULL,
  F_CLOB CLOB Default NULL,
  F_BLOB BLOB Default NULL,
  M_DATE DATE,
  M_USER VARCHAR2(60),
  CONSTRAINT PK_LOBS PRIMARY KEY (ID)
)
  TABLESPACE SP_FILES
;


COMMENT ON TABLE SP.LOB_S IS 'Данные файлов, сохранённых в базе.(SP-Lobs.sql)';

COMMENT ON COLUMN SP.LOB_S.ID       	IS 'Идентификатор записи';
COMMENT ON COLUMN SP.LOB_S.GUID     	IS 'Глобальный идентификатор файла';
COMMENT ON COLUMN SP.LOB_S.TAG        IS 'Тag. Произвольное число.';
COMMENT ON COLUMN SP.LOB_S.F_TYPE     IS 'Тип файла. Тип определяется, ка идентификатор именованного значения TFileType';
COMMENT ON COLUMN SP.LOB_S.F_CLOB     IS 'Текстовый файл';
COMMENT ON COLUMN SP.LOB_S.F_BLOB     IS 'Бинарный файл';
COMMENT ON COLUMN SP.LOB_S.M_DATE     IS 'Дата создания или изменения записи.';
COMMENT ON COLUMN SP.LOB_S.M_USER     IS 'Пользователь, создавший или изменивший запись.';

-- end of file

