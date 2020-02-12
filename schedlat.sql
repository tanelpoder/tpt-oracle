-- Copyright 2020 Tanel Poder. All rights reserved. More info at https://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms and conditions.

-- Name:    schedlat.sql
-- Purpose: List PSP0 process scheduling latency test results (where scheduling latency is not 0)
-- Other:   Oracle 12c+ PSP0 process regularly (voluntarily) goes to sleep for 1000 microseconds
--          taking a high resolution system timestamp just before going to sleep and right after
--          getting back onto CPU. Usin these timestamps it checks if it managed to wake up 
--          "exactly" 1000 usec later or

PROMPT Listing recent non-zero scheduling delays from X$KSO_SCHED_DELAY_HISTORY

SELECT 
    MIN(sample_start_time) history_begin_time, MAX(sample_end_time) history_end_time
  , MAX(sched_delay_micro) max_latency_us
  , AVG(sched_delay_micro) avg_latency_us
FROM
    sys.x$kso_sched_delay_history
/

PROMPT Any noticed scheduling delays during the in-memory history window are listed below:

SELECT 
    sample_start_time
  , sample_end_time
  , sched_delay_micro
FROM
    sys.x$kso_sched_delay_history
WHERE
    sched_delay_micro != 0
/

