-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SET LINES 999 PAGES 5000 TRIMSPOOL ON TRIMOUT ON VERIFY OFF

SPOOL ash13a.txt

--DEF from_time="2010-10-30 18:12:00"
--DEF to_time="2010-10-30 18:14:00"
DEF cols=session_type,program,sql_opcode

--PROMPT FROM_TIME=&from_time TO_TIME=&to_time

SELECT * FROM (
  SELECT
        &cols
      , count(*)
      , lpad(round(ratio_to_report(count(*)) over () * 100)||'%',10,' ') percent
    FROM
        gv$active_session_history
        -- dba_hist_active_sess_history
    WHERE
        1=1
    -- AND sample_time BETWEEN TIMESTAMP'from_time' AND TIMESTAMP'to_time'
    -- AND event IS NULL
    -- AND sql_id IS NULL
    GROUP BY
        &cols
    ORDER BY
        percent DESC
)
WHERE ROWNUM <= 30
/

DEF cols=event
/

DEF cols=sql_id
/

DEF cols=module
/

DEF cols=action
/

DEF cols=user_id
/

DEF cols=session_type,program,top_level_sql_opcode
/

DEF cols=session_type,program,top_level_sql_opcode,top_level_sql_id
/

DEF cols=session_type,program,plsql_object_id,plsql_subprogram_id
/

DEF cols=wait_class,event
/

DEF cols=sql_id,wait_class
/

DEF cols=sql_id,event
/

DEF cols=program,event
/


SPOOL OFF

