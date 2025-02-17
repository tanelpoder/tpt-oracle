-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.
col name for a35
col version for a15
col version_outline for a15
col inverse for a35

col hint_scope for a27

select 
    name,
    version,
    version_outline,
    inverse,
    decode(bitand(target_level,1),1,'STATEMENT ')    ||
    decode(bitand(target_level,2),2,'QBLOCK ')  ||
    decode(bitand(target_level,4),4,'OBJECT ')  ||
    decode(bitand(target_level,8),8,'JOIN ') hint_scope
from v$sql_hint 
where lower(name) like lower('%&1%')
/

