-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- experimental script - it will only capture a tiny portion of disk reread waits
-- due to relatively infrequent sampling of ASH

SELECT
    SUM(rereads) 
  , t.tablespace_name
  , ts.block_size
  , o.owner
  , o.object_name
FROM 
    (SELECT current_obj#, p1, p2, TO_CHAR(p1)||':'||TO_CHAR(p2), COUNT(*) rereads 
     FROM v$active_session_history 
     WHERE 
         sample_time < SYSDATE-1/24 
     AND event = 'db file sequential read' 
     GROUP BY 
         current_obj#, p1, p2 
     HAVING
         COUNT(*) > 1
    ) a
  , dba_data_files t
  , dba_tablespaces ts 
  , dba_objects o
WHERE 
    a.p1 = t.file_id 
AND t.tablespace_name = ts.tablespace_name 
AND a.current_obj# = o.object_id (+)
GROUP BY 
    t.tablespace_name
  , ts.block_size 
  , o.owner
  , o.object_name
ORDER BY SUM(rereads) DESC
/
