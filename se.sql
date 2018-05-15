-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col se_time_waited head TIME_WAITED for 99999999.90
col se_sid head SID for 999999
col se_event head EVENT for a40 truncate

break on se_sid skip 1

select * from (
    select sid se_sid, event se_event, time_waited/100 se_time_waited, total_waits, total_timeouts, average_wait/100 average_wait, max_wait/100 max_wait
    from v$session_event 
    where sid in (&1)
    union all
    select sid, 'CPU Time', value/100, cast(null as number), cast(null as number), cast(null as number), cast(null as number)
    from v$sesstat
    where sid in (&1)
    and statistic# = (select statistic# from v$statname where name =('CPU used by this session'))
)
order by se_sid, se_time_waited desc, total_waits desc;
