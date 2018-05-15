-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col du_MB head MB FOR 99999999.9
col du_GB head GB FOR 99999999.9
col du_owner HEAD OWNER FOR A30

select
    owner              du_owner
  , sum(bytes)/1048576 du_MB
  , sum(bytes)/1048576/1024 du_GB
from
    dba_segments
where
    lower(owner) like lower('&1')
group by
    owner
order by
    du_MB desc
/
