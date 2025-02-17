-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col kghluidx head "SUB|POOL"
col kghludur head "SSUB|POOL"
col kghlufsh head "FLUSHED|CHUNKS"
col kghluops head "LRU LIST|OPERATIONS"
col kghlurcr head "RECURRENT|CHUNKS"
col kghlutrn head "TRANSIENT|CHUNKS"
col kghlunfu head "FREE UNPIN|UNSUCCESS"
col kghlunfs head "LAST FRUNP|UNSUCC SIZE"
col kghlurcn head "RESERVED|SCANS"
col kghlurmi head "RESERVED|MISSES"
col kghlurmz head "RESERVED|MISS SIZE"
col kghlurmx head "RESERVED|MISS MAX SZ"


select
    to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS') current_time
  , kghluidx
  , kghludur
  , kghlufsh
  , kghluops
  , kghlurcr
  , kghlutrn
  , kghlunfu
  , kghlunfs
  , kghlurcn
  , kghlurmi
  , kghlurmz
  , kghlurmx
--  , kghlumxa
--  , kghlumes
--  , kghlumer
from
    x$kghlu
order by
    kghluidx
  , kghludur
/
