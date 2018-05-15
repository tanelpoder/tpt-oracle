-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Script by Tanel Poder (http://www.tanelpoder.com)
--
-- Look up object info by object id 

col o_owner heading owner for a25
col o_object_name heading object_name for a30
col o_object_type heading object_type for a18
col o_status heading status for a9

select 
    owner o_owner,
    object_name o_object_name, 
    object_type o_object_type,
    subobject_name,
    created, 
    last_ddl_time,
    status o_status,
    data_object_id
from 
    dba_objects 
where 
    object_id in (&1)
order by 
    o_object_name,
    o_owner,
    o_object_type
/
