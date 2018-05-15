-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select 	
	ru.indx SID,
/*	decode ( KSURIND                                                       
		, 0, 'COMPOSITE_LIMIT'
		, 1, 'LOGINS_PER_USER'
		, 2, 'CPU_PER_SESSION'
		, 3, 'CPU_PER_CALL'
		, 4, 'IO_PER_SESSION'
		, 5, 'IO_PER_CALL' 
		, 6, 'MAX_IDLE_TIME'   
		, 7, 'MAX_CONNECT_TIME'
		, 8, 'PRIVATE_SGA'     
		, 9, 'PROCEDURE_SPACE'
		, to_char(KSURIND) */
	rm.name RES,
	ru.ksuruse USED
from
	sys.resource_map	rm,
	x$ksuru				ru
where
	ru.indx = to_number(&1)
and rm.resource# = ru.ksurind
and rm.type# = 0
/
