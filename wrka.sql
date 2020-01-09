-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Purpose:     List ACTIVE SQL workarea memory usage details at session/workarea level.
--              Show both PGA workarea usage and TEMP usage by workareas (workareas don't include
--              other PGA/TEMP use like PL/SQL arrays and global temporary tables)
--
-- Usage:       @wrka 1=1 
--              @wrka sid=123
--              @wrka username='APPUSER'
--              @wrka "sid IN (123,234,456)"
--              @wrka "program LIKE '%BatchRunner.exe%' AND machine='host123'"
--              @wrka "sid in (SELECT sid FROM v$session WHERE ....)"

prompt Show Active workarea memory usage for where &1....

COL wrka_operation_type HEAD OPERATION_TYPE FOR A30

SELECT 
    inst_id
  , sid
  , qcinst_id
  , qcsid
  , sql_id
--  , sql_exec_start -- 11g+
  , operation_type wrka_operation_type
  , operation_id plan_line
  , policy
  , ROUND(active_time/1000000,1) active_sec
  , actual_mem_used
  , max_mem_used
  , work_area_size
  , number_passes
  , tempseg_size
  , tablespace
FROM 
    gv$sql_workarea_active 
WHERE 
    &1
ORDER BY
    sid
  , sql_hash_value
  , operation_id
/
