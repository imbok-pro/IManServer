CREATE OR REPLACE PACKAGE BODY SP.TRANSLIT
-- TRANSLIT package body
--
-- Транслитерация русского языка латинским алфавитом 
--
-- by PF
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 2021-03-23
-- update 2021-03-26
AS

Type AA_Dict Is Table Of Varchar2(8) Index By Varchar2(2);

SimpleDict AA_Dict;

--==============================================================================
-- Инициализация словаря для упрощённой транслитерации с русского на латинский
Procedure SimpleDictInit
As

Begin
  SimpleDict('а'):='a';
  SimpleDict('б'):='b';
  SimpleDict('в'):='v';
  SimpleDict('г'):='g';
  SimpleDict('д'):='d';
  SimpleDict('е'):='e';
  SimpleDict('ё'):='yo';
  SimpleDict('ж'):='zh';
  SimpleDict('з'):='z';
  SimpleDict('и'):='i';
  SimpleDict('й'):='j';
  SimpleDict('к'):='k';
  SimpleDict('л'):='l';
  SimpleDict('м'):='m';
  SimpleDict('н'):='n';
  SimpleDict('о'):='o';
  SimpleDict('п'):='p';
  SimpleDict('р'):='r';
  SimpleDict('с'):='s';
  SimpleDict('т'):='t';
  SimpleDict('у'):='u';
  SimpleDict('ф'):='f';
  SimpleDict('х'):='x';
  SimpleDict('ц'):='c';
  SimpleDict('ч'):='ch';
  SimpleDict('ш'):='sh';
  SimpleDict('щ'):='shh';
  SimpleDict('ъ'):='''''';  --Два апострофа
  SimpleDict('ы'):='y';
  SimpleDict('ь'):='''';  --один апостроф
  SimpleDict('э'):='e';
  SimpleDict('ю'):='yu';
  SimpleDict('я'):='ya';
  
  SimpleDict('А'):='A';
  SimpleDict('Б'):='B';
  SimpleDict('В'):='V';
  SimpleDict('Г'):='G';
  SimpleDict('Д'):='D';
  SimpleDict('Е'):='E';
  SimpleDict('Ё'):='YO';
  SimpleDict('Ж'):='ZH';
  SimpleDict('З'):='Z';
  SimpleDict('И'):='I';
  SimpleDict('Й'):='J';
  SimpleDict('К'):='K';
  SimpleDict('Л'):='L';
  SimpleDict('М'):='M';
  SimpleDict('Н'):='N';
  SimpleDict('О'):='O';
  SimpleDict('П'):='P';
  SimpleDict('Р'):='R';
  SimpleDict('С'):='S';
  SimpleDict('Т'):='T';
  SimpleDict('У'):='U';
  SimpleDict('Ф'):='F';
  SimpleDict('Х'):='X';
  SimpleDict('Ц'):='C';
  SimpleDict('Ч'):='CH';
  SimpleDict('Ш'):='SH';
  SimpleDict('Щ'):='SHH';
  SimpleDict('Ъ'):='''''';  --Два апострофа
  SimpleDict('Ы'):='Y';
  SimpleDict('Ь'):='''';  --один апостроф
  SimpleDict('Э'):='E';
  SimpleDict('Ю'):='YU';
  SimpleDict('Я'):='YA';

End SimpleDictInit;
--==============================================================================
-- Упрощённая транслитерация русского письма латинским алфавитом 
-- В соответствии с ГОСТ Р 7.0.34-2014
-- Меняет русскую букву на латинское буквосочетсние, 
-- остальные символы оставляет как есть.
FUNCTION TransSimpleChar(Char$ In Varchar2) return Varchar2
is
  rv Varchar2(4000);
begin
  return SimpleDict(Char$);
Exception When Others Then
  Return Char$;
end TransSimpleChar;  

--==============================================================================
-- Упрощенная транслитерация русского письма латинским алфавитом 
-- В соответствии с ГОСТ Р 7.0.34-2014
-- Все русские буквы заменяет латинскими буквосочетсниями, 
-- остальные символы оставляет как есть.
FUNCTION TransSimple(Str$ In Varchar2) return Varchar2
is
  rv Varchar2(4000);
  r# CLOB;
  iLen# BINARY_INTEGER;
begin
  iLen#:=LENGTH(Str$);
  If iLen#<1 Then
    Return rv;
  End If;

  DBMS_LOB.CREATETEMPORARY(r#, cache => false, dur => DBMS_LOB.CALL );
  
  For i in 1..iLen# Loop
    DBMS_Lob.append(r#,TransSimpleChar(SUBSTR(Str$,i,1)));
  End Loop;
  rv:=TO_CHAR(SUBSTR(r#,1,4000)); 
  --DBMS_LOB.CLOSE(r#);
  return rv;
end TransSimple;  

--==============================================================================
Begin
  --Инициализация словаря для упрощённой транслитерации с русского на латинский.
  SimpleDictInit; 
END TRANSLIT;
/
