-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   latchprof.sql ( Latch Holder Profiler )
-- Purpose:     Perform high-frequency sampling on V$LATCHHOLDER
--              and present a profile of latches held by sessions
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @latchprof <what> <sid> <latch name> <#samples>
--              @latchprof name 350 % 100000                - monitor all latches SID 350 is holding
--              @latchprof sid,name % library 1000000       - monitor which SIDs hold latches with "library" in their name
--              @latchprof sid,name,laddr % 40D993A0 100000 - monitor which SIDs hold child latch with address 0x40D993A0
-- Other:
--              The sampling relies on NESTED LOOP join method and having
--              V$LATCHHOLDER as the inner (probed) table. Note that on 9i
--              you may need to run this script as SYS as it looks like otherwise
--              the global USE_NL hint is not propagated down to X$ base tables
--
--              The join in exec plan step 8 MUST be a NESTED LOOPS join, this is how
--              the high speed sampling of changing dataset from V$LATCHHOLDER
--              is done, otherwise you will not see correct results.
--
-- -----------------------------------------------------------------------------------------------
-- | Id  | Operation                            | Name       | E-Rows |  OMem |  1Mem | Used-Mem |
-- -----------------------------------------------------------------------------------------------
-- |   1 |  MERGE JOIN CARTESIAN                |            |      1 |       |       |          |
-- |   2 |   MERGE JOIN CARTESIAN               |            |      1 |       |       |          |
-- |*  3 |    FIXED TABLE FULL                  | X$KSUTM    |      1 |       |       |          |
-- |   4 |    BUFFER SORT                       |            |      1 |  9216 |  9216 | 8192  (0)|
-- |   5 |     VIEW                             |            |      1 |       |       |          |
-- |   6 |      SORT ORDER BY                   |            |      1 |  2048 |  2048 | 2048  (0)|
-- |   7 |       SORT GROUP BY                  |            |      1 |  9216 |  9216 | 8192  (0)|
-- |   8 |        NESTED LOOPS                  |            |      1 |       |       |          |
-- |   9 |         VIEW                         |            |      1 |       |       |          |
-- |  10 |          CONNECT BY WITHOUT FILTERING|            |        |       |       |          |
-- |  11 |           FAST DUAL                  |            |      1 |       |       |          |
-- |* 12 |         FIXED TABLE FULL             | X$KSUPRLAT |      1 |       |       |          |
-- |  13 |   BUFFER SORT                        |            |      1 |  9216 |  9216 | 8192  (0)|
-- |* 14 |    FIXED TABLE FULL                  | X$KSUTM    |      1 |       |       |          |
-- -----------------------------------------------------------------------------------------------
--
--              If you want to drill down to latch child level, include "laddr" in first parameter
--              to latchprof
--
--              Then you can use la.sql (V$LATCH_PARENT/V$LATCH_CHILDREN) to
--              map the latch address back to latch child# if needed
--
--------------------------------------------------------------------------------

-- what includes what columns to display & aggregate and also options like latch name filtering
DEF _lhp_what="&1"
DEF _lhp_sid="&2"
DEF _lhp_name="&3"
DEF _lhp_samples="&4"

COL name FOR A40 WRAP
COL latchprof_total_ms HEAD "Held ms" FOR 999999.999
COL latchprof_pct_total_samples head "Held %" format 999.99
COL latchprof_avg_ms HEAD "Avg hold ms" FOR 999.999
COL dist_samples HEAD Gets
COL total_samples HEAD Held

BREAK ON lhp_name SKIP 1

DEF _IF_ORA_10_OR_HIGHER="--"

PROMPT
PROMPT -- LatchProf 2.02 by Tanel Poder ( http://www.tanelpoder.com )

COL latchprof_oraversion NEW_VALUE _IF_ORA_10_OR_HIGHER

SET TERMOUT OFF
SELECT DECODE(SUBSTR(BANNER, INSTR(BANNER, 'Release ')+8,1), 1, '', '--') latchprof_oraversion 
FROM v$version WHERE ROWNUM=1;
SET TERMOUT ON

WITH 
    t1 AS (SELECT hsecs FROM v$timer),
    samples AS (
        SELECT /*+ ORDERED USE_NL(l) USE_NL(s) USE_NL(l.gv$latchholder.x$ksuprlat) NO_TRANSFORM_DISTINCT_AGG  */
            &_lhp_what
          &_IF_ORA_10_OR_HIGHER , COUNT(DISTINCT gets)      dist_samples
          , COUNT(*)                    total_samples
          , COUNT(*) / &_lhp_samples    total_samples_pct
        FROM 
            (SELECT /*+ NO_MERGE */ 1 FROM DUAL CONNECT BY LEVEL <= &_lhp_samples) s,
            v$latchholder l,
            (SELECT
                    sid                                     indx
                  , sql_hash_value                          sqlhash
                  , sql_address                             sqladdr 
                  &_IF_ORA_10_OR_HIGHER , sql_child_number  sqlchild
                  &_IF_ORA_10_OR_HIGHER , sql_id            sqlid
             FROM v$session) s
        WHERE
            l.sid LIKE '&_lhp_sid'
        AND (LOWER(l.name) LIKE LOWER('%&_lhp_name%') OR LOWER(RAWTOHEX(l.laddr)) LIKE LOWER('%&_lhp_name%'))
        AND l.sid = s.indx
        GROUP BY
            &_lhp_what
        ORDER BY
            total_samples DESC
    ),
    t2 AS (SELECT hsecs FROM v$timer)
SELECT /*+ ORDERED */
    &_lhp_what
  , s.total_samples
  &_IF_ORA_10_OR_HIGHER , s.dist_samples
  --  , s.total_samples_pct
  , s.total_samples / &_lhp_samples * 100 latchprof_pct_total_samples
  , (t2.hsecs - t1.hsecs) * 10 * s.total_samples / &_lhp_samples latchprof_total_ms
  --   s.dist_events,
  &_IF_ORA_10_OR_HIGHER , (t2.hsecs - t1.hsecs) * 10 * s.total_samples / dist_samples / &_lhp_samples latchprof_avg_ms
  FROM
    t1,
    samples s,
    t2
  WHERE ROWNUM <= 30
/

COL name CLEAR
