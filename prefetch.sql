-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   prefetch.sql   
-- Purpose:     Show KCB layer prefetch 
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       
-- 	        
--	        
-- Other:       
--              
--              
--
--------------------------------------------------------------------------------
col "BLOCKS/OP" for 999.9

select
    p.id
  , p.name
  , p.block_size
  , pf.timestamp
  , pf.prefetch_ops ops
  , pf.prefetch_blocks blocks
  , pf.prefetch_blocks / pf.prefetch_ops "BLOCKS/OP"
from
    X$KCBKPFS pf
  , v$buffer_pool p
where
    pf.BUFFER_POOL_ID = p.id
and pf.prefetch_ops > 0
order by
    pf.timestamp
/
