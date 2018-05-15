-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select 'exec dbms_scheduler.disable( '''||owner||'.'||job_name||''' );' 
from dba_scheduler_jobs where lower(job_name) like lower('&1');
