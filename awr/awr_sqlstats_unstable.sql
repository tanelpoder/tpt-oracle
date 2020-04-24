-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- @awr/awr_sqlstats_unstable.sql version 0.1 BETA by Tanel Poder
--
-- detect sql_id that use a varying amount of *elapsed time per execution* across different plan hash values
-- or across AWR time ranges
--
-- usage examples:
-- a) typical use - show SQL_IDs from last 2 weeks that have different plans with different
--                  elapsed time per execution (per plan)
-- 
--   @awr/awr_sqlstats_unstable sql_id plan_hash_value sysdate-14 sysdate
--
-- b) special case use with SQL using literals (note that AWR may not persist many of these queries)
--    as due to literals these tend to be executed only once
--
--   @awr/awr_sqlstats_unstable force_matching_signature plan_hash_value sysdate-14 sysdate
--
-- c) advanced use - show cases where *the same plan* (same plan hash value) uses different amounts
--                   of elapsed time per execution over time. so it's not a *plan* flipping problem
--
--   @awr/awr_sqlstats_unstable sql_id,plan_hash_value begin_interval_time sysdate-14 sysdate
--
--  Once you have found a SQL_ID of interest, you can drill down into its actual plans and elapsed times using:
-- 
--   @awr/awr_sqlstats_per_exec &sqlid % sysdate-14 sysdate
-- 
--
-- other:
--   Inspired by Kerry Osborne's unstable_plans.sql script - http://kerryosborne.oracle-guy.com/2008/10/unstable-plans/
--

SET TERMOUT OFF pagesize 5000 tab off verify off linesize 999 trimspool on trimout on null ""
SET TERMOUT ON

COL force_matching_signature FOR 99999999999999999999

WITH metrics AS(
    SELECT
        &1
      , MIN(CAST(begin_interval_time AS DATE)) first_seen
      , MAX(CAST(end_interval_time   AS DATE)) last_seen
      , SUM(executions_delta)     executions
      , ROUND(SUM(elapsed_time_delta  ) / CASE WHEN SUM(executions_delta) = 0 THEN 1 ELSE SUM(executions_delta) END) ela_us_per_exec
      , ROUND(SUM(cpu_time_delta      ) / NULLIF(SUM(executions_delta),0))      cpu_us_per_exec
      , ROUND(SUM(rows_processed_delta) / NULLIF(SUM(executions_delta),0),1)    rows_per_exec
      , ROUND(SUM(buffer_gets_delta   ) / NULLIF(SUM(executions_delta),0),1)    lios_per_exec
      , ROUND(SUM(disk_reads_delta    ) / NULLIF(SUM(executions_delta),0),1)    blkrd_per_exec
      , ROUND(SUM(iowait_delta        ) / NULLIF(SUM(executions_delta),0))      iow_us_per_exec
      , ROUND(SUM(iowait_delta        ) / NULLIF(SUM(physical_read_requests_delta)+SUM(physical_write_requests_delta),0),1) avg_iow_us
      , ROUND(SUM(clwait_delta        ) / NULLIF(SUM(executions_delta),0))      clw_us_per_exec
      , ROUND(SUM(apwait_delta        ) / NULLIF(SUM(executions_delta),0))      apw_us_per_exec
      , ROUND(SUM(ccwait_delta        ) / NULLIF(SUM(executions_delta),0))      ccw_us_per_exec
    FROM
        dba_hist_snapshot sn
      , dba_hist_sqlstat st
    WHERE
    -- join conditions
        sn.snap_id         = st.snap_id
    AND sn.dbid            = st.dbid
    AND sn.instance_number = st.instance_number
    -- filter conditions
    AND executions_delta > 0
    AND begin_interval_time >= &3
    AND end_interval_time   <= &4
    GROUP BY
        &1, &2
)
, sq AS (
    SELECT
        &1
      , executions
      , ela_us_per_exec
      , STDDEV(ela_us_per_exec) OVER (PARTITION BY &1) ela_us_stddev
    FROM 
        metrics
), norm AS (
    SELECT
        &1
      , SUM(executions)                             total_executions
      , MIN(ela_us_per_exec) / 1000000              min_s_per_exec
      , MAX(ela_us_per_exec) / 1000000              max_s_per_exec
      , ela_us_stddev        / MIN(ela_us_per_exec) ela_norm_stddev
      , ela_us_stddev        / 1000000              seconds_stddev
    FROM
    		sq
    GROUP BY
    		&1
      , ela_us_stddev
)
SELECT
    *
FROM
		norm
WHERE
    ela_norm_stddev > 3
AND max_s_per_exec  > 1  -- avoid reporting very short queries
ORDER BY
    ela_norm_stddev DESC
/

