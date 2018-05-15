-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   ses.sql (SEssion Statistics)
-- Purpose:     Display Session statistics for given sessions, filter by
--              statistic name
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @ses <sid> <statname>
--              @ses 10 %
--              @ses 10 parse
--              @ses 10,11,12 redo
--              @ses "select sid from v$session where username = 'APPS'" parse
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
/
