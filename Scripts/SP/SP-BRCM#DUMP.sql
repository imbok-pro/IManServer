-- Вспомогательные временные таблицы для пакета BRCM#DUMP 
-- file: SP-BRCM#DUMP.sql  
-- by PF  
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2019-09-16
-- update 2019-09-25 2019-10-31:2019-11-05 2021-04-20

  CREATE GLOBAL TEMPORARY TABLE "SP"."BRCM_EQP" 
   (	
    EQP_RID Number NOT NULL, 
    EQP_RNAME Varchar2(128 BYTE),
    EQP_EID Varchar2(128 BYTE),
    EQP_NAME Varchar2(128 BYTE),
    EQP_DESIGN_FILE varchar2(40 BYTE),
    TV_X Number,
    TV_Y Number,
    TV_Z Number,
    UX_X Number,
    UX_Y Number,
    UX_Z Number,
    UY_X Number,
    UY_Y Number,
    UY_Z Number,
    UZ_X Number,
    UZ_Y Number,
    UZ_Z Number,
    CONSTRAINT eqp_pk PRIMARY KEY (EQP_RID)    
   ) ON COMMIT PRESERVE ROWS ;

   COMMENT ON COLUMN "SP"."BRCM_EQP"."EQP_RID" 
   IS 'Уникальный идентификатор записи (Record) устройства в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."EQP_RNAME" 
   IS 'Уникальное имя записи (RecordXXX) устройства в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."EQP_EID" 
   IS 'Уникальный идентификатор (совместно с EQP_DESIGN_FILE) элемента (ELEMENT_ID) устройства в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."EQP_NAME" 
   IS 'Неуникальное (de facto) имя устройства (KKS-код) в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."EQP_DESIGN_FILE" 
   IS 'GUID файла исходных данных дампа.';
   
   COMMENT ON COLUMN "SP"."BRCM_EQP"."TV_X" 
   IS 'Абсцисса вектора сдвига (HP_trans_vec) в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."TV_Y" 
   IS 'Ордината вектора сдвига (HP_trans_vec) в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."TV_Z" 
   IS 'Аппликата вектора сдвига (HP_trans_vec) в дампе.';
   
   COMMENT ON COLUMN "SP"."BRCM_EQP"."UX_X" 
   IS 'Абсцисса единичного вектора направления X (HP_unit_vec_x) в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."UX_Y" 
   IS 'Ордината единичного вектора направления X (HP_unit_vec_x) в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."UX_Z" 
   IS 'Аппликата единичного вектора направления X (HP_unit_vec_x) в дампе.';

   COMMENT ON COLUMN "SP"."BRCM_EQP"."UY_X" 
   IS 'Абсцисса единичного вектора направления Y (HP_unit_vec_y) в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."UY_Y" 
   IS 'Ордината единичного вектора направления Y (HP_unit_vec_y) в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."UY_Z" 
   IS 'Аппликата единичного вектора направления Y (HP_unit_vec_y) в дампе.';
   
   COMMENT ON COLUMN "SP"."BRCM_EQP"."UZ_X" 
   IS 'Абсцисса единичного вектора направления Z (HP_unit_vec_z) в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."UZ_Y" 
   IS 'Ордината единичного вектора направления Z (HP_unit_vec_z) в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."UZ_Z" 
   IS 'Аппликата единичного вектора направления Z (HP_unit_vec_z) в дампе.';

   COMMENT ON TABLE "SP"."BRCM_EQP"  
   IS 'Устройства. Сводные данные для запросов.';
--------------------------------------------------------
--  DDL for Indexes
--------------------------------------------------------

  CREATE UNIQUE INDEX "SP"."BRCM_EQP_EID_DF" 
  ON "SP"."BRCM_EQP" ("EQP_EID","EQP_DESIGN_FILE") ;
--------------------------------------------------------
--  Constraints for Table BRCM_EQP
--------------------------------------------------------

  GRANT SELECT ON SP.BRCM_EQP to public;
  
--==============================================================================
  CREATE GLOBAL TEMPORARY TABLE "SP"."BRCM_RACEWAY" 
   (	
    RW_RID Number NOT NULL, 
    RW_RNAME Varchar2(128 BYTE),
    RW_EID Varchar2(128 BYTE),
    RW_DESIGN_FILE varchar2(40 BYTE),
    RW_CLASS Varchar2(128 BYTE),
    CONSTRAINT BRCM_RACEWAY_PK PRIMARY KEY (RW_RID)    
   ) ON COMMIT PRESERVE ROWS;
  
   COMMENT ON COLUMN "SP"."BRCM_RACEWAY"."RW_RID" 
   IS 'Уникальный идентификатор записи (Record) элемента RACEWAY в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_RACEWAY"."RW_RNAME" 
   IS 'Уникальное имя записи (RecordXXX) элемента RACEWAY в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_RACEWAY"."RW_EID" 
   IS 'Уникальный идентификатор элемента (ELEMENT_ID) элемента RACEWAY в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_RACEWAY"."RW_DESIGN_FILE"
   IS 'GUID файла исходных данных дампа.';

   COMMENT ON TABLE "SP"."BRCM_RACEWAY"  
   IS 'Элементы кабельных трасс (RACEWAY). Сводные данные для запросов.';
--------------------------------------------------------
--  DDL for Indexes
--------------------------------------------------------

  CREATE UNIQUE INDEX "SP"."BRCM_RW_EID_DESIGN" 
  ON "SP"."BRCM_RACEWAY" ("RW_EID","RW_DESIGN_FILE") ;

  GRANT SELECT ON SP.BRCM_RACEWAY to public;
--==============================================================================  

  CREATE GLOBAL TEMPORARY TABLE "SP"."BRCM_RLINE" 
   (	
    RL_RID Number NOT NULL,
    RL_RNAME Varchar2(128 BYTE), 
    RL_EID Varchar2(128 BYTE),
    RL_DESIGN_FILE varchar2(40 BYTE),
    "HP_catalog" varchar2(40 BYTE),
    "HP_system" varchar2(40 BYTE),
    "HP_variant" varchar2(40 BYTE),
    X1 Number, 
    Y1 Number, 
    Z1 Number, 
    X2 Number, 
    Y2 Number, 
    Z2 Number,
    LENGTH Number,  --Длина участка
    "HP_BendAngle" Varchar2(128 BYTE),
    "HP_BendRadius" Varchar2(128 BYTE),
    HP_RWID Varchar2(128 BYTE),
    -- наименование локального направления кабелепровода
    -- Обычно совпадает с HP_RWID, но для TEEs HP_RWID должна быть заменена на
    -- HP_RWID примыкающего элемента
    COURSE_NAME Varchar2(128 BYTE),
    SHELF_NUM Varchar2(40 BYTE),
    "HP_RWCategory" Varchar2(128 BYTE),
    "HP_RWCategory2" Varchar2(128 BYTE), 
    "HP_description" Varchar2(4000 BYTE),
    "HP_ec:GUID" varchar2(40 BYTE),
    "HP_fitting" varchar2(40 BYTE),
    RW_RID Number
   ) ON COMMIT PRESERVE ROWS ;

   COMMENT ON COLUMN "SP"."BRCM_RLINE"."RL_RID" 
   IS 'Уникальный идентификатор записи (Record) элемента RLINE в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_RLINE"."RL_RNAME" 
   IS 'Уникальное имя записи (RecordXXX) элемента RLINE в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_RLINE"."RL_EID" 
   IS 'Уникальный идентификатор элемента (ELEMENT_ID) элемента RLINE в дампе.';
   COMMENT ON COLUMN "SP"."BRCM_RLINE"."RL_DESIGN_FILE"
   IS 'GUID файла исходных данных дампа.';

   COMMENT ON COLUMN "SP"."BRCM_RLINE"."LENGTH" IS 'Длина участка.';

   COMMENT ON COLUMN "SP"."BRCM_RLINE"."COURSE_NAME"
   IS 'Hаименование локального направления кабелепровода. Обычно совпадает с HP_RWID, но для TEEs HP_RWID должна быть заменена на HP_RWID примыкающего элемента.';

   COMMENT ON COLUMN "SP"."BRCM_RLINE"."SHELF_NUM" IS 'Hомер полки.';

   COMMENT ON COLUMN "SP"."BRCM_RLINE"."RW_RID"
   IS 'Ссылка на соответствующий элемент RACEWAY';

   COMMENT ON TABLE "SP"."BRCM_RLINE"  
   IS 'Элементы Routing Lines. Сводные данные для запросов.';

--------------------------------------------------------
--  DDL for Indexes
--------------------------------------------------------

  CREATE UNIQUE INDEX "SP"."BRCM_RL_RID" ON "SP"."BRCM_RLINE" ("RL_RID") ;
  CREATE UNIQUE INDEX "SP"."BRCM_RL_EID_DESIGN" 
  ON "SP"."BRCM_RLINE" ("RL_EID","RL_DESIGN_FILE") ;
  
  CREATE INDEX "SP"."BRCM_RL_COURSE_NAME" ON "SP"."BRCM_RLINE" ("COURSE_NAME");
--------------------------------------------------------
--  Constraints for Table BRCM_EQP
--------------------------------------------------------

  ALTER TABLE "SP"."BRCM_RLINE" ADD PRIMARY KEY ("RL_RID") ENABLE;

  GRANT SELECT ON SP.BRCM_RLINE to public;

--==============================================================================  
  CREATE GLOBAL TEMPORARY TABLE "SP"."BRCM_ADJ" 
   (	
    RL_RID1 Number NOT NULL, 
    RL_RID2 Number NOT NULL,
    X Number NOT NULL,
    Y Number NOT NULL,
    Z Number NOT NULL,
    PARALLEL NUMBER(1,0) NOT NULL,
    CONSTRAINT rel_pk PRIMARY KEY (RL_RID1, RL_RID2)
   ) ON COMMIT PRESERVE ROWS ;
   
  COMMENT ON COLUMN "SP"."BRCM_ADJ"."RL_RID1" IS 
  'Ссылка на первичный элемент Routing Line. ';
   
  COMMENT ON COLUMN "SP"."BRCM_ADJ"."RL_RID2" IS 
  'Ссылка на смежный элемент Routing Line. ';

  COMMENT ON COLUMN "SP"."BRCM_ADJ"."X" IS 'Абсцисса точки смежности.';
  COMMENT ON COLUMN "SP"."BRCM_ADJ"."Y" IS 'Ордината точки смежности.';
  COMMENT ON COLUMN "SP"."BRCM_ADJ"."Z" IS 'Аппликата точки смежности.';
  COMMENT ON COLUMN "SP"."BRCM_ADJ"."PARALLEL" 
  IS '1 - RLINEs параллельны, 0 - в противном случае';

  COMMENT ON TABLE "SP"."BRCM_ADJ"  IS 'Матрица смежности RLINEs';

  GRANT SELECT ON SP.BRCM_ADJ to public;
  
--==============================================================================  
  CREATE GLOBAL TEMPORARY TABLE "SP"."BRCM_CABLE" 
   (	
    CBL_RID Number NOT NULL,
    CBL_RNAME Varchar2(128 BYTE) NOT NULL,
    "HP_CableNo" Varchar2(128 BYTE) NOT NULL,
    EQP_FROM_RID Number,
    EQP_TO_RID Number,
    START_RL_RID Number,
    "HP_VoltageLevel" Varchar2(128 BYTE),
    "HP_CableLength" Number,
    IS_VALID Number(1), 
    CONSTRAINT cbl_pk PRIMARY KEY (CBL_RID)
   ) ON COMMIT PRESERVE ROWS ;
    
    COMMENT ON COLUMN "SP"."BRCM_CABLE"."CBL_RID" IS 
    'Уникальный идентификатор обязательной записи (Record) о кабеле в дампе.';
    
    COMMENT ON COLUMN "SP"."BRCM_CABLE"."CBL_RNAME" IS 
    'Уникальное имя обязательной записи (RecordXXX) о кабеле в дампе.';
    
    COMMENT ON COLUMN "SP"."BRCM_CABLE"."HP_CableNo" IS 
    'Уникальное имя кабеля (код KKS).';
    
    COMMENT ON COLUMN "SP"."BRCM_CABLE"."EQP_FROM_RID" IS 
    'Ссылка на единицу оборудования (табл. BRCM_EQP), откуда прокладывается кабель.';
    
     COMMENT ON COLUMN "SP"."BRCM_CABLE"."EQP_TO_RID" IS 
    'Ссылка на единицу оборудования (табл. BRCM_EQP), куда прокладывается кабель.';
    
     COMMENT ON COLUMN "SP"."BRCM_CABLE"."START_RL_RID" IS 
    'Ссылка на элемент Routing Line (табл. BRCM_RLINE), откуда стартует кабель. ';
    
     COMMENT ON COLUMN "SP"."BRCM_CABLE"."HP_VoltageLevel" IS 
    'Класс цепи (CTRL, LV1, etc.).';
    
     COMMENT ON COLUMN "SP"."BRCM_CABLE"."HP_CableLength" IS 'Длина кабеля.';
     
     COMMENT ON COLUMN "SP"."BRCM_CABLE"."IS_VALID" IS 
    '1 - кабель корректно пролежен между устройствами. 0 - кабель некорректный.';
   
    COMMENT ON TABLE "SP"."BRCM_CABLE" IS 'Кабели. Сводные данные для запросов.';

--------------------------------------------------------
--  DDL for Indexes
--------------------------------------------------------
    CREATE UNIQUE INDEX "SP"."BRCM_CABLE_CableNo" 
    ON "SP"."BRCM_CABLE" ("HP_CableNo");
    
    GRANT SELECT ON SP.BRCM_CABLE to public;
--==============================================================================  
  CREATE GLOBAL TEMPORARY TABLE "SP"."BRCM_AREP" 
  (	
    AREP_RID Number NOT NULL,
    AREP_RNAME Varchar2(128 BYTE) NOT NULL,
    EQP_RID Number,
    EQP_MAX_DIST Number,
    EQP_FROM_X Number,
    EQP_FROM_Y Number,
    EQP_FROM_Z Number,
    CONSTRAINT arep_pk PRIMARY KEY (AREP_RID)
  );

    COMMENT ON COLUMN "SP"."BRCM_AREP"."AREP_RID" IS 
    'Уникальный идентификатор обязательной записи (Record) в дампе.';
    COMMENT ON COLUMN "SP"."BRCM_AREP"."AREP_RNAME" IS 
    'Уникальное имя обязательной записи (RecordXXX) в дампе.';

    COMMENT ON COLUMN "SP"."BRCM_AREP"."EQP_RID" IS 
    'Ссылка на единицу оборудования. Может быть NULL. Тогда все остальные поля - тоже NULL';

    COMMENT ON COLUMN "SP"."BRCM_AREP"."EQP_MAX_DIST" IS 
    'Максимальное расстояние в миллиметрах (от устройства(шкафа) ) до конца кабеля (параметр ...INT_CM_AREP/RecordXXX/...AREP_BIN_DATA/HP_MaxDistance).';

   COMMENT ON COLUMN "SP"."BRCM_AREP"."EQP_FROM_X" 
   IS 'Абсцисса точки привязки устройства в дампе (параметр ...INT_CM_AREP/RecordXXX/...AREP_BIN_DATA/HP_ObjectFromCoord1).';
   COMMENT ON COLUMN "SP"."BRCM_AREP"."EQP_FROM_Y" 
   IS 'Ордината точки привязки устройства в дампе (параметр ...INT_CM_AREP/RecordXXX/...AREP_BIN_DATA/HP_ObjectFromCoord1).';
   COMMENT ON COLUMN "SP"."BRCM_AREP"."EQP_FROM_Z" 
   IS 'Аппликата точки привязки устройства в дампе (параметр ...INT_CM_AREP/RecordXXX/...AREP_BIN_DATA/HP_ObjectFromCoord1).';

    COMMENT ON TABLE "SP"."BRCM_AREP" IS 'Equipment Reference Points?';
    
    GRANT SELECT ON SP.BRCM_AREP to public;

--==============================================================================  
  CREATE GLOBAL TEMPORARY TABLE "SP"."BRCM_CFC" 
   (	
    CFC_RID Number NOT NULL,
    CFC_RNAME Varchar2(128 BYTE) NOT NULL,
    CBL_RID Number,
    RL_RID Number,
    HP_CID Varchar2(128 BYTE),
    ORDINAL Number,
    CONSTRAINT cfc_pk PRIMARY KEY (CFC_RID)
   ) ON COMMIT PRESERVE ROWS ;
 
    COMMENT ON COLUMN "SP"."BRCM_CFC"."CFC_RID" IS 
    'Уникальный идентификатор обязательной записи (Record) в дампе.';
    COMMENT ON COLUMN "SP"."BRCM_CFC"."CFC_RNAME" IS 
    'Уникальное имя обязательной записи (RecordXXX) в дампе.';

    COMMENT ON COLUMN "SP"."BRCM_CFC"."CBL_RID" IS 'Ссылка на кабель.';

    COMMENT ON COLUMN "SP"."BRCM_CFC"."RL_RID" IS 
    'Ссылка на направляющую (Routing Line).';

    COMMENT ON COLUMN "SP"."BRCM_CFC"."HP_CID" IS '????';

    COMMENT ON COLUMN "SP"."BRCM_CFC"."ORDINAL" IS 
    'Порядковый номер элемента RLine в последовательности прокладки кабеля.';

    COMMENT ON TABLE "SP"."BRCM_CFC" IS 
    'Множество направляющих, вдоль которых проложен кабель. Cвязь многие ко многим направляющих и кабелей.';
    
    CREATE UNIQUE INDEX "SP"."BRCM_CFC_CBL_RL" 
    ON "SP"."BRCM_CFC" ("CBL_RID","RL_RID");
    
    GRANT SELECT ON SP.BRCM_AREP to public;
   