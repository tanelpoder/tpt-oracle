-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select 
	* 
from 
	dba_audit_object
where
	upper(owner) like upper('&1')
and 	upper(obj_name) like upper('&2')
order by
	timestamp desc
/
