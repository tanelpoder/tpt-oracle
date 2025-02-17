-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL begin_interval_time FOR A30
COL end_interval_time FOR A30
COL stat_name FOR A50

SELECT * FROM (
    SELECT
        TO_CHAR(end_interval_time, 'YYYY-MM-DD HH24:MI:SS') snap_end_time
      , stat_name
      , CASE WHEN value - LAG(value) OVER (PARTITION BY stat_name ORDER BY begin_interval_time) < 0 THEN value ELSE value - LAG(value) OVER (PARTITION BY stat_name ORDER BY begin_interval_time) END value
    FROM
         dba_hist_sysstat
       NATURAL JOIN
         dba_hist_snapshot
    WHERE
        REGEXP_LIKE(stat_name, '&1', 'i')
    AND begin_interval_time >= &2
    AND end_interval_time   <= &3
    ORDER BY
        begin_interval_time, stat_name
)
WHERE value > 0
/

