-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

column xco_kqfcoidx heading IX format 99
column xco_name heading TABLE_NAME format a30 wrap
column xco_kqfconam heading COLUMN_NAME format a30 wrap

break on xco_name

select 
    t.name xco_name, c.kqfconam xco_kqfconam, c.kqfcodty, c.kqfcosiz, c.kqfcooff, 
    to_number(decode(c.kqfcoidx,0,null,c.kqfcoidx)) xco_kqfcoidx
from v$fixed_table t, x$kqfco c 
where t.object_id = c.kqfcotob 
and upper(c.kqfconam) like upper('%&1%')
/
