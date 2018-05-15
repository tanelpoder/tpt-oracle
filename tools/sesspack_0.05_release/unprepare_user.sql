-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- Author:	Tanel Poder
-- Copyright:	(c) http://www.tanelpoder.com
-- 
-- Notes:	This software is provided AS IS and doesn't guarantee anything
-- 		Proofread before you execute it!
--
--------------------------------------------------------------------------------

prompt 
prompt Dropping roles...
prompt

drop role sesspack_admin_role;
drop role sesspack_user_role;

prompt
prompt Ready to revoke SAWR privileges from user &spuser
prompt The following commands will be run:
prompt 

prompt revoke select on sys.v_$session from &spuser;
prompt revoke select on sys.v_$session_wait from &spuser;
prompt revoke select on sys.v_$session_event from &spuser;
prompt revoke select on sys.v_$sess_time_model from &spuser;
prompt revoke select on sys.v_$sesstat from &spuser;
prompt revoke select on sys.v_$event_name from &spuser;
prompt revoke select on sys.v_$statname from &spuser;

prompt
pause Press CTRL-C if you don't want to run those commands, otherwise press ENTER...
prompt

revoke select on sys.v_$session from &spuser;
revoke select on sys.v_$session_wait from &spuser;
revoke select on sys.v_$session_event from &spuser;
revoke select on sys.v_$sess_time_model from &spuser;
revoke select on sys.v_$sesstat from &spuser;
revoke select on sys.v_$event_name from &spuser;
revoke select on sys.v_$statname from &spuser;

whenever sqlerror continue
