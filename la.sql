-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   la.sql ( Latch Address )
-- Purpose:     Show which latch occupies a given memory address and its stats
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @la <address_in_hex>
--              @la 50BE2178
--
--------------------------------------------------------------------------------
column la_name heading NAME format a45
column la_chld heading CHLD format 99999

select 
    addr, latch#, 0 la_chld, name la_name, gets, immediate_gets igets, 
    misses, immediate_misses imisses, spin_gets spingets, sleeps, wait_time
from v$latch_parent
where addr = hextoraw(lpad('&1', (select vsize(addr)*2 from v$latch_parent where rownum = 1) ,0))
union all
select 
    addr, latch#, child#, name la_name, gets, immediate_gets igets, 
    misses, immediate_misses imisses, spin_gets spingets, sleeps, wait_time 
from v$latch_children
where addr = hextoraw(lpad('&1', (select vsize(addr)*2 from v$latch_children where rownum = 1) ,0))
/
