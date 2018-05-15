-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt A-Script: Display CURRENT active sessions...

select
    count(*)
  , sql_id
  , case state when 'WAITING' then 'WAITING' else 'ON CPU' end state
  , case state when 'WAITING' then event else 'On CPU / runqueue' end event
from
    v$session
where
    status='ACTIVE'
and type !='BACKGROUND'
and wait_class != 'Idle'
and sid != (select sid from v$mystat where rownum=1)
group by
    sql_id
  , case state when 'WAITING' then 'WAITING' else 'ON CPU' end
  , case state when 'WAITING' then event else 'On CPU / runqueue' end
order by
    count(*) desc
/

