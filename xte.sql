-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--col xte_procs head ENABLED_FOR_ORAPIDS for a100 word_wrap
col procs head ENABLED_FOR_ORAPIDS for a100 word_wrap

select
--	event,
--	trclevel,
--	status,
--	to_char(flags, 'XXXXXXXX') 	flags,
--	procs				xte_procs
	*
from
	x$trace_events
where
	procs is not null
order by
	event
/

