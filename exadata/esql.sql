-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT
    child_number chld
  , ROUND( physical_read_bytes             / 1048576 ) phyrd_mb
  , ROUND( physical_write_bytes            / 1048576 ) phywr_mb
  , ROUND( io_cell_offload_eligible_bytes  / 1048576 ) phyrd_offl_elig_mb
  , ROUND( io_cell_offload_returned_bytes  / 1048576 ) phyrd_offl_ret_mb
  , ROUND( io_interconnect_bytes           / 1048576 ) ic_total_traffic_mb
  , ROUND( io_cell_uncompressed_bytes      / 1048576 ) total_uncomp_mb
  , optimized_phy_read_requests               phyrd_optim_rq
FROM
    v$sql
WHERE
    sql_id = '&1'
AND child_number LIKE '&2'
@pr

