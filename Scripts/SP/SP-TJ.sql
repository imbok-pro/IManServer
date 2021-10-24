-- Таблицы TJ (Total Jornal) 
-- by Azarov SP-TJ.sql 
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 12.02.2018
-- update 08.06.2018 27.03.2019

--truncate TABLE "SP"."TJ_CABLES" 
--drop  TABLE "SP"."TJ_CABLES" 

  CREATE GLOBAL TEMPORARY TABLE "SP"."TJ_CABLES" 
   (
    "CID" NUMBER PRIMARY KEY, 
	"CNAME" VARCHAR2(4000 BYTE),     
    "DEVICE1ID" NUMBER, 
    "DEVICE2ID" NUMBER,   
    "DEVICE1"   VARCHAR2(256 BYTE), 
    "DEVICE2"   VARCHAR2(256 BYTE),    
    "PLACE1"    VARCHAR2(256 BYTE), 
    "PLACE2"    VARCHAR2(256 BYTE), 
    "SYSTEMID"  NUMBER, 
    "SYSTEM"    VARCHAR2(4000 BYTE), 
    "№"        INTEGER    
    --"WORKID" NUMBER, 
	--"WORKNAME" VARCHAR2(4000 BYTE)    
    )
  ON COMMIT PRESERVE ROWS;

COMMENT ON TABLE "SP"."TJ_CABLES" IS 'Сводные данные по кабелям TJ - кеш для запросов.';

COMMENT ON COLUMN SP.TJ_CABLES.CID is 'Уникальный идентификатор кабеля в базе данных.';
COMMENT ON COLUMN SP.TJ_CABLES.CNAME is 'Имя кабеля в базе данных.';

COMMENT ON COLUMN SP.TJ_CABLES.DEVICE1ID is 'Уникальный идентификатор левого устройства (в базе данных), от которого (или от пина которого) идет кабель.';
COMMENT ON COLUMN SP.TJ_CABLES.DEVICE2ID is 'Уникальный идентификатор правого устройства (в базе данных), к которому (или к пину которого) идет кабель.';
COMMENT ON COLUMN SP.TJ_CABLES.DEVICE1 is 'Имя левого устройства (в базе данных), от которого (или от пина которого) идет кабель.';
COMMENT ON COLUMN SP.TJ_CABLES.DEVICE2 is 'Имя правого устройства (в базе данных), к которому (или к пину которого) идет кабель.';
COMMENT ON COLUMN SP.TJ_CABLES.PLACE1 is 'Имя места левого устройства.';
COMMENT ON COLUMN SP.TJ_CABLES.PLACE2 is 'Имя места правого устройства.';

COMMENT ON COLUMN SP.TJ_CABLES.SYSTEMID is 'Уникальный идентификатор системы, к которой относится кабель.';
COMMENT ON COLUMN SP.TJ_CABLES.SYSTEM is 'Имя системы, к которой относится кабель.';

COMMENT ON COLUMN SP.TJ_CABLES."№" is 'Порядковый номер кабеля, полученный при загрузке из кабельного журнала (из транспортной формы Excel). Может использоваться при сортировке';

--COMMENT ON COLUMN SP.TJ_CABLES.WORKID is 'Уникальный идентификатор работы в базе данных. Работа - узел объектов модели TJ.';
--COMMENT ON COLUMN SP.TJ_CABLES.WORKNAME is 'Имя работы в базе данных.';

GRANT SELECT ON SP.TJ_CABLES to public;
