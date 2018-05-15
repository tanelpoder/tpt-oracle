-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SET TERMOUT OFF pagesize 5000 tab off verify off linesize 999 trimspool on trimout on null ""
SET TERMOUT ON

SELECT
    CAST(begin_interval_time AS DATE) sample_time
  , sql_id
  , plan_hash_value
  , ROUND(SUM(executions_delta    )        / ((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400), 1) exec_per_sec
  , ROUND(SUM(elapsed_time_delta  ) / 1000 / ((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400), 1) ela_ms_per_sec
  , ROUND(SUM(rows_processed_delta)        / ((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400), 1) rows_per_sec
  , ROUND(SUM(buffer_gets_delta   )        / ((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400), 1) lios_per_sec
  , ROUND(SUM(disk_reads_delta    )        / ((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400), 1) blkrd_per_sec
  , ROUND(SUM(cpu_time_delta      ) / 1000 / ((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400), 1) cpu_ms_per_sec
  , ROUND(SUM(iowait_delta        ) / 1000 / ((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400), 1) iow_ms_per_sec
  , ROUND(SUM(clwait_delta        ) / 1000 / ((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400), 1) clw_ms_per_sec
  , ROUND(SUM(apwait_delta        ) / 1000 / ((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400), 1) apw_ms_per_sec
  , ROUND(SUM(ccwait_delta        ) / 1000 / ((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400), 1) ccw_ms_per_sec
  , CAST(end_interval_time AS DATE) sample_end_time
FROM
    dba_hist_snapshot sn
  , dba_hist_sqlstat st
WHERE
    sn.snap_id = st.snap_id
AND sn.dbid    = st.dbid
AND sn.instance_number = st.instance_number
AND sql_id = '&1'
AND plan_hash_value LIKE '&2'
AND begin_interval_time >= &3
AND end_interval_time   <= &4
GROUP BY
    CAST(begin_interval_time AS DATE)
  , CAST(end_interval_time AS DATE)
  , sql_id
  , plan_hash_value
ORDER BY
    sample_time
  , sql_id
  , plan_hash_value
/

