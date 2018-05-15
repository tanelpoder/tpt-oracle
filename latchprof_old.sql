-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   lhp.sql ( Latch Holder Profile )
-- Purpose:     Perform high-frequency sampling on V$LATCHHOLDER
--				and present a profile of latches held by sessions
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @latchprof <what> <sid> <latch name> <#samples>
-- 	        	@latchprof sid,name 350 library 100000
--	        	@latchprof name % % 1000000
-- Other:
--				The sampling relies on NESTED LOOP join method and having
--				V$LATCHHOLDER as the inner (probed) table. Note that on 9i
--				you may need to run this script as SYS as it looks like otherwise
--				the global USE_NL hint is not propagated down to X$ base tables
--
--				If sampling always reports a single latch event even though 
--				many different events (or parameter values) are expected then 
--				the execution plan used is not right.
--
--				If you want to drill down to latch child level, uncomment the
--				l.laddr fields from select and group by list.
--				Then you can use la.sql (V$LATCH_PARENT/V$LATCH_CHILDREN) to
--				map the latch address back to latch child#
--
--------------------------------------------------------------------------------

-- what includes what columns to display & aggregate and also options like latch name filtering
DEF _lhp_what="&1"
DEF _lhp_sid="&2"
DEF _lhp_name="&3"
DEF _lhp_samples="&4"

COL lhp_name HEAD NAME 
COL latchprof_total_ms HEAD "Held ms" FOR 999999.999
COL latchprof_pct_total_samples head "Held %" format 999.99
COL latchprof_avg_ms HEAD "Avg hold ms" FOR 999.999
COL dist_samples HEAD Gets
COL total_samples HEAD Held

BREAK ON lhp_name SKIP 1

WITH 
    t1 AS (SELECT hsecs FROM v$timer),
    samples AS (
		SELECT /*+ ORDERED USE_NL(l.gv$latchholder.x$ksuprlat) */
			&_lhp_what
--		  , COUNT(DISTINCT gets)		dist_samples
		  , COUNT(*) 					total_samples
		  , COUNT(*) / &_lhp_samples	total_samples_pct
		FROM 
--			(SELECT /*+ NO_MERGE */ 1 FROM DUAL CONNECT BY LEVEL <= &_lhp_samples) s,
	        (	SELECT /*+ NO_MERGE */ 1 FROM 
	        		(SELECT rownum r FROM dual CONNECT BY ROWNUM <= 1000) a,
	        		(SELECT rownum r FROM dual CONNECT BY ROWNUM <= 1000) b,
	        		(SELECT rownum r FROM dual CONNECT BY ROWNUM <= 1000) c
		        WHERE ROWNUM <= &_lhp_samples
	        ) s,
			v$latchholder l
		WHERE
			l.sid LIKE '&_lhp_sid'
		AND (LOWER(l.name) LIKE LOWER('%&_lhp_name%') OR LOWER(RAWTOHEX(l.laddr)) LIKE LOWER('%&_lhp_name%'))
		GROUP BY
			&_lhp_what
		ORDER BY
			total_samples DESC
	),
    t2 AS (SELECT hsecs FROM v$timer)
SELECT /*+ ORDERED */
	&_lhp_what
  , s.total_samples
--  , s.dist_samples
--  , s.total_samples_pct
  , s.total_samples / &_lhp_samples * 100 latchprof_pct_total_samples
  , (t2.hsecs - t1.hsecs) * 10 * s.total_samples / &_lhp_samples latchprof_total_ms
--   s.dist_events,
--  , (t2.hsecs - t1.hsecs) * 10 * s.total_samples / dist_samples / &_lhp_samples latchprof_avg_ms
  FROM
    t1,
    samples s,
    t2
/

