-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- EST_TIME_S column is a rough ESTIMATE of total wait time consumed by waits in a latency bucket
-- it assumes random distribution of event latencies between adjacent buckets which may not be the
-- case in reality

COL evh_event HEAD WAIT_EVENT
COL evh_est_time HEAD "EST_TIME_S*"
COL wait_count_graph FOR A22
COL evh_wait_time_milli HEAD WAIT_TIME_MILLI FOR A15 JUST RIGHT
BREAK ON evh_event SKIP 1

SELECT
    event             evh_event 
  , LPAD('< ' ||wait_time_milli, 15)  evh_wait_time_milli
  , wait_count 
  , CASE WHEN wait_count = 0 THEN NULL ELSE ROUND(wait_time_milli * wait_count * CASE WHEN wait_time_milli = 1 THEN 0.5 ELSE 0.75 END / 1000, 3) END evh_est_time
  , last_update_time   -- 11g
fROM
    v$event_histogram
WHERE
    regexp_like(event, '&1', 'i')
ORDER BY
    event
  , wait_time_milli
/
