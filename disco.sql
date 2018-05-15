-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   disco.sql
-- Purpose:     Generates commands for disconnecting selected sessions
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @disco <filter expression>
-- 	        @disco sid=150
--	        @disco username='SYSTEM'
--              @disco "username='APP' and program like 'sqlplus%'"
--
-- Other:       This script doesnt actually kill or disconnect any sessions       
--              it just generates the ALTER SYSTEM DISCONNECT SESSION
--              commands, the user can select and paste in the selected
--              commands manually
--
--------------------------------------------------------------------------------

select '-- alter system disconnect session '''||sid||','||serial#||''' immediate -- '
       ||username||'@'||machine||' ('||program||');' commands_to_verify_and_run
from v$session
where &1
/
