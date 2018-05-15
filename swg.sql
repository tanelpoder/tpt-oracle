-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   swg.sql
-- Purpose:     Display given Session Wait info grouped by state and event
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @sw <sid>
--              @sw 52,110,225
-- 	        	@sw "select sid from v$session where username = 'XYZ'"
--              @sw &mysid
--
--------------------------------------------------------------------------------

col sw_event 	head EVENT for a40 truncate
col sw_p1transl head P1TRANSL for a42
col sw_sid		head SID for 999999

select 
	count(*),
	CASE WHEN state != 'WAITING' THEN 'WORKING'
	     ELSE 'WAITING'
	END AS state, 
	CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue'
	     ELSE event
	END AS sw_event
FROM 
	v$session_wait 
WHERE 
	sid IN (&1)
GROUP BY
	CASE WHEN state != 'WAITING' THEN 'WORKING'
	     ELSE 'WAITING'
	END, 
	CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue'
	     ELSE event
	END
ORDER BY
	1 DESC, 2 DESC
/



