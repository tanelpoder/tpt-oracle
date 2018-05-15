-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- this scripts uses "ASH math" by Graham Wood, Uri Shaft and John Beresniewicz for
-- estimating the event counts (and average durations)

COL evh_event HEAD WAIT_EVENT for A50 TRUNCATE
COL evh_graph HEAD "Event|Breakdown" JUST CENTER FOR A12
COL evh_cell_graph HEAD "Cell Event|Breakdown" JUST CENTER FOR A12
COL pct_cell_time HEAD "% Cell|Time"
COL pct_evt_time HEAD "% Event|Time"
COL evh_est_total_ms HEAD "Estimated|Total ms"
COL evh_millisec HEAD "Wait time|bucket ms+" FOR 999999
COL evh_event HEAD "Wait Event"
COL evh_sample_count HEAD "Num ASH|Samples"
COL evh_est_event_count HEAD "Estimated|Total Waits"
COL evh_cell_path HEAD "Cell Path" FOR A16

BREAK ON evh_event SKIP 1 ON evh_cell_path SKIP 1 NODUPLICATES

SELECT 
    event evh_event
  , cell_path evh_cell_path
  , CASE WHEN time_waited = 0 THEN 0 ELSE TRUNC(POWER(2,TRUNC(LOG(2,time_waited/1000)))) END evh_millisec
  , COUNT(*)  evh_sample_count
  , ROUND(SUM(CASE WHEN time_waited >= 1000000 THEN 1 WHEN time_waited = 0 THEN 0 ELSE 1000000 / time_waited END),1) evh_est_event_count
  , ROUND(CASE WHEN time_waited = 0 THEN 0 ELSE TRUNC(POWER(2,TRUNC(LOG(2,time_waited/1000)))) END * COUNT(*),1) evh_est_total_ms
  , ROUND ( 100 * RATIO_TO_REPORT( CASE WHEN time_waited = 0 THEN 0 ELSE TRUNC(POWER(2,TRUNC(LOG(2,time_waited/1000)))) END * COUNT(*) ) OVER (PARTITION BY event) , 1 ) pct_evt_time
  , '|'||RPAD(NVL(RPAD('#', ROUND (10 * RATIO_TO_REPORT( CASE WHEN time_waited = 0 THEN 0 ELSE TRUNC(POWER(2,TRUNC(LOG(2,time_waited/1000)))) END * COUNT(*) ) OVER (PARTITION BY event)), '#'),' '), 10)||'|' evh_graph
  , ROUND ( 100 * RATIO_TO_REPORT( CASE WHEN time_waited = 0 THEN 0 ELSE TRUNC(POWER(2,TRUNC(LOG(2,time_waited/1000)))) END * COUNT(*) ) OVER (PARTITION BY event, cell_path) , 1 ) pct_cell_time
  , '|'||RPAD(NVL(RPAD('#', ROUND (10 * RATIO_TO_REPORT( CASE WHEN time_waited = 0 THEN 0 ELSE TRUNC(POWER(2,TRUNC(LOG(2,time_waited/1000)))) END * COUNT(*) ) OVER (PARTITION BY event, cell_path)), '#'),' '), 10)||'|' evh_cell_graph
FROM 
    v$cell
  , V$ACTIVE_SESSION_HISTORY 
    --dba_hist_active_sess_history
WHERE 
    regexp_like(event, '&1') 
AND v$cell.cell_hashval = v$active_session_history.p1
AND sample_time > SYSDATE - 1
AND time_waited > 0  -- TODO
GROUP BY 
    event
  , cell_path
  , CASE WHEN time_waited = 0 THEN 0 ELSE TRUNC(POWER(2,TRUNC(LOG(2,time_waited/1000)))) END -- evh_millisec
ORDER BY 1, 2
/

