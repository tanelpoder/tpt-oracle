-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select
  service_name
, stat_name
, value
from 
  v$service_stats
where
    lower(service_name) like lower('&1')
and lower(stat_name) like lower('&2')
/

