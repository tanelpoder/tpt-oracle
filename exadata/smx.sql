-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

set echo on

SELECT 
    ROUND(physical_read_bytes/1048576)    phyrd_mb
  , ROUND(io_interconnect_bytes/1048576)  ret_mb
  , (1-(io_interconnect_bytes / NULLIF(physical_read_bytes,0)))*100 "SAVING%"
FROM 
    v$sql 
WHERE 
    sql_id = '9n2fg7abbcfyx' 
AND child_number = 1;


SELECT 
    plan_line_id id
  , LPAD(' ',plan_depth) || plan_operation
      ||' '||plan_options||' '
      ||plan_object_name operation
  , ROUND(SUM(physical_read_bytes)   /1048576) phyrd_mb
  , ROUND(SUM(io_interconnect_bytes) /1048576) ret_mb
  , AVG(1-(io_interconnect_bytes / NULLIF(physical_read_bytes,0)))*100 "SAVING%"
FROM 
    v$sql_plan_monitor 
WHERE 
    sql_id = '&1' 
AND sql_exec_id = &2
GROUP BY 
    plan_line_id
  , LPAD(' ',plan_depth) || plan_operation
      ||' '||plan_options||' '
      ||plan_object_name
ORDER BY
    plan_line_id
/

set echo off

