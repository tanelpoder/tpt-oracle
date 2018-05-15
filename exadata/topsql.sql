-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT * FROM (
    SELECT 
        sql_id, executions, physical_read_bytes --, sql_text 
    FROM 
        v$sqlstats
    WHERE io_cell_offload_eligible_bytes = 0
    ORDER BY physical_read_bytes DESC
) 
WHERE 
    ROWNUM <= 10
/
