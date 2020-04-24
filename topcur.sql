-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

DEF atleast=&1

PROMPT Showing SQLs with at least &atleast cursors

COL "MIN(first_load_time)" FOR A20
COL "MAX(last_load_time)" FOR A20

PROMPT ==============================================================================================
PROMPT == SQLs not using bind variables (check the SQL texts of top offenders)                     ==
PROMPT ==============================================================================================

SELECT
    COUNT(*) total_children
  , COUNT(DISTINCT sql_id) distinct_sqlids
  , COUNT(DISTINCT plan_hash_value) distinct_plans
  , plan_hash_value
  , MIN(sql_id)
  , MAX(sql_id)
  , MIN(first_load_time)
  , MAX(last_load_time)
FROM v$sql
--WHERE plan_hash_value != 0
GROUP BY plan_hash_value
HAVING COUNT(DISTINCT sql_id) > &atleast
ORDER BY COUNT(*) DESC
/

PROMPT ==============================================================================================
PROMPT == SQLs with many child cursors under a parent (use nonshared*.sql to find the reasons)     ==
PROMPT ==============================================================================================

SELECT 
    COUNT(*) total_children
  , COUNT(DISTINCT sql_id) distinct_sqlids
  , COUNT(DISTINCT plan_hash_value) distinct_plans
  , sql_id
  , MIN(plan_hash_value)
  , MAX(plan_hash_value)
  , MIN(first_load_time)
  , MAX(last_load_time)
FROM v$sql
GROUP BY sql_id
HAVING COUNT(*) > &atleast
ORDER BY COUNT(*) DESC
/

