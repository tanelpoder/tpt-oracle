-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL wait_event FOR A45 TRUNCATE
COL ash_storage_graph HEAD "GRAPHIC" JUST CENTER FOR A12

SELECT 
    CASE WHEN sql_plan_options LIKE '%STORAGE%' THEN sql_plan_operation ELSE 'not storage-aware' END sql_plan_operation
  , CASE WHEN sql_plan_options LIKE '%STORAGE%' THEN sql_plan_options ELSE 'not storage-aware' END sql_plan_options
  , CASE WHEN sql_plan_options LIKE '%STORAGE%' THEN 
      CASE WHEN session_state = 'WAITING' THEN event ELSE 'ON CPU' END
    ELSE
      'not storage-aware'
    END wait_event
  , COUNT(*) 
  , ROUND(RATIO_TO_REPORT(COUNT(*)) OVER() * 100 ,1) pct
  , '|'||RPAD(NVL(RPAD('#', ROUND (10 * RATIO_TO_REPORT(COUNT(*)) OVER()), '#'),' '), 10)||'|' ash_storage_graph
FROM 
    v$active_session_history 
WHERE
    1=1
AND sample_time BETWEEN sysdate-1/24/12 AND sysdate
-- AND sql_plan_options LIKE '%STORAGE%'
GROUP BY 
    CASE WHEN sql_plan_options LIKE '%STORAGE%' THEN sql_plan_operation ELSE 'not storage-aware' END
  , CASE WHEN sql_plan_options LIKE '%STORAGE%' THEN sql_plan_options ELSE 'not storage-aware' END 
  , CASE WHEN sql_plan_options LIKE '%STORAGE%' THEN 
      CASE WHEN session_state = 'WAITING' THEN event ELSE 'ON CPU' END
    ELSE
      'not storage-aware'
    END
ORDER BY 
    COUNT(*) DESC
/

