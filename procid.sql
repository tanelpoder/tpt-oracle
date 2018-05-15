-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col proc_owner 		head OWNER for a25
col proc_object_name	head OBJECT_NAME for a30
col proc_procedure_name	head PROCEDURE_NAME for a30

select 
	owner		proc_owner,
	object_name	proc_object_name,
	procedure_name	proc_procedure_name,
        subprogram_id
from 
	dba_procedures 
where 
        object_id like '&1'
and	subprogram_id like '&2'
order by
        owner,
        object_name,
        procedure_name
/

