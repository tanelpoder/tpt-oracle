-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Purpose:     List UPDATE/DELETE statements that have experienced restarts due to write consistency from V$SQL_PLAN_MONITOR

SELECT
    inst_id
  , sql_id
  , starts
  , sql_exec_start
  , sql_exec_id
  , plan_operation
  , plan_object_owner||'.'||plan_object_name object_name 
FROM 
    gv$sql_plan_monitor 
WHERE 
    plan_line_id = 1 
AND starts > 1
ORDER BY
    sql_id
  , sql_exec_start
/

