-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   fcha.sql (Find CHunk Address) v0.2
-- Purpose:     Find in which heap (UGA, PGA or Shared Pool) a memory address resides
--              
-- Author:      Tanel Poder
-- Copyright:   (c) http://blog.tanelpoder.com | @tanelpoder
--              
-- Usage:       @fcha <addr_hex>
--              @fcha F6A14448
--
-- Other:       This would only report an UGA/PGA chunk address if it belongs
--              to *your* process/session (x$ksmup and x$ksmpp do not see other
--              session/process memory)
--              
--------------------------------------------------------------------------------

prompt Find in which heap (UGA, PGA or Shared Pool) the memory address &1 resides...
prompt
prompt WARNING!!! This script will query X$KSMSP, which will cause heavy shared pool latch contention 
prompt in systems under load and with large shared pool. This may even completely hang 
prompt your instance until the query has finished! You probably do not want to run this in production!
prompt
pause  Press ENTER to continue, CTRL+C to cancel...


select
    'SGA' LOC,
    KSMCHPTR,
    KSMCHIDX,
    KSMCHDUR,
    KSMCHCOM,
    KSMCHSIZ,
    KSMCHCLS,
    KSMCHTYP,
    KSMCHPAR
from 
    x$ksmsp 
where 
    to_number(substr('&1', instr(lower('&1'), 'x')+1) ,'XXXXXXXXXXXXXXXX') 
    between 
        to_number(ksmchptr,'XXXXXXXXXXXXXXXX')
    and to_number(ksmchptr,'XXXXXXXXXXXXXXXX') + ksmchsiz - 1
union all
select
    'UGA',
    KSMCHPTR,
    null,
    null,
    KSMCHCOM,
    KSMCHSIZ,
    KSMCHCLS,
    KSMCHTYP,
    KSMCHPAR
from 
    x$ksmup 
where 
    to_number(substr('&1', instr(lower('&1'), 'x')+1) ,'XXXXXXXXXXXXXXXX') 
    between 
        to_number(ksmchptr,'XXXXXXXXXXXXXXXX')
    and to_number(ksmchptr,'XXXXXXXXXXXXXXXX') + ksmchsiz - 1
union all
select
    'PGA',
    KSMCHPTR,
    null,
    null,
    KSMCHCOM,
    KSMCHSIZ,
    KSMCHCLS,
    KSMCHTYP,
    KSMCHPAR
from 
    x$ksmpp 
where 
    to_number(substr('&1', instr(lower('&1'), 'x')+1) ,'XXXXXXXXXXXXXXXX') 
    between 
        to_number(ksmchptr,'XXXXXXXXXXXXXXXX')
    and to_number(ksmchptr,'XXXXXXXXXXXXXXXX') + ksmchsiz - 1
/
