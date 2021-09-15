WITH ash AS (
    SELECT
        sql_id
      , sample_time
      , sample_time - CAST(MIN(sql_exec_start) OVER(PARTITION BY session_id,session_serial#,sql_exec_start,sql_exec_id) AS TIMESTAMP) elapsed_time
      , sql_exec_start
      , sql_exec_id
      , session_state
      , event
    FROM
        v$active_session_history
    WHERE
        sql_id = '&1'
    --AND sample_time BETWEEN TIMESTAMP'2020-02-26 14:45:17' AND TIMESTAMP'2020-02-26 15:15:17'
    GROUP BY
        sql_id
      , session_id
      , session_serial#
      , sample_time
      , sql_exec_start
      , sql_exec_id
      , session_state
      , event
),
longrunning AS (
SELECT * FROM ash
WHERE
    elapsed_time > INTERVAL '1' SECOND
)
SELECT
    sql_id
  , sql_exec_start
  , MAX(elapsed_time) -- an earlier analytic function already does the "partition by session_id,session_serial#"
  , session_state
  , event
  , COUNT(*) seconds
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

