-- Copyright 2018 Tanel Poder. All rights reserved. More info at https://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.


COL approx_elapsed_time FOR A30

WITH ash AS (
    SELECT
        sql_id
      , session_id
      , sample_time
      , sample_time - CAST(MIN(sql_exec_start) 
          OVER(PARTITION BY session_id,session_serial#,sql_exec_start,sql_exec_id)
          AS TIMESTAMP) elapsed_time
      , sql_exec_start
      , sql_exec_id
      , session_state
      , event
      , machine
      , module
    FROM
        v$active_session_history
    WHERE
        sql_id = '&1'
    AND &2
    AND sample_time BETWEEN &3 AND &4
    GROUP BY
        sql_id
      , session_id
      , session_serial#
      , sample_time
      , sql_exec_start
      , sql_exec_id
      , session_state
      , event
      , machine
      , module
),
longrunning AS (
SELECT * FROM ash
WHERE
    elapsed_time > INTERVAL '1' SECOND
)
SELECT
    sql_id
  , sql_exec_start
    -- an earlier analytic function already does the "partition by session_id,session_serial#"
  , MAX(elapsed_time) approx_elapsed_time
  , session_state
  , event
  , COUNT(*) seconds
  , COUNT(DISTINCT session_id) sesssions
FROM longrunning
GROUP BY
    sql_id
  , sql_exec_start
  , session_state
  , event
ORDER BY
    sql_id
  , sql_exec_start
  , COUNT(*) DESC
/

