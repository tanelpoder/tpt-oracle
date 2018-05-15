-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select 
	lock_id1,
	session_id, 
	lock_Type, 
	mode_held, 
	mode_requested
from 
	dba_lock_internal 
where 
	lower(lock_id1) like lower('&1')
/
