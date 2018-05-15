-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT
    "AREA NAME"                               -- VARCHAR2(32)
  , "NUMAPG"                                  -- NUMBER
  , "PAGESIZE" / 1024 mempage_kb                 -- NUMBER
  , ROUND("SEGMENT SIZE" / 1048576) segsize_mb -- NUMBER
  , ROUND("SIZE" / 1048576) area_size_mb            -- NUMBER
  , ROUND("REMAINING ALLOC SIZE" / 1048576) remain_mb                   -- NUMBER
  , "SHMID"                                   -- NUMBER
  , "SEGMENT DISTRIBUTED"                     -- VARCHAR2(20)
  , "AREA FLAGS"                              -- NUMBER
  , "SEGMENT DEFERRED"                        -- VARCHAR2(20)
  , "SEG_START ADDR"                          -- RAW(8)
  , "START ADDR"                              -- RAW(8)
FROM
    x$ksmssinfo
/

