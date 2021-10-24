CREATE OR REPLACE FUNCTION SP.get_obj_param_value
(
  pi_mod_obj_id IN NUMBER,
  pi_param_name IN VARCHAR2
) RETURN sp.tvalue AS
  v_value       sp.tvalue;
  -- v_date_format VARCHAR2(50) := 'dd.mm.yyyy hh24:mi:ss';
BEGIN

  BEGIN
    SELECT sp.tvalue(mp.type_id, mp.e_val, mp.n, mp.d, 0, mp.s, mp.x, mp.y)
      INTO v_value
      FROM SP.MODEL_OBJECT_PAR_S mp
     WHERE mp.name IS NOT NULL     
       AND mp.MOD_OBJ_ID = pi_mod_obj_id
       AND mp.name = pi_param_name;
  EXCEPTION
    WHEN no_data_found THEN
      BEGIN
        SELECT sp.tvalue(mp.type_id,
                         mp.e_val,
                         mp.n,
                         mp.d,
                         0,
                         mp.s,
                         mp.x,
                         mp.y)
          INTO v_value
          FROM SP.MODEL_OBJECT_PAR_S mp, sp.object_par_s op
         WHERE mp.obj_par_id = op.id
           AND UPPER(op.name) = upper(pi_param_name)
           AND mp.MOD_OBJ_ID = pi_mod_obj_id;
      EXCEPTION
        WHEN no_data_found THEN
          v_value := NULL;
      END;
    WHEN too_many_rows THEN
      raise_application_error(-20001,
                              'Для объекта модели: ' || pi_mod_obj_id ||
                              ' - найдено более одного параметра с наименованием' ||
                              pi_param_name);
  END;
  
  RETURN v_value;
  
END;
/
