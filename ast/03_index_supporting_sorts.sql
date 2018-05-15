-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select 
     owner, object_type, status, count(*)
from
     indexed_objects o 
where 
    owner = 'SYS' 
and object_type = 'JAVA CLASS'
and created > sysdate - 3650
group by
    owner,object_type,status
order by
    status
/


-- Then re-create the index with also the column that we sort/group by
--   drop index idx2_indexed_objects;
--   create index idx2_indexed_objects on indexed_objects (owner, object_type, created, status);

-- And try tho swap the last 2 columns in end of the index:
--   drop index idx2_indexed_objects;
--   create index idx2_indexed_objects on indexed_objects (owner, object_type, status, created);

