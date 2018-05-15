-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Display active sessions current SQLs

select
    sql_id
  , sql_hash_value
  , sql_child_number
  , count(*)
from
    v$session
where
    status='ACTIVE'
and type !='BACKGROUND'
and sid != (select sid from v$mystat where rownum=1)
group by
    sql_id
  , sql_hash_value
  , sql_child_number
order by
    count(*) desc
/

