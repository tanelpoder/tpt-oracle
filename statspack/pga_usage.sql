-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

break on snap_time

select
    s.snap_time
  , round(sum(m.allocated)/1048576) MB_ALLOC
  , round(sum(m.used)/1048576) MB_USED
  , count(distinct m.pid) processes
from
    STATS$PROCESS_MEMORY_ROLLUP m
  , STATS$SNAPSHOT s
where
    s.snap_id = m.snap_id
and s.dbid    = m.dbid
and s.instance_number = m.instance_number
group by
    s.snap_time
order by
    s.snap_time
/

select
    s.snap_time
  , m.category alloc_type
  , round(sum(m.allocated)/1048576) MB_ALLOC
  , round(sum(m.used)/1048576) MB_USED
  , count(distinct m.pid) processes
from
    STATS$PROCESS_MEMORY_ROLLUP m
  , STATS$SNAPSHOT s
where
    s.snap_id = m.snap_id
and s.dbid    = m.dbid
and s.instance_number = m.instance_number
group by
    s.snap_time
  , m.category
order by
    s.snap_time
  , m.category
/

