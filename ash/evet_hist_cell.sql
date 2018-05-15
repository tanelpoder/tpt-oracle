-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- this scripts uses "ASH math" by Graham Wood, Uri Shaft and John Beresniewicz for
-- estimating the event counts (and average durations)

COL evh_event HEAD WAIT_EVENT for A50 TRUNCATE
COL evh_graph HEAD "Awesome|Graphic" JUST CENTER FOR A12
COL pct_evt_time HEAD "% Event|Time"
COL evh_est_total_ms HEAD "Estimated|Total ms"
COL evh_millisec HEAD "Wait time|bucket ms+"
COL evh_event HEAD "Wait Event"
COL evh_sample_count HEAD "Num ASH|Samples"
COL evh_est_event_count HEAD "Estimated|Total Waits"

BREAK ON evh_event SKIP 1

SELECT 
    event evh_event
  , CASE WHEN time_waited = 0 THEN 0 ELSE TRUNC(POWER(2,TRUNC(LOG(2,time_waited/1000)))) END evh_millisec
  , COUNT(*)  evh_sample_count
  , ROUND(SUM(CASE WHEN time_waited >= 1000000 THEN 1 WHEN time_waited = 0 THEN 0 ELSE 1000000 / time_waited END),1) evh_est_event_count
  , ROUND(CASE WHEN time_waited = 0 THEN 0 ELSE TRUNC(POWER(2,TRUNC(LOG(2,time_waited/1000)))) END * COUNT(*),1) evh_est_total_ms
  , ROUND ( 100 * RATIO_TO_REPORT( CASE WHEN time_waited = 0 THEN 0 ELSE TRUNC(POWER(2,TRUNC(LOG(2,time_waited/1000)))) END * COUNT(*) ) OVER (PARTITION BY event) , 1 ) pct_evt_time
  , '|'||RPAD(NVL(RPAD('#', ROUND (10 * RATIO_TO_REPORT( CASE WHEN time_waited = 0 THEN 0 ELSE TRUNC(POWER(2,TRUNC(LOG(2,time_waited/1000)))) END * COUNT(*) ) OVER (PARTITION BY event)), '#'),' '), 10)||'|' evh_graph
FROM 
    V$ACTIVE_SESSION_HISTORY 
    --dba_hist_active_sess_history
WHERE 
    regexp_like(event, '&1') 
AND sample_time > SYSDATE - 1
AND time_waited > 0  -- TODO
GROUP BY 
    event
  , CASE WHEN time_waited = 0 THEN 0 ELSE TRUNC(POWER(2,TRUNC(LOG(2,time_waited/1000)))) END -- evh_millisec
ORDER BY 1, 2
/

