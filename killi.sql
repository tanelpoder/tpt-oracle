-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   kill.sql
-- Purpose:     Generates commands for killing selected sessions
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @kill <filter expression> (example: @kill username='SYSTEM')
-- 	        @kill sid=150
--	        @kill username='SYSTEM'
--              @kill "username='APP' and program like 'sqlplus%'"
--
-- Other:       This script doesnt actually kill any sessions       
--              it just generates the ALTER SYSTEM KILL SESSION
--              commands, the user can select and paste in the selected
--              commands manually
--
--------------------------------------------------------------------------------

select 'alter system kill session '''||sid||','||serial#||''' immediate -- '
       ||username||'@'||machine||' ('||program||');' commands_to_verify_and_run
from v$session
where &1
and sid != (select sid from v$mystat where rownum = 1)
/ 
