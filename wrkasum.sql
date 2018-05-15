-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

PROMPT Top allocation reason by PGA memory usage

COL wrkasum_operation_type FOR A30
 
SELECT
    operation_type wrkasum_operation_type
  , policy
  , ROUND(SUM(actual_mem_used)/1048576) actual_pga_mb
  , ROUND(SUM(work_area_size)/1048576)  allowed_pga_mb
  , ROUND(SUM(tempseg_size)/1048576)    temp_mb
  , MAX(number_passes)                  num_passes
  , COUNT(DISTINCT qcinst_id||','||qcsid)   num_qc
  , COUNT(DISTINCT inst_id||','||sid)   num_sessions
FROM
    gv$sql_workarea_active
WHERE
    &1
GROUP BY 
    operation_type
  , policy
ORDER BY 
    actual_pga_mb DESC NULLS LAST
/

PROMPT Top SQL_ID by TEMP usage...

 SELECT
     sql_id
   , policy
   , ROUND(SUM(actual_mem_used)/1048576) actual_pga_mb
   , ROUND(SUM(work_area_size)/1048576)  allowed_pga_mb
   , ROUND(SUM(tempseg_size)/1048576)    temp_mb
   , MAX(number_passes)                  num_passes
   , COUNT(DISTINCT qcinst_id||','||qcsid)   num_qc
   , COUNT(DISTINCT inst_id||','||sid)   num_sessions
 FROM
     gv$sql_workarea_active
 WHERE
     &1
 GROUP BY 
     sql_id
   , policy
 ORDER BY 
     temp_mb DESC NULLS LAST
/

