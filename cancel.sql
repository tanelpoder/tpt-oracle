-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.


--------------------------------------------------------------------------------
--
-- File name:   cancel.sql
-- Purpose:     Generates commands for canceling selected sessions
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @cancel <filter expression> (example: @cancel username='SYSTEM')
--              @cancel sid=150
--              @cancel username='SYSTEM'
--              @cancel "username='APP' and program like 'sqlplus%'"
--
-- Other:       Oracle 12.2 or newer required!
-- 
--              This script doesnt actually cancel any sessions       
--              it just generates the ALTER SYSTEM CANCEL SQL
--              commands, the user can select and paste in the selected
--              commands manually
-- 
--              See more info at:
--                https://blog.tanelpoder.com/2010/02/17/how-to-cancel-a-query-running-in-another-session/
--              
--              Oracle 12.2 and 18c take SID,SERIAL#[,@inst_id,sql_id] as arguments. 
--              Just SID,SERIAL# are enough for canceling the currently running SQL
-- 
--              An older resource manager technique that doesn't always seem to work (not fast enough at least):
--
--              EXEC DBMS_RESOURCE_MANAGER.SWITCH_CONSUMER_GROUP_FOR_SESS (sid, serial#, 'CANCEL_SQL'); 
--
--------------------------------------------------------------------------------

SELECT 'ALTER SYSTEM CANCEL SQL '''||sid||','||serial#||''' -- '
       ||username||' ['||NVL(sql_id, 'sql_id is null')||'] @'||machine||' ('||program||');' commands_to_verify_and_run
FROM v$session
WHERE &1
AND sid != (SELECT sid FROM v$mystat WHERE ROWNUM = 1)
/

