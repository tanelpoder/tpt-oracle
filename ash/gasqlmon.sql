-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL asqlmon_operation FOR a80
COL asqlmon_predicates FOR a100 word_wrap
COL options   FOR a30

COL asqlmon_plan_hash_value HEAD PLAN_HASH_VALUE
COL asqlmon_sql_id          HEAD SQL_ID
COL asqlmon_sql_child       HEAD CHILD#
COL asqlmon_sample_time     HEAD SAMPLE_HOUR

BREAK ON asqlmon_plan_hash_value SKIP 1 ON asqlmon_sql_id SKIP 1 ON asqlmon_sql_child SKIP 1 ON asqlmon_sample_time SKIP 1 DUP

WITH  sample_times AS (
    select * from dual
), 
sq AS (
SELECT /*+ MATERIALIZE */
  --  to_char(ash.sample_time, 'YYYY-MM-DD HH24') sample_time
    count(*) samples
  , ash.inst_id
  , ash.sql_id
  , ash.sql_child_number
  , ash.sql_plan_hash_value
  , ash.sql_plan_line_id
  , ash.sql_plan_operation
  , ash.sql_plan_options
FROM
    gv$active_session_history ash
WHERE
    1=1
AND ash.sql_id LIKE '&1'
AND ash.sql_child_number LIKE '%&2%'
GROUP BY
  --to_char(ash.sample_time, 'YYYY-MM-DD HH24')
    ash.inst_id
  , ash.sql_id
  , ash.sql_child_number
  , ash.sql_plan_hash_value
  , ash.sql_plan_line_id
  , ash.sql_plan_operation
  , ash.sql_plan_options
),
plan AS (
    SELECT /*+ MATERIALIZE */ * FROM gv$sql_plan
    WHERE sql_id IN (SELECT DISTINCT sql_id FROM sq)
)
SELECT
    plan.sql_id            asqlmon_sql_id
--  , plan.child_number      asqlmon_sql_child
  , plan.plan_hash_value asqlmon_plan_hash_value
  , sq.samples seconds
  , LPAD(TO_CHAR(TO_NUMBER(ROUND(RATIO_TO_REPORT(sq.samples) OVER (PARTITION BY sq.sql_id, sq.sql_plan_hash_value) * 100, 1), 999.9))||' %',8) pct_child
  , '|'||RPAD( NVL( LPAD('#', ROUND(RATIO_TO_REPORT(sq.samples) OVER (PARTITION BY sq.sql_id, sq.sql_plan_hash_value) * 10), '#'), ' '), 10,' ')||'|' pct_child_vis
  --, sq.sample_time         asqlmon_sample_time
  , plan.id 
  , LPAD(' ', depth) || plan.operation ||' '|| plan.options || NVL2(plan.object_name, ' ['||plan.object_name ||']', null) asqlmon_operation
  , plan.access_predicates ||' ' || plan.filter_predicates asqlmon_predicates
FROM
    plan
  , sq
WHERE
    1=1
AND sq.inst_id = plan.inst_id
AND sq.sql_id(+) = plan.sql_id
AND sq.sql_child_number(+) = plan.child_number
AND sq.sql_plan_line_id(+) = plan.id
AND sq.sql_plan_hash_value(+) = plan.plan_hash_value
AND plan.sql_id LIKE '&1'
AND plan.child_number LIKE '%&2%'
ORDER BY
  --sq.sample_time
    plan.sql_id
  , plan.plan_hash_value
  , plan.id
/
