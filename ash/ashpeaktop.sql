-- Copyright 2020 Tanel Poder. All rights reserved. More info at https://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
-- 
-- File name:   ashpeak.sql
-- Purpose:     
--              
-- Author:      Tanel Poder
-- Copyright:   (c) https://tanelpoder.com
--              
-- Usage:       
--     @dashpeaktop <grouping_cols> <filters> <fromtime> <totime>
--
-- Example:
--
-- Other:
--     This script uses only the in-memory GV$ACTIVE_SESSION_HISTORY, use
--     @dashpeak.sql for accessiong the DBA_HIST_ACTIVE_SESS_HISTORY archive
--              
--------------------------------------------------------------------------------
COL "%Total" FOR A7 JUST RIGHT
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
COL AAS                 FOR 9999999999.9
COL log2_aas_4k         FOR A14 HEAD "Log(2,AAS)" JUST LEFT
COL totalseconds HEAD "Total|Seconds" FOR 99999999
COL dist_sqlexec_seen HEAD "Distinct|Execs Seen" FOR 999999
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

PROMPT
PROMPT Top AAS peaks within time range between &3 and &4

WITH bclass AS (SELECT /*+ INLINE */ class, ROWNUM r from v$waitstat)
SELECT * FROM (
    SELECT
        &1
      , COUNT(*)                      sessions
      , COUNT(*)                      totalseconds
      , ROUND(COUNT(*) / NULLIF(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE),0) / 86400, 1) AAS
    FROM (
        SELECT 
             TRUNC(sample_time, 'DD')  dd
           , TRUNC(sample_time, 'HH')  hh
           , TRUNC(sample_time, 'MI')  mi
           , CAST(sample_time AS DATE) ss
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
           , a.*
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
        FROM
            gv$active_session_history a
        WHERE
            &2
        AND sample_time BETWEEN &3 AND &4
    )
    GROUP BY
        &1
    ORDER BY
        totalseconds DESC
)
WHERE
    rownum <= 25
/

