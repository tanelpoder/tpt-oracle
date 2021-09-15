-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- check if there's sample time drift in ASH (should be every 1 seconds)
-- it makes sense to run this only on active systems where every sample there
-- are some active sessions seen

select * from (
    select 
        to_char(sample_time,'YYYYMMDD HH24:MI:SS')
      , sample_time-lag(sample_time) over(order by sample_time) delta
    from 
        (select distinct sample_time from v$active_session_history)
)
where
    delta < numtodsinterval(2, 'second') -- eliminate ASH sample gaps without captured DB activity
/


