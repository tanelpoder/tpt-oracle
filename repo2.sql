-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select 
    SNAME
  , ONAME
  , TYPE
  , STATUS
--  , GENERATION_STATUS
  , ID
--  , OBJECT_COMMENT
  , GNAME
  , MIN_COMMUNICATION
  , REPLICATION_TRIGGER_EXISTS
  , INTERNAL_PACKAGE_EXISTS
  , GROUP_OWNER
  , NESTED_TABLE
from
    dba_repobject
where
    lower(gname) like lower('&1')
and lower(oname) like lower('&2')
/
