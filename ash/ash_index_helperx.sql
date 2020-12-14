-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SET LINESIZE 999 PAGESIZE 5000 TRIMOUT ON TRIMSPOOL ON 

COL accessed_table     HEAD Accessed_Table FOR a40
COL aindex_operation  HEAD Plan_Operation FOR a70
COL aindex_predicates HEAD PREDICATES     FOR a100 truncate
COL obj_alias_qbc_name FOR a40
COL options   FOR a30

COL AAS                 FOR 9999.9
COL cpu_pct  HEAD CPU  FOR A5
COL wait_pct HEAD WAIT FOR A5

COL ela_sec_exec HEAD "ELA_SEC/EXEC" FOR 9999990.999

COL aindex_plan_hash_value HEAD PLAN_HASH_VALUE   PRINT
COL aindex_sql_id          HEAD SQL_ID          NOPRINT
COL aindex_sql_child       HEAD "CHILD"          PRINT
COL aindex_sample_time     HEAD SAMPLE_HOUR
COL projection FOR A520

COL pct_child HEAD "Activity %" FOR A8
COL pct_child_vis HEAD "Visual" FOR A12

COL aindex_id        HEAD "ID" FOR 9999
COL aindex_parent_id HEAD "PID"  FOR 9999


PROMPT
PROMPT -- Santa's Little (Index) Helper BETA v0.5 - by Tanel Poder ( https://tanelpoder.com ) 

WITH 
tab AS (SELECT /*+ MATERIALIZE */ owner, table_name, num_rows 
        FROM dba_tables
        WHERE UPPER(table_name) LIKE 
                UPPER(CASE 
                  WHEN INSTR('&2','.') > 0 THEN 
                      SUBSTR('&2',INSTR('&2','.')+1)
                  ELSE
                      '&2'
                  END
                     ) ESCAPE '\'
        AND owner LIKE
            CASE WHEN INSTR('&2','.') > 0 THEN
              UPPER(SUBSTR('&2',1,INSTR('&2','.')-1))
            ELSE
              user
            END ESCAPE '\'
),
ind AS (SELECT /*+ MATERIALIZE */ owner, index_name, table_owner, table_name 
        FROM dba_indexes
        WHERE (table_owner, table_name) IN (SELECT owner, table_name FROM tab)),
sample_times AS (
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
  , ash.wait_class
  , ash.event
FROM
    v$active_session_history ash
WHERE
    1=1
AND ash.sql_plan_operation IN ('TABLE ACCESS', 'INDEX')
AND ash.sql_id LIKE '&1'
AND ash.sample_time BETWEEN &3 AND &4
GROUP BY
    ash.sql_id
  , ash.sql_child_number
  , ash.sql_plan_hash_value
  , NVL(ash.sql_plan_line_id,1)
  , ash.sql_plan_operation
  , ash.sql_plan_options
  , ash.session_state
  , ash.wait_class
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
--, LPAD(plan.id,4)||CASE WHEN parent_id IS NULL THEN '    ' ELSE ' <- ' END||LPAD(plan.parent_id,4) aindex_plan_id
  , plan.id aindex_id
  , plan.parent_id aindex_parent_id
  , plan.operation ||' '|| plan.options || NVL2(plan.object_name, ' ['||plan.object_owner||'.'||plan.object_name ||']', null) aindex_operation
  , plan.object_owner
  , plan.object_name
  , plan.object_type
  , plan.cardinality
  , stat.executions
  , stat.elapsed_time
  , sq.session_state
  , sq.wait_class
  , sq.event
  , plan.object_alias || CASE WHEN plan.qblock_name IS NOT NULL THEN ' ['|| plan.qblock_name || ']' END obj_alias_qbc_name
  , CASE WHEN plan.access_predicates IS NOT NULL THEN '[A:] '|| SUBSTR(plan.access_predicates,1,1994) END || CASE WHEN plan.filter_predicates IS NOT NULL THEN ' [F:] ' || SUBSTR(plan.filter_predicates,1,1994) END aindex_predicates
  , plan.projection
FROM
    v$sql_plan plan
  , v$sqlstats_plan_hash stat
  , sq
WHERE
    1=1
AND sq.sql_id(+) = plan.sql_id
AND sq.sql_child_number(+) = plan.child_number
AND sq.sql_plan_line_id(+) = plan.id
AND sq.sql_plan_hash_value(+) = plan.plan_hash_value
--
AND sq.sql_id(+) = stat.sql_id
AND sq.sql_plan_hash_value(+) = stat.plan_hash_value
AND stat.sql_id = plan.sql_id
AND stat.plan_hash_value = plan.plan_hash_value
--
AND plan.sql_id LIKE '&1'
----
)
SELECT * FROM (
    SELECT
        SUM(ap.seconds) seconds
      , ROUND(SUM(ap.seconds) / ((CAST(&4 AS DATE) - CAST(&3 AS DATE)) * 86400), 1) AAS
      , LPAD(TO_CHAR(ROUND(SUM(CASE WHEN ap.session_state = 'ON CPU'  THEN ap.seconds ELSE 0 END) / SUM(ap.seconds) * 100))||'%',4) cpu_pct
      , LPAD(TO_CHAR(ROUND(SUM(CASE WHEN ap.session_state = 'WAITING' THEN ap.seconds ELSE 0 END) / SUM(ap.seconds) * 100))||'%',4) wait_pct
      --, SUM(CASE WHEN ap.wait_class = 'User I/O'   THEN ap.seconds ELSE 0 END) iowait_sec
      , t.owner||'.'||table_name accessed_table
      , ap.aindex_operation
      , ap.cardinality plan_card
      , t.num_rows table_rows
      , ap.cardinality / NULLIF(t.num_rows,0) * 100 filter_pct
      , ap.executions sql_execs
      , ROUND(ap.elapsed_time / NULLIF(ap.executions,0) / 1000000,3) ela_sec_exec
      , ap.aindex_predicates
      , COUNT(DISTINCT ap.sql_id) dist_sqlids
      , COUNT(DISTINCT ap.plan_hash_value) dist_plans
      , MIN(ap.sql_id)
      , MAX(ap.sql_id)
      , ap.projection
    FROM
        ash_and_plan ap
      , (SELECT tab.*, 'TABLE' object_type, tab.owner object_owner, tab.table_name object_name FROM tab
         UNION ALL
         SELECT tab.*, 'INDEX', ind.owner object_owner, ind.index_name object_name 
         FROM tab, ind 
         WHERE tab.owner = ind.table_owner AND tab.table_name = ind.table_name
        ) t
    WHERE
       ap.object_owner = t.object_owner AND ap.object_name = t.object_name AND SUBSTR(ap.object_type,1,5) = t.object_type
    AND ap.seconds > 0
    GROUP BY
        t.owner
      , t.table_name
      , ap.aindex_operation
      , t.num_rows
      , ap.cardinality
      , ap.executions
      , ap.elapsed_time
      , ap.aindex_predicates
      , ap.projection
    ORDER BY
        seconds DESC
)
WHERE rownum <= 30
/
