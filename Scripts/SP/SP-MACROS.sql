-- SP Macros
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 05.08.2010
-- update 01.09.2010 06.09.2010 22.09.2010 12.10.2010 29.10.2010 19.11.2010
--        07.12.2010 20.12.2010 23.09.2011 21.12.2011 19.01.2012 22.03.2012
--        11.04.2012 03.04.2013 14.06.2014 08.07.2015 23.12.2015 04.02.2016
--        11.02.2016 23.02.2016 03.03.2016 10.03.2016 22.11.2016 
--***************************************************************************** 

-- Макрокоманды.
-------------------------------------------------------------------------------
CREATE TABLE SP.MACROS( 
  ID NUMBER NOT NULL,
  OBJ_ID NUMBER NOT NULL,
  ALIAS VARCHAR2(30),
  COMMENTS VARCHAR2(4000),
	PREV_ID NUMBER,
  CMD_ID NUMBER(3) NOT NULL,
  USED_OBJ_ID NUMBER,
	MACRO VARCHAR2(4000),
  CONDITION VARCHAR2(4000),
  M_DATE DATE NOT NULL,
  M_USER VARCHAR2(60) NOT NULL,
	CONSTRAINT PK_MACROS PRIMARY KEY (ID),
	CONSTRAINT CHK_MACROS CHECK (ID!=PREV_ID),
  CONSTRAINT REF_MACROS_INTERNAL
    FOREIGN KEY (PREV_ID) 
    REFERENCES SP.MACROS (ID) ON DELETE SET NULL,
  CONSTRAINT REF_MACROS_to_COMMANDS
    FOREIGN KEY (CMD_ID) 
    REFERENCES SP.COMMANDS (ID) ON DELETE CASCADE,
  CONSTRAINT REF_MACROS_to_OBJECTS
    FOREIGN KEY (OBJ_ID) 
    REFERENCES SP.OBJECTS (ID) ON DELETE CASCADE,
  CONSTRAINT REF_USED_OBJ_to_OBJECTS
    FOREIGN KEY (USED_OBJ_ID) 
    REFERENCES SP.OBJECTS (ID) ON DELETE SET NULL
	);
  
CREATE UNIQUE INDEX SP.MACROS_ALIAS 
  ON SP.MACROS(OBJ_ID, NVL(UPPER(ALIAS),TO_CHAR(PREV_ID)));
CREATE UNIQUE INDEX SP.MACROS_ORDER ON SP.MACROS(OBJ_ID, PREV_ID);

CREATE INDEX SP.MACROS_PREV_ID ON SP.MACROS(PREV_ID);
CREATE INDEX SP.MACROS_CMD_ID ON SP.MACROS(CMD_ID);
CREATE INDEX SP.MACROS_OBJ_ID ON SP.MACROS(OBJ_ID);
CREATE INDEX SP.MACROS_USED_OBJ_ID ON SP.MACROS(USED_OBJ_ID);

COMMENT ON TABLE SP.MACROS
  IS 'Макрокоманды составляющие макропрецедуры (типовые процедуры создания объектов). Каждая макропроцедура преобразуется в отдельный пакет с именем "M_XXXXXX", где XXXXX - уникальный идентификатор объекта, который основан на данной макропоследовательности. Внутри каждого такого пакета существуют три массива параметров: P - входные и рабочие параметры IP - входные параметры, передаваемые в вызываемую процедуру.  OPa - выходные параметры, получаемые из вызываемой процедуры. Массив Opa очищается перед вызовом очередной макропроцедуры, а массив IP - вручную. При вызове макропроцедуры массив IP вызывающей макропроцедуры переписывается в массив P вызываемой.(SP-MACROS.sql)';

COMMENT ON COLUMN SP.MACROS.ID
  IS 'Уникальный идентификатор.';
COMMENT ON COLUMN SP.MACROS.OBJ_ID
  IS 'Идентификатор объекта (типовой процедуры).';
COMMENT ON COLUMN SP.MACROS.ALIAS
  IS 'Имя макрокоманды. Может быть нулл. Если не нулл, то можно использовать как метку при переходах.';
COMMENT ON COLUMN SP.MACROS.COMMENTS
  IS 'Описание действия макрокоманды (комментарий к конкретному действию).';
COMMENT ON COLUMN SP.MACROS.PREV_ID
  IS 'Ссылка на идентификатор предыдущей макрокоманды.';
COMMENT ON COLUMN SP.MACROS.CMD_ID
  IS 'Тип команды.';
COMMENT ON COLUMN SP.MACROS.USED_OBJ_ID
  IS 'Идентификатор объекта каталога или типовой процедуры, использованный текущей коммандой. ';
COMMENT ON COLUMN SP.MACROS.MACRO
  IS 'Блок PlSql выполняющий рассчёт или заполняющий массив параметров и команд.';
COMMENT ON COLUMN SP.MACROS.CONDITION
  IS 'Блок PlSql или нулл. Если поле нулл или вычисление этого поля как логического выражения даёт значение "true", то макроопределение будет выполнено, иначе макрогенератор переходит к следующей макрокоманде.';
COMMENT ON COLUMN SP.MACROS.M_DATE 
  IS 'Дата создания или изменения макрокоманды.';
COMMENT ON COLUMN SP.MACROS.M_USER 
  IS 'Пользователь, создавший или изменивший макрокоманду.';

CREATE GLOBAL TEMPORARY TABLE SP.INSERTED_MACROS( 
  NEW_ID NUMBER,
  NEW_OBJ_ID NUMBER,
  NEW_ALIAS VARCHAR2(30),
  NEW_COMMENTS VARCHAR2(4000),
	NEW_PREV_ID NUMBER,
  NEW_CMD_ID NUMBER,
  NEW_USED_OBJ_ID NUMBER,
	NEW_MACRO VARCHAR2(4000),
  NEW_CONDITION VARCHAR2(4000),
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.INSERTED_MACROS
  IS 'Временная таблица, содержащая перечень добавленных записей.(SP-MACROS.sql)';
  
CREATE GLOBAL TEMPORARY TABLE SP.UPDATED_MACROS( 
  NEW_ID NUMBER,
  NEW_OBJ_ID NUMBER,
  NEW_ALIAS VARCHAR2(30),
  NEW_COMMENTS VARCHAR2(4000),
	NEW_PREV_ID NUMBER,
  NEW_CMD_ID NUMBER,
  NEW_USED_OBJ_ID NUMBER,
	NEW_MACRO VARCHAR2(4000),
  NEW_CONDITION VARCHAR2(4000),
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60),
  OLD_ID NUMBER,
  OLD_OBJ_ID NUMBER,
  OLD_ALIAS VARCHAR2(30),
  OLD_COMMENTS VARCHAR2(4000),
	OLD_PREV_ID NUMBER,
  OLD_CMD_ID NUMBER,
  OLD_USED_OBJ_ID NUMBER,
	OLD_MACRO VARCHAR2(4000),
  OLD_CONDITION VARCHAR2(4000),
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.UPDATED_MACROS
  IS 'Временная таблица, содержащая перечень изменённых записей.(SP-MACROS.sql)';
  
CREATE GLOBAL TEMPORARY TABLE SP.DELETED_MACROS( 
  OLD_ID NUMBER,
  OLD_OBJ_ID NUMBER,
  OLD_ALIAS VARCHAR2(30),
  OLD_COMMENTS VARCHAR2(4000),
	OLD_PREV_ID NUMBER,
  OLD_CMD_ID NUMBER,
  OLD_USED_OBJ_ID NUMBER,
	OLD_MACRO VARCHAR2(4000),
  OLD_CONDITION VARCHAR2(4000),
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.DELETED_MACROS
  IS 'Временная таблица, содержащая перечень удалённых записей.(SP-MACROS.sql)';
  

-------------------------------------------------------------------------------
CREATE GLOBAL TEMPORARY TABLE SP.WORK_COMMAND_PAR_S( 
  NAME VARCHAR2(128) NOT NULL,
  COMMENTS VARCHAR2(4000),
  R_ONLY NUMBER(1) DEFAULT 0 NOT NULL,
  MODIFIED NUMBER(1) DEFAULT 0 NOT NULL,
  TYPE_ID NUMBER(9) NOT NULL,
	E_VAL VARCHAR2(128),
	N NUMBER,
  D DATE,
	S VARCHAR2(4000),
	X NUMBER,
	Y NUMBER,
  Def_V VARCHAR2(4000)
	)
ON COMMIT PRESERVE ROWS;
  
CREATE UNIQUE INDEX SP.WORK_COMMAND_PAR_S
  ON SP.WORK_COMMAND_PAR_S(UPPER(NAME));
  
GRANT INSERT, SELECT, UPDATE, DELETE ON SP.WORK_COMMAND_PAR_S TO PUBLIC; 

COMMENT ON TABLE SP.WORK_COMMAND_PAR_S
  IS 'Временная таблица содержит параметры макропроцедуры, редактируемые или просматриваемые пользователем в процессе или перед выполнением макропроцедуры. Структура таблицы соответствует типу SP.TMACRO_PAR_S. (SP-MACROS.sql)';

COMMENT ON COLUMN SP.WORK_COMMAND_PAR_S.NAME
  IS 'Имя параметра.';
COMMENT ON COLUMN SP.WORK_COMMAND_PAR_S.COMMENTS
  IS 'Примечание или инструкция по заполнению параметра.';
COMMENT ON COLUMN SP.WORK_COMMAND_PAR_S.R_ONLY 
  IS 'Если значение равно 1, то этот параметр только для чтения. Если значение равно -1, то этот параметр обязательно должен быть присвоен перед вызовом  команды. Значение по умолчанию из каталога можно использовать только для справки.';
COMMENT ON COLUMN SP.WORK_COMMAND_PAR_S.MODIFIED    IS 'Признак редактирования параметра, используется совмесно со значением R_ONLY = -1.';
COMMENT ON COLUMN SP.WORK_COMMAND_PAR_S.TYPE_ID    IS 'Тип параметра.';
COMMENT ON COLUMN SP.WORK_COMMAND_PAR_S.E_VAL 
  IS 'Значение перечисляемого типа.';	 
COMMENT ON COLUMN SP.WORK_COMMAND_PAR_S.N         IS 'Поле значения.';
COMMENT ON COLUMN SP.WORK_COMMAND_PAR_S.D         IS 'Поле значения.';
COMMENT ON COLUMN SP.WORK_COMMAND_PAR_S.S         IS 'Поле значения.';
COMMENT ON COLUMN SP.WORK_COMMAND_PAR_S.X         IS 'Поле значения.';
COMMENT ON COLUMN SP.WORK_COMMAND_PAR_S.Y         IS 'Поле значения.';
COMMENT ON COLUMN SP.WORK_COMMAND_PAR_S.Def_V     IS 'Значение по умолчанию.';

-------------------------------------------------------------------------------
CREATE GLOBAL TEMPORARY TABLE SP.WORK_OBJECTS_PAR_S( 
NAME VARCHAR2(255),
T NUMBER(9),
E VARCHAR2(128),
N NUMBER,
D DATE,
S VARCHAR2(4000),
X NUMBER,
Y NUMBER,
R_ONLY NUMBER(1),
/* Данное поле используется при передачи нескольких объектов в одном запросе. Причём значение данного поля может быть как просто индексом массива, так и уникальным идентификатором объекта.*/
OBJECT_INDEX NUMBER
)
ON COMMIT PRESERVE ROWS;
  
CREATE UNIQUE INDEX SP.WORK_OBJECTS_PAR_S
  ON SP.WORK_OBJECTS_PAR_S(OBJECT_INDEX, UPPER(NAME));

GRANT INSERT, SELECT, UPDATE, DELETE ON SP.WORK_OBJECTS_PAR_S TO PUBLIC; 

COMMENT ON TABLE SP.WORK_OBJECTS_PAR_S
  IS 'Временная таблица используется при передаче значения параметров объекта модели или макрокоманды. При работе с пакетом SP.MACRO используется для передачи опорного объекта. Структура таблицы совпадает со структурой типа SP.TIMAN_PARS.(SP-MACROS.sql)';

COMMENT ON COLUMN SP.WORK_OBJECTS_PAR_S.NAME
  IS 'Имя параметра.';
COMMENT ON COLUMN SP.WORK_OBJECTS_PAR_S.R_ONLY 
  IS 'Если значение равно 1, то этот параметр только для чтения. Если значение равно -1, то этот параметр обязательно должен быть присвоен или обновлён пользователем.';
COMMENT ON COLUMN SP.WORK_OBJECTS_PAR_S.T   IS 'Тип параметра.';
COMMENT ON COLUMN SP.WORK_OBJECTS_PAR_S.E
  IS 'Имя значения для перечисляемых типов.';	 
COMMENT ON COLUMN SP.WORK_OBJECTS_PAR_S.N         IS 'Поле значения.';
COMMENT ON COLUMN SP.WORK_OBJECTS_PAR_S.D         IS 'Поле значения.';
COMMENT ON COLUMN SP.WORK_OBJECTS_PAR_S.S         IS 'Поле значения.';
COMMENT ON COLUMN SP.WORK_OBJECTS_PAR_S.X         IS 'Поле значения.';
COMMENT ON COLUMN SP.WORK_OBJECTS_PAR_S.Y         IS 'Поле значения.';
COMMENT ON COLUMN SP.WORK_OBJECTS_PAR_S.OBJECT_INDEX    
  IS 'Данное поле используется при передачи нескольких объектов в одном запросе. Причём значение данного поля может быть как просто индексом массива, так и уникальным идентификатором объекта.';

-------------------------------------------------------------------------------
CREATE GLOBAL TEMPORARY TABLE SP.M_LOG( 
  LINE NUMBER(9),
  ThID NUMBER(9),
  TIME DATE,
  TEXT VARCHAR2(4000)
	)
ON COMMIT PRESERVE ROWS;
	
CREATE UNIQUE INDEX SP.M_LOG
  ON SP.M_LOG(ThID, TIME, LINE);

GRANT INSERT, SELECT, UPDATE, DELETE ON SP.M_LOG TO PUBLIC; 

COMMENT ON TABLE SP.M_LOG
  IS 'Временная таблица содержит протокол работы макропроцедур.(SP-MACROS.sql)';

COMMENT ON COLUMN SP.M_LOG.LINE  IS 'Номер строки.';
COMMENT ON COLUMN SP.M_LOG.ThID  
  IS 'Идентификатор потока выполнения.';
COMMENT ON COLUMN SP.M_LOG.TIME  IS 'Время занесения.';
COMMENT ON COLUMN SP.M_LOG.TEXT  IS 'Содержание строки.';

-------------------------------------------------------------------------------
CREATE GLOBAL TEMPORARY TABLE SP.M_ERRORS_and_WARNINGS( 
  LINE NUMBER(9),
  ThID NUMBER(9),
  TIME DATE,
  TEXT VARCHAR2(4000),
  ERR_OR_WARN VARCHAR2(7) DEFAULT 'WARNUNG',
  CHECK (ERR_OR_WARN in ('ERROR','WARNUNG'))
	)
ON COMMIT PRESERVE ROWS;
	
CREATE UNIQUE INDEX SP.M_ERRORS_and_WARNINGS
  ON SP.M_ERRORS_and_WARNINGS(ThID, TIME, LINE);

GRANT INSERT, SELECT, UPDATE, DELETE ON SP.M_ERRORS_and_WARNINGS TO PUBLIC; 

COMMENT ON TABLE SP.M_ERRORS_and_WARNINGS
  IS 'Временная таблица содержит ошибки и предупреждения, полученные в ходе выполнения макропроцедур.(SP-MACROS.sql)';

COMMENT ON COLUMN SP.M_ERRORS_and_WARNINGS.LINE  IS 'Номер строки.';
COMMENT ON COLUMN SP.M_ERRORS_and_WARNINGS.ThID  
  IS 'Идентификатор потока выполнения.';
COMMENT ON COLUMN SP.M_ERRORS_and_WARNINGS.TIME  IS 'Время занесения.';
COMMENT ON COLUMN SP.M_ERRORS_and_WARNINGS.TEXT  IS 'Содержание строки.';
COMMENT ON COLUMN SP.M_ERRORS_and_WARNINGS.ERR_OR_WARN  
  IS 'Признак ошибки. Как правило ошибка бывает одна и это последнее сообщение.';

-- end of file
