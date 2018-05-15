-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   waitprof.sql ( Session Wait Profiler )
-- Purpose:     Sample V$SESSION_WAIT at high frequency and show resulting 
--              session wait event and parameter profile by session
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--
-- Usage:       @waitprof <print|noprint> <sid> <e[123s]> <#samples>
--
--                  <print|noprint>
--                              - whether to print P2,P3,SEQ# values or not
--
--                  <sid>       - session ID of session to sample
--
--                  <[e123s]>   - sample grouping
--                      e - group by event name
--                      1 - group by P1 of v$session_wait event
--                      2 - group by P2
--                      3 - group by P3
--                      s - group by SEQ#
--
--                  <#samples>  - how many samples to take (a modern CPU can take
--                                tens of thousands to low hundreds of k samples
--                                per second)
--
--  Examples:
--              @waitprof noprint 350 e 1000000   -- take million samples, group by event only
--              @waitprof print 350 e123 500000 -- take 500k samples, group by event,p1,p2,p3
--              @waitprof print 350 e3 1000000  -- take million samples, group by event,p3
--              @waitprof print 350 es 1000000  -- take million samples, group by event,seq#
--
--  Other:
--              The sampling relies on NESTED LOOP join method and having
--              V$SESSION_WAIT as the inner (probed) table. Note that on 9i
--              you may need to run this script as SYS as it looks like otherwise
--              the global USE_NL hint is not propagated down to X$ base tables
--
--              If sampling always reports a single distinct event even though 
--              many different events (or parameter values) are expected then 
--              the execution plan used is not right.
--
--------------------------------------------------------------------------------

DEF _swp_print=&1
DEF _swp_sid=&2
DEF _swp_p123=&3
DEF _swp_samples=&4

col sw_event    head EVENT for a35 truncate
col sw_p1transl head P1TRANSL for a42
col sw_sid      head SID for 999999
col swp_p1 head P1 for a26 word_wrap
col swp_p2 head P2 for a16 word_wrap &_swp_print
col swp_p3 head P3 for a16 word_wrap &_swp_print
col swp_seq# head SEQ# &_swp_print
col pct_total_samples head "% Total|Time" format 999.99
col waitprof_total_ms head "Total Event|Time ms" format 9999999.999
col dist_events head Distinct|Events
col average_samples head Average|Samples
col waitprof_avg_ms head "Avg time|ms/Event" format 99999.999

prompt
prompt -- WaitProf 1.04 by Tanel Poder ( http://www.tanelpoder.com )

WITH 
    t1 AS (SELECT hsecs FROM v$timer),
    samples AS (
    SELECT /*+ ORDERED NO_MERGE USE_NL(sw.gv$session_wait.s) */
        s.sid sw_sid,
        CASE WHEN sw.state = 'WAITING' THEN 'WAITING' ELSE 'WORKING' END AS state,
        CASE WHEN sw.state = 'WAITING' THEN event ELSE 'On CPU / runqueue' END AS sw_event,
        CASE WHEN sw.state = 'WAITING' AND '&_swp_p123' LIKE '%1%' THEN sw.p1text || '= ' || CASE WHEN (LOWER(sw.p1text) LIKE '%addr%' OR sw.p1 >= 536870912) THEN RAWTOHEX(sw.p1raw) ELSE TO_CHAR(sw.p1) END ELSE NULL END swp_p1,
        CASE WHEN sw.state = 'WAITING' AND '&_swp_p123' LIKE '%2%' THEN sw.p2text || '= ' || CASE WHEN (LOWER(sw.p2text) LIKE '%addr%' OR sw.p2 >= 536870912) THEN RAWTOHEX(sw.p2raw) ELSE TO_CHAR(sw.p2) END ELSE NULL END swp_p2,
        CASE WHEN sw.state = 'WAITING' AND '&_swp_p123' LIKE '%3%' THEN sw.p3text || '= ' || CASE WHEN (LOWER(sw.p3text) LIKE '%addr%' OR sw.p3 >= 536870912) THEN RAWTOHEX(sw.p3raw) ELSE TO_CHAR(sw.p3) END ELSE NULL END swp_p3,
        CASE WHEN LOWER('&_swp_p123') LIKE '%s%' THEN sw.seq# ELSE NULL END seq#,
        COUNT(*) total_samples,
        COUNT(DISTINCT seq#) dist_events,
        TRUNC(COUNT(*)/COUNT(DISTINCT seq#)) average_samples
    FROM
        (	SELECT /*+ NO_MERGE */ TO_NUMBER(&_swp_sid) sid FROM 
        		(SELECT rownum r FROM dual CONNECT BY ROWNUM <= 1000) a,
        		(SELECT rownum r FROM dual CONNECT BY ROWNUM <= 1000) b,
        		(SELECT rownum r FROM dual CONNECT BY ROWNUM <= 1000) c
	        WHERE ROWNUM <= &_swp_samples
        ) s,
        v$session_wait sw
    WHERE
        s.sid = sw.sid
    GROUP BY
        s.sid,
        CASE WHEN sw.state = 'WAITING' THEN 'WAITING' ELSE 'WORKING' END,
        CASE WHEN sw.state = 'WAITING' THEN event ELSE 'On CPU / runqueue' END,
        CASE WHEN sw.state = 'WAITING' AND '&_swp_p123' LIKE '%1%' THEN sw.p1text || '= ' || CASE WHEN (LOWER(sw.p1text) LIKE '%addr%' OR sw.p1 >= 536870912) THEN RAWTOHEX(sw.p1raw) ELSE TO_CHAR(sw.p1) END ELSE NULL END,
        CASE WHEN sw.state = 'WAITING' AND '&_swp_p123' LIKE '%2%' THEN sw.p2text || '= ' || CASE WHEN (LOWER(sw.p2text) LIKE '%addr%' OR sw.p2 >= 536870912) THEN RAWTOHEX(sw.p2raw) ELSE TO_CHAR(sw.p2) END ELSE NULL END,
        CASE WHEN sw.state = 'WAITING' AND '&_swp_p123' LIKE '%3%' THEN sw.p3text || '= ' || CASE WHEN (LOWER(sw.p3text) LIKE '%addr%' OR sw.p3 >= 536870912) THEN RAWTOHEX(sw.p3raw) ELSE TO_CHAR(sw.p3) END ELSE NULL END,
        CASE WHEN LOWER('&_swp_p123') LIKE '%s%' THEN sw.seq# ELSE NULL END
    ORDER BY
        CASE WHEN LOWER('&_swp_p123') LIKE '%s%' THEN -seq# ELSE total_samples END DESC
),
    t2 AS (SELECT hsecs FROM v$timer)
SELECT /*+ ORDERED */
    s.sw_sid,
    s.state,
    s.sw_event,
    s.swp_p1,
    s.swp_p2,
    s.swp_p3,
    s.seq# swp_seq#,
    s.total_samples / &_swp_samples * 100 pct_total_samples,
    (t2.hsecs - t1.hsecs) * 10 * s.total_samples / &_swp_samples waitprof_total_ms,
    s.dist_events,
--  s.average_samples,
    (t2.hsecs - t1.hsecs) * 10 * s.total_samples / dist_events / &_swp_samples waitprof_avg_ms
FROM
    t1,
    samples s,
    t2
/

--UNDEF _swp_sid=&1
--UNDEF _swp_p123=&2
--UNDEF _swp_samples=&3
