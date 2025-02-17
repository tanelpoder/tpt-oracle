-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL hintf_name FOR A35

select 
    name            hintf_name
  , sql_feature
  , version
  , version_outline 
  , decode(bitand(target_level,1),1,'STATEMENT ') ||
    decode(bitand(target_level,2),2,'QBLOCK ')    ||
    decode(bitand(target_level,4),4,'OBJECT ')    ||
    decode(bitand(target_level,8),8,'JOIN ') hint_scope
from 
    v$sql_hint 
where 
    lower(sql_feature) like lower('%&1%')
/
