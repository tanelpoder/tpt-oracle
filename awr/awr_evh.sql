-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

BREAK ON snap_begin SKIP 1 ON snap_end ON event_name

COL event_name FOR A40

SELECT
    CAST(begin_interval_time AS DATE) snap_begin
  , TO_CHAR(CAST(end_interval_time AS DATE), 'HH24:MI') snap_end
  , event_name
  , wait_time_milli 
  , CASE WHEN wait_count >= LAG(wait_count) OVER (PARTITION BY event_name,wait_time_milli ORDER BY CAST(begin_interval_time AS DATE)) THEN
        wait_count - LAG(wait_count) OVER (PARTITION BY event_name,wait_time_milli ORDER BY CAST(begin_interval_time AS DATE)) 
    ELSE
        wait_count
    END wait_count
FROM
    dba_hist_snapshot
  NATURAL JOIN
    dba_hist_event_histogram
WHERE
    begin_interval_time > SYSDATE - 1/24
--AND event_name LIKE 'ASM file metadata operation'
--AND event_name LIKE 'flashback log switch'
-- AND event_name LIKE 'KSV master wait'
AND wait_class = 'User I/O'
ORDER BY
    event_name
  , snap_begin
  , wait_time_milli
/

