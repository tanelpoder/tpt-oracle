-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select  
	c.ts#
  , t.tablespace_name
  , t.block_size blksz
  , status
  , t.bigfile
  , contents
  , logging
  , force_logging forcelog 
  , extent_management
  , allocation_type
  , segment_space_management ASSM
  , min_extlen EXTSZ
  , compress_for
  , predicate_evaluation
from 
	v$tablespace c, 
	dba_tablespaces t
where c.name = t.tablespace_name
and   upper(tablespace_name) like upper('%&1%');




