-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL metric_group_id HEAD GID FORMAT 999
COL group_name HEAD GROUP_NAME FORMAT A35
COL metric_name FORMAT A48
COL metric_unit FORMAT A45

select
    g.group_id AS metric_group_id
  , g.name group_name
  , n.metric_name
  , n.metric_unit
from
    v$metricname n
  , v$metricgroup g
where
    n.group_id = g.group_id
and
    lower(n.metric_name) like lower('%&1%')
order by
    metric_group_id 
  , metric_name
/
