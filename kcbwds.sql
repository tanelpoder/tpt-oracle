-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select 
    addr
  , set_id
  , dbwr_num       dbwr#
  , flag
  , blk_size
  , proc_group
  , CNUM_SET
  , CNUM_REPL
  , ANUM_REPL
  , CKPT_LATCH
  , CKPT_LATCH1
  , SET_LATCH
  , COLD_HD
  , HBMAX
  , HBUFS 
from 
    X$KCBWDS
WHERE 
    CNUM_SET != 0
/


