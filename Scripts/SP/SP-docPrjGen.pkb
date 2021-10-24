CREATE OR REPLACE PACKAGE BODY SP.docPrjGen IS

  ------------------------------------------------------------------------
  -- docPrjGen package body
  -- by Gemba Sergey
  -- пакет используется для генерации скриптов - создающих макры для работы с заголовками проектных документов
  -- create 03.09.2014
  -- update 03.09.2014
  ------------------------------------------------------------------------

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
    PIPELINED IS

    v_makra_name  VARCHAR2(4000) := pi_marka_name;
    v_doc_prj_id  NUMBER(20) := pi_doc_prj_id;
    v_row_count   NUMBER(20) := 0;
    v_command_rnm NUMBER(20) := 0;
    v_macra_txt   VARCHAR2(4000);

    CURSOR docPr IS
      SELECT c.parent_mod_obj_id,
             c.oid,
             c.id,
             c.cs_name,
             c.cs_is_reg,
             -- c.cs_seq,
             lpad(c.cs_seq, length(MAX(to_number(c.cs_seq)) over()), '0') cs_seq,
             c.cs_formula,
             c.cs_ref,
             nvl(c.cs_desc, c.cs_name) cs_desc,
             c.cs_fixVal,
             c.cs_delim
        FROM (SELECT t.PARENT_MOD_OBJ_ID,
                     t.OID,
                     t.ID,
                     MAX(CASE
                           WHEN pr.PARAM_NAME = 'NAME' THEN
                            pr.S
                         END) cs_name,
                     MAX(CASE
                           WHEN pr.PARAM_NAME = 'IS_REQ' THEN
                            pr.n
                         END) cs_is_reg,
                     MAX(CASE
                           WHEN pr.PARAM_NAME = 'CS_SEQ' THEN
                            pr.n
                         END) cs_seq,
                     MAX(CASE
                           WHEN pr.PARAM_NAME = 'FORMULA' THEN
                            pr.S
                         END) cs_formula,
                     MAX(CASE
                           WHEN pr.PARAM_NAME = 'REF' THEN
                            pr.S
                         END) cs_ref,
                     MAX(CASE
                           WHEN pr.PARAM_NAME = 'DESCRIPTION' THEN
                            pr.S
                         END) cs_desc,
                     MAX(CASE
                           WHEN pr.PARAM_NAME = 'FIXED_VALUE' THEN
                            pr.S
                         END) cs_fixVal,
                     MAX(CASE
                           WHEN pr.PARAM_NAME = 'DELIM' THEN
                            pr.S
                         END) cs_delim
                FROM sp.v_model_objects t, sp.v_model_object_pars pr
               WHERE t.ID = pr.MOD_OBJ_ID
                 AND t.MODEL_NAME = pi_model_name
                 AND t.CATALOG_NAME = '#CodeSectors'
                 AND t.PARENT_MOD_OBJ_ID = v_doc_prj_id
                 AND pr.PARAM_NAME IN ('CS_SEQ',
                                       'REF',
                                       'NAME',
                                       'FORMULA',
                                       'IS_REQ',
                                       'DESCRIPTION',
                                       'FIXED_VALUE',
                                       'DELIM')
               GROUP BY t.PARENT_MOD_OBJ_ID, t.OID, t.ID) c
       ORDER BY cs_seq;

    CURSOR docH IS
      SELECT t.ID,
             t.OID,
             MAX(CASE
                   WHEN pr.PARAM_NAME = 'NAME' THEN
                    pr.S
                 END) cs_name,
             MAX(CASE
                   WHEN pr.PARAM_NAME = 'DESCRIPTION' THEN
                    pr.S
                 END) cs_desc
        FROM sp.v_model_objects t, sp.v_model_object_pars pr
       WHERE t.ID = pr.MOD_OBJ_ID
         AND t.MODEL_NAME = pi_model_name
         AND t.CATALOG_NAME = '#DocPrjHeaders'
         AND t.ID = v_doc_prj_id
         AND pr.PARAM_NAME IN ('DESCRIPTION', 'NAME')
       GROUP BY t.ID, t.OID;

  BEGIN

    v_row_count := v_row_count + 1;
    PIPE ROW(sp.tsource_line(v_row_count, 'BEGIN'));

    FOR r IN docH LOOP
      v_row_count := v_row_count + 1;
      v_macra_txt := 'SP.INPUT.Object(NAME=>''' || v_makra_name ||
                     ''', GroupName=>''macros.pkf.docflow'',' || EOL ||
                     'Comments=>''' || r.cs_name || ' (' || r.cs_desc ||
                     ')'',' || EOL || 'Kind=>''MACRO'',' || EOL || 'Q=>0);';

      PIPE ROW(sp.tsource_line(v_row_count, v_macra_txt));

    END LOOP;

    IF docH%ISOPEN THEN
      CLOSE docH;
    END IF;

    FOR r IN docPr LOOP

      IF r.cs_fixVal IS NULL THEN
        v_row_count := v_row_count + 1;

        SELECT 'SP.INPUT.ObjectPar(Name=>''SECTOR' || r.cs_seq || ''',' || EOL ||
                'ObjectName=>''' || v_makra_name || ''',' || EOL || '
Comments=>''' || r.cs_name || '(' || r.cs_formula || ')' ||
                ''',' || EOL || '
ParType=>''' || nvl2(r.cs_ref, 'T_' || r.cs_ref, 'Str4000') ||
                ''',' || EOL || '
 R_ONLY=>''' || decode(r.cs_is_reg, 1, 'Required', 'R/W') ||
                ''',' || EOL || '
Q=>0);'
          INTO v_macra_txt
          FROM DUAL;

        PIPE ROW(sp.tsource_line(v_row_count, v_macra_txt));
      END IF;

    END LOOP;

    v_row_count := v_row_count + 1;
    PIPE ROW(sp.tsource_line(v_row_count, 'COMMIT;'));

    v_row_count := v_row_count + 1;
    PIPE ROW(sp.tsource_line(v_row_count, 'END;' || EOL || '/'));

    v_row_count := v_row_count + 1;
    v_macra_txt := 'BEGIN
 o(''Загружен объект ' || v_makra_name ||
                   '''||SP.B.compile_macro(''' || v_makra_name ||
                   '''));
 d(''Загружен объект ' || v_makra_name || ''',''Update_macros'');
END;
/';
    PIPE ROW(sp.tsource_line(v_row_count, v_macra_txt));

    v_row_count   := v_row_count + 1;
    v_command_rnm := v_command_rnm + 1;
    v_macra_txt   := '--Макрокоманды-- ' || v_makra_name || EOL || 'BEGIN' || EOL || '
SP.INPUT.Macro(ObjectName=>''' || v_makra_name || ''',' || EOL || '
LineNum=>''' || v_command_rnm ||
                     ''', Command=>''Declare'',' || EOL || '
MacroBlock=>''v_doc_header_text varchar2(4000):= '''''''';''' || EOL || '
,' || EOL || '
Comments=>''v_doc_header_text - заголовок документа - результат'', ' || EOL || '
Q=>0);' || EOL || '
end;' || EOL || '
/';
    PIPE ROW(sp.tsource_line(v_row_count, v_macra_txt));

    FOR r IN docPr LOOP
      v_row_count   := v_row_count + 1;
      v_command_rnm := v_command_rnm + 1;
      v_macra_txt   := 'BEGIN' || EOL || '
SP.INPUT.Macro(LineNum=>''' || v_command_rnm ||
                       ''', Command=>''Calculate'',' || EOL || '
MacroBlock=>''EM := null;' || EOL;
      IF r.cs_fixVal IS NULL THEN
        v_macra_txt := v_macra_txt || '/* ' || r.cs_desc ||
                       ' */' || EOL || 'if regexp_instr(P(''''SECTOR' ||
                       r.cs_seq || ''''').AsString, ''''' || r.cs_formula ||
                       ''''') = 1 AND regexp_replace(P(''''SECTOR' ||
                       r.cs_seq || ''''').AsString, ''''' || r.cs_formula ||
                       ''''') IS NULL then' || EOL || '
  dprn(''''SECTOR' || r.cs_seq ||
                       ': ''''||P(''''SECTOR' || r.cs_seq ||
                       ''''').AsString);' || EOL || '
  v_doc_header_text := v_doc_header_text||''''' ||
                       r.cs_delim || '''''||P(''''SECTOR' || r.cs_seq ||
                       ''''').AsString;' || EOL || '
else' || EOL || '
  EM := ''''Не правильно заполнено значение параметра email,  значение не соответствует выражению: ' ||
                       r.cs_formula || '!'''';' || EOL || '
end if;' || EOL;
      ELSE
        v_macra_txt := v_macra_txt || ' dprn(''''SECTOR' || r.cs_seq || ':' ||
                       r.cs_fixVal || ''''');' || EOL || '
  v_doc_header_text := v_doc_header_text||''''' ||
                       r.cs_delim || r.cs_fixVal || ''''';' || EOL;
      END IF;

      v_macra_txt := v_macra_txt || 'if EM is not null then' || EOL || '
 dprn(EM);' || EOL || '
 return g.Cmd_CANCEL;' || EOL || '
end if;';

      v_macra_txt := v_macra_txt || ''',' || EOL || 'Comments=>''"'||r.cs_desc||'" - проверка введенного значения сектора на соответствие регулярному выражению и добавление этого значения в заголовок документа v_doc_header_text''' || EOL;

      v_macra_txt := v_macra_txt || ',' || EOL || 'Q=>0' || EOL;

      v_macra_txt := v_macra_txt || ');' || EOL ||
                     'END;' || EOL || '/';

      PIPE ROW(sp.tsource_line(v_row_count, v_macra_txt));

      v_row_count   := v_row_count + 1;
      v_command_rnm := v_command_rnm + 1;
      v_macra_txt   := 'BEGIN' || EOL || '
SP.INPUT.Macro(LineNum=>''' || v_command_rnm ||
                       ''', Command=>''Cancel'',' || EOL || '
Condition=>''EM IS NOT NULL'');' || EOL || '
END;
/';
      PIPE ROW(sp.tsource_line(v_row_count, v_macra_txt));

    END LOOP;

    IF docPr%ISOPEN THEN
      CLOSE docPr;
    END IF;

    v_row_count   := v_row_count + 1;
    v_command_rnm := v_command_rnm + 1;
    v_macra_txt   := 'BEGIN' || EOL || '
    SP.INPUT.Macro(LineNum=>''' || v_command_rnm ||
                     ''', Command=>''Calculate'',' || EOL || '
    MacroBlock=>''dprn(''''------------------------------------------'''');' || EOL || '
dprn(''''Заголовок документа: ''''||v_doc_header_text);' || EOL || '
dprn(''''------------------------------------------'''');'',
    Q=>0);' || EOL || 'END;' || EOL || '/';

    PIPE ROW(sp.tsource_line(v_row_count, v_macra_txt));

    v_row_count := v_row_count + 1;
    v_macra_txt := 'begin' || EOL || '
commit;' || EOL || '
end;' || EOL || '
/';
    PIPE ROW(sp.tsource_line(v_row_count, v_macra_txt));

    v_row_count := v_row_count + 1;
    v_macra_txt := 'declare EM SP.COMMANDS.COMMENTS%type;' || EOL || '
begin EM:=SP.B.compile_macro_body(''' || v_makra_name ||
                   ''');' || EOL || '
o(''compile body ' || v_makra_name || ' ''||EM);' || EOL || '
d(''compile body ' || v_makra_name ||
                   ' ''||EM,''Update_macros'');' || EOL || '
end;' || EOL || '
/';

    PIPE ROW(sp.tsource_line(v_row_count, v_macra_txt));

  END;

  -- Функция используется для генерации скрипта - типа справочника, на основе данных модели справочников шаблонов заголовков документов(#CodeSectorRefs)
  --   pi_ref_name - название справочника (параметр NAME объекта #CodeSectorRefs)
  FUNCTION gen_type_for_ref(pi_ref_name IN VARCHAR2, pi_model_name IN VARCHAR2 DEFAULT 'DocFlow||Documents') RETURN sp.tsource
    PIPELINED IS
    v_ref_name VARCHAR2(4000) := pi_ref_name;
  BEGIN
    FOR r IN (SELECT 'BEGIN
SP.INPUT."Type"(
NAME=>''T_' || tp.t_name || ''',
Comments=>''Тип справочник: ' || tp.t_desc || ''',
CheckVal=>''if (V.E is not null) or (V.X is not null) or (V.Y is not null)  then raise_application_error(-20030,''''Неверные данные, выберите из списка!''''); end if;'',
ValToString=>''S:=V.S;'',
StringToVal=>''V.S:=S;'',
SetOfValues=>''SELECT NULL S_VALUE, NULL COMMENTS FROM DUAL
UNION ALL
SELECT MAX(CASE
             WHEN pr.PARAM_NAME = ''''CODE'''' THEN
              pr.S
           END) S_VALUE,
       MAX(CASE
             WHEN pr.PARAM_NAME = ''''DESCRIPTION'''' THEN
              pr.S
           END) COMMENTS
  FROM sp.v_model_objects t, sp.v_model_object_pars pr
 WHERE t.ID = pr.MOD_OBJ_ID
   AND t.MODEL_NAME = '''||pi_model_name||'''
   AND t.CATALOG_NAME = ''''#CodeSectorRefRows''''
   AND t.PARENT_MOD_OBJ_ID =
       (SELECT r.ID
          FROM sp.v_model_objects r, sp.v_model_object_pars r_pr
         WHERE r.ID = r_pr.MOD_OBJ_ID
           AND r.MODEL_NAME = '''||pi_model_name||'''
           AND r.CATALOG_NAME = ''''#CodeSectorRefs''''
           AND r_pr.PARAM_NAME = ''''NAME''''
           AND r_pr.s = ''''' || tp.t_name || ''''')
   AND pr.PARAM_NAME IN (''''DESCRIPTION'''', ''''CODE'''')
 GROUP BY t.ID
ORDER BY S_VALUE NULLS FIRST'',
MDATE=>''' || to_char(SYSDATE, 'dd.mm.yyyy hh24:mi:ss') ||
                      ''', MUSER=>''' || (SELECT USER FROM dual) || ''',
Q=>0);
end;
/' makra_txt
                FROM (SELECT MAX(CASE
                                   WHEN r_pr.PARAM_NAME = 'CODE' THEN
                                    r_pr.S
                                 END) t_name,
                             MAX(CASE
                                   WHEN r_pr.PARAM_NAME = 'NAME' THEN
                                    r_pr.S
                                 END) t_desc
                        FROM sp.v_model_objects     r,
                             sp.v_model_object_pars r_pr
                       WHERE r.ID = r_pr.MOD_OBJ_ID
                         AND r.MODEL_NAME = pi_model_name
                         AND r.CATALOG_NAME = '#CodeSectorRefs'
                         AND r_pr.PARAM_NAME IN ('CODE', 'NAME')
                         AND r_pr.s = v_ref_name
                       GROUP BY r.ID) tp) LOOP
      PIPE ROW(sp.tsource_line(1, r.makra_txt));
    END LOOP;
  END;
END;
/
