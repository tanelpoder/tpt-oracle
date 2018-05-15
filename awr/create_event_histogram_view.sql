-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

CREATE OR REPLACE VIEW sys.t_hist_event_histogram AS
SELECT
    SNAP_ID                         -- NOT NULL NUMBER
  , DBID                            -- NOT NULL NUMBER
  , INSTANCE_NUMBER                 -- NOT NULL NUMBER
  , EVENT_ID                        -- NOT NULL NUMBER
  , EVENT_NAME                      -- NOT NULL VARCHAR2(64)
  , WAIT_CLASS_ID                   --          NUMBER
  , WAIT_CLASS                      --          VARCHAR2(64)
  , WAIT_TIME_MILLI                 -- NOT NULL NUMBER
  , WAIT_COUNT                      --          NUMBER
  , CAST(BEGIN_INTERVAL_TIME AS DATE) snapshot_begin_time   -- NOT NULL TIMESTAMP(3)
  , CAST(END_INTERVAL_TIME AS DATE)   snapshot_end_time     -- NOT NULL TIMESTAMP(3)
  , TO_CHAR(begin_interval_time, 'YYYY')  snapshot_begin_year
  , TO_CHAR(begin_interval_time, 'MM')    snapshot_begin_month_num
  , TO_CHAR(begin_interval_time, 'MON')   snapshot_begin_mon
  , TO_CHAR(begin_interval_time, 'Month') snapshot_begin_month
  , TO_CHAR(begin_interval_time, 'DD')    snapshot_begin_day
  , TO_CHAR(begin_interval_time, 'HH24')  snapshot_begin_hour
  , TO_CHAR(begin_interval_time, 'MI')    snapshot_begin_minute
FROM
    dba_hist_snapshot
NATURAL JOIN
    dba_hist_event_histogram
/

GRANT SELECT ON sys.t_hist_event_histogram TO PUBLIC;
CREATE PUBLIC SYNONYM t_hist_event_histogram FOR sys.t_hist_event_histogram;

