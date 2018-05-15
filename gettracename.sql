-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select value ||'/'||(select lower(instance_name) from v$instance) ||'_ora_'||
       (select spid from v$process where addr = (select paddr from v$session
                                         where sid = (select sid from v$mystat
                                                    where rownum = 1
                                               )
                                    )
       ) || '.trc' tracefile
from v$parameter where name = 'user_dump_dest';

