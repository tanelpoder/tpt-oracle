-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- on 10.2.0.1
-- doesn't work in all cases...

set feedback off termout off
alter session set optimizer_mode=first_rows;

select * from dba_lock_internal;

set feedback on termout on
