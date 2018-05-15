-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select 
    'exec dbms_monitor.session_trace_enable('||sid||','||serial#||',waits=>true,binds=>true);' command_to_run
from
    v$session
where
    &1
/
