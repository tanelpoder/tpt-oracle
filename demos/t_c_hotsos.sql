-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

ALTER SESSION SET EVENTS 'immediate trace name trace_buffer_on level 1048576';

DECLARE
    j NUMBER;
BEGIN
    WHILE TRUE LOOP
      BEGIN
          SELECT /*+ INDEX_RS_ASC(t i_c_hotsos) */ data_object_id INTO j
          FROM t_c_hotsos t 
          WHERE object_id = 21230 - 5000 + TRUNC(DBMS_RANDOM.VALUE(0, 10000)); -- 21230
  
          --DBMS_LOCK.SLEEP(DBMS_RANDOM.VALUE(0,0.01));
      EXCEPTION
          WHEN OTHERS THEN NULL; -- Do not show this to Tom Kyte!!!
      END;
    END LOOP;
END;
/

ALTER SESSION SET EVENTS 'immediate trace name trace_buffer_off';

