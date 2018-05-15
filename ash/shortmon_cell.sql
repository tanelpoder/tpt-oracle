-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- shortmon_cell.sql : script by Tanel Poder (http://blog.tanelpoder.com)

COL wait_class FOR a15
COL event FOR a35
COL time_range  HEAD "WAIT_TIM_BUCKET_US+" FOR A26 JUST RIGHT
COL avg_wait_us HEAD "AVG_WAIT_IN_BKT_US" FOR 9,999,999,999
COL pct_event FOR a9
COL pct_total FOR a9
COL cell_path FOR a16
BREAK ON state ON wait_class ON event SKIP 1 NODUPLICATES ON CELL_PATH SKIP 1

-- TODO: ignore latest sample (0 waits)

SELECT /* (hint disabled) LEADING(@"SEL$4" "S"@"SEL$4" "A"@"SEL$4") USE_HASH(@"SEL$4" "A"@"SEL$4") */
    session_state state
  , wait_class
  , event
  , cell_path
  , ROUND(AVG(time_waited)) avg_wait_us
  , LPAD(REPLACE(TO_CHAR(POWER(2,TRUNC(LOG(2,CASE WHEN time_waited < 1 THEN NULL ELSE time_waited END))),'9,999,999,999')||' ..'||TO_CHAR(POWER(2,TRUNC(LOG(2,CASE WHEN time_waited < 1 THEN NULL ELSE time_waited END)))*2, '9,999,999,999'), ' ',''), 26) time_range
  , COUNT(*) samples
  , LPAD(TO_CHAR(TO_NUMBER(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER (PARTITION BY session_state, wait_class, event) * 100, 1), 999.9))||' %',8) pct_event
  , '|'||RPAD( NVL( LPAD('#', ROUND(RATIO_TO_REPORT(COUNT(*)) OVER (PARTITION BY session_state, wait_class, event) * 10), '#'), ' '), 10,' ')||'|' pct_event_vis
  , LPAD(TO_CHAR(TO_NUMBER(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1), 999.9))||' %',8) pct_total 
  , '|'||RPAD( NVL( LPAD('#', ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 10), '#'), ' '), 10,' ')||'|' pct_total_vis
FROM
    v$active_session_history
  , v$cell
WHERE
    1=1
AND v$cell.cell_hashval = v$active_session_history.p1
AND sample_time BETWEEN &1 AND &2 -- sysdate-1/24 AND sysdate
--AND sample_time BETWEEN TIMESTAMP'2012-04-29 19:30:00' AND TIMESTAMP'2012-04-29 19:30:59'
AND (REGEXP_LIKE(wait_class, 'User I/O')) --OR REGEXP_LIKE(event, '&1'))
GROUP BY
    session_state
  , wait_class
  , event
  , cell_path
  , POWER(2,TRUNC(LOG(2,CASE WHEN time_waited < 1 THEN NULL ELSE time_waited END)))
ORDER BY
    session_state
  , wait_class
  , event
  , cell_path
  , time_range NULLS FIRST
  , samples DESC
/

