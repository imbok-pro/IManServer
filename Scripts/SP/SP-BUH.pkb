CREATE OR REPLACE PACKAGE BODY SP.BUH
-- BUH package body
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 26.08.2014
-- update 
AS

-------------------------------------------------------------------------------
FUNCTION CurBuhName return VARCHAR2
is
begin
  return null;
end CurBuhName;  

-------------------------------------------------------------------------------
FUNCTION CurBuh return NUMBER
is
begin
  return null;
end CurBuh;  

-------------------------------------------------------------------------------
PROCEDURE Turnover(Account in NUMBER, CONTRACTOR in NUMBER, 
                   DATE_IN in DATE, DATE_OUT in DATE,
                   VALID IN BOOLEAN default true)
is
begin
  return;
end Turnover;  

-------------------------------------------------------------------------------
PROCEDURE BALANCE_LIST(DATE_IN in DATE, DATE_OUT in DATE,
                       VALID IN BOOLEAN default true)
is
begin
  return;
end BALANCE_LIST; 
 
END BUH;
/
