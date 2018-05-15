-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT * FROM (
    SELECT
        TO_CHAR(sample_time, 'YYYY-MM-DD HH24:MI:SS.FF') sample_time
      , ROUND(SUM(pga_allocated)/1024/1024) total_pga_mb
      , ROUND(SUM(temp_space_allocated)/1024/1024) total_temp_mp
      , COUNT(DISTINCT session_id||':'||session_serial#) act_sessions 
    FROM 
        v$active_session_history 
    GROUP BY 
        sample_time 
    ORDER BY total_pga_mb
        DESC
) 
WHERE rownum <= 10
/


