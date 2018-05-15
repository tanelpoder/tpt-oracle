-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

set echo on

select 
    t.owner, t.created, i.last_ddl_time
from 
    test_objects    t
  , indexed_objects i
where 
    t.object_id = i.object_id 
and t.owner = 'SH'  
and t.object_name like 'S%'
/

@xall


select /*+ LEADING(t,i) USE_NL(i) */
    t.owner, t.created, i.last_ddl_time
from 
    test_objects    t
  , indexed_objects i
where 
    t.object_id = i.object_id 
and t.owner = 'SH'  
and t.object_name like 'S%'
/

@xall


select /*+ LEADING(t,i) USE_NL(i) NO_NLJ_PREFETCH(i) */
    t.owner, t.created, i.last_ddl_time
from 
    test_objects    t
  , indexed_objects i
where 
    t.object_id = i.object_id 
and t.owner = 'SH'  
and t.object_name like 'S%'
/

@xall

select /*+ LEADING(t,i) USE_NL(i) NO_NLJ_BATCHING(i) */
    t.owner, t.created, i.last_ddl_time
from 
    test_objects    t
  , indexed_objects i
where 
    t.object_id = i.object_id 
and t.owner = 'SH'  
and t.object_name like 'S%'
/

@xall

select /*+ LEADING(t,i) USE_NL(i) NO_NLJ_PREFETCH(t) NO_NLJ_PREFETCH(i) NO_NLJ_BATCHING(t) NO_NLJ_BATCHING(i) */
    t.owner, t.created, i.last_ddl_time
from 
    test_objects    t
  , indexed_objects i
where 
    t.object_id = i.object_id 
and t.owner = 'SH'  
and t.object_name like 'S%'
/

@xall

set echo off
