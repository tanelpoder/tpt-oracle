-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   latchprofx.sql ( Latch Holder Profile eXtended )
-- Purpose:     Perform high-frequency sampling on V$LATCHHOLDER
--				and present a profile of latches held by sessions
--              with information where from Oracle kernel code a
--              latch was held
--
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @lhp <sid> <#samples>
-- 	        	@lhp 350 100000
--	        	@lhp % 1000000
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

COL lhpx_sid HEAD SID FOR 99999
COL lhpx_held_mode HEAD HELD_MODE FOR A15
COL latch_name FOR A40
COL ksllwnam FOR A45
COL ksllwlbl FOR a30

DEF _lhp_sid=&1
DEF _lhp_latchname=&2
DEF _lhp_samples=&3

SELECT /*+ ORDERED USE_NL(l) */
--	l.ksuprpid		pid, 
	l.ksuprsid 		lhpx_sid, 
--	l.ksuprlat		address, 
	l.ksuprlnm 		latch_name,
--	l.ksuprlmd		lhpx_held_mode,
	w.ksllwnam,
	w.ksllwlbl,
	COUNT(*) "COUNT"
--	,COUNT(DISTINCT ksulagts) "DISTGETS"
FROM 
	(SELECT /*+ NO_MERGE */ 1 FROM DUAL CONNECT BY LEVEL <= &_lhp_samples) s,
	x$ksuprlat l,
	x$ksllw w
WHERE
	l.ksuprsid LIKE '&_lhp_sid'
AND lower(l.ksuprlnm) LIKE lower('&_lhp_latchname')
AND l.ksulawhr = w.indx (+)
GROUP BY
--	l.ksuprpid,
	l.ksuprsid, 
--	l.ksuprlat, 
	ksuprlnm,
--	ksuprlmd,
	w.ksllwnam,
	w.ksllwlbl
ORDER BY
	"COUNT"
/

UNDEF _lhp_sid
UNDEF _lhp_samples



-- sqlprof
-- row wait prof / rwprof
-- modactprof    / maprof

-- ROW_WAIT_OBJ#
-- ROW_WAIT_FILE#
-- ROW_WAIT_BLOCK#
-- ROW_WAIT_ROW#

-- SQL_ADDRESS
-- SQL_HASH_VALUE
-- SQL_ID
-- SQL_CHILD_NUMBER
-- SQL_EXEC_START
-- SQL_EXEC_ID
-- PREV_SQL_ADDR
-- PREV_HASH_VALUE
-- PREV_SQL_ID
-- PREV_CHILD_NUMBER
-- PREV_EXEC_START
-- PREV_EXEC_ID
-- PLSQL_ENTRY_OBJECT_ID
-- PLSQL_ENTRY_SUBPROGRAM_ID
-- PLSQL_OBJECT_ID
-- PLSQL_SUBPROGRAM_ID
-- MODULE
-- MODULE_HASH
-- ACTION
-- ACTION_HASH
-- CLIENT_INFO
-- FIXED_TABLE_SEQUENCE
-- 
-- @lm

