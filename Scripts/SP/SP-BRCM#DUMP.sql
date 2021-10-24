-- ��������������� ��������� ������� ��� ������ BRCM#DUMP 
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
   IS '���������� ������������� ������ (Record) ���������� � �����.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."EQP_RNAME" 
   IS '���������� ��� ������ (RecordXXX) ���������� � �����.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."EQP_EID" 
   IS '���������� ������������� (��������� � EQP_DESIGN_FILE) �������� (ELEMENT_ID) ���������� � �����.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."EQP_NAME" 
   IS '������������ (de facto) ��� ���������� (KKS-���) � �����.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."EQP_DESIGN_FILE" 
   IS 'GUID ����� �������� ������ �����.';
   
   COMMENT ON COLUMN "SP"."BRCM_EQP"."TV_X" 
   IS '�������� ������� ������ (HP_trans_vec) � �����.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."TV_Y" 
   IS '�������� ������� ������ (HP_trans_vec) � �����.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."TV_Z" 
   IS '��������� ������� ������ (HP_trans_vec) � �����.';
   
   COMMENT ON COLUMN "SP"."BRCM_EQP"."UX_X" 
   IS '�������� ���������� ������� ����������� X (HP_unit_vec_x) � �����.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."UX_Y" 
   IS '�������� ���������� ������� ����������� X (HP_unit_vec_x) � �����.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."UX_Z" 
   IS '��������� ���������� ������� ����������� X (HP_unit_vec_x) � �����.';

   COMMENT ON COLUMN "SP"."BRCM_EQP"."UY_X" 
   IS '�������� ���������� ������� ����������� Y (HP_unit_vec_y) � �����.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."UY_Y" 
   IS '�������� ���������� ������� ����������� Y (HP_unit_vec_y) � �����.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."UY_Z" 
   IS '��������� ���������� ������� ����������� Y (HP_unit_vec_y) � �����.';
   
   COMMENT ON COLUMN "SP"."BRCM_EQP"."UZ_X" 
   IS '�������� ���������� ������� ����������� Z (HP_unit_vec_z) � �����.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."UZ_Y" 
   IS '�������� ���������� ������� ����������� Z (HP_unit_vec_z) � �����.';
   COMMENT ON COLUMN "SP"."BRCM_EQP"."UZ_Z" 
   IS '��������� ���������� ������� ����������� Z (HP_unit_vec_z) � �����.';

   COMMENT ON TABLE "SP"."BRCM_EQP"  
   IS '����������. ������� ������ ��� ��������.';
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
   IS '���������� ������������� ������ (Record) �������� RACEWAY � �����.';
   COMMENT ON COLUMN "SP"."BRCM_RACEWAY"."RW_RNAME" 
   IS '���������� ��� ������ (RecordXXX) �������� RACEWAY � �����.';
   COMMENT ON COLUMN "SP"."BRCM_RACEWAY"."RW_EID" 
   IS '���������� ������������� �������� (ELEMENT_ID) �������� RACEWAY � �����.';
   COMMENT ON COLUMN "SP"."BRCM_RACEWAY"."RW_DESIGN_FILE"
   IS 'GUID ����� �������� ������ �����.';

   COMMENT ON TABLE "SP"."BRCM_RACEWAY"  
   IS '�������� ��������� ����� (RACEWAY). ������� ������ ��� ��������.';
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
    LENGTH Number,  --����� �������
    "HP_BendAngle" Varchar2(128 BYTE),
    "HP_BendRadius" Varchar2(128 BYTE),
    HP_RWID Varchar2(128 BYTE),
    -- ������������ ���������� ����������� �������������
    -- ������ ��������� � HP_RWID, �� ��� TEEs HP_RWID ������ ���� �������� ��
    -- HP_RWID ������������ ��������
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
   IS '���������� ������������� ������ (Record) �������� RLINE � �����.';
   COMMENT ON COLUMN "SP"."BRCM_RLINE"."RL_RNAME" 
   IS '���������� ��� ������ (RecordXXX) �������� RLINE � �����.';
   COMMENT ON COLUMN "SP"."BRCM_RLINE"."RL_EID" 
   IS '���������� ������������� �������� (ELEMENT_ID) �������� RLINE � �����.';
   COMMENT ON COLUMN "SP"."BRCM_RLINE"."RL_DESIGN_FILE"
   IS 'GUID ����� �������� ������ �����.';

   COMMENT ON COLUMN "SP"."BRCM_RLINE"."LENGTH" IS '����� �������.';

   COMMENT ON COLUMN "SP"."BRCM_RLINE"."COURSE_NAME"
   IS 'H����������� ���������� ����������� �������������. ������ ��������� � HP_RWID, �� ��� TEEs HP_RWID ������ ���� �������� �� HP_RWID ������������ ��������.';

   COMMENT ON COLUMN "SP"."BRCM_RLINE"."SHELF_NUM" IS 'H���� �����.';

   COMMENT ON COLUMN "SP"."BRCM_RLINE"."RW_RID"
   IS '������ �� ��������������� ������� RACEWAY';

   COMMENT ON TABLE "SP"."BRCM_RLINE"  
   IS '�������� Routing Lines. ������� ������ ��� ��������.';

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
  '������ �� ��������� ������� Routing Line. ';
   
  COMMENT ON COLUMN "SP"."BRCM_ADJ"."RL_RID2" IS 
  '������ �� ������� ������� Routing Line. ';

  COMMENT ON COLUMN "SP"."BRCM_ADJ"."X" IS '�������� ����� ���������.';
  COMMENT ON COLUMN "SP"."BRCM_ADJ"."Y" IS '�������� ����� ���������.';
  COMMENT ON COLUMN "SP"."BRCM_ADJ"."Z" IS '��������� ����� ���������.';
  COMMENT ON COLUMN "SP"."BRCM_ADJ"."PARALLEL" 
  IS '1 - RLINEs �����������, 0 - � ��������� ������';

  COMMENT ON TABLE "SP"."BRCM_ADJ"  IS '������� ��������� RLINEs';

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
    '���������� ������������� ������������ ������ (Record) � ������ � �����.';
    
    COMMENT ON COLUMN "SP"."BRCM_CABLE"."CBL_RNAME" IS 
    '���������� ��� ������������ ������ (RecordXXX) � ������ � �����.';
    
    COMMENT ON COLUMN "SP"."BRCM_CABLE"."HP_CableNo" IS 
    '���������� ��� ������ (��� KKS).';
    
    COMMENT ON COLUMN "SP"."BRCM_CABLE"."EQP_FROM_RID" IS 
    '������ �� ������� ������������ (����. BRCM_EQP), ������ �������������� ������.';
    
     COMMENT ON COLUMN "SP"."BRCM_CABLE"."EQP_TO_RID" IS 
    '������ �� ������� ������������ (����. BRCM_EQP), ���� �������������� ������.';
    
     COMMENT ON COLUMN "SP"."BRCM_CABLE"."START_RL_RID" IS 
    '������ �� ������� Routing Line (����. BRCM_RLINE), ������ �������� ������. ';
    
     COMMENT ON COLUMN "SP"."BRCM_CABLE"."HP_VoltageLevel" IS 
    '����� ���� (CTRL, LV1, etc.).';
    
     COMMENT ON COLUMN "SP"."BRCM_CABLE"."HP_CableLength" IS '����� ������.';
     
     COMMENT ON COLUMN "SP"."BRCM_CABLE"."IS_VALID" IS 
    '1 - ������ ��������� �������� ����� ������������. 0 - ������ ������������.';
   
    COMMENT ON TABLE "SP"."BRCM_CABLE" IS '������. ������� ������ ��� ��������.';

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
    '���������� ������������� ������������ ������ (Record) � �����.';
    COMMENT ON COLUMN "SP"."BRCM_AREP"."AREP_RNAME" IS 
    '���������� ��� ������������ ������ (RecordXXX) � �����.';

    COMMENT ON COLUMN "SP"."BRCM_AREP"."EQP_RID" IS 
    '������ �� ������� ������������. ����� ���� NULL. ����� ��� ��������� ���� - ���� NULL';

    COMMENT ON COLUMN "SP"."BRCM_AREP"."EQP_MAX_DIST" IS 
    '������������ ���������� � ����������� (�� ����������(�����) ) �� ����� ������ (�������� ...INT_CM_AREP/RecordXXX/...AREP_BIN_DATA/HP_MaxDistance).';

   COMMENT ON COLUMN "SP"."BRCM_AREP"."EQP_FROM_X" 
   IS '�������� ����� �������� ���������� � ����� (�������� ...INT_CM_AREP/RecordXXX/...AREP_BIN_DATA/HP_ObjectFromCoord1).';
   COMMENT ON COLUMN "SP"."BRCM_AREP"."EQP_FROM_Y" 
   IS '�������� ����� �������� ���������� � ����� (�������� ...INT_CM_AREP/RecordXXX/...AREP_BIN_DATA/HP_ObjectFromCoord1).';
   COMMENT ON COLUMN "SP"."BRCM_AREP"."EQP_FROM_Z" 
   IS '��������� ����� �������� ���������� � ����� (�������� ...INT_CM_AREP/RecordXXX/...AREP_BIN_DATA/HP_ObjectFromCoord1).';

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
    '���������� ������������� ������������ ������ (Record) � �����.';
    COMMENT ON COLUMN "SP"."BRCM_CFC"."CFC_RNAME" IS 
    '���������� ��� ������������ ������ (RecordXXX) � �����.';

    COMMENT ON COLUMN "SP"."BRCM_CFC"."CBL_RID" IS '������ �� ������.';

    COMMENT ON COLUMN "SP"."BRCM_CFC"."RL_RID" IS 
    '������ �� ������������ (Routing Line).';

    COMMENT ON COLUMN "SP"."BRCM_CFC"."HP_CID" IS '????';

    COMMENT ON COLUMN "SP"."BRCM_CFC"."ORDINAL" IS 
    '���������� ����� �������� RLine � ������������������ ��������� ������.';

    COMMENT ON TABLE "SP"."BRCM_CFC" IS 
    '��������� ������������, ����� ������� �������� ������. C���� ������ �� ������ ������������ � �������.';
    
    CREATE UNIQUE INDEX "SP"."BRCM_CFC_CBL_RL" 
    ON "SP"."BRCM_CFC" ("CBL_RID","RL_RID");
    
    GRANT SELECT ON SP.BRCM_AREP to public;
   