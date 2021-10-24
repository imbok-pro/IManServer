CREATE OR REPLACE PACKAGE SP.docPrjGen IS
  ------------------------------------------------------------------------
  -- docPrjGen package body
  -- by Gemba Sergey
  -- пакет используется для генерации скриптов - создающих макры для работы с заголовками проектных документов
  -- create 03.09.2014
  -- update 03.09.2014
  ------------------------------------------------------------------------

  EOL CONSTANT CHAR(1) := CHR(13);

  -- Функция используется для генерации скрипта: макра для создания заголовка документа,
  --   скрипт генерится на основе данных модели (шаблоны заголовков документов)
  --   pi_marka_name - название макры
  --   pi_doc_prj_id - объекта модели - шаблона заголовка документа (#DocPrjHeaders)
  FUNCTION gen_marka_create_doc_header
  (
    pi_marka_name IN VARCHAR2,
    pi_doc_prj_id IN NUMBER,
    pi_model_name IN VARCHAR2 DEFAULT 'DocFlow||Documents'
  ) RETURN sp.tsource
    PIPELINED;

  -- Функция используется для генерации скрипта - типа справочника, на основе данных модели справочников шаблонов заголовков документов(#CodeSectorRefs)
  --   pi_ref_name - название справочника (параметр NAME объекта #CodeSectorRefs)
  FUNCTION gen_type_for_ref(pi_ref_name IN VARCHAR2, pi_model_name IN VARCHAR2 DEFAULT 'DocFlow||Documents') RETURN sp.tsource
  PIPELINED;
END;
/
