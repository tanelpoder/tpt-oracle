-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT
    sql_exec_start
  , sql_id
  , ROUND(elapsed_time)      ela_us
  , ROUND(cpu_time)          cpu_us
  , ROUND(elapsed_time/1000) ela_ms
  , ROUND(cpu_time/1000)     cpu_ms
--  , ROUND(cpu_time * 1000 / 10000000) cpu_ns_row
  , buffer_gets              lios
  , ROUND(physical_read_bytes/1024/1024,2)      rd_mb
  , ROUND(physical_write_bytes/1024/1024,2)     wr_mb
FROM
    v$sql_monitor
WHERE
    sid = SYS_CONTEXT('USERENV','SID')
AND last_refresh_time = (SELECT MAX(last_refresh_time) 
                         FROM v$sql_monitor
                         WHERE sid = SYS_CONTEXT('USERENV','SID')
                        )
/

