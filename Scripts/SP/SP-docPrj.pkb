CREATE OR REPLACE PACKAGE BODY SP.docPrj IS
  ------------------------------------------------------------------------
  -- docPrj package body
  -- by Gemba Sergey
  -- пакет используется для работы с заголовками проектных документов
  -- create 03.09.2014
  -- update 03.09.2014
  ------------------------------------------------------------------------

  -- Функция выбирает значение параметра
  --   pi_mod_obj_id - id модели (поле sp.models.id)
  --   pi_param_name - название параметра объекта модели

  FUNCTION get_param_value(pi_mod_obj_id IN NUMBER,
                           pi_param_name IN VARCHAR2) RETURN VARCHAR2 IS
    v_res VARCHAR2(4000);
  BEGIN

    SELECT s.VAL
      INTO v_res
      FROM sp.v_model_object_pars s
     WHERE s.MOD_OBJ_ID = pi_mod_obj_id
       AND s.PARAM_NAME = pi_param_name;

    RETURN v_res;

  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;

    WHEN dup_val_on_index THEN
      RETURN NULL;
  END;

  -- Функция возвращает регулярное выражение для шаблона документа в целом
  --   pi_doc_prj_id - id модели (поле sp.models.id )
  --   return - регулярное выражение для шаблона заголовка документа

  FUNCTION build_regexp(pi_doc_prj_id IN NUMBER,
                        pi_model_name IN VARCHAR2 DEFAULT 'DocFlow||Documents') 
    RETURN VARCHAR2 IS
    v_formula_all VARCHAR2(4000) := '';
  BEGIN

    FOR i IN (SELECT m.*, to_number(get_param_value(m.ID, 'CS_SEQ')) seq
                FROM sp.v_model_objects m
               WHERE m.model_name = pi_model_name
                 AND m.catalog_name = '#CodeSectors'
                 AND m.PARENT_MOD_OBJ_ID = pi_doc_prj_id
               ORDER BY seq)
    LOOP

      v_formula_all := v_formula_all || '\' ||
                       get_param_value(i.id, 'DELIM') || '(' ||
                       get_param_value(i.id, 'FORMULA') || ')';

    END LOOP;

    dbms_output.put_line(v_formula_all);

    RETURN v_formula_all;

  END;

  FUNCTION get_regexp2doc_header(pi_doc_prj_id IN VARCHAR2) RETURN VARCHAR2 IS
    v_formula_all VARCHAR2(4000) := '';
  BEGIN

    dbms_output.put_line(v_formula_all);

    RETURN v_formula_all;

  END;

  -- Разбор заголовка документа на сектора, и проверка значений секторов на соответствие справочникам
  PROCEDURE check_refs4doc_template(pi_doc_prj_id  IN NUMBER,
                                    pi_doc_header  IN VARCHAR2,
                                    pi_reg_formula IN VARCHAR2,
                                    po_error_text  OUT VARCHAR2,
                                    pi_model_name  IN VARCHAR2 DEFAULT 'DocFlow||Documents') IS

    v_doc_header  VARCHAR2(4000) := pi_doc_header;
    v_reg_formula VARCHAR2(4000) := pi_reg_formula;
    v_res         VARCHAR2(4000);
    v_ref_code    VARCHAR2(4000);

  BEGIN

    po_error_text := '';

    FOR i IN (SELECT t.*,
                     sq.n n_seq,
                     rf.s ref_obj,
                     dl.s delim,
                     fr.s formula,
                     rq.n is_req
                FROM sp.v_model_objects     t,
                     sp.v_model_object_pars sq,
                     sp.v_model_object_pars rf,
                     sp.v_model_object_pars dl,
                     sp.v_model_object_pars fr,
                     sp.v_model_object_pars rq
               WHERE t.ID = sq.MOD_OBJ_ID
                 AND t.ID = rf.MOD_OBJ_ID
                 AND t.ID = dl.MOD_OBJ_ID
                 AND t.ID = fr.MOD_OBJ_ID
                 AND t.ID = rq.MOD_OBJ_ID
                 AND t.MODEL_NAME = pi_model_name
                 AND t.CATALOG_NAME = '#CodeSectors'
                 AND t.PARENT_MOD_OBJ_ID = pi_doc_prj_id
                 AND sq.PARAM_NAME = 'CS_SEQ'
                 AND dl.PARAM_NAME = 'DELIM'
                 AND rf.PARAM_NAME = 'REF'
                 AND fr.PARAM_NAME = 'FORMULA'
                 AND rq.PARAM_NAME = 'IS_REQ'
               ORDER BY n_seq)
    LOOP

      SELECT regexp_replace(v_doc_header, v_reg_formula, '\1')
        INTO v_res
        FROM dual;

      IF v_res IS NOT NULL THEN
        SELECT substr(v_doc_header, length(i.delim || v_res) + 1)
          INTO v_doc_header
          FROM dual;

        SELECT substr(v_reg_formula,
                      length(nvl2(i.delim, '\' || i.delim, NULL) || '(' ||
                             i.formula || ')') + 1)
          INTO v_reg_formula
          FROM dual;

      ELSE
        IF i.is_req = 0 THEN
          SELECT substr(v_reg_formula,
                        length(nvl2(i.delim, '\' || i.delim, NULL) || '(' ||
                               i.formula || ')') + 1)
            INTO v_reg_formula
            FROM dual;
        ELSE
          po_error_text := po_error_text||chr(13)||'Ошибка при разборе выражения ' || i.formula ||
                           ' для шаблона:' || pi_doc_prj_id;
          --          DBMS_OUTPUT.put_line('ERROR: '||v_error_text);
        END IF;
      END IF;

      IF i.ref_obj IS NOT NULL THEN

        BEGIN

          SELECT ptr.S
            INTO v_ref_code
            FROM sp.v_model_objects tr, sp.v_model_object_pars ptr
           WHERE tr.ID = ptr.MOD_OBJ_ID
             AND tr.CATALOG_NAME = '#CodeSectorRefRows'
             AND tr.MODEL_NAME = 'DocFlow||DocPrjProps'
             AND ptr.PARAM_NAME = 'CODE'
             AND tr.PARENT_MOD_OBJ_ID IN
                 (SELECT t.ID
                    FROM sp.v_model_objects t, sp.v_model_object_pars pt
                   WHERE t.ID = pt.MOD_OBJ_ID
                     AND t.CATALOG_NAME = '#CodeSectorRefs'
                     AND t.MODEL_NAME = pi_model_name
                     AND pt.PARAM_NAME = 'NAME'
                     AND pt.S = i.ref_obj)
             AND ptr.S = v_res;
        EXCEPTION
          WHEN no_data_found THEN
            po_error_text := po_error_text||chr(13)||'Кода ' || v_res || ' - нет в справочнике: ' ||i.ref_obj || '!';
        END;

      END IF;

    END LOOP;
  END;

  -- поиск шаблона заголовка договора соответствующего заголовку: pi_doc_header
  --   в параметр po_text_out - записывается информация о заголовке документа - соответствия шаблону,
  --   в случае ошибки - записывается информация об ошибке
  PROCEDURE find_doc_template(pi_doc_header IN VARCHAR2, po_text_out OUT VARCHAR2, pi_model_name IN VARCHAR2 DEFAULT 'DocFlow||Documents') IS

    v_doc_header  VARCHAR2(4000);
    v_reg_formula VARCHAR2(4000);
    v_error_text  VARCHAR2(4000);
    v_doc_name    VARCHAR2(4000);

  BEGIN

    po_text_out := '';

    --  v_doc_header := 'AKU-P02-BAA0001';
    v_doc_header := pi_doc_header;


    -- в запросе идет проверка соответствия заголовка документа шаблону в целом:
    --   из регулярных выражений всех секторов собирается одно общее,
    --   и проверяется соответствие ему заголовка
    --   если соответствующий шаблон найден, то далее в цикле идет разбор заголовка документа на
    --   составляющие (сектора),  если для сектора установлен параметр REF (справочник),
    --   то значение сектора проверяется на наличие в этом справочнике

    FOR r IN (SELECT -- is_doc_prj,
               res.reg_formula,
               res.PARENT_MOD_OBJ_ID doc_prj_id,
               res.poid doc_prj_oid
                FROM (SELECT res_tm.*
                        FROM (SELECT agg_concat(nvl2(dl.S, '\' || dl.S, NULL) || '(' || fr.s || ')') over(PARTITION BY t.PARENT_MOD_OBJ_ID ORDER BY sq.N) reg_formula,
                                     row_number() over(PARTITION BY t.PARENT_MOD_OBJ_ID ORDER BY sq.N) rnum,
                                     COUNT(fr.s) over(PARTITION BY t.PARENT_MOD_OBJ_ID) cnt,
                                     fr.s,
                                     t.*
                                FROM sp.v_model_objects     t,
                                     sp.v_model_object_pars sq,
                                     sp.v_model_object_pars fr,
                                     sp.v_model_object_pars dl
                               WHERE t.ID = sq.MOD_OBJ_ID
                                 AND t.ID = fr.MOD_OBJ_ID
                                 AND t.ID = dl.MOD_OBJ_ID
                                 AND t.MODEL_NAME = pi_model_name
                                 AND t.CATALOG_NAME = '#CodeSectors'
                                 AND sq.PARAM_NAME = 'CS_SEQ'
                                 AND fr.PARAM_NAME = 'FORMULA'
                                 AND dl.PARAM_NAME = 'DELIM') res_tm
                       WHERE res_tm.rnum = res_tm.cnt) res
               WHERE regexp_instr(v_doc_header, res.reg_formula) = 1
                 AND regexp_replace(v_doc_header, res.reg_formula) IS NULL)

    LOOP

      -- разбор заголовка на сектора и проверка значений в соответствии с справочниками
      check_refs4doc_template(r.doc_prj_id,
                              v_doc_header,
                              r.reg_formula,
                              v_error_text,
                              pi_model_name);

      -- в случае успешного разбора заголовка документа,  выбираем название шаблона которому соответствует заголовок
      IF v_error_text IS NULL THEN

        BEGIN
          SELECT ptr.S
            INTO v_doc_name
            FROM sp.v_model_objects tr, sp.v_model_object_pars ptr
           WHERE tr.ID = ptr.MOD_OBJ_ID
             AND tr.CATALOG_NAME = '#DocPrjHeaders'
             AND tr.MODEL_NAME = pi_model_name
             AND ptr.PARAM_NAME = 'NAME'
             AND tr.ID = r.doc_prj_id;
        EXCEPTION
          WHEN no_data_found THEN
            NULL;
          WHEN dup_val_on_index THEN
            NULL;
        END;

        po_text_out := po_text_out||chr(13)||'Документ соответствует шаблону: ' || v_doc_name || ' (' || r.doc_prj_id || ')';

      ELSE

        po_text_out := po_text_out||chr(13)||'ERROR: ' || v_error_text;

      END IF;

    END LOOP;

    IF po_text_out IS NULL THEN
      po_text_out := chr(13)||'Документ не соответствует не одному шаблону из модели!';
    END IF;

  END;

END;
/
