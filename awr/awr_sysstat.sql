-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL begin_interval_time FOR A30
COL end_interval_time FOR A30
COL stat_name FOR A50

SELECT
    TO_CHAR(end_interval_time, 'YYYY-MM-DD HH24:MI:SS') snap_end_time
  , stat_name
  , CASE WHEN value - LAG(value) OVER (PARTITION BY stat_name ORDER BY begin_interval_time) < 0 THEN value ELSE value - LAG(value) OVER (PARTITION BY stat_name ORDER BY begin_interval_time) END value
FROM
     dba_hist_sysstat
   NATURAL JOIN
     dba_hist_snapshot
WHERE
    stat_name IN (
                  'sql area evicted'
                , 'sql area purged'
                , 'CCursor + sql area evicted'
                , 'logons cumulative'
                , 'user logons cumulative'
              --, 'auto extends on undo tablespace'                                                          
              --, 'total number of undo segments dropped'                                                    
              --, 'undo segment header was pinned'                                                           
              --, 'SMON posted for undo segment recovery'                                                    
              --, 'SMON posted for undo segment shrink' 
)
AND begin_interval_time >= &1
AND end_interval_time   <= &2
ORDER BY
    begin_interval_time, stat_name
/

