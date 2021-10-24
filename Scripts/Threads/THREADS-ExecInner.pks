CREATE or REPLACE PACKAGE THREADS.ExecI
-- KARBUILDER Threads.ExecInner PACKAGE
-- by Nikolai Krasilnikov
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 11.11.2006
-- update 12.08.2007 24.12.2015 01.02.2016 03.02.2016 24.02.2016 
-- Этот пакет внутренний и гранты никому не раздаются
AUTHID CURRENT_USER
AS
-- Массив используется в основной сессиии.
Pars THREADS.Exec.TPars;

-- В режиме отладки эта переменная содержит текущий исполняемый идентификатор
-- потока.
DebugThreadID PLS_INTEGER;

-- Процедуры и функции работают внутри демона.
-- В режиме отладки не используются.
PROCEDURE ExecThread(PipeInName IN VARCHAR2);
PROCEDURE SendStateI(PrBar in NUMBER,Mess IN VARCHAR2);
PROCEDURE SendErrorI(Err IN VARCHAR2);
FUNCTION GetSignal return VARCHAR2;
end ExecI;
/

