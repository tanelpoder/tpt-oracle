-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col sed_name head EVENT_NAME for a45
col sed_p1 head PARAMETER1 for a30
col sed_p2 head PARAMETER2 for a30
col sed_p3 head PARAMETER3 for a30
col sed_event# head EVENT# for 99999

select 
	event# sed_event#, 
	name sed_name, 
	parameter1 sed_p1, 
	parameter2 sed_p2, 
	parameter3 sed_p3 
from 
	v$event_name 
where 
	event# in (&1)
order by 
	sed_name
/
