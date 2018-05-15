-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT * FROM (
SELECT 
    sql_id
  , executions
  , px_servers_executions  px_execs
  , physical_read_requests phyrd_rq
  , ROUND(physical_read_bytes/1048576) physrd_mb 
  , ROUND((physical_read_bytes / physical_read_requests) / 1024) avg_read_kb
  , optimized_phy_read_requests opt_phyrd_rq
  , ROUND(((physical_read_bytes / physical_read_requests) * optimized_phy_read_requests) / 1048576) est_optim_mb
  , ROUND(optimized_phy_read_requests / physical_read_requests * 100) opt_rq_pct
FROM 
    v$sql 
WHERE 
    optimized_phy_read_requests > 0 
ORDER BY 
    optimized_phy_read_requests DESC
)
WHERE
    rownum <= 20
/

