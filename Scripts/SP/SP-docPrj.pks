CREATE OR REPLACE PACKAGE SP.docPrj IS
  ------------------------------------------------------------------------
  -- docPrj package
  -- by Gemba Sergey
  -- create 03.09.2014
  -- update 03.09.2014
  ------------------------------------------------------------------------
  -- ‘ункци€ выбирает значение параметра
  --   pi_mod_obj_id - id модели (поле sp.models.id)
  --   pi_param_name - название параметра объекта модели
  FUNCTION get_param_value(pi_mod_obj_id IN NUMBER,
                           pi_param_name IN VARCHAR2) RETURN VARCHAR2;

  -- ‘ункци€ возвращает регул€рное выражение дл€ шаблона документа в целом
  --   pi_doc_prj_id - id модели (поле sp.models.id )
  --   return - регул€рное выражение дл€ шаблона заголовка документа
  FUNCTION build_regexp(pi_doc_prj_id IN NUMBER,
                        pi_model_name IN VARCHAR2 DEFAULT 'DocFlow||Documents') 
  RETURN VARCHAR2;

  -- функци€ используетс€ при распознании заголовка документа,
  --  pi_doc_header - заголовок документа
  --  po_text_out - выходной параметр,  сообщение о ходе выполнени€ процедуры:
  --        в случае успешного определени€ соответстви€ шаблону - выводитс€ наименование этого шаблона,
  --        иначе выдаетс€ ошибка
  PROCEDURE find_doc_template(pi_doc_header IN VARCHAR2, po_text_out OUT VARCHAR2, pi_model_name IN VARCHAR2 DEFAULT 'DocFlow||Documents');
END;
/
