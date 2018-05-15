-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT
    CAST(begin_interval_time AS DATE) begin_time
  , AVG(CASE WHEN event_name = 'log file sync' THEN time_waited_micro/nullif(total_waits,0) END) avg_log_file_sync
  , AVG(CASE WHEN event_name = 'log file parallel write' THEN time_waited_micro/nullif(total_waits,0) END) avg_log_file_parallel_write
FROM
    dba_hist_snapshot
NATURAL JOIN
    dba_hist_system_event
WHERE
    event_name IN ('log file sync', 'log file parallel write')
AND begin_interval_time > SYSDATE - 15
GROUP BY CAST(begin_interval_time AS DATE)
ORDER BY
    begin_time
/

