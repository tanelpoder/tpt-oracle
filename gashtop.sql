-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- usage: @ashtop sql_id

COL ash_from_date NEW_VALUE ash_from_date
COL ash_to_date   NEW_VALUE ash_to_date

-- This was too much!
--SELECT 
--    regexp_replace('&3','^-([0-9]*)(.)$', ' sysdate - \1 / ', 1, 0, 'i')
--        ||decode(regexp_replace('&3', '^-[0-9]*(.)$', '\1', 1, 0, 'i'),
--            'd', '1', 
--            'h', '24', 
--            'm','24/60',
--            's','24/60/60', 
--            ''
--          ) ash_from_date, 
--    regexp_replace(regexp_replace('&4', '^now$', 'sysdate'),'^-([0-9]*)(.)$', ' sysdate - \1 / ', 1, 0, 'i')
--        ||decode(regexp_replace(regexp_replace('&4', '^now$', 'sysdate'), '^-[0-9]*(.)$', '\1', 1, 0, 'i'),
--            'd', '1', 
--            'h', '24', 
--            'm','24/60',
--            's','24/60/60', 
--            ''
--          ) ash_to_date 
--from 
--    dual
--/

SELECT * FROM (
    SELECT
        LPAD(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100)||'%',5,' ') "%This"
      , &1
      , COUNT(*)                                                     "TotalSeconds"
      , SUM(CASE WHEN wait_class IS NULL           THEN 1 ELSE 0 END) "CPU"
      , SUM(CASE WHEN wait_class ='User I/O'       THEN 1 ELSE 0 END) "User I/O"
      , SUM(CASE WHEN wait_class ='Application'    THEN 1 ELSE 0 END) "Application"
      , SUM(CASE WHEN wait_class ='Concurrency'    THEN 1 ELSE 0 END) "Concurrency"
      , SUM(CASE WHEN wait_class ='Commit'         THEN 1 ELSE 0 END) "Commit"
      , SUM(CASE WHEN wait_class ='Configuration'  THEN 1 ELSE 0 END) "Configuration"
      , SUM(CASE WHEN wait_class ='Cluster'        THEN 1 ELSE 0 END) "Cluster"
      , SUM(CASE WHEN wait_class ='Idle'           THEN 1 ELSE 0 END) "Idle"
      , SUM(CASE WHEN wait_class ='Network'        THEN 1 ELSE 0 END) "Network"
      , SUM(CASE WHEN wait_class ='System I/O'     THEN 1 ELSE 0 END) "System I/O"
      , SUM(CASE WHEN wait_class ='Scheduler'      THEN 1 ELSE 0 END) "Scheduler"
      , SUM(CASE WHEN wait_class ='Administrative' THEN 1 ELSE 0 END) "Administrative"
      , SUM(CASE WHEN wait_class ='Queueing'       THEN 1 ELSE 0 END) "Queueing"
      , SUM(CASE WHEN wait_class ='Other'          THEN 1 ELSE 0 END) "Other"
    FROM
        gv$active_session_history a
      , dba_users u
    WHERE
        a.user_id = u.user_id (+)
    AND &2
    AND sample_time BETWEEN &3 AND &4
    GROUP BY
        &1
    ORDER BY
        "TotalSeconds" DESC
       , &1
)
WHERE
    ROWNUM <= 20
/

