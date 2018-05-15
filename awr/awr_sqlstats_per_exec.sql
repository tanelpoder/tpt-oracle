-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SET TERMOUT OFF pagesize 5000 tab off verify off linesize 999 trimspool on trimout on null ""
SET TERMOUT ON

SELECT
    CAST(begin_interval_time AS DATE) sample_time
  , sql_id
  , plan_hash_value
  , SUM(executions_delta)     executions
  , ROUND(SUM(elapsed_time_delta  ) / NULLIF(SUM(executions_delta),0)/1000) ela_ms_per_exec
  , ROUND(SUM(cpu_time_delta      ) / NULLIF(SUM(executions_delta),0)/1000) cpu_ms_per_exec
  , ROUND(SUM(rows_processed_delta) / NULLIF(SUM(executions_delta),0),1)    rows_per_exec
  , ROUND(SUM(buffer_gets_delta   ) / NULLIF(SUM(executions_delta),0),1)    lios_per_exec
  , ROUND(SUM(disk_reads_delta    ) / NULLIF(SUM(executions_delta),0),1)    blkrd_per_exec
  , ROUND(SUM(iowait_delta        ) / NULLIF(SUM(executions_delta),0)/1000) iow_ms_per_exec
  , ROUND(SUM(iowait_delta        ) / NULLIF(SUM(physical_read_requests_delta)+SUM(physical_write_requests_delta),0)/1000,1) avg_iow_ms
  , ROUND(SUM(clwait_delta        ) / NULLIF(SUM(executions_delta),0)/1000) clw_ms_per_exec
  , ROUND(SUM(apwait_delta        ) / NULLIF(SUM(executions_delta),0)/1000) apw_ms_per_exec
  , ROUND(SUM(ccwait_delta        ) / NULLIF(SUM(executions_delta),0)/1000) ccw_ms_per_exec
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
  , sql_id
  , plan_hash_value
ORDER BY
    sample_time
  , sql_id
  , plan_hash_value
/

