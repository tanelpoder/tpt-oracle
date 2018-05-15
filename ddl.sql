-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   ddl.sql
-- Purpose:     Extracts DDL statements for specified objects
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @ddl [schema.]<object_name_pattern>
-- 	        @ddl mytable
--	        @ddl system.table
--              @ddl sys%.%tab%
--
--------------------------------------------------------------------------------


exec dbms_metadata.set_transform_param( dbms_metadata.session_transform,'SQLTERMINATOR', TRUE);

select
	dbms_metadata.get_ddl( object_type, object_name, owner ) 
from 
	all_objects 
where 
    object_type NOT LIKE '%PARTITION' AND object_type NOT LIKE '%BODY'
AND	upper(object_name) LIKE 
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
/

