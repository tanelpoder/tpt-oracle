-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select * from (
	select timestamp, username, os_username, userhost, terminal, action_name 
	from dba_audit_session
	order by timestamp desc
)
where rownum <= 20;
