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
--     @ashpeak <grouping_cols> <filters> <fromtime> <totime>
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

SELECT * FROM (
    SELECT
        &1
      , COUNT(*)                                                     totalseconds
      , ROUND(COUNT(*) / NULLIF(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE),0) / 86400, 1) AAS
    FROM (
        SELECT 
            TRUNC(sample_time, 'DD')  dd
          , TRUNC(sample_time, 'HH')  hh
          , TRUNC(sample_time, 'MI')  mi
          , CAST(sample_time AS DATE) ss
          , a.*
        FROM
            v$active_session_history a
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
    rownum <= 10
/

PROMPT Press ENTER to show detailed timeline, CTRL+C to cancel...
PAUSE 

WITH bclass AS (SELECT /*+ INLINE */ class, ROWNUM r from v$waitstat)
SELECT
    &1
  , COUNT(*)                                                     totalseconds
  , ROUND(COUNT(*) / NULLIF(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE),0) / 86400, 1) AAS
  , LPAD(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100)||'%',5,' ') "%Total"
  , '|'||RPAD(NVL(RPAD('#', ROUND(LOG(2,COUNT(*) / NULLIF(CAST(MAX(sample_time) AS DATE) - CAST(MIN(sample_time) AS DATE),0) / 86400), 1), '#'),' '), 12)||'|' log2_aas_4k
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
    FROM
        v$active_session_history a 
    WHERE
        &2
    AND sample_time BETWEEN &3 AND &4
)
GROUP BY
    &1
ORDER BY
    &1
/

