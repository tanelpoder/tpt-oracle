-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL partial_sql_text FOR A40
SELECT
    SUBSTR(sql_text,1,40) partial_sql_text
  , sql_exec_start
  , sql_id
  , ROUND(elapsed_time/1000) ela_ms
  , ROUND(cpu_time/1000)     cpu_ms
  , buffer_gets              lios
  , ROUND(physical_read_bytes/1024/1024,2)      rd_mb
  , ROUND(physical_write_bytes/1024/1024,2)     wr_mb
FROM
    v$sql_monitor
WHERE
    sid = SYS_CONTEXT('USERENV','SID')
AND (sql_id, last_refresh_time) IN (
                         SELECT sql_id, MAX(last_refresh_time) 
                         FROM v$sql_monitor
                         WHERE sid = SYS_CONTEXT('USERENV','SID')
                         AND sql_text LIKE '&1'
                         GROUP BY sql_id
                        )
ORDER BY
    sql_exec_start
  , sql_exec_id
/

