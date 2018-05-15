-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- object arguments

col proc_owner 		head OWNER for a25
col proc_object_name	head OBJECT_NAME for a30
col proc_procedure_name	head PROCEDURE_NAME for a30

select 
	  a.owner           proc_owner
  , a.object_name	    proc_object_name
  , p.procedure_name	proc_procedure_name
  , a.subprogram_id
from 
    dba_arguments a
  , dba_procedures p
where 
    a.owner = p.owner
and a.object_name = p.object_name
and a.object_id = p.object_id
and a.subprogram_id = p.subprogram_id
and lower(p.owner) like lower('%&1%')
and lower(p.object_name) like lower('%&2%')
and	lower(p.procedure_name) like lower('%&3%')
/
