-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SET LINES 999 PAGES 5000 TRIMSPOOL ON TRIMOUT ON VERIFY OFF

COL sql_plan_step FOR A50 WORD_WRAP

SELECT * FROM (
  SELECT 
        a.session_state
      , a.event
      , a.sql_id
      , a.blocking_session_status
      , a.blocking_session
      , a.blocking_session_serial#
      , a.current_obj#
      , a.sql_plan_line_id
      , a.sql_plan_operation ||' '||a.sql_plan_options sql_plan_step
      , count(*)
      , lpad(round(ratio_to_report(count(*)) over () * 100)||'%',10,' ') percent
      , MIN(a.sample_time)
      , MAX(a.sample_time)
    FROM
        DBA_HIST_ACTIVE_SESS_HISTORY a
    WHERE
        a.sample_time BETWEEN TIMESTAMP'2011-01-20 17:25:00' AND TIMESTAMP'2011-01-20 18:55:00'
    AND a.event = 'enq: TX - index contention'
    GROUP BY
        a.session_state
      , a.event
      , a.sql_id
      , a.blocking_session_status
      , a.blocking_session
      , a.blocking_session_serial#
      , a.current_obj#
      , a.sql_plan_line_id
      , a.sql_plan_operation ||' '||a.sql_plan_options
    ORDER BY
        percent DESC
)
WHERE ROWNUM <= 30
/

