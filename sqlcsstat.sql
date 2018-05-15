-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select
 * 
from 
    v$sql_cs_statistics 
where
    sql_id = '&1'
and child_number like '&2'
order by
    sql_id
  , child_number
/

