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
-- Usage:       @lhp <sid> <latch name> <#samples>
-- 	        	@lhp 350 library 100000
--	        	@lhp % % 1000000
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

DEF _lhp_sid="&1"
DEF _lhp_name="&2"
DEF _lhp_samples="&3"

COL lhp_name HEAD NAME 

BREAK ON lhp_name SKIP 1


SELECT /*+ ORDERED USE_NL(l.gv$latchholder.x$ksuprlat) */
	l.name		lhp_name,
	l.laddr, 
	l.sid, 
--	l.pid, 
	COUNT(*) "COUNT"
FROM 
	(SELECT /*+ NO_MERGE */ 1 FROM DUAL CONNECT BY LEVEL <= &_lhp_samples) s,
	v$latchholder l
WHERE
	l.sid LIKE '&_lhp_sid'
AND LOWER(l.name) LIKE LOWER('%&_lhp_name%')
GROUP BY
--	l.pid,
	l.sid,
	l.laddr,
	l.name
ORDER BY
	l.name,
	"COUNT" DESC
/

-- UNDEF _lhp_sid
-- UNDEF _lhp_samples



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
