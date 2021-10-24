CREATE OR REPLACE PROCEDURE SP.GLOBAL_VAR_CHANGE(pi_name IN VARCHAR2,
                                                 pi_value IN VARCHAR2)
AS
--pragma autonomous_transaction;
BEGIN
  
  UPDATE sp.v_globals s SET s.S_VALUE = pi_value WHERE s.name = pi_name;
--  insert into sp.a1 values (pi_name||'; '||pi_value);
--  RAISE_APPLICATION_ERROR(-20555, 'ERRORRRR!!!');
--  commit;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20555, SQLERRM);
END;
/

grant EXECUTE on SP.GLOBAL_VAR_CHANGE to PUBLIC;
create or replace public synonym GLOBAL_VAR_CHANGE for SP.GLOBAL_VAR_CHANGE;