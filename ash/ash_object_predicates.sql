-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SET LINESIZE 999 PAGESIZE 5000 TRIMOUT ON TRIMSPOOL ON 

COL asqlmon_operation  HEAD Plan_Operation FOR a72
COL asqlmon_predicates HEAD PREDICATES     FOR a100 word_wrap
COL obj_alias_qbc_name FOR a40
COL options   FOR a30

COL asqlmon_plan_hash_value HEAD PLAN_HASH_VALUE   PRINT
COL asqlmon_sql_id          HEAD SQL_ID          NOPRINT
COL asqlmon_sql_child       HEAD "CHILD"          PRINT
COL asqlmon_sample_time     HEAD SAMPLE_HOUR
COL projection FOR A520

COL pct_child HEAD "Activity %" FOR A8
COL pct_child_vis HEAD "Visual" FOR A12

COL asqlmon_id        HEAD "ID" FOR 9999
COL asqlmon_parent_id HEAD "PID"  FOR 9999


BREAK ON asqlmon_plan_hash_value SKIP 1 ON asqlmon_sql_id SKIP 1 ON asqlmon_sql_child SKIP 1 ON asqlmon_sample_time SKIP 1 DUP ON asqlmon_operation

PROMPT
PROMPT -- ASQLMon v1.1 - by Tanel Poder ( http://blog.tanelpoder.com ) - Display SQL execution plan line level activity breakdown from ASH

WITH  sample_times AS (
    select * from dual
), 
sq AS (
SELECT
    count(*) samples
  , ash.sql_id
  , ash.sql_child_number
  , ash.sql_plan_hash_value
  , NVL(ash.sql_plan_line_id,1) sql_plan_line_id -- this is because simple "planless" operations like single-row insert
  , ash.sql_plan_operation
  , ash.sql_plan_options
  , ash.session_state
  , ash.event
--  , AVG(ash.p3) avg_p3 -- p3 is sometimes useful for listing block counts for IO wait events
FROM
    v$active_session_history ash
WHERE
    1=1
AND ash.sql_plan_operation IN ('TABLE ACCESS', 'INDEX')
AND ash.sql_id LIKE '&1'
AND ash.sql_child_number LIKE '&2'
AND ash.sample_time BETWEEN &3 AND &4
GROUP BY
    ash.sql_id
  , ash.sql_child_number
  , ash.sql_plan_hash_value
  , NVL(ash.sql_plan_line_id,1)
  , ash.sql_plan_operation
  , ash.sql_plan_options
  , ash.session_state
  , ash.event
), 
ash_and_plan AS (
SELECT
    plan.sql_id            
  , plan.child_number      
  , plan.plan_hash_value 
  , sq.samples seconds
  , LPAD(TO_CHAR(ROUND(RATIO_TO_REPORT(sq.samples) OVER (PARTITION BY sq.sql_id, sq.sql_plan_hash_value) * 100, 1), 999.9)||' %',8) pct_child
  , '|'||RPAD( NVL( LPAD('#', ROUND(RATIO_TO_REPORT(sq.samples) OVER (PARTITION BY sq.sql_id, sq.sql_plan_hash_value) * 10), '#'), ' '), 10,' ')||'|' pct_child_vis
--, LPAD(plan.id,4)||CASE WHEN parent_id IS NULL THEN '    ' ELSE ' <- ' END||LPAD(plan.parent_id,4) asqlmon_plan_id
  , plan.id asqlmon_id
  , plan.parent_id asqlmon_parent_id
  , plan.operation ||' '|| plan.options || NVL2(plan.object_name, ' ['||plan.object_name ||']', null) asqlmon_operation
  , sq.session_state
  , sq.event
--  , sq.avg_p3 
  , plan.object_alias || CASE WHEN plan.qblock_name IS NOT NULL THEN ' ['|| plan.qblock_name || ']' END obj_alias_qbc_name
  , CASE WHEN plan.access_predicates IS NOT NULL THEN '[A:] '|| SUBSTR(plan.access_predicates,1,1994) END || CASE WHEN plan.filter_predicates IS NOT NULL THEN ' [F:] ' || SUBSTR(plan.filter_predicates,1,1994) END asqlmon_predicates
--  , plan.projection
FROM
    v$sql_plan plan
  , sq
WHERE
    1=1
AND sq.sql_id(+) = plan.sql_id
AND sq.sql_child_number(+) = plan.child_number
AND sq.sql_plan_line_id(+) = plan.id
AND sq.sql_plan_hash_value(+) = plan.plan_hash_value
AND plan.sql_id LIKE '&1'
AND plan.child_number LIKE '&2'
)
SELECT * FROM (
    SELECT
        SUM(seconds) seconds
      , asqlmon_operation
      , session_state
--      , event
--      , obj_alias_qbc_name
      , asqlmon_predicates
      , COUNT(DISTINCT sql_id) dist_sqlids
      , COUNT(DISTINCT plan_hash_value) dist_plans
      , MIN(sql_id)
      , MAX(sql_id)
    FROM
        ash_and_plan
    WHERE
        seconds > 0
    GROUP BY
        asqlmon_operation
      , session_state
--      , event
--      , obj_alias_qbc_name
      , asqlmon_predicates
    ORDER BY
        seconds DESC
)
WHERE rownum <= 30
/
