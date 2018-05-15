-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

PROMPT List background I/O write priorities and reasons from X$KCBBES...
PROMPT (X$KCBBES = Kerncel Cache Buffers dB writer Event Statistics)

SELECT
    indx
  , CASE indx
      WHEN 0  THEN 'Invalid Reason'
      WHEN 1  THEN 'Ping Write'
      WHEN 2  THEN 'High Prio Thread Ckpt'
      WHEN 3  THEN 'Instance Recovery Ckpt'
      WHEN 4  THEN 'Med Prio (incr) Ckpt'
      WHEN 5  THEN 'Aging Writes'
      WHEN 6  THEN 'Media Recovery Ckpt'
      WHEN 7  THEN 'Low Prio Thread Ckpt'
      WHEN 8  THEN 'Tablespace Ckpt'
      WHEN 9  THEN 'Reuse Object Ckpt'
      WHEN 10 THEN 'Reuse Block Range Ckpt'
      WHEN 11 THEN 'Limit Dirty Buff Ckpt'
      WHEN 12 THEN 'Smart Scan Ckpt'
      WHEN 14 THEN 'Direct Path Read Ckpt'
    END reason_name
  , reason reason_buffers
  , ROUND(NULLIF(RATIO_TO_REPORT(reason) OVER () * 100,0), 1) "REASON%"
  , CASE indx
      WHEN 0  THEN 'Invalid Priority'
      WHEN 1  THEN 'High Priority'
      WHEN 2  THEN 'Medium Priority'
      WHEN 3  THEN 'Low Priority'
    END priority_name
  , priority priority_buffers
  , ROUND(NULLIF(RATIO_TO_REPORT(priority) OVER () * 100,0), 1) "PRIO%"
  , CASE indx
      WHEN 0  THEN 'Queued For Writing'
      WHEN 1  THEN 'Deferred (log file sync)'
      WHEN 2  THEN 'Already being written'
      WHEN 3  THEN 'Buffer not dirty'
      WHEN 4  THEN 'Buffer is pinned'
      WHEN 5  THEN 'I/O limit reached'
      WHEN 6  THEN 'Buffer logically flushed'
      WHEN 7  THEN 'No free IO slots'
    END io_proc_status
  , savecode io_count
  , ROUND(NULLIF(RATIO_TO_REPORT(savecode) OVER () * 100,0), 1) "STATUS%"
FROM
    x$kcbbes
/
