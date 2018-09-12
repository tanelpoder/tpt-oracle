-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   ash_wait_chains.sql (v0.2 BETA)
-- Purpose:     Display ASH wait chains (multi-session wait signature, a session
--              waiting for another session etc.)
--              
-- Author:      Tanel Poder
-- Copyright:   (c) http://blog.tanelpoder.com
--              
-- Usage:       
--     @ash_wait_chains <grouping_cols> <filters> <fromtime> <totime>
--
-- Example:
--     @ash_wait_chains username||':'||program2||event2 session_type='FOREGROUND' sysdate-1/24 sysdate
--
-- Other:
--     This script uses only the in-memory V$ACTIVE_SESSION_HISTORY, use
--     @dash_wait_chains.sql for accessiong the DBA_HIST_ACTIVE_SESS_HISTORY archive
--
--     Oracle 10g does not  have the BLOCKING_INST_ID column in ASH so you'll need
--     to comment out this column in this script. This may give you somewhat
--     incorrect results in RAC environment with global blockers.
--              
--------------------------------------------------------------------------------
COL wait_chain FOR A300 WORD_WRAP
COL "%This" FOR A6

PROMPT
PROMPT -- Display ASH Wait Chain Signatures script v0.4 BETA by Tanel Poder ( http://blog.tanelpoder.com )

WITH 
bclass AS (SELECT class, ROWNUM r from v$waitstat),
ash AS (SELECT /*+ QB_NAME(ash) LEADING(a) USE_HASH(u) SWAP_JOIN_INPUTS(u) */
            a.*
          , u.username
          , CASE WHEN a.session_type = 'BACKGROUND' OR REGEXP_LIKE(a.program, '.*\([PJ]\d+\)') THEN
              REGEXP_REPLACE(SUBSTR(a.program,INSTR(a.program,'(')), '\d', 'n')
            ELSE
                '('||REGEXP_REPLACE(REGEXP_REPLACE(a.program, '(.*)@(.*)(\(.*\))', '\1'), '\d', 'n')||')'
            END || ' ' program2
          , NVL(a.event||CASE WHEN a.event IN ('buffer busy waits', 'gc buffer busy', 'gc buffer busy acquire', 'gc buffer busy release') 
                              THEN ' ['||NVL((SELECT class FROM bclass WHERE r = a.p3),'undo @bclass '||a.p3)||']' ELSE null END,'ON CPU') 
                       || ' ' event2
          , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p1 ELSE null END, '0XXXXXXXXXXXXXXX') p1hex
          , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p2 ELSE null END, '0XXXXXXXXXXXXXXX') p2hex
          , TO_CHAR(CASE WHEN session_state = 'WAITING' THEN p3 ELSE null END, '0XXXXXXXXXXXXXXX') p3hex
        FROM 
            gv$active_session_history a
          , dba_users u
        WHERE
            a.user_id = u.user_id (+)
        AND sample_time BETWEEN &3 AND &4
    ),
ash_samples AS (SELECT DISTINCT sample_id FROM ash),
ash_data AS (SELECT /*+ MATERIALIZE */ * FROM ash),
chains AS (
    SELECT
        sample_time ts
      , level lvl
      , session_id sid
      , REPLACE(SYS_CONNECT_BY_PATH(&1, '->'), '->', ' -> ')||CASE WHEN CONNECT_BY_ISLEAF = 1 AND d.blocking_session IS NOT NULL THEN ' -> [idle blocker '||d.blocking_inst_id||','||d.blocking_session||','||d.blocking_session_serial#||(SELECT ' ('||s.program||')' FROM gv$session s WHERE (s.inst_id, s.sid , s.serial#) = ((d.blocking_inst_id,d.blocking_session,d.blocking_session_serial#)))||']' ELSE NULL END path -- there's a reason why I'm doing this 
      --, SYS_CONNECT_BY_PATH(&1, ' -> ')||CASE WHEN CONNECT_BY_ISLEAF = 1 THEN '('||d.session_id||')' ELSE NULL END path
      -- , REPLACE(SYS_CONNECT_BY_PATH(&1, '->'), '->', ' -> ')||CASE WHEN CONNECT_BY_ISLEAF = 1 AND LEVEL > 1 THEN ' [sid='||session_id||' seq#='||TO_CHAR(seq#)||']' ELSE NULL END path -- there's a reason why I'm doing this 
      --, REPLACE(SYS_CONNECT_BY_PATH(&1, '->'), '->', ' -> ') path -- there's a reason why I'm doing this (ORA-30004 :)
      , CASE WHEN CONNECT_BY_ISLEAF = 1 THEN d.session_id ELSE NULL END sids
      , CONNECT_BY_ISLEAF isleaf
      , CONNECT_BY_ISCYCLE iscycle
      , d.*
    FROM
        ash_samples s
      , ash_data d
    WHERE
        s.sample_id = d.sample_id 
    AND d.sample_time BETWEEN &3 AND &4
    CONNECT BY NOCYCLE
        (    PRIOR d.blocking_session = d.session_id
         AND PRIOR d.blocking_inst_id = d.inst_id
         AND PRIOR s.sample_id = d.sample_id
        )
    START WITH &2
)
SELECT * FROM (
    SELECT
        LPAD(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100)||'%',5,' ') "%This"
      , COUNT(*) seconds
      , ROUND(COUNT(*) / ((CAST(&4 AS DATE) - CAST(&3 AS DATE)) * 86400), 1) AAS
      , path wait_chain
      , TO_CHAR(MIN(sample_time), 'YYYY-MM-DD HH24:MI:SS') first_seen
      , TO_CHAR(MAX(sample_time), 'YYYY-MM-DD HH24:MI:SS') last_seen
      -- , COUNT(DISTINCT sids)
      -- , MIN(sids)
      -- , MAX(sids)
    FROM
        chains
    WHERE
        isleaf = 1
    GROUP BY
        &1
      , path
    ORDER BY
        COUNT(*) DESC
    )
WHERE
    ROWNUM <= 30
/

