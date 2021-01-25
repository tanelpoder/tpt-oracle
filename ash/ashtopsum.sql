-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
-- 
-- File name:   ashtopsum.sql v1.3
-- Purpose:     Display top ASH time (count of ASH samples) grouped by your
--              specified dimensions AND (potentially lossy) SUM of IO rate metrics
--              
-- Author:      Tanel Poder
-- Copyright:   (c) http://blog.tanelpoder.com
--              
-- Usage:       
--     @ashtop <grouping_cols> <filters> <fromtime> <totime>
--
-- Example:
--     @ashtop username,sql_id session_type='FOREGROUND' sysdate-1/24 sysdate
--
-- Other:
--     This script uses only the in-memory GV$ACTIVE_SESSION_HISTORY, use
--     @dashtop.sql for accessiong the DBA_HIST_ACTIVE_SESS_HISTORY archive
--              
--------------------------------------------------------------------------------
COL "%This" FOR A7
--COL p1     FOR 99999999999999
--COL p2     FOR 99999999999999
--COL p3     FOR 99999999999999
COL p1text              FOR A30 word_wrap
COL p2text              FOR A30 word_wrap
COL p3text              FOR A30 word_wrap
COL p1hex               FOR A17
COL p2hex               FOR A17
COL p3hex               FOR A17
COL dop                 FOR 99
COL AAS                 FOR 9999.9
COL totalseconds        HEAD "Total|Seconds" FOR 99999999
COL dist_sqlexec_seen   HEAD "Distinct|Execs Seen" FOR 999999
COL dist_timestamps     HEAD "Distinct|Tstamps" FOR 999999
COL event               FOR A42 WORD_WRAP
COL event2              FOR A42 WORD_WRAP
COL time_model_name     FOR A50 WORD_WRAP
COL program2            FOR A40 TRUNCATE
COL username            FOR A20 wrap
COL obj                 FOR A30
COL objt                FOR A50
COL sql_opname          FOR A20
COL top_level_call_name FOR A30
COL wait_class          FOR A15

COL rd_rq               FOR 9,999,999
COL wr_rq               FOR 9,999,999
COL rd_mb               FOR 9,999,999
COL wr_mb               FOR 9,999,999
COL pgamem_mb              FOR 9,999,999
COL tempspc_mb             FOR 9,999,999

PROMPT This is an experimental script as some documentation/explanation is needed.
PROMPT The ASH "delta" metrics are not tied to individual SQL_IDs or wait events,
PROMPT They increase in the session scope (which SQL_ID/operation happens to be
PROMPT active when ASH samples its data is just matter of luck). 

SELECT
    * 
FROM (
    WITH bclass AS (SELECT /*+ INLINE */ class, ROWNUM r from v$waitstat)
    SELECT /*+ LEADING(a) USE_HASH(u) */
        COUNT(*)                                                     totalseconds
      , ROUND(COUNT(*) / ((CAST(&4 AS DATE) - CAST(&3 AS DATE)) * 86400), 1) AAS
      , LPAD(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100)||'%',5,' ')||' |' "%This"
      , SUM(delta_read_io_requests)  rd_rq
      , SUM(delta_write_io_requests) wr_rq
      , SUM(delta_read_io_bytes)/1048576     rd_mb   
      , SUM(delta_write_io_bytes)/1048576    wr_mb
      --, SUM(delta_interconnect_io_bytes)
      --, SUM(delta_read_mem_bytes)       
      , MAX(pga_allocated)/1048576           pgamem_mb              
      , MAX(temp_space_allocated)/1048576    tempspc_mb
      , &1
      , TO_CHAR(MIN(sample_time), 'YYYY-MM-DD HH24:MI:SS') first_seen
      , TO_CHAR(MAX(sample_time), 'YYYY-MM-DD HH24:MI:SS') last_seen
--    , MAX(sql_exec_id) - MIN(sql_exec_id) 
      , COUNT(DISTINCT sql_exec_start||':'||sql_exec_id) dist_sqlexec_seen
      , COUNT(DISTINCT sample_time) dist_timestamps
    FROM
        (SELECT
             a.*
           , session_id sid
           , session_serial# serial
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p1 ELSE null END, '0XXXXXXXXXXXXXXX') p1hex
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p2 ELSE null END, '0XXXXXXXXXXXXXXX') p2hex
           , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p3 ELSE null END, '0XXXXXXXXXXXXXXX') p3hex
           , TRUNC(px_flags / 2097152) dop
           , NVL(a.event, a.session_state)||
                CASE 
                    WHEN a.event like 'enq%' AND session_state = 'WAITING'
                    THEN ' [mode='||BITAND(p1, POWER(2,14)-1)||']'
                    WHEN a.event IN (SELECT name FROM v$event_name WHERE parameter3 = 'class#')
                    THEN ' ['||CASE WHEN a.p3 <= (SELECT MAX(r) FROM bclass) 
                               THEN (SELECT class FROM bclass WHERE r = a.p3)
                               ELSE (SELECT DECODE(MOD(BITAND(a.p3,TO_NUMBER('FFFF','XXXX')) - 17,2),0,'undo header',1,'undo data', 'error') FROM dual)
                               END  ||']' 
                    ELSE null 
                END event2 -- event is NULL in ASH if the session is not waiting (session_state = ON CPU)
           , CASE WHEN a.session_type = 'BACKGROUND' OR REGEXP_LIKE(a.program, '.*\([PJ]\d+\)') THEN
                REGEXP_REPLACE(SUBSTR(a.program,INSTR(a.program,'(')), '\d', 'n')
             ELSE
                '('||REGEXP_REPLACE(REGEXP_REPLACE(a.program, '(.*)@(.*)(\(.*\))', '\1'), '\d', 'n')||')'
             END || ' ' program2
           , CASE WHEN BITAND(time_model, POWER(2, 01)) = POWER(2, 01) THEN 'DBTIME '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 02)) = POWER(2, 02) THEN 'BACKGROUND '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 03)) = POWER(2, 03) THEN 'CONNECTION_MGMT '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 04)) = POWER(2, 04) THEN 'PARSE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 05)) = POWER(2, 05) THEN 'FAILED_PARSE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 06)) = POWER(2, 06) THEN 'NOMEM_PARSE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 07)) = POWER(2, 07) THEN 'HARD_PARSE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 08)) = POWER(2, 08) THEN 'NO_SHARERS_PARSE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 09)) = POWER(2, 09) THEN 'BIND_MISMATCH_PARSE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 10)) = POWER(2, 10) THEN 'SQL_EXECUTION '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 11)) = POWER(2, 11) THEN 'PLSQL_EXECUTION '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 12)) = POWER(2, 12) THEN 'PLSQL_RPC '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 13)) = POWER(2, 13) THEN 'PLSQL_COMPILATION '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 14)) = POWER(2, 14) THEN 'JAVA_EXECUTION '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 15)) = POWER(2, 15) THEN 'BIND '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 16)) = POWER(2, 16) THEN 'CURSOR_CLOSE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 17)) = POWER(2, 17) THEN 'SEQUENCE_LOAD '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 18)) = POWER(2, 18) THEN 'INMEMORY_QUERY '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 19)) = POWER(2, 19) THEN 'INMEMORY_POPULATE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 20)) = POWER(2, 20) THEN 'INMEMORY_PREPOPULATE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 21)) = POWER(2, 21) THEN 'INMEMORY_REPOPULATE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 22)) = POWER(2, 22) THEN 'INMEMORY_TREPOPULATE '  END
           ||CASE WHEN BITAND(time_model, POWER(2, 23)) = POWER(2, 23) THEN 'TABLESPACE_ENCRYPTION ' END time_model_name 
        FROM gv$active_session_history a) a
      , dba_users u
      , (SELECT
             object_id,data_object_id,owner,object_name,subobject_name,object_type
           , owner||'.'||object_name obj
           , owner||'.'||object_name||' ['||object_type||']' objt
         FROM dba_objects) o
    WHERE
        a.user_id = u.user_id (+)
    AND a.current_obj# = o.object_id(+)
    AND &2
    AND sample_time BETWEEN &3 AND &4
    GROUP BY
        &1
    ORDER BY
        TotalSeconds DESC
       , &1
)
WHERE
    ROWNUM <= 20
/

