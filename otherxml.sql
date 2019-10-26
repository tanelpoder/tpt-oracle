-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select
--      sql_id
--    , child_number
--    , plan_hash_value
    xmltype(other_xml)
from
    v$sql_plan
where
    sql_id = '&1'
and  child_number = TO_NUMBER('&2')
and  other_xml is not null
/

