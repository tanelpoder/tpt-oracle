-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

------------------------------------------------------------------------------------------------------------------------
--
-- File name:   daplanline.sql (v1.0)
--
-- Purpose:     Report response time consumption data from DBA_HIST_ACTIVE_SESS_HISTORY
--              by top SQL PLAN rowsource TYPE (not individual SQL)
--
-- Author:      Tanel Poder
--
-- Copyright:   (c) http://blog.tanelpoder.com - All rights reserved.
--
-- Disclaimer:  This script is provided "as is", no warranties nor guarantees are
--              made. Use at your own risk :)
--              
-- Usage:       @daplanline SYSDATE-1 SYSDATE
--              @daplanline DATE'2013-11-11' DATE'2013-11-12'
--              @daplanline "TIMESTAMP'2013-11-11 10:00:00'" "TIMESTAMP'2013-11-11 15:00:00'"
--                          ^^^- note the double quotes around the timestamp syntax, needed due to spaces
--
-- Notes:       This script runs on Oracle 11g+ and you should have the
--              Diagnostics and Tuning pack licenses for using it as it queries
--              some separately licensed views.
--
------------------------------------------------------------------------------------------------------------------------
SET LINESIZE 999 PAGESIZE 5000 TRIMOUT ON TRIMSPOOL ON 

COL asqlmon_operation FOR a100
COL asqlmon_predicates FOR a100 word_wrap
COL options   FOR a30

COL asqlmon_plan_hash_value HEAD PLAN_HASH_VALUE
COL asqlmon_sql_id          HEAD SQL_ID  NOPRINT
COL asqlmon_sql_child       HEAD CHILD#  NOPRINT
COL asqlmon_sample_time     HEAD SAMPLE_HOUR
COL projection FOR A520

COL pct_child HEAD "Activity %" FOR A8
COL pct_child_vis HEAD "Visual" FOR A12

COL asqlmon_id        HEAD "Line ID" FOR 9999
COL asqlmon_parent_id HEAD "Parent"  FOR 9999
COL daplanline_plan_line FOR A60 HEAD "Plan Line"

BREAK ON asqlmon_plan_hash_value SKIP 1 ON asqlmon_sql_id SKIP 1 ON asqlmon_sql_child SKIP 1 ON asqlmon_sample_time SKIP 1 DUP ON asqlmon_operation

WITH sq AS (
SELECT
  --  to_char(ash.sample_time, 'YYYY-MM-DD HH24') sample_time
    count(*) samples
  , ash.sql_plan_operation
  , ash.sql_plan_options
  , ash.session_state
  , ash.event
FROM
    dba_hist_active_sess_history ash
WHERE
    sample_time BETWEEN &1 AND &2
AND snap_id IN (SELECT snap_id FROM dba_hist_snapshot WHERE begin_interval_time >= &1 AND end_interval_time <= &2)
AND session_type = 'FOREGROUND'
GROUP BY
  --to_char(ash.sample_time, 'YYYY-MM-DD HH24')
    ash.sql_plan_operation
  , ash.sql_plan_options
  , ash.session_state
  , ash.event
)
SELECT * FROM (
    SELECT
        sq.samples * 10 seconds
      , LPAD(TO_CHAR(ROUND(RATIO_TO_REPORT(sq.samples) OVER () * 100, 1), 999.9)||' %',8) pct_child
      , '|'||RPAD( NVL( LPAD('#', ROUND(RATIO_TO_REPORT(sq.samples) OVER () * 10), '#'), ' '), 10,' ')||'|' pct_child_vis
      --, sq.sample_time         asqlmon_sample_time
      , sq.sql_plan_operation ||' '|| sq.sql_plan_options daplanline_plan_line
      , sq.session_state
      , sq.event
    FROM
        sq
    WHERE
        1=1
    ORDER BY
      --sq.sample_time
      seconds DESC
)
WHERE
    rownum <= 30
/
