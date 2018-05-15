-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col jobs_what head WHAT for a50
col jobs_interval head INTERVAL for a40

col jobs_job_name head JOB_NAME for a40
col jobs_program_name head PROGRAM_NAME for a40

select job, what jobs_what, last_date, next_date, interval jobs_interval, failures, broken from dba_jobs;

select
    job_name      jobs_job_name
  , program_name  jobs_program_name
  , state         jobs_state
  , to_char(start_date, 'YYYY-MM-DD HH24:MI') start_date
  , to_char(next_run_date, 'YYYY-MM-DD HH24:MI') next_run_date
  , enabled
from
    dba_scheduler_jobs
where
    state = 'RUNNING'
/

