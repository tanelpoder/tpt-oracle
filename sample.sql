-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   sample.sql (v1.1)
-- Purpose:     Sample any V$ view or X$ table and display aggregated results
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @sample <column[,column]> <table> <filter condition> <num. samples>
-- 	        
-- Examples:    @sample sql_id v$session sid=142 1000000 
--              @sample sql_id,event v$session "sid=142 and state='WAITING'" 1000000
--              @sample plsql_object_id,plsql_subprogram_id,sql_id v$session sid=142 1000000
--              @sample indx,ksllalaq x$ksupr ksllalaq!=hextoraw('00') 10000
--
-- Other:       This script temporarily disables hash and sort merge join to 
--              get NESTED LOOPS join method (this is how the sampling is done)
--
-- WARNING!     Sampling some views like V$SQL, V$OPEN_CURSOR, X$KSMSP in a tight
--              loop may cause some serious latch contention in your instance.
--
-- Thanks to:   Olivier Bernhard for finding and reporting performance issues with
--              the ORDERED hint
--              
--------------------------------------------------------------------------------

col sample_msec for 9999999.99

-- the alter session commands should be uncommented
-- if running this script on 10.1.x or earlier as the opt_param hints work on 10.2+

set termout off
--begin
--    begin execute immediate 'alter session set "_optimizer_sortmerge_join_enabled"=false'; exception when others then null; end;
--    begin execute immediate 'alter session set "hash_join_enabled"=false'; exception when others then null; end;
--end;
--/

set termout on

WITH 
    t1 AS (SELECT hsecs FROM v$timer),
    q AS (
        select /*+ LEADING(r t) USE_NL(t)
                   opt_param('_optimizer_sortmerge_join_enabled','false') 
                   opt_param('hash_join_enabled','false') 
                   opt_param('_optimizer_use_feedback', 'false')
                   NO_TRANSFORM_DISTINCT_AGG */ 
            &1 , count(*) "COUNT", count(distinct r.rn) DISTCOUNT
        from
            (select /*+ no_unnest */ rownum rn from dual connect by level <= &4) r
          , &2 t
        where &3
        group by
            &1
        order by
            "COUNT" desc, &1
    ),
    t2 AS (SELECT hsecs FROM v$timer)
SELECT /*+ ORDERED */
    trunc((t2.hsecs - t1.hsecs) * 10 * q.distcount / &4, 2) sample_msec
  , (t2.hsecs - t1.hsecs) * 10 total_msec
  , ROUND(((t2.hsecs - t1.hsecs) * 10 * q.distcount / &4) / ((t2.hsecs - t1.hsecs) * 10) * 100, 2) percent
  , q.*
FROM
     t1,
     q,
     t2
/

--set termout off
--begin
--    begin execute immediate 'alter session set "_optimizer_sortmerge_join_enabled"=true'; exception when others then null; end;
--    begin execute immediate 'alter session set "hash_join_enabled"=true'; exception when others then null; end;
--end;
--/
set termout on
