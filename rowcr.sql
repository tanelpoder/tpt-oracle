-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

UPDATE /*+ INDEX (t1) */ t1
SET t1.data_object_id = (
                   SELECT /*+ INDEX (t2) */ t2.data_object_id
                   FROM  t2
                   WHERE 
                       t1.object_id = t2.object_id
                   --AND t1.data_object_id = t2.data_object_id
                   AND t1.owner = t2.owner
                   AND t1.object_name = t2.object_name
                   AND MOD(t2.object_id,2)=0
)
WHERE t1.owner = 'SYS'
AND MOD(t1.object_id,2)=0
/

