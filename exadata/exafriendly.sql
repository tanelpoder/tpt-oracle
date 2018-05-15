-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
-- File name:   exafriendly.sql (report non-exadata-friendly SQL and their stats)
--
-- Purpose:     This script is a collection of queries against ASH, which will
--              report and drill down into workloads which don't use Exadata smart
--              scanning and are doing buffered full table scans or random single 
--              block reads instead. It uses the 11g new ASH columns
--              (SQL_PLAN_OPERATION, SQL_PLAN_OPTIONS) which give SQL plan line
--              level activity breakdown.
--
--              Note that this script is not a single SQL performance diagnosis tool,
--              for looking into a single SQL, use the SQL Monitoring report. This 
--              exafriendly.sql script is aimed for giving you a high-level
--              bird's-eye view of "exadata-friendiness" of your workloads, so you'd 
--              detect systemic problems and drill down where needed.
--
-- Usage:       @exafriendly.sql <ash_data_source>
--
-- Examples:    @exafriendly.sql gv$active_session_history
--                       
--              @exafriendly.sql "dba_hist_active_sess_history WHERE snap_time > SYSDATE-1"
--
-- Author:      Tanel Poder ( http://blog.tanelpoder.com | tanel@tanelpoder.com )
--
-- Copyright:   (c) 2012 All Rights Reserved
-- 
--
-- Other:       I strongly recommend you to read through the script to understand
--              what it's doing and how the drilldown happens. You likely need
--              to customize things (or at least adjust filters) when you diagnose
--              stuff in your environment.
--   
--------------------------------------------------------------------------------

set timing on tab off verify off linesize 999 pagesize 5000 trimspool on trimout on null ""

COL wait_class FOR A20
COL event FOR A40
COL plan_line FOR A40
COL command_name FOR A15
COL pct FOR 999.9

define ash=&1

SELECT MAX(sample_time) - MIN(sample_time) 
FROM &ash
/

PROMPT Report the top active SQL statements regardless of their CPU usage/wait event breakdown
SELECT * FROM (
    SELECT 
        sql_id
      , SUM(1) seconds
      , ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1) pct 
    FROM &ash
    WHERE
        session_type = 'FOREGROUND'
    GROUP BY
        sql_id
    ORDER BY 
        seconds DESC
)
WHERE
    rownum <= 10
/

PROMPT Report the top session state/wait class breakdown
SELECT * FROM (
    SELECT 
        session_state,wait_class
      , SUM(1) seconds
      , ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1) pct 
    FROM &ash 
    GROUP BY
            session_state,wait_class
    ORDER BY 
        seconds DESC
)
WHERE
    rownum <= 10
/

PROMPT Report the top session state/wait event breakdown (just like TOP-5 Timed Events in AWR)
SELECT * FROM (
    SELECT 
        session_state,wait_class,event
      , SUM(1) seconds
      , ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1) pct 
    FROM &ash 
    GROUP BY
            session_state,wait_class,event
    ORDER BY 
        seconds DESC
)
WHERE
    rownum <= 10
/

PROMPT Report the top SQL waiting for buffered single block reads
SELECT * FROM (
    SELECT 
        session_state,wait_class,event,sql_id
      , SUM(1) seconds
      , ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1) pct 
    FROM &ash 
    WHERE
         session_state = 'WAITING'
    AND  event = 'cell single block physical read'
    GROUP BY
        session_state,wait_class,event,sql_id
    ORDER BY 
        seconds DESC
)
WHERE
    rownum <= 10
/

PROMPT Report the top SQL waiting for buffered single block reads the most (with sampled execution count)
SELECT * FROM (
    SELECT 
        sql_plan_operation||' '||sql_plan_options plan_line,event,sql_id
      , COUNT(DISTINCT(sql_exec_id)) noticed_executions
      , SUM(1) seconds
      , ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1) pct 
    FROM &ash 
    WHERE
         session_state = 'WAITING'
    AND  event = 'cell single block physical read'
    GROUP BY
        sql_plan_operation||' '||sql_plan_options,event,sql_id
    ORDER BY 
        seconds DESC
)
WHERE
    rownum <= 10
/

PROMPT Report what kind of SQL execution plan operations, executed by which user wait for buffered single block reads the most
SELECT * FROM (
    SELECT 
        sql_plan_operation||' '||sql_plan_options plan_line,u.username,event
      , SUM(1) seconds
      , ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1) pct 
    FROM &ash a
       , dba_users u
    WHERE
         a.user_id = u.user_id 
    AND  session_state = 'WAITING'
    AND  event = 'cell single block physical read'
    GROUP BY
        sql_plan_operation||' '||sql_plan_options,event,u.username
    ORDER BY 
        seconds DESC
)
WHERE
    rownum <= 10
/

PROMPT Report what kind of execution plan operations wait for buffered single block reads
SELECT * FROM (
    SELECT 
        sql_plan_operation||' '||sql_plan_options plan_line,event
      , SUM(1) seconds
      , ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1) pct 
    FROM &ash 
    WHERE
         session_state = 'WAITING'
    AND  event = 'cell single block physical read'
    GROUP BY
        sql_plan_operation||' '||sql_plan_options,event
    ORDER BY 
        seconds DESC
)
WHERE
    rownum <= 10
/


PROMPT Report what kind of execution plan operations wait for buffered single block reads - against which schemas
SELECT * FROM (
    SELECT
        sql_plan_operation||' '||sql_plan_options plan_line,p.object_owner,event
      , SUM(1) seconds
      , ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1) pct
    FROM
        v$active_session_history a
      , v$sql_plan p
    WHERE
         a.sql_id = p.sql_id
    AND  a.sql_child_number = p.child_number
    AND  a.sql_plan_line_id = p.id
    AND  session_state = 'WAITING'
    AND  event = 'cell single block physical read'
    GROUP BY
        sql_plan_operation||' '||sql_plan_options,p.object_owner,event
    ORDER BY
        seconds DESC
)
WHERE
    rownum <= 10
/

PROMPT Report what kind of execution plan operations wait for buffered single block reads - against which objects
SELECT * FROM (
    SELECT
        sql_plan_operation||' '||sql_plan_options plan_line,p.object_owner,p.object_name,event
      , SUM(1) seconds
      , ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1) pct
    FROM
        v$active_session_history a
      , v$sql_plan p
    WHERE
         a.sql_id = p.sql_id
    AND  a.sql_child_number = p.child_number
    AND  a.sql_plan_line_id = p.id
    AND  session_state = 'WAITING'
    AND  event = 'cell single block physical read'
    GROUP BY
        sql_plan_operation||' '||sql_plan_options,p.object_owner,p.object_name,event
    ORDER BY
        seconds DESC
)
WHERE
    rownum <= 10
/

PROMPT Report which SQL command type consumes the most time (broken down by wait class) 
SELECT * FROM (
    SELECT 
        command_name,session_state,wait_class
      , SUM(1) seconds
      , ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1) pct 
    FROM &ash, v$sqlcommand
    WHERE &ash..sql_opcode = v$sqlcommand.command_type 
    GROUP BY
        command_name,session_state,wait_class
    ORDER BY 
        seconds DESC
)
WHERE
    rownum <= 10
/

PROMPT Report what kind of execution plan operations wait for buffered multiblock reads the most
SELECT * FROM (
    SELECT
        sql_plan_operation||' '||sql_plan_options plan_line,event
      , SUM(1) seconds
      , ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1) pct
    FROM
        &ash
    WHERE
        session_state = 'WAITING'
    AND event = 'cell multiblock physical read'
    GROUP BY
        sql_plan_operation||' '||sql_plan_options,event
    ORDER BY
        seconds DESC
)
WHERE
    rownum <= 10
/

PROMPT Report what kind of execution plan operations wait for buffered multiblock reads - against which objects
SELECT * FROM (
    SELECT
        sql_plan_operation||' '||sql_plan_options plan_line,p.object_owner,p.object_name,event
      , SUM(1) seconds
      , ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1) pct
    FROM
        v$active_session_history a
      , v$sql_plan p
    WHERE
         a.sql_id = p.sql_id
    AND  a.sql_child_number = p.child_number
    AND  a.sql_plan_line_id = p.id
    AND  session_state = 'WAITING'
    AND  event = 'cell multiblock physical read'
    GROUP BY
        sql_plan_operation||' '||sql_plan_options,p.object_owner,p.object_name,event
    ORDER BY
        seconds DESC
)
WHERE
    rownum <= 10
/

PROMPT Report any PARALLEL full table scans which use buffered reads (in-memory PX)
SELECT * FROM (
    SELECT
        sql_id
      , sql_plan_operation||' '||sql_plan_options plan_line
      , CASE WHEN qc_session_id IS NULL THEN 'SERIAL' ELSE 'PARALLEL' END is_parallel
    --  , px_flags
      , session_state
      , wait_class
      , event
      , COUNT(*)
      , ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1) pct
    FROM &ash
    WHERE
        sql_plan_operation = 'TABLE ACCESS'
    AND sql_plan_options = 'STORAGE FULL'
    AND session_state = 'WAITING'
    AND event IN ('cell single block physical read', 'cell multiblock physical read', 'cell list of blocks physical read')
    AND qc_session_id IS NOT NULL  -- is a px session
    GROUP BY
        sql_id
      , sql_plan_operation||' '||sql_plan_options
      , CASE WHEN qc_session_id IS NULL THEN 'SERIAL' ELSE 'PARALLEL' END --is_parallel
    --  , px_flags
      , session_state
      , wait_class
      , event
    ORDER BY COUNT(*) DESC
    )
WHERE rownum <= 20
/

DEF sqlid=4mpjt2rhwd1p4
PROMPT Report a single SQL_ID &sqlid

SELECT * FROM (
    SELECT 
        sql_plan_operation||' '||sql_plan_options plan_line,session_state,event
      , SUM(1) seconds
      , ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1) pct 
    FROM &ash 
    WHERE
         sql_id = '&sqlid'
    GROUP BY
        sql_plan_operation||' '||sql_plan_options,session_state,event
    ORDER BY 
        seconds DESC
)
WHERE
    rownum <= 10
/

