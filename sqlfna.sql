-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL sqlfna_name HEAD NAME FOR A30
BREAK ON sqlfna_name SKIP 1 ON func_id

SELECT
    f.name           sqlfna_name
  , f.func_id
  , f.analytic
  , f.aggregate
  , f.offloadable
--  , f.usage
  , f.minargs
  , f.maxargs
  , a.argnum
  , a.datatype
  , a.descr
--  , f.descr 
FROM
    v$sqlfn_metadata f
  , v$sqlfn_arg_metadata a
WHERE 
    a.func_id = f.func_id
AND UPPER(f.name) LIKE UPPER('&1')
ORDER BY
    f.name
  , f.func_id
  , f.analytic
  , f.aggregate
  , a.argnum
/

