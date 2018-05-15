-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col o_owner heading owner for a25
col o_object_name heading object_name for a30
col o_object_type heading object_type for a20
col o_status heading status for a9

select 
    owner o_owner,
    object_name o_object_name, 
    object_type o_object_type,
    status o_status,
    object_id oid,
    data_object_id d_oid,
    created, 
    last_ddl_time
from 
    dba_objects 
where 
	upper(object_name) LIKE 
				upper(CASE 
					WHEN INSTR('&1','.') > 0 THEN 
					    SUBSTR('&1',INSTR('&1','.')+1)
					ELSE
					    '&1'
					END
				     )
AND	owner LIKE
		CASE WHEN INSTR('&1','.') > 0 THEN
			UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
		ELSE
			user
		END
order by 
    o_object_name,
    o_owner,
    o_object_type
/
