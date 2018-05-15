-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Display Latch Children stats from V$LATCH for latches matching %&1%

select addr, child#, name, gets, misses, immediate_gets ig, immediate_misses im, spin_gets spingets
from v$latch_children
where lower(name) like lower('%&1%')
order by name, child#
/
