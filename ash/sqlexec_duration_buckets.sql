-- Copyright 2018 Tanel Poder. All rights reserved. More info at https://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.


COL approx_elapsed_time FOR A30

BREAK ON ash_sql_id SKIP 1

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
      , COUNT(*) seconds
    FROM
        gv$active_session_history
    WHERE
        sql_id LIKE '&1'
    AND &2
    AND sample_time BETWEEN &3 AND &4
    GROUP BY
        sql_id
      , session_id
      , session_serial#
      , sample_time
      , sql_exec_start
      , sql_exec_id
),
longrunning AS (
SELECT * FROM ash
WHERE
    elapsed_time > INTERVAL '1' SECOND
),
individualexecutions AS (
SELECT
    sql_id
  , sql_exec_start
    -- an earlier analytic function already does the "partition by session_id,session_serial#"
  , MAX(elapsed_time) approx_elapsed_time
  , TRUNC((EXTRACT(DAY    FROM MAX(elapsed_time)) * 24 * 60 * 60) + 
          (EXTRACT(HOUR   FROM MAX(elapsed_time)) * 60 * 60) +
          (EXTRACT(MINUTE FROM MAX(elapsed_time)) * 60) +
          (EXTRACT(SECOND FROM MAX(elapsed_time)))
    ) as approx_elapsed_sec
  , SUM(seconds) sqlexec_db_time
  , COUNT(DISTINCT session_id) sessions
FROM longrunning
GROUP BY
    sql_id
  , sql_exec_start
ORDER BY
    sql_id
  , sql_exec_start
  , COUNT(*) DESC
)
SELECT
    sql_id as ash_sql_id
  , approx_elapsed_sec
  , SUM(sqlexec_db_time) total_db_time
  , MIN(sql_exec_start)  first_seen_start
  , MAX(sql_exec_start)  last_seen_start
FROM
    individualexecutions
GROUP BY
    sql_id
  , approx_elapsed_sec
ORDER BY
    sql_id
  , approx_elapsed_sec
/

