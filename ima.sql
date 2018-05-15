-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL "USED%" FOR A7 JUST RIGHT
PROMPT Querying GV$INMEMORY_AREA...

SELECT 
    inst_id
  , pool                    
  , ROUND(alloc_bytes/1048576) alloc_mb          
  , ROUND(used_bytes/1048576)  used_mb
  , LPAD(ROUND(used_bytes/NULLIF(alloc_bytes,0)*100,1)||'%',7) "USED%"
  , populate_status         
  , con_id                  
FROM
    gv$inmemory_area
ORDER BY
    pool
  , inst_id
/
