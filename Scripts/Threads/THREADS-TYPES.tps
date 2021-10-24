-- Threads for ORACLE
-- by Nikolai Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 11.11.2006
-- update 29.01.2016  
--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE THREADS.TNUMBERs 
/* Набор чисел.*/
/* THREADS-TYPES.tps*/
IS TABLE OF NUMBER 
                   ');
END;
/
GRANT EXECUTE ON THREADS.TNUMBERs to public;
CREATE OR REPLACE PUBLIC SYNONYM TNUMBERS for THREADS.TNUMBERs;
/
--
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE THREADS.THREAD_REC
/* THREADS-TYPES.tps*/
/* Данный тип использует потоковая фунция, в запросах предоставляющих
потоки текущей сессии.*/
AS OBJECT
(
/* Идентификатор потока.*/
ID NUMBER,
/* Идентификатор демона (JOB), в котором запущен поток.*/
JobID NUMBER, 
/* Базовое имя трубы */
PipeName VARCHAR2(128), 
/* Количество строк принимаемых за один опрос состояния. */
BufSize NUMBER,  
/* Идентификатор состояния потока.*/
StateID NUMBER,           
/* Состояние потока.*/
State VARCHAR2(100),           
/* % выполнения.*/
PrBar NUMBER,						 
/* Время присвоения значения.*/
Moment DATE,           
/* Сообщение потока.*/
Mess VARCHAR2(256),    
/* Сообщение об ошибке Оракла, возникшей в потоке.*/
ERR VARCHAR2(3000),     
/* Признак отладки.*/
FlagDebug VARCHAR2(50),  
/* Признак неявного потока.*/
isImplicit VARCHAR2(50),
/* Конструктор пустой записи.*/
CONSTRUCTOR FUNCTION THREAD_REC 
RETURN SELF AS RESULT
);
/
GRANT EXECUTE ON THREADS.THREAD_REC TO PUBLIC;
--
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE('
CREATE OR REPLACE TYPE THREADS.TTHREADS 
/* Набор состояний потока.*/
/* THREADS-TYPES.tps*/
IS TABLE OF THREADS.THREAD_REC
                   ');
END;
/
GRANT EXECUTE ON THREADS.TTHREADS to public;
