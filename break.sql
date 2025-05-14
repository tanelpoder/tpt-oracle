-- Copyright 2025 Tanel Poder. All rights reserved. More info at https://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   break.sql
-- Purpose:     Display the PREV_SQL_ID of sessions if this query manages to
--              to catch a session in "SQL*Net break/reset to client" wait event
--
--              Otherwise, scan the V$SESSION_WAIT_HISTORY (different from ASH)
--              and if seeing any break/reset waits in history (10 last waits)
--              then show whatever happens to be the current & prev SQL_ID for
--              the related session (in this case, the SQL_ID may be not related
--              to the error at all, as the app has moved on since the break
--              in history happened.
--              
-- Author:      Tanel Poder
-- Copyright:   (c) https://tanelpoder.com
--              
-- Usage:       @break
--              (you can run it multiple times in a loop, to increase the chance
--              to catch an error handling in progress)
--
--------------------------------------------------------------------------------

COL username FOR A30
COL break_op FOR A9
COL break_event HEAD EVENT FOR A30
COL break_wait_us HEAD WAIT_US
COL break_run_us HEAD RUN_US
COL break_ses_type HEAD TYPE FOR A4

BREAK ON inst_id SKIP 1 DUP ON sid SKIP 1 DUP

WITH swaits AS (
    SELECT
        'CUR' AS type, inst_id, sid, 0 AS seq#
      , CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue'
             ELSE event
        END AS event
      , CASE WHEN state != 'WAITING' THEN NULL -- don't show old p2 if not in wait
             ELSE p2
        END AS p2
      , username
      , sql_id
      , prev_sql_id
      , null AS wait_time_micro, null AS time_since_last_wait_micro
    FROM
        gv$session s
    WHERE 
        1=1 -- get all sessions to look up current activity if only ses wait history shows a break
    UNION ALL
    SELECT
        'SWH', inst_id, sid, seq#, event, p2, null, null, null, wait_time_micro, time_since_last_wait_micro
    FROM
        gv$session_wait_history
    WHERE
        event = 'SQL*Net break/reset to client'
)
SELECT
    type AS break_ses_type
  , inst_id
  , sid
  , seq#   waits_ago
  , event  break_event
  , CASE WHEN event = 'SQL*Net break/reset to client' THEN
        CASE WHEN p2 = 0 THEN 'reset' WHEN p2 = 1 THEN 'break' END||'('||TO_CHAR(p2)||')' 
    END break_op
  , prev_sql_id
  , wait_time_micro AS break_wait_us
  , time_since_last_wait_micro AS break_run_us
  , username -- could add module, action, etc into this script
  , sql_id AS curr_sql_id -- usually NULL for CUR as the error cleans up state returning ORA- error and break wait shows up
FROM 
    swaits s1
WHERE
    event = 'SQL*Net break/reset to client'
OR  (type = 'CUR' AND EXISTS (
            SELECT 1 FROM swaits s2
            WHERE
                s2.event = 'SQL*Net break/reset to client'
            AND s2.type = 'SWH'
            AND s2.inst_id = s1.inst_id
            AND s2.sid = s1.sid
        )
    )
ORDER BY 
    inst_id
  , sid
  , seq#
/


