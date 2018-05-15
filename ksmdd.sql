-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT 
    addr
  , indx
  , inst_id
  , name
  , DECODE(BITAND(flags,1),1,'DYN ','') flags
  , elements_chunk
  , items_pt
  , initentries
  , numentries
  , curentries
  , numchunks
  , elemsize
  , heap
  , secondary
FROM
    X$KSMDD
WHERE
    LOWER(name) LIKE LOWER('%&1%')
ORDER BY
    addr
/
