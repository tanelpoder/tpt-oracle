-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL begin_interval_time FOR A30
COL end_interval_time FOR A30
COL stat_name FOR A50


SELECT
    TO_CHAR(end_interval_time, 'YYYY-MM-DD HH24:MI:SS') snap_end_time
  , component
  , oper_type
  , TO_CHAR(start_time, 'YYYY-MM-DD HH24:MI:SS') start_time
  , TO_CHAR(end_time,   'YYYY-MM-DD HH24:MI:SS') end_time
  , target_size
  , oper_mode
  , parameter
  , initial_size
  , final_size
  , status
FROM
     dba_hist_memory_resize_ops
   NATURAL JOIN
     dba_hist_snapshot
WHERE
    begin_interval_time >= &1
AND end_interval_time   <= &2
ORDER BY
    snap_end_time
/

