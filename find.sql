-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt PARAMETERS

@pd "&1"

prompt STATS
select * from v$sysstat where lower(name) like lower('%&1%');

prompt EVENTS
select * from v$system_event where lower(event) like lower('%&1%');

prompt LATCHES
select name, gets, immediate_gets from v$latch where lower(name) like lower('%&1%');

prompt ENQUEUES

select name, expl descr from x$ksqeqtyp where lower(name) like lower('%&1%')
union
select name, expl from x$ksirestyp where lower(name) like lower('%&1%');


set feed on
