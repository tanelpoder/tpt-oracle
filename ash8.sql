-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SET LINES 999 PAGES 5000 TRIMSPOOL ON TRIMOUT ON VERIFY OFF

SELECT * FROM (
  SELECT 
        a.session_state
      , a.event
      , count(*)
      , lpad(round(ratio_to_report(count(*)) over () * 100)||'%',10,' ') percent
      , MIN(a.sample_time)
      , MAX(a.sample_time)
    FROM
        dba_hist_active_sess_history a
    WHERE
        a.sample_time BETWEEN TIMESTAMP'2011-01-10 18:00:00' AND TIMESTAMP'2011-01-10 19:00:00'
    GROUP BY
        a.session_state
      , a.event
    ORDER BY
        percent DESC
)
WHERE ROWNUM <= 30
/

SELECT * FROM (
  SELECT 
        a.program
      , a.sql_id
      , a.session_state
      , a.event
      , count(*)
      , lpad(round(ratio_to_report(count(*)) over () * 100)||'%',10,' ') percent
      , MIN(a.sample_time)
      , MAX(a.sample_time)
    FROM
        dba_hist_active_sess_history a
    WHERE
        a.sample_time BETWEEN TIMESTAMP'2011-01-10 18:00:00' AND TIMESTAMP'2011-01-10 19:00:00'
    GROUP BY
        a.program
      , a.sql_id
      , a.session_state
      , a.event
    ORDER BY
        percent DESC
)
WHERE ROWNUM <= 30
/

SELECT * FROM (
  SELECT
        a.program
      , a.sql_id
      , a.session_state
      , a.event
      , a.p1
      , a.p2
      , count(*)
      , lpad(round(ratio_to_report(count(*)) over () * 100)||'%',10,' ') percent
      , MIN(a.sample_time)
      , MAX(a.sample_time)
    FROM
        dba_hist_active_sess_history a
    WHERE
        a.sample_time BETWEEN TIMESTAMP'2011-01-10 18:00:00' AND TIMESTAMP'2011-01-10 19:00:00'
    GROUP BY
        a.program
      , a.sql_id
      , a.session_state
      , a.event
      , a.p1
      , a.p2
    ORDER BY
        percent DESC
)
WHERE ROWNUM <= 300
/

