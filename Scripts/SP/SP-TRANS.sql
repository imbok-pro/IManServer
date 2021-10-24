-- SP TRANS
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 21.08.2014
-- update 22.08.2014-25.08.2014
--*****************************************************************************

-- Таблица транзакций.
-------------------------------------------------------------------------------
CREATE TABLE SP.TRANS
(
  ID NUMBER,
  D DATE NOT NULL,
  BLOCK_ID NUMBER,
  BUH_ID NUMBER NOT NULL,
  S NUMBER DEFAULT 0 NOT NULL,
  N NUMBER DEFAULT 0 NOT NULL,
  A_DEBET NUMBER,
  C_DEBET NUMBER NOT NULL,
  A_CREDIT NUMBER,
  C_CREDIT NUMBER NOT NULL,
  MACRO NUMBER,
  COMMENTS VARCHAR2(4000) NOT NULL,
  VALIDATED DATE,
  M_DATE DATE NOT NULL,
  M_USER VARCHAR2(60) NOT NULL,
  CONSTRAINT PK_TRANS PRIMARY KEY (ID),
  CONSTRAINT REF_TRANS_TO_BUH
    FOREIGN KEY (BUH_ID)
    REFERENCES SP.MODELS (ID),
  CONSTRAINT REF_TRANS_TO_A_DEBET
    FOREIGN KEY (A_DEBET)
    REFERENCES SP.MODEL_OBJECTS (ID),
  CONSTRAINT REF_TRANS_TO_C_DEBET
    FOREIGN KEY (C_DEBET)
    REFERENCES SP.MODEL_OBJECTS (ID),
  CONSTRAINT REF_TRANS_TO_A_CREDIT
    FOREIGN KEY (A_CREDIT)
    REFERENCES SP.MODEL_OBJECTS (ID),
  CONSTRAINT REF_TRANS_TO_C_CREDIT
    FOREIGN KEY (C_CREDIT)
    REFERENCES SP.MODEL_OBJECTS (ID),
  CONSTRAINT REF_TRANS_TO_MACRO
    FOREIGN KEY (MACRO)
    REFERENCES SP.OBJECTS (ID)
);

--CREATE UNIQUE INDEX SP.TRANS ON SP.TRANS (UPPER(NAME));

COMMENT ON TABLE SP.TRANS IS 'Список операций (транзакций).';

COMMENT ON COLUMN SP.TRANS.ID IS 'Идентификатор операции.';
COMMENT ON COLUMN SP.TRANS.D IS 'Дата проведения  транзакции. Как правило эта дата не совпадает с датой занесения операции.';
COMMENT ON COLUMN SP.TRANS.BLOCK_ID IS 'Идентификатор блока операций. Несколько операций можно объединить в логический блок.';
COMMENT ON COLUMN SP.TRANS.BUH_ID IS 'Идентификатор бухгалтерии. Идентификатор модели, содержащей план счетов для данной бухгалтерии.';
COMMENT ON COLUMN SP.TRANS.S IS 'Сумма операции.';
COMMENT ON COLUMN SP.TRANS.N IS 'Количество.';
COMMENT ON COLUMN SP.TRANS.A_DEBET IS 'Ссылка на статью дебета.';
COMMENT ON COLUMN SP.TRANS.C_DEBET IS 'Ссылка на контрагента дебета.';
COMMENT ON COLUMN SP.TRANS.A_CREDIT IS 'Ссылка на статью кредита.';
COMMENT ON COLUMN SP.TRANS.C_CREDIT IS 'Ссылка на контрагента кредита.';
COMMENT ON COLUMN SP.TRANS.MACRO IS 'Ссылка на макрооперацию, создавшую этот блок операций.';
COMMENT ON COLUMN SP.TRANS.COMMENTS IS 'Примечания к операции.';
COMMENT ON COLUMN SP.TRANS.VALIDATED IS 'Дата актуализации данного блока операций. Отличается от даты операции, если для актуализации необходимо предоставить документ: счет, акт ...';
COMMENT ON COLUMN SP.TRANS.M_DATE 
  IS 'Дата занесения или изменения данной операция в таблице.';
COMMENT ON COLUMN SP.TRANS.M_USER 
  IS 'Пользователь создавший модель или изменивший операцию.';

--INSERT INTO SP.TRANS VALUES(0,....
--  to_date('05-01-2014','dd-mm-yyyy'), 'SP');

CREATE GLOBAL TEMPORARY TABLE SP.INSERTED_TRANS
(  
  NEW_ID NUMBER,
  NEW_D DATE,
  NEW_BLOCK_ID NUMBER,
  NEW_BUH_ID NUMBER,
  NEW_S NUMBER,
  NEW_N NUMBER,
  NEW_A_DEBET NUMBER,
  NEW_C_DEBET NUMBER,
  NEW_A_CREDIT NUMBER,
  NEW_C_CREDIT NUMBER,
  NEW_MACRO NUMBER,
  NEW_COMMENTS VARCHAR2(4000),
  NEW_VALIDATED DATE,
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;

COMMENT ON TABLE SP.INSERTED_TRANS
  IS 'Временная таблица, содержащая перечень добавленных записей.';

CREATE GLOBAL TEMPORARY TABLE SP.UPDATED_TRANS
(
  NEW_ID NUMBER,
  NEW_D DATE,
  NEW_BLOCK_ID NUMBER,
  NEW_BUH_ID NUMBER,
  NEW_S NUMBER,
  NEW_N NUMBER,
  NEW_A_DEBET NUMBER,
  NEW_C_DEBET NUMBER,
  NEW_A_CREDIT NUMBER,
  NEW_C_CREDIT NUMBER,
  NEW_MACRO NUMBER,
  NEW_COMMENTS VARCHAR2(4000),
  NEW_VALIDATED DATE,
  NEW_M_DATE DATE,
  NEW_M_USER VARCHAR2(60),
  OLD_ID NUMBER,
  OLD_D DATE,
  OLD_BLOCK_ID NUMBER,
  OLD_BUH_ID NUMBER,
  OLD_S NUMBER,
  OLD_N NUMBER,
  OLD_A_DEBET NUMBER,
  OLD_C_DEBET NUMBER,
  OLD_A_CREDIT NUMBER,
  OLD_C_CREDIT NUMBER,
  OLD_MACRO NUMBER,
  OLD_COMMENTS VARCHAR2(4000),
  OLD_VALIDATED DATE,
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;
COMMENT ON TABLE SP.UPDATED_TRANS
  IS 'Временная таблица, содержащая перечень изменённых записей.';
  
CREATE GLOBAL TEMPORARY TABLE SP.DELETED_TRANS
(
  OLD_ID NUMBER,
  OLD_D DATE,
  OLD_BLOCK_ID NUMBER,
  OLD_BUH_ID NUMBER,
  OLD_S NUMBER,
  OLD_N NUMBER,
  OLD_A_DEBET NUMBER,
  OLD_C_DEBET NUMBER,
  OLD_A_CREDIT NUMBER,
  OLD_C_CREDIT NUMBER,
  OLD_MACRO NUMBER,
  OLD_COMMENTS VARCHAR2(4000),
  OLD_VALIDATED DATE,
  OLD_M_DATE DATE,
  OLD_M_USER VARCHAR2(60)
)
ON COMMIT DELETE ROWS;
COMMENT ON TABLE SP.DELETED_TRANS
  IS 'Временная таблица, содержащая перечень удалённых записей.';


-- Оборот. 
CREATE GLOBAL TEMPORARY TABLE SP.OBOROT
(
  ID NUMBER,
  D DATE,
  BLOCK_ID NUMBER,
  S_DEBET NUMBER,
  S_CREDIT NUMBER,
  S_SALDO NUMBER,
  N_DEBET NUMBER,
  N_CREDIT NUMBER,
  N_SALDO NUMBER,
  ACCOUNT NUMBER,
  ACCOUNT_NAME VARCHAR2(4000),
  ACCOUNT_FULL_NAME VARCHAR2(4000),
  ACCOUNT_NUMBER_NAME VARCHAR2(4000),
  CONTRACTOR NUMBER,
  CONTRACTOR_NAME VARCHAR2(4000),
  MACRO NUMBER,
  MACRO_NAME VARCHAR2(4000),
  COMMENTS VARCHAR2(4000),
  VALIDATED DATE,
  MODIFIED VARCHAR2(128),
  M_DATE DATE,
  M_USER VARCHAR2(60)
)
ON COMMIT PRESERVE ROWS;

COMMENT ON TABLE SP.OBOROT
  IS 'Временная таблица, содержащая перечень операций по какому либо счёту или субсчёту с рассчитанным значением сальдо полсе каждой операции. Таблица используется для просмотра операций по какому либо счёту.';

COMMENT ON COLUMN SP.OBOROT.ID IS 'Идентификатор операции.';
COMMENT ON COLUMN SP.OBOROT.D IS 'Дата операции.';
COMMENT ON COLUMN SP.OBOROT.BLOCK_ID IS 'Идентификатор блока операций, которому принадлежит данная операция.';
COMMENT ON COLUMN SP.OBOROT.S_DEBET IS 'Сумма дебета. или ноль для кредитовых операций.';
COMMENT ON COLUMN SP.OBOROT.S_CREDIT IS 'Сумма кредита или ноль для дебетовых операций.';
COMMENT ON COLUMN SP.OBOROT.S_SALDO IS 'Исходящее сальдо (после завершения текущей операции).';
COMMENT ON COLUMN SP.OBOROT.N_DEBET IS 'Дебет количества или ноль, если количество кредитуется.';
COMMENT ON COLUMN SP.OBOROT.N_CREDIT IS 'Кредит количества или ноль, если количество дебетуется.';
COMMENT ON COLUMN SP.OBOROT.N_SALDO IS 'Исходящее сальдо по количеству (после завершения текущей операции).';
COMMENT ON COLUMN SP.OBOROT.ACCOUNT IS 'Ссылка на корреспондирующий счёт для данной операции.';
COMMENT ON COLUMN SP.OBOROT.ACCOUNT_NAME IS 'Имя объекта - корреспондирующего счёта.';
COMMENT ON COLUMN SP.OBOROT.ACCOUNT_FULL_NAME IS 'Полное имя коррю счёта - полный путь объекта счёта от корня модели содержащей план счетов бухгалтерии, которой принадлежит операция.';
COMMENT ON COLUMN SP.OBOROT.ACCOUNT_NUMBER_NAME IS 'Путь объекта счёта, но записанный при помощи перечисления номеров, а не имён родительских счетов. См. комментарий к полю "ACCOUNT_NAME"';
COMMENT ON COLUMN SP.OBOROT.CONTRACTOR IS 'Ссылка на контрагента аналитического учёта.';
COMMENT ON COLUMN SP.OBOROT.CONTRACTOR_NAME IS 'Имя объекта контрагента аналитицеского учёта.';
COMMENT ON COLUMN SP.OBOROT.MACRO IS 'Ссылка на макрооперацию, создавшую эту транзакцию.';
COMMENT ON COLUMN SP.OBOROT.MACRO_NAME IS 'Полное имя макрооперации, создавшей эту транзакцию.';
COMMENT ON COLUMN SP.OBOROT.COMMENTS IS 'Примечания к транзакции.';
COMMENT ON COLUMN SP.OBOROT.VALIDATED IS 'Дата актуализации.';
COMMENT ON COLUMN SP.OBOROT.MODIFIED IS 'Признак изменения записи во временной таблице. Поле содержит строковое значение типа modified.';
COMMENT ON COLUMN SP.OBOROT.M_DATE 
  IS 'Дата занесения или изменения данной операция в таблице.';
COMMENT ON COLUMN SP.OBOROT.M_USER 
  IS 'Пользователь создавший модель или изменивший операцию.';

-- Документы транзакций.
CREATE GLOBAL TEMPORARY TABLE SP.TRANS_DOC_S
(
  TRANS_ID NUMBER,
  BLOCK_ID NUMBER,
  DOC_ID NUMBER
)
ON COMMIT PRESERVE ROWS;

COMMENT ON TABLE SP.TRANS_DOC_S
  IS 'Временная таблица, содержащая перечень документов, прикреплённых к каждой операции.';

-- Баланс.
CREATE GLOBAL TEMPORARY TABLE SP.BALANS
(
  ACCOUNT_ID NUMBER,
  ACCOUNT_NAME VARCHAR2(4000),
  ACCOUNT_NUMBER NUMBER(5),
  CONTRACTOR NUMBER,
  CONTRACTOR_NAME VARCHAR2(4000),
  PARENT_ACCOUNT NUMBER,
  S_DEBET NUMBER,
  S_CREDIT NUMBER,
  S_SALDO_IN NUMBER,
  S_SALDO_OUT NUMBER,
  N_DEBET NUMBER,
  N_CREDIT NUMBER,
  N_SALDO_IN NUMBER,
  N_SALDO_OUT NUMBER
)
ON COMMIT PRESERVE ROWS;

COMMENT ON TABLE SP.BALANS
  IS 'Временная таблица, содержащая дерево счетов с рассчитанным значением оборота и сальдо по каждому счёту и контрагенту.';

COMMENT ON COLUMN SP.BALANS.ACCOUNT_ID IS 'Ссылка на счёт.';
COMMENT ON COLUMN SP.BALANS.ACCOUNT_NAME IS 'Имя объекта - счёта.';
COMMENT ON COLUMN SP.BALANS.ACCOUNT_NUMBER IS 'Значение свойства "номер счёта" для данного объекта счёт.';
COMMENT ON COLUMN SP.BALANS.CONTRACTOR IS 'Ссылка на контрагента аналитического учёта.';
COMMENT ON COLUMN SP.BALANS.CONTRACTOR_NAME IS 'Имя объекта контрагента аналитицеского учёта.';
COMMENT ON COLUMN SP.BALANS.PARENT_ACCOUNT IS 'Ссылка на счёт, субщётом которого является данный счёт.';
COMMENT ON COLUMN SP.BALANS.S_DEBET IS 'Деньги. Оборот по дебету.';
COMMENT ON COLUMN SP.BALANS.S_CREDIT IS 'Деньги. Оборот по кредиту.';
COMMENT ON COLUMN SP.BALANS.S_SALDO_IN IS 'Деньги. Входящее сальдо.';
COMMENT ON COLUMN SP.BALANS.S_SALDO_OUT IS 'Деньги. Исходящее сальдо.';
COMMENT ON COLUMN SP.BALANS.N_DEBET IS 'Количество. Оборот по дебету.';
COMMENT ON COLUMN SP.BALANS.N_CREDIT IS 'Количество. Оборот по кредиту.';
COMMENT ON COLUMN SP.BALANS.N_SALDO_IN IS 'Количество. Входящее сальдо.';
COMMENT ON COLUMN SP.BALANS.N_SALDO_OUT IS 'Количество. Исходящее сальдо.';

-- end of file
  