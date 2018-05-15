-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col source_owner head OWNER for a20
col source_name for a25
col source_line head LINE# for 999999
col source_text for a100
col source_type noprint

break on type skip 1

select 
	owner source_owner,
	type source_type,
	name source_name,
	line source_line, 
	text source_text
from 
	dba_source
where 
	lower(name) like '&1'
and	lower(text) like lower('&2')
order by
	source_owner,
	source_name,
	source_type,
	line
;
