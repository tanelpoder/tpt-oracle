-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.
col name for a35
col version for a15
col version_outline for a15
col inverse for a35
col statement_level for a17
col query_block_level for a17
col object_level for a17
col join_level for a17
select 
    name,
    version,
    version_outline,
    inverse,
    decode(bitand(target_level,1),0,'NO','YES') AS statement_level,
    decode(bitand(target_level,2),0,'NO','YES') AS query_block_level,
    decode(bitand(target_level,4),0,'NO','YES') AS object_level,
    decode(bitand(target_level,6),0,'NO','YES') AS join_level
from v$sql_hint 
where lower(name) like lower('%&1%');
