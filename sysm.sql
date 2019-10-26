-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL sysm_group_name HEAD METRICGROUP FOR A30
COL sysm_metric_name HEAD METRIC_NAME FOR A45

prompt Display SYSTEM metrics from V$METRIC

select
   (sysdate-end_time)*86400    seconds_ago
-- , end_time last_updated
 , ROUND(mg.interval_size/100) seconds
 , m.metric_name               sysm_metric_name
 , ROUND(m.value,2)            value
 , m.metric_unit
 , mg.name                     sysm_group_name
from
   v$metric m
 , v$metricgroup mg
where
   1=1
and m.group_id = mg.group_id
and mg.name like 'System Metrics % Duration'
and lower(m.metric_name) like lower('%&1%')
/

