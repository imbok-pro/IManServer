CREATE OR REPLACE PACKAGE SP.Lobs
-- Lobs package
-- by Nikolay Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 08.03.2021
-- update 10.03.2021 14.03.2021 01.07.2021-03.07.2021 15.07.2021

AS

-- Проверка Clob и Blob
PROCEDURE testLob(V in SP.TVALUE);

-- Проверка существования и получение TAG||GUID|TYPE файла.
FUNCTION BL2Str(V in SP.TVALUE) return VARCHAR2;

-- Получение значения типа ссылки на файл по его GUID.
-- Строка может быть вида TAG||GUID|TYPE
-- При получении ссылки TAG и GUID игнорируются и всегда читаются из таблицы
-- Lobs
PROCEDURE S2BLob(S in VARCHAR2, V in out nocopy SP.TVALUE);

-- Проверка существования и получение TAG||GUID|TYPE текстового файла.
FUNCTION CL2Str(V in SP.TVALUE) return VARCHAR2;

-- Получение значения типа ссылки на текстовый файл по его GUID.
-- Строка может быть вида TAG||GUID|TYPE. 
-- При получении ссылки TAG и GUID игнорируются и могут отличаться от
-- значений таблицы SP.LOB_S
PROCEDURE S2CLob(S in VARCHAR2, V in out nocopy SP.TVALUE);

-- Запись в базу нового файла, и получение ссылки на этот файл.
-- При этом поле X может содержать TAG файла,
-- a поле Y - идентифакатор его типа(TFileType). 
FUNCTION LStore(BinFile in BLOB,
                tag in NUMBER default null,
                FileType in SP.TVALUE default null)
return SP.TVALUE;

-- Запись в базу нового текстового файла, и получение ссылки на этот файл.
-- При этом поле X может содержать TAG файла,
-- a поле Y - идентифакатор его типа(TFileType). 
FUNCTION LStore(TxtFile in CLOB,
                tag in NUMBER default null,
                FileType in SP.TVALUE default null)
return SP.TVALUE;

-- Чтение файла по ссылке.
-- У пользователя должна быть роль на использования объекта,
-- которому принадлежит параметр.
-- Если задана дата, то ссылка на файл будет взята из истории параметра.
FUNCTION getFile(FileRef in SP.TMPAR, D in DATE default null) return BLOB;

-- Чтение текстового файла по ссылке.
-- У пользователя должна быть роль на использования объекта,
-- которому принадлежит параметр
-- Если задана дата, то ссылка на файл будет взята из истории параметра.
FUNCTION getTxtFile(FileRef in SP.TMPAR, D in DATE default null) return CLOB;

-- Чтение файла по ссылке.
-- У пользователя должна быть роль на использования объекта,
-- которому принадлежит параметр.
-- Будет выбран конкретный файл из истории или из параметра при совпадении 
-- VAL.N и N, будет возвращён null иначе. 
FUNCTION getFilebyRef(FileRef in SP.TMPAR, N in NUMBER) return BLOB;

-- Чтение текстового файла по ссылке.
-- У пользователя должна быть роль на использования объекта,
-- которому принадлежит параметр
-- Будет выбран конкретный файл из истории или из параметра при совпадении 
-- VAL.N и N, будет возвращён null иначе. 
FUNCTION getTxtFilebyRef(FileRef in SP.TMPAR, N in NUMBER) return CLOB;

-- Чтение файла по ссылке.
-- У пользователя должна быть роль на использования объекта,
-- которому принадлежит параметр.
-- Если не задан tag, то ссылка на файл будет взята из параметра.
-- Если задана дата, то ссылка на файл будет взята из истории параметра,
-- но с учётом tag.
FUNCTION getFilebyTag(FileRef in SP.TMPAR, TAG in NUMBER,
                      D in DATE default null) 
return BLOB; 

-- Чтение текстового файла по ссылке.
-- У пользователя должна быть роль на использования объекта,
-- которому принадлежит параметр
-- Если не задан tag, то ссылка на файл будет взята из параметра.
-- Если задана дата, то ссылка на файл будет взята из истории параметра,
-- но с учётом tag.
FUNCTION getTxtFilebyTag(FileRef in SP.TMPAR, TAG in NUMBER,
                         D in DATE default null)
return CLOB;

-- Обновление полей TAG(X) и F_TYPE(Y) в ссылке на значения из таблицы LOB_S
PROCEDURE refresh_LOB(Lob in out nocopy SP.TVALUE);

-- Обновление всех значений параметров типов Blob и Clob. Приведение их полей 
-- N, X и Y в соответствии с таблицей Lob_s.
PROCEDURE refresh_all_LOBs;

-- Изменение типа файла в таблице LOB_S. Если параметр F_Type null,
-- то используем значение из Lob. 
PROCEDURE updateTYPE(Lob in out nocopy SP.TVALUE,
                     F_Type in SP.TVALUE default null);

-- Изменение тега файла в таблице LOB_S. Если параметр TAG null,
-- то используем значение из Lob. 
PROCEDURE updateTAG(Lob in out nocopy SP.TVALUE, TAG in NUMBER default null);

-- Удаление файлов, на которые нет ссылок.
PROCEDURE Delete_not_Used;

end Lobs;
/
