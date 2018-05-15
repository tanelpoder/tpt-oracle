-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col o_owner heading OWNER for a25
col o_object_name heading OBJECT_NAME for a30
col o_object_type heading OBJECT_TYPE for a18
col o_status heading STATUS for a9

prompt Listing Other Users objects where username matches %&1% and object matches %&2%

select 
    owner o_owner,
    object_name o_object_name, 
    object_type o_object_type,
    created, 
    last_ddl_time,
    status o_status
from 
    dba_objects 
where 
    upper(owner) like upper('%&1%')
and upper(object_name) like upper('%&2%')
order by 
    o_object_name,
    o_owner,
    o_object_type
;

