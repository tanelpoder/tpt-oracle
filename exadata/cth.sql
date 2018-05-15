-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

------------------------------------------------------------------------------------------------------------------------
--
-- File name:   cth.sql (v1.01)
--
-- Purpose:     Display the "ASH for Storage Cells" info from V$CELL_THREAD_HISTORY
--
-- Author:      Tanel Poder (tanel@tanelpoder.com)
--
-- Copyright:   (c) http://blog.tanelpoder.com - All rights reserved.
--
-- Disclaimer:  This script is provided "as is", no warranties nor guarantees are
--              made. Use at your own risk :)
--              
-- Usage:       @cth <grouping_columns> <sid> <from_date> <to_date>
--
--              @cth job_type,wait_state,wait_object_name,sql_id,database_id session_id=1234 sysdate-1/24 sysdate
--              @cth job_type,wait_state,wait_object_name,sql_id,database_id sql_id='5huy4dwv57qmt' sysdate-1/24 sysdate
--
-- Notes:       The v$cell_thread_history is pretty limited compared to the database ASH, so don't get 
--              your hopes too up :)
--              Also, the snapshot_time is the cell OS time, so if your DB and cells have clock drift,
--              you may end up matching the wrong time range from cell with the DB performance data.
--
------------------------------------------------------------------------------------------------------------------------

PROMPT Querying V$CELL_THREAD_HISTORY ("ASH" for Storage Cells) ...

SELECT * FROM (
    SELECT
        COUNT(*) seconds
      , ROUND(COUNT(*) / LEAST((CAST(&4 AS DATE)-CAST(&3 AS DATE))*86400, 600),1) avg_threads -- V$CELL_THREAD_HISTORY doesn't usually keep more than 10 minutes of history
      , &1
      , MIN(snapshot_time), MAX(snapshot_time)
    FROM (
        SELECT
            substr(cell_name,1,20) cell_name             
          , thread_id             
          , job_type              
          , wait_state            
          , wait_object_name      
          , sql_id                
          , database_id           
          , instance_id           
          , session_id            
          , session_serial_num    
          , snapshot_time
        FROM
            v$cell_thread_history 
        WHERE
            snapshot_time BETWEEN &3 AND &4
        AND &2
        AND wait_state NOT IN ( -- "idle" thread states
            'waiting_for_SKGXP_receive'
          , 'waiting_for_connect'      
          , 'waiting_for_SKGXP_receive'
          , 'looking_for_job'          
        )
    )
    GROUP BY &1
    ORDER BY COUNT(*) DESC
)
WHERE ROWNUM <= 20
/

