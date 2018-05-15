-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

WITH sq AS (
    SELECT /*+ MATERIALIZE */ 
        sp.id, sp.parent_id, sp.operation, sp.options
      , sp.object_owner, sp.object_name, ss.last_elapsed_time 
    FROM v$sql_plan_statistics ss, v$sql_plan sp 
    WHERE 
        sp.sql_id=ss.sql_id 
    AND sp.child_number=ss.child_number 
    AND sp.address=ss.address 
    AND sp.id=ss.operation_id 
    AND sp.sql_id='5zp0kfkz9gmck' 
    AND sp.child_number=0
)
SELECT
    'SELECT STATEMENT'||REPLACE(TRIM(SYS_CONNECT_BY_PATH(operation||' '||options||NVL2(object_owner||object_name, ' ['||object_owner||'.'||object_name||']', NULL), ';')),' ','_')||' '||last_elapsed_time
FROM
    sq 
CONNECT BY
    parent_id = PRIOR id 
    START WITH id=1
/


