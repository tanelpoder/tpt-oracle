-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   ses2.sql (SEssion Statistics 2)
-- Purpose:     Display Session statistics for given sessions, filter by
--              statistic name and show only stats with value > 0
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @ses2 <sid> <statname>
--              @ses2 10 %
--              @ses2 10 parse
--              @ses2 10,11,12 redo
--              @ses2 "select sid from v$session where username = 'APPS'" parse
--          
--------------------------------------------------------------------------------

select 
    ses.sid,
    sn.name, 
    ses.value
from
    v$sesstat ses,
    v$statname sn
where
    sn.statistic# = ses.statistic#
and ses.sid in (&1)
and lower(sn.name) like lower('%&2%')
and ses.value > 0
/
