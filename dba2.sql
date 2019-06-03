-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Usage: @dba2 <file#> <block#>

PROMPT Translate file#=&1 block#=&2 to segment name ...

COL dba2_owner HEAD OWNER FOR A30
COL dba2_segment_name HEAD SEGMENT_NAME FOR A30
COL dba2_partition_name HEAD PARTITION_NAME FOR A30

select 
    owner dba2_owner
  , segment_name dba2_segment_name
  , partition_name dba2_partition_name
  , tablespace_name
  , extent_id
from dba_extents
where file_id = &1
and &2 between block_id and block_id + blocks - 1;
