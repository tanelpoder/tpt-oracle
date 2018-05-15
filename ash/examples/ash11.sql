-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SET LINES 999 PAGES 5000 TRIMSPOOL ON TRIMOUT ON VERIFY OFF

COL sql_plan_step FOR A50 WORD_WRAP

SELECT * FROM (
  SELECT 
        a.session_type
      , a.session_state
      , a.event
      , a.sql_id
      , count(*)
      , lpad(round(ratio_to_report(count(*)) over () * 100)||'%',10,' ') percent
      , MIN(a.sample_time)
      , MAX(a.sample_time)
    FROM
        DBA_HIST_ACTIVE_SESS_HISTORY a
    WHERE
        a.sample_time BETWEEN TIMESTAMP'2011-05-14 06:00:00' AND TIMESTAMP'2011-05-14 06:10:00'
    GROUP BY
        a.session_type
      , a.session_state
      , a.event
      , a.sql_id
    ORDER BY
        percent DESC
)
WHERE ROWNUM <= 30
/

