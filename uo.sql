-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col o_owner heading owner for a25
col o_object_name heading object_name for a30
col o_object_type heading object_type for a15

prompt Listing current user's objects matching %&1%

select 
    object_name o_object_name, 
    object_type o_object_type,
    created, 
    last_ddl_time,
    status
from 
    user_objects
where 
    upper(object_name) like upper('%&1%')
order by 
    o_object_type,
    o_object_name
;

