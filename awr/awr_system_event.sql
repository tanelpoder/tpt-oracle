-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT
    CAST(begin_interval_time AS DATE) begin_time
  , event_name
  , time_waited_micro
  , total_waits
  , total_timeouts
  , time_waited_micro/nullif(total_waits,0) avg_wait_micro
FROM
    dba_hist_snapshot
NATURAL JOIN
    dba_hist_system_event
WHERE
    event_name IN ('log file sync', 'log file parallel write', 'ksfd: async disk IO') 
AND begin_interval_time > SYSDATE - 15
ORDER BY
    event_name
  , begin_time
/

