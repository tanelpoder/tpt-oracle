-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL sysm_group_name HEAD METRICGROUP FOR A30

prompt Display SYSTEM metrics from V$METRIC

select
   mg.name sysm_group_name
 , ROUND(mg.interval_size/100) seconds
 , m.metric_name
 , ROUND(m.value,2) value
 , m.metric_unit
from
   v$metric m
 , v$metricgroup mg
where
   1=1
and m.group_id = mg.group_id
and mg.name like 'System Metrics % Duration'
and lower(m.metric_name) like lower('%&1%')
/

