-- 
-- by Сергей Гемба
-- This file is distributed under Apache License 2.0 (01.2004).
--   http://www.apache.org/licenses/
-- create 18.02.2015
-- update 
--*****************************************************************************

CREATE OR REPLACE PROCEDURE SP.DND_PROCESSING(pi_source_id IN VARCHAR2,
                                              pi_target_id IN VARCHAR2,
                                              pi_component_id IN VARCHAR2)
AS
BEGIN
  d('pi_source_id: '||pi_source_id||'; pi_target_id:'||pi_target_id||'; pi_component_id:'||pi_component_id, 'DND');
  -- RAISE_APPLICATION_ERROR(-20555, 'pi_source_id: '||pi_source_id||'; pi_target_id:'||pi_target_id||'; pi_component_id:'||pi_component_id);
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20555, SQLERRM);
END;
/

grant EXECUTE on SP.DND_PROCESSING to PUBLIC;
create or replace public synonym DND_PROCESSING for SP.DND_PROCESSING;
