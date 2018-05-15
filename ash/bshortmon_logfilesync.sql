-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL wait_class FOR a15
COL event FOR a55
COL time_range  HEAD "WAIT_TIM_BUCKET_US+" FOR 999,999,999,999
COL avg_wait_us HEAD "AVG_WAIT_IN_BKT_US" FOR 999,999,999,999
COL pct_event FOR a9
COL pct_total FOR a9

BREAK ON event SKIP 1 DUPLICATES

-- TODO: ignore latest sample (0 waits)

SELECT 
    session_state state
  , wait_class
  , event
  , ROUND(AVG(time_waited)) avg_wait_us
  , POWER(2,TRUNC(LOG(2,CASE WHEN time_waited < 1 THEN NULL ELSE time_waited END))) time_range
  , COUNT(*) samples
  , LPAD(TO_CHAR(TO_NUMBER(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER (PARTITION BY session_state, wait_class, event) * 100, 1), 999.9))||' %',8) pct_event
  , '|'||RPAD( NVL( LPAD('#', ROUND(RATIO_TO_REPORT(COUNT(*)) OVER (PARTITION BY session_state, wait_class, event) * 10), '#'), ' '), 10,' ')||'|' pct_event_vis
  , LPAD(TO_CHAR(TO_NUMBER(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1), 999.9))||' %',8) pct_total 
  , '|'||RPAD( NVL( LPAD('#', ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 10), '#'), ' '), 10,' ')||'|' pct_total_vis
FROM
    dba_hist_ash_aug
    --gv$active_session_history
    --DBA_HIST_ACTIVE_SESS_HISTORY
WHERE
    &2
AND sample_time BETWEEN &3 AND &4
--AND sample_time BETWEEN TIMESTAMP'2013-10-01 13:54:00' AND TIMESTAMP'2013-10-01 13:55:00'
AND (UPPER(wait_class) LIKE UPPER('%&1%') OR UPPER(event) LIKE UPPER('%&1%'))
--AND program LIKE 'sqlplus%'
GROUP BY
    session_state
  , wait_class
  , event
  , POWER(2,TRUNC(LOG(2,CASE WHEN time_waited < 1 THEN NULL ELSE time_waited END)))
ORDER BY
    session_state
  , wait_class
  , event
  , time_range NULLS FIRST
  , samples DESC
/

