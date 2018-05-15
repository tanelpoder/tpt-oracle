-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SET LINES 999 PAGES 5000 TRIMSPOOL ON TRIMOUT ON VERIFY OFF

DEF from_time="2010-10-30 18:12:00"
DEF to_time="2010-10-30 18:14:00"
DEF cols=session_type,program,sql_opcode

PROMPT FROM_TIME=&from_time TO_TIME=&to_time

SELECT * FROM (
  SELECT
        &cols
      , CASE WHEN IN_CONNECTION_MGMT='Y' THEN 'CONNECTION_MGMT' 
        WHEN IN_PARSE               ='Y' THEN 'PARSE'                      
        WHEN IN_HARD_PARSE          ='Y' THEN 'HARD_PARSE'                 
        WHEN IN_SQL_EXECUTION       ='Y' THEN 'SQL_EXECUTION'              
        WHEN IN_PLSQL_EXECUTION     ='Y' THEN 'PLSQL_EXECUTION'            
        WHEN IN_PLSQL_RPC           ='Y' THEN 'PLSQL_RPC'                  
        WHEN IN_PLSQL_COMPILATION   ='Y' THEN 'PLSQL_COMPILATION'          
        WHEN IN_JAVA_EXECUTION      ='Y' THEN 'JAVA_EXECUTION'             
        WHEN IN_BIND                ='Y' THEN 'BIND'                       
        WHEN IN_CURSOR_CLOSE        ='Y' THEN 'CURSOR_CLOSE'               
        WHEN IN_SEQUENCE_LOAD       ='Y' THEN 'SEQUENCE_LOAD'
        END stage
      , count(*)
      , lpad(round(ratio_to_report(count(*)) over () * 100)||'%',10,' ') percent
    FROM
        -- active_session_history_bak
         v$active_session_history
        -- dba_hist_active_sess_history
    WHERE
        1=1 --   sample_time BETWEEN TIMESTAMP'&from_time' AND TIMESTAMP'&to_time'
    AND session_state = 'ON CPU'
    AND event IS NULL
    AND sql_id IS NULL
    GROUP BY
        &cols
      , CASE WHEN IN_CONNECTION_MGMT='Y' THEN 'CONNECTION_MGMT' 
        WHEN IN_PARSE               ='Y' THEN 'PARSE'                      
        WHEN IN_HARD_PARSE          ='Y' THEN 'HARD_PARSE'                 
        WHEN IN_SQL_EXECUTION       ='Y' THEN 'SQL_EXECUTION'              
        WHEN IN_PLSQL_EXECUTION     ='Y' THEN 'PLSQL_EXECUTION'            
        WHEN IN_PLSQL_RPC           ='Y' THEN 'PLSQL_RPC'                  
        WHEN IN_PLSQL_COMPILATION   ='Y' THEN 'PLSQL_COMPILATION'          
        WHEN IN_JAVA_EXECUTION      ='Y' THEN 'JAVA_EXECUTION'             
        WHEN IN_BIND                ='Y' THEN 'BIND'                       
        WHEN IN_CURSOR_CLOSE        ='Y' THEN 'CURSOR_CLOSE'               
        WHEN IN_SEQUENCE_LOAD       ='Y' THEN 'SEQUENCE_LOAD'
        END 
    ORDER BY
        percent DESC
)
WHERE ROWNUM <= 30
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

