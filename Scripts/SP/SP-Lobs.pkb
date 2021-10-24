CREATE OR REPLACE PACKAGE BODY SP.Lobs
-- Lobs package body
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 08.03.2021
-- update 10.03.2021 14.03.2021 27.06.2021-28.06.2021 01.07.2021-04.07.2021
--        15.09.2021
AS

PROCEDURE testLob(V in SP.TVALUE)
is
tmpS VARCHAR2(1000);
tmpN NUMBER;
begin 
  tmpS := null;
  if V.N is not null then 
    select count(*) into tmpN from SP.LOB_S where ID = V.N; 
    if tmpN = 0 then 
      raise_application_error(-20030,'Lob '||to_char(V.N)||' not found! ');
    else 
      select GUID into tmpS from SP.LOB_S where ID = V.N;
    end if; 
  end if; 
  if V.S is not null then 
    select count(*) into tmpN from SP.LOB_S where GUID = V.S; 
    if tmpN = 0 then 
      raise_application_error(-20030,'Lob '||V.N||' not found! ');
    end if;
    if (tmpS is not null) and (V.S != tmpS) then
      raise_application_error(-20030,'Lob field V.N'||V.N||' point out GUID '||
      tmpS||' whitch differ from V.S '||V.S||'! ');
    end if;
  end if;
end testLob;

-------------------------------------------------------------------------------
FUNCTION L2Str(V in SP.TVALUE) return VARCHAR2
is
  tmpVar VARCHAR2(100);
  L_tag NUMBER;
  L_type NUMBER;
  BType SP.TVALUE; 
begin
  if (V.N is null) and (V.S is null) then return ''; end if;
  if V.N is not null then
    select GUID, TAG, nvl(F_TYPE,0) into tmpVar, L_tag, L_type 
    from sp.Lob_s where V.N = ID;
  elsif V.S is not null then
    select GUID, TAG, nvl(F_TYPE,0) into tmpVar, L_tag, L_type
    from sp.Lob_s where V.S = GUID;
  end if;
  BType := SP.TVALUE(G.TFileType,L_type);
  return case
           when (L_tag is null) and (L_type = 0) then
             tmpVar
           when L_type = 0 then
             to_char(L_tag)||'||'||tmpVar
           when L_tag is null then
             tmpVar||'|'||to_.str(BType)
         else
           to_char(L_tag)||'||'||tmpVar||'|'||to_.str(BType)
         end;
exception
  when others then
    d('Ссылка на файл не найдена! '||SQLERRM, 'SP.Lobs.L2Str');
    raise_application_error(-20033,
      'SP.Lobs.L2Str. Ссылка на файл не найдена!');
end L2Str;

-------------------------------------------------------------------------------
FUNCTION BL2Str(V in SP.TVALUE) return VARCHAR2
is
begin
  if V is null then return ''; end if;
  if V.t != G.TBlob then
    raise_application_error(-20033,
      'SP.Lobs.BL2Str. Тип значения '||SP.to_strtype(V.t)
      ||' не является ссылкой на файл!');
  end if;
  return L2Str(V);
exception
  when others then
    raise_application_error(-20033,
      'SP.Lobs.BL2Str. Ссылка на файл не найдена!');
end BL2Str;

-------------------------------------------------------------------------------
PROCEDURE S2BLob(S in VARCHAR2, V in out nocopy SP.TVALUE)
is
SS SP.TSTRINGS;
B_GUID VARCHAR2(1000);
L_tag NUMBER;
L_type NUMBER;
begin
  V := SP.TVALUE(G.TBlob);
  if S is null then return; end if;
  SS := SP.STRINGS_from_STRING(S=>S, Delim=>'\|', delEmpStr => false);
  case SS.Count
    when 1 then -- только GUID
      B_GUID := S;
      L_tag := null;
      L_type := null; 
    when 2 then -- только GUID и тип
      B_GUID := Ss(ss.first);
      L_tag := null;
      L_type := SP.TVALUE(G.TFileType,Ss(ss.last)).N; 
    when 3 then -- только GUID и TAG
      B_GUID := Ss(ss.first+2);
      L_tag := to_Char(Ss(ss.first));
      L_type := null; 
    when 4 then 
      B_GUID := Ss(ss.first+2);
      L_tag := to_Char(Ss(ss.first));
      L_type := SP.TVALUE(G.TFileType,Ss(ss.last)).N; 
  end case;  
  V.S := B_GUID;
  V.X := L_tag;
  V.Y := L_type;
  if V.S is not null then
    select ID, TAG, F_TYPE  into V.N, V.X, V.Y from SP.LOB_S 
      where GUID = B_GUID;
  end if;    
  return;
exception
  when others then
    d('Ссылка на файл не найдена!'
      ||'BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE(),
       'ERROR in SP.Lobs.S2BLob');      
    raise_application_error(-20033,
      'SP.Lobs.S2BLob. Ссылка на файл не найдена!');
end S2BLob;

-------------------------------------------------------------------------------
FUNCTION CL2Str(V in SP.TVALUE) return VARCHAR2
is
begin
  if V is null then return ''; end if;
  if V.t != G.TClob then
    raise_application_error(-20033,
      'SP.Lobs.CL2Str. Тип значения '||SP.to_strtype(V.t)
      ||' не является ссылкой на текстовый файл!');
  end if;
  return L2Str(V);
exception
  when others then
    d('Ссылка на файл не найдена!'
      ||'BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE(),
       'ERROR in SP.Lobs.S2BLob');      
    raise_application_error(-20033,
      'SP.Lobs.CL2Str. Ссылка на файл не найдена!');
end CL2Str;

-------------------------------------------------------------------------------
PROCEDURE S2CLob(S in VARCHAR2, V in out nocopy SP.TVALUE)
is
B_GUID VARCHAR2(1000);
SS SP.TSTRINGS;
L_tag NUMBER;
L_type NUMBER;
begin
  V := SP.TVALUE(G.TClob);
  if S is null then return; end if;
  SS := SP.STRINGS_from_STRING(S=>S, Delim=>'\|', delEmpStr => false);
  case SS.Count
    when 1 then -- только GUID
      B_GUID := S;
      L_tag := null;
      L_type := null; 
    when 2 then -- только GUID и тип
      B_GUID := Ss(ss.first);
      L_tag := null;
      L_type := SP.TVALUE(G.TFileType,Ss(ss.last)).N; 
    when 3 then -- только GUID и TAG
      B_GUID := Ss(ss.first+2);
      L_tag := to_Char(Ss(ss.first));
      L_type := null; 
    when 4 then 
      B_GUID := Ss(ss.first+2);
      L_tag := to_Char(Ss(ss.first));
      L_type := SP.TVALUE(G.TFileType,Ss(ss.last)).N; 
  end case;  
  V.S := B_GUID;
  V.X := L_tag;
  V.Y := L_type;
  if V.S is not null then
    select ID, TAG, F_TYPE  into V.N, V.X, V.Y from SP.LOB_S 
      where GUID = B_GUID;
  end if;    
  return;
exception
  when others then
    d('Ссылка на файл не найдена!'
      ||'BACKTRACE '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE(),
       'ERROR in SP.Lobs.S2CLob');      
    raise_application_error(-20033,
      'SP.Lobs.S2CLob. Ссылка на файл не найдена!');     
end S2CLob;

-------------------------------------------------------------------------------
FUNCTION LStore(BinFile in BLOB,
                tag in NUMBER default null,
                FileType in SP.TVALUE default null)
return SP.TVALUE
is
V SP.TVALUE;
begin
  
  V := SP.TVALUE(G.TBlob);
  V.X := tag;
  V.Y := case when FileType is null then null else FileType.N end;
  if BinFile is null then
    return V; 
  end if;
  insert into SP.Lob_s (F_BLOB, TAG, F_TYPE) values (BinFile, V.X, V.Y) 
    returning ID, GUID into V.N, V.S;  
  return V;
end LStore;

-------------------------------------------------------------------------------
FUNCTION LStore(TxtFile in CLOB,
                tag in NUMBER default null,
                FileType in SP.TVALUE default null)
return SP.TVALUE
is
V SP.TVALUE;
begin
  V := SP.TVALUE(G.TClob);
  V.X := tag;
  V.Y := case when FileType is null then null else FileType.N end;
  if TxtFile is null then
    return V; 
  end if;
  insert into SP.Lob_s (F_CLOB, TAG, F_TYPE) values (TxtFile, V.X, V.Y) 
    returning ID, GUID into V.N, V.S;  
  return V;
end LStore;

-------------------------------------------------------------------------------
FUNCTION getFile(FileRef in SP.TMPAR, D in DATE default null) return BLOB
is
  tmpVar NUMBER;
  BlobID NUMBER;
  tmpFile BLOB;
  p SP.TSPAR;
begin
  if FileRef is null then return null; end if;
  if FileRef.VAL is null then return null; end if;
  -- Проверяем, что тип параметра - BLOB
  if FileRef.Val.T !=  g.TBlob then
    raise_application_error(-20033,
      'SP.Lobs.getFile. Параметр '||FileRef.Name||' имеет тип '
      ||SP.to_StrTYPE(FileRef.Val.T)||', а не BLOB!');       
  end if;
  if FileRef.VAL.N is null and FileRef.VAL.S is null then return null; end if;
  if FileRef.VAL.N is null then 
    select ID into BlobID from SP.LOB_S where GUID = FileRef.Val.S;
  else
    BlobID := FileRef.Val.N;
  end if;
  -- Получаем роль объекта.
  select USING_ROLE into tmpVar from SP.MODEL_OBJECTS 
    where ID = FileRef.MO_ID;
  -- Если у пользователя есть роль на чтение объекта, то читаем файл с учётом
  -- даты.   
  if SP.HasUserRoleID(tmpVar) then
    -- Если дата null, то читаем файл,
    if D is null then
      select F_BLOB into tmpFile from SP.LOB_S where ID = BlobID;
      return tmpFile;
    -- иначе находим идентификатор файла из истории значений параметра
    else
      p := SP.TSPAR(FileRef.MO_ID, FileRef.Name, D);
      if p.VAL.N is null and p.VAL.S is null then return null; end if;
      if p.VAL.N is null then 
        select ID into BlobID from SP.LOB_S where GUID = p.Val.S;
      else
        BlobID := p.Val.N;
      end if;
      select F_BLOB into tmpFile from SP.LOB_S where ID = BlobID;
      return tmpFile;
    end if;
  else
    raise_application_error(-20033,
      'SP.Lobs.getFile. Привилегий недостаточно!');     
  end if;
--!! описать ошибку!!!    
end getFile;

-------------------------------------------------------------------------------
FUNCTION getTxtFile(FileRef in SP.TMPAR, D in DATE default null) return CLOB
is
  ClobID NUMBER;
  tmpVar NUMBER;
  tmpFile CLOB;
  p SP.TSPAR;
begin
  if FileRef is null then return null; end if;
  if FileRef.VAL is null then return null; end if;
  -- Проверяем, что тип параметра - CLOB
  if FileRef.Val.T !=  g.TClob then
    raise_application_error(-20033,
      'SP.Lobs.getFile. Параметр '||FileRef.Name||' имеет тип '
      ||SP.to_StrTYPE(FileRef.Val.T)||', а не CLOB!');       
  end if;
  if FileRef.VAL.N is null and FileRef.VAL.S is null then return null; end if;
  if FileRef.VAL.N is null then 
    select ID into ClobID from SP.LOB_S where GUID = FileRef.Val.S;
  else
    ClobID := FileRef.Val.N;
  end if;
  -- Получаем роль объекта.
  select USING_ROLE into tmpVar from SP.MODEL_OBJECTS 
    where ID = FileRef.MO_ID;
  -- Если у пользователя есть роль на чтение объекта, то читаем файл с учётом
  -- даты.   
  if SP.HasUserRoleID(tmpVar) then
    -- Если дата null, то читаем файл,
    if D is null then
      select F_CLOB into tmpFile from SP.LOB_S where ID = ClobID;
      return tmpFile;
    -- иначе находим идентификатор файла из истории значений параметра
    else
      p := SP.TSPAR(FileRef.MO_ID, FileRef.Name, D);
      if p.VAL.N is null and p.VAL.S is null then return null; end if;
      if p.VAL.N is null then 
        select ID into ClobID from SP.LOB_S where GUID = p.Val.S;
      else
        ClobID := p.Val.N;
      end if;
      select F_CLOB into tmpFile from SP.LOB_S where ID = ClobID;
      return tmpFile;
    end if;
  else
    raise_application_error(-20033,
      'SP.Lobs.getFile. Привилегий недостаточно!');     
  end if;  
end getTxtFile;

FUNCTION getFilebyRef(FileRef in SP.TMPAR, N in NUMBER) return BLOB
is
  tmpVar NUMBER;
  pN NUMBER;
  BlobID NUMBER;
  tmpFile BLOB;
  p SP.TSPAR;
begin
  pN := N;
  if FileRef is null then return null; end if;
  if FileRef.VAL is null then return null; end if;
  -- Проверяем, что тип параметра - BLOB
  if FileRef.Val.T !=  g.TBlob then
    raise_application_error(-20033,
      'SP.Lobs.getFilebyRef. Параметр '||FileRef.Name||' имеет тип '
      ||SP.to_StrTYPE(FileRef.Val.T)||', а не BLOB!');       
  end if;
  if FileRef.VAL.N is null and FileRef.VAL.S is null then return null; end if;
  if FileRef.VAL.N is null then 
    select ID into BlobID from SP.LOB_S where GUID = FileRef.Val.S;
  else
    BlobID := FileRef.Val.N;
  end if;
  -- Получаем роль объекта.
  select USING_ROLE into tmpVar from SP.MODEL_OBJECTS 
    where ID = FileRef.MO_ID;
  -- Если у пользователя есть роль на чтение объекта, то читаем файл с учётом
  -- даты.   
  if SP.HasUserRoleID(tmpVar) then
    p := SP.TSPAR(FileRef);
    select count(*) into tmpVar from table(p.Get_Values()) where N = pN;
    if tmpVar > 0  then
      select F_BLOB into tmpFile from SP.LOB_S where ID = pN;
      return tmpFile;
    else 
      raise_application_error(-20033,
      'SP.Lobs.getFilebyRef. Отсутствует файл с ID = '||to_char(pN)||'!');     
    end if;
  else
    raise_application_error(-20033,
      'SP.Lobs.getFilebyRef. Привилегий недостаточно!');     
  end if;  
end getFilebyRef;

FUNCTION getTxtFilebyRef(FileRef in SP.TMPAR, N in NUMBER) return CLOB
is
  tmpVar NUMBER;
  pN NUMBER;
  ClobID NUMBER;
  tmpFile CLOB;
  p SP.TSPAR;
begin
  pN := N;
  if FileRef is null then return null; end if;
  if FileRef.VAL is null then return null; end if;
  -- Проверяем, что тип параметра - CLOB
  if FileRef.Val.T !=  g.TClob then
    raise_application_error(-20033,
      'SP.Lobs.getTxtFilebyRef. Параметр '||FileRef.Name||' имеет тип '
      ||SP.to_StrTYPE(FileRef.Val.T)||', а не CLOB!');       
  end if;
  if FileRef.VAL.N is null and FileRef.VAL.S is null then return null; end if;
  if FileRef.VAL.N is null then 
    select ID into ClobID from SP.LOB_S where GUID = FileRef.Val.S;
  else
    ClobID := FileRef.Val.N;
  end if;
  -- Получаем роль объекта.
  select USING_ROLE into tmpVar from SP.MODEL_OBJECTS 
    where ID = FileRef.MO_ID;
  -- Если у пользователя есть роль на чтение объекта, то читаем файл с учётом
  -- даты.   
  if SP.HasUserRoleID(tmpVar) then
    p := SP.TSPAR(FileRef);
    select count(*) into tmpVar from table(p.Get_Values()) where N = pN;
    if tmpVar > 0  then
      select F_CLOB into tmpFile from SP.LOB_S where ID = pN;
      return tmpFile;
    else 
      raise_application_error(-20033,
      'SP.Lobs.getTxtFilebyRef. Отсутствует файл с ID = '||to_char(pN)||'!');     
    end if;
  else
    raise_application_error(-20033,
      'SP.Lobs.getTxtFilbyRef. Привилегий недостаточно!');     
  end if;  
end getTxtFilebyRef;

FUNCTION getFilebyTag(FileRef in SP.TMPAR, TAG in NUMBER,
                      D in DATE default null) 
return BLOB
is
  BlobID NUMBER;
  tmpVar NUMBER;
  tmpFile BLOB;
  p SP.TSPAR;
  pD DATE;
begin
  if FileRef is null then return null; end if;
  if FileRef.VAL is null then return null; end if;
  pD := D;
  -- Проверяем, что тип параметра - BLOB
  if FileRef.Val.T !=  g.TBlob then
    raise_application_error(-20033,
      'SP.Lobs.getFilebyTag. Параметр '||FileRef.Name||' имеет тип '
      ||SP.to_StrTYPE(FileRef.Val.T)||', а не BLOB!');       
  end if;
  -- Получаем роль объекта.
  select USING_ROLE into tmpVar from SP.MODEL_OBJECTS 
    where ID = FileRef.MO_ID;
  -- Если у пользователя есть роль на чтение объекта, то читаем файл с учётом
  -- даты.   
  if SP.HasUserRoleID(tmpVar) then
      p := SP.TSPAR(FileRef);
      for B in
        ( 
          select N,S  
            from table(p.GET_VALUES())
            where X = TAG
              and MDATE <= nvl(D, sysdate + 1000) 
            order by MDATE  
         )
      loop 
        if B.N is null and B.S is null then return null; end if;
        if B.N is null then 
          select ID into BlobID from SP.LOB_S where GUID = B.S;
        else
          BlobID := B.N;   
        end if; 
        if BlobID is not null then
          select F_BLOB into tmpFile from SP.LOB_S where ID = BlobID;
          return tmpFile;
        end if;
      end loop; 
      return null;
  else
    raise_application_error(-20033,
      'SP.Lobs.getFilebyTag. Привилегий недостаточно!');     
  end if;  
end getFilebyTag;

FUNCTION getTxtFilebyTag(FileRef in SP.TMPAR, TAG in NUMBER,
                         D in DATE default null)
return CLOB
is
  ClobID NUMBER;
  tmpVar NUMBER;
  tmpFile CLOB;
  p SP.TSPAR;
begin
  if FileRef is null then return null; end if;
  if FileRef.VAL is null then return null; end if;
  -- Проверяем, что тип параметра - CLOB
  if FileRef.Val.T !=  g.TClob then
    raise_application_error(-20033,
      'SP.Lobs.getTxtFilebyTag. Параметр '||FileRef.Name||' имеет тип '
      ||SP.to_StrTYPE(FileRef.Val.T)||', а не CLOB!');       
  end if;
  -- Получаем роль объекта.
  select USING_ROLE into tmpVar from SP.MODEL_OBJECTS 
    where ID = FileRef.MO_ID;
  -- Если у пользователя есть роль на чтение объекта, то читаем файл с учётом
  -- даты.   
  if SP.HasUserRoleID(tmpVar) then
    p := SP.TSPAR(FileRef);
    for B in
      ( 
        select N,S 
          from table(p.GET_VALUES())
          where X = TAG
            and MDATE <= nvl(D, sysdate + 1000) 
          order by MDATE  
       )
    loop 
      if B.N is null and B.S is null then return null; end if;
      if B.N is null then 
        select ID into ClobID from SP.LOB_S where GUID = B.S;
      else
        ClobID := B.N;  
      end if; 
      if ClobID is not null then
        select F_CLOB into tmpFile from SP.LOB_S where ID = ClobID;
        return tmpFile;
      end if;
    end loop; 
    return null;
  else
    raise_application_error(-20033,
      'SP.Lobs.getTxtFilebyTag. Привилегий недостаточно!');     
  end if;  
end getTxtFilebyTag;


PROCEDURE refresh_LOB(Lob in out nocopy SP.TVALUE)
is
begin
  -- Проверяем тип значения Lob
  if Lob is null then return; end if;
  -- Проверяем, что тип параметра - CLOB
  if Lob.T not in (g.TClob, g.TBlob) then
    raise_application_error(-20033,
      'SP.Lobs.refresh_LOB. Значение Lob  имеет тип '
      ||SP.to_StrTYPE(Lob.T)||', а не Clob или Blob!');       
  end if;
  -- Обновляем значения полей из таблицы LOB_S
  if Lob.S is not null then 
    select ID, TAG, F_TYPE into Lob.N, Lob.X, Lob .Y 
    from SP.LOB_S where GUID = Lob.S;
  elsif Lob.N is not null then
    select GUID, TAG, F_TYPE into Lob.S, Lob.X, Lob .Y 
    from SP.LOB_S where ID = Lob.N;
  else
    Lob.N := null;
    Lob.S := null;
    Lob.X := null;
    Lob.Y := 0;
  end if;
null;
end refresh_LOB;

PROCEDURE updateTYPE(Lob in out nocopy SP.TVALUE,
                     F_Type in SP.TVALUE default null)
is
new_TYPE NUMBER;
lobID NUMBER;
begin
  if Lob is null then return; end if;
  -- Проверяем тип значения Lob
  if Lob.T not in (g.TClob, g.TBlob) then
    raise_application_error(-20033,
      'SP.Lobs.updateTYPE. Значение Lob  имеет тип '
      ||SP.to_StrTYPE(Lob.T)||', а не Clob или Blob!');       
  end if;
  if F_Type is null then 
    new_TYPE := Lob.Y;
  else  
    -- Проверяем тип значения F_Type
    if F_TYPE.T != g.TFileType then
      raise_application_error(-20033,
        'SP.Lobs.updateTYPE. Значение F_TYPE  имеет тип '
        ||SP.to_StrTYPE(F_TYPE.T)||', а не FileType!');       
    end if;
    new_TYPE := F_Type.N;
  end if;  
  -- Обновляем таблицу LOB_S
  if Lob.N is null then 
    select ID into lobID from SP.LOB_S where GUID = Lob.S;
  else
    lobID := Lob.N;
  end if;
  update SP.LOB_S set F_TYPE = new_TYPE where ID = lobID;
end updateTYPE;                    

PROCEDURE updateTAG(Lob in out nocopy SP.TVALUE, TAG in NUMBER default null)
is
new_TAG NUMBER;
lobID NUMBER;
begin
  -- Проверяем тип значения Lob
  if Lob.T not in (g.TClob, g.TBlob) then
    raise_application_error(-20033,
      'SP.Lobs.updateTAG. Значение Lob  имеет тип '
      ||SP.to_StrTYPE(Lob.T)||', а не Clob или Blob!');       
  end if;
  -- Обновляем таблицу LOB_S
  if TAG is null then 
    new_TAG := Lob.X;
  else  
    new_TAG := TAG;
  end if;  
  -- Обновляем таблицу LOB_S
  if Lob.N is null then 
    select ID into lobID from SP.LOB_S where GUID = Lob.S;
  else
    lobID := Lob.N;
  end if;
  update SP.LOB_S set TAG = new_TAG where ID = lobID;
end updateTAG;

PROCEDURE Delete_not_Used
is
begin
null;
end Delete_not_Used;

PROCEDURE refresh_all_LOBs
is
begin
null;
end refresh_all_LOBs;

End Lobs;
/
