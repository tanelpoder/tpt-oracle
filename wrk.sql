-- Copyright 2019 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Purpose:     List "last completed execution" SQL workarea memory and TEMP usage details 
--              for cursors still in cache.
--
-- Usage:       @wrk 1=1                                            -- lots of output
--              @wrk sql_id='d394v2sjq5p51'                         -- report last completed execution of a SQL_ID
--              @wrk "sql_id='d394v2sjq5p51' and child_number = 0"  -- show only child=0 for the given SQL_ID

COL wrk_operation_type HEAD OPERATION_TYPE FOR A30
COL wrk_policy HEAD POLICY FOR A10
COL wrk_operation_id HEAD PLAN_LINE FOR 9999
COL wrk_last_execution HEAD LAST_EXEC  FOR A15
COL wrk_max_tempseg_size HEAD MAX_TEMP
COL wrk_last_tempseg_size HEAD LAST_TEMP
COL wrk_last_memory_used HEAD LAST_MEM

SELECT
  --  address
    sql_id
  , child_number
  , operation_id           wrk_operation_id
  , operation_type         wrk_operation_type 
  , policy                 wrk_policy
  , estimated_optimal_size est_0mem
  , estimated_onepass_size est_1mem
  , last_memory_used       wrk_last_memory_used 
  , last_execution         wrk_last_execution 
  , active_time           
  , max_tempseg_size       wrk_max_tempseg_size
  , last_tempseg_size      wrk_last_tempseg_size
  , last_degree           
  , total_executions      
  , optimal_executions    
  , onepass_executions    
  , multipasses_executions
FROM 
    v$sql_workarea 
WHERE 
    &1
ORDER BY
    address
  , sql_id
  , child_number
  , operation_id
/

