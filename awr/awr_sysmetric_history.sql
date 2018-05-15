-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT
    CAST(begin_interval_time AS DATE) begin_time
  , metric_name
  , metric_unit
  , value
FROM
    dba_hist_snapshot
NATURAL JOIN
    dba_hist_sysmetric_history
WHERE
    metric_name LIKE '&1'
--    metric_name IN ('Physical Reads Per Sec')
--    metric_name IN ('Host CPU Utilization (%)')
--    metric_name IN ('Logons Per Sec')
AND begin_interval_time > SYSDATE - 15
ORDER BY
    metric_name
  , begin_time
/

