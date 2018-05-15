-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT 
   o1.NAME,
   s.fts_statnam,
   s.fts_staval,
   s.fts_preval
FROM 
    x$ksolsfts s,
    OBJ$ o1,
    OBJ$ o2
WHERE 
    s.fts_objd = o1.dataobj#
AND s.fts_objd = o2.obj#
AND fts_statnam IN (
      SELECT st_name FROM x$ksolsstat WHERE BITAND(st_flag, 2) = 2
) 
AND (s.fts_staval != 0 OR  s.fts_preval != 0)
/
