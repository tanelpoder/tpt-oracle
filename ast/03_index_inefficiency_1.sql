-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select /*+ index_rs(o o(owner)) */ avg(sysdate - created) days_old 
from
     indexed_objects o 
where 
    owner = 'SYS' 
and object_type = 'PACKAGE'
/

@x

-- Then create an index which satisfies the additional filter column...
--   create index idx2_indexed_objects on indexed_objects (owner, object_type);

-- Then re-create the index with also the column that includes the columns selected in the query
--   drop index idx2_indexed_objects;
--   create index idx2_indexed_objects on indexed_objects (owner, object_type, created);

