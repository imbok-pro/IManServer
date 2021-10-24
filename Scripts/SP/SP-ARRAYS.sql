-- SP ARRAYS
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 17.01.2018
-- update 19.01.2018
--*****************************************************************************

-- Массивы.
-------------------------------------------------------------------------------
CREATE TABLE SP.ARRAYS
(
  ID NUMBER,
  CONSTRAINT PK_ARRAYS PRIMARY KEY (ID),
  NAME VARCHAR2(128) NOT NULL,
  GROUP_ID NUMBER NOT NULL,
  IND_X NUMBER DEFAULT NULL,
  IND_Y NUMBER DEFAULT NULL,
  IND_Z NUMBER DEFAULT NULL,
  IND_S VARCHAR2(4000) DEFAULT NULL,
  IND_D DATE DEFAULT NULL,
  TYPE_ID NUMBER(9) NOT NULL,
  E_VAL VARCHAR2(128) DEFAULT NULL,
  N NUMBER DEFAULT NULL,
  D DATE DEFAULT NULL,
  S VARCHAR2(4000) DEFAULT NULL,
  X NUMBER DEFAULT NULL,
  Y NUMBER DEFAULT NULL,
  M_DATE DATE NOT NULL,
  M_USER VARCHAR2(60) NOT NULL,
  CONSTRAINT REF_ARRAYS_TO_GROUPS
  FOREIGN KEY (GROUP_ID)
  REFERENCES SP.GROUPS (ID),
  CONSTRAINT REF_ARRAYS_to_TYPES_ID
  FOREIGN KEY (TYPE_ID) 
  REFERENCES SP.PAR_TYPES (ID),
  CONSTRAINT CH_ARRAYS CHECK
  (
    instr(NAME,'.')=0
    and
      (
           IND_X is not null
        or IND_Y is not null
        or IND_Z is not null
        or IND_S is not null
        or IND_D is not null
      )
  )
);

CREATE UNIQUE INDEX SP.UN_ARRAYS_ELT 
  ON SP.ARRAYS (GROUP_ID, UPPER(NAME), IND_X, IND_Y,UPPER(IND_S),IND_D);
CREATE INDEX SP.ARRAYS_GROUPS ON SP.ARRAYS(GROUP_ID);
CREATE INDEX SP.ARRAYS_TYPES ON SP.ARRAYS(TYPE_ID);
CREATE INDEX SP.ARRAYS_IX ON SP.ARRAYS(IND_X);
CREATE INDEX SP.ARRAYS_ID ON SP.ARRAYS(IND_D);
CREATE INDEX SP.ARRAYS_E_VAL ON SP.ARRAYS(E_VAL);

COMMENT ON TABLE SP.ARRAYS IS 'Массивы IMan.(SP-ARRAYS.sql)';

COMMENT ON COLUMN SP.ARRAYS.ID IS 'Уникальный идентификатор элемента масссива.';
COMMENT ON COLUMN SP.ARRAYS.NAME IS 'Имя массива.';
COMMENT ON COLUMN SP.ARRAYS.GROUP_ID IS 'Ссылка на группу, определяющую пространство имён массива.';
COMMENT ON COLUMN SP.ARRAYS.IND_X IS 'Индекс массива.';
COMMENT ON COLUMN SP.ARRAYS.IND_Y IS 'Индекс массива.';
COMMENT ON COLUMN SP.ARRAYS.IND_Z IS 'Индекс массива.';
COMMENT ON COLUMN SP.ARRAYS.IND_S IS 'Индекс массива.';
COMMENT ON COLUMN SP.ARRAYS.IND_D IS 'Индекс массива.';
COMMENT ON COLUMN SP.ARRAYS.TYPE_ID    IS 'Тип элемента массива.';
COMMENT ON COLUMN SP.ARRAYS.E_VAL 
  IS 'Имя значения элемента массива (для перечисляемых типов).';   
COMMENT ON COLUMN SP.ARRAYS.N         IS 'Значение элемента массива.';
COMMENT ON COLUMN SP.ARRAYS.D         IS 'Значение элемента массива.';
COMMENT ON COLUMN SP.ARRAYS.S         IS 'Значение элемента массива.';
COMMENT ON COLUMN SP.ARRAYS.X         IS 'Значение элемента массива.';
COMMENT ON COLUMN SP.ARRAYS.Y         IS 'Значение элемента массива.';
COMMENT ON COLUMN SP.ARRAYS.M_DATE 
  IS 'Дата создания или изменения значение элемента.';
COMMENT ON COLUMN SP.ARRAYS.M_USER 
  IS 'Пользователь создавший или изменивший значение элемента.';


-- end of file
  