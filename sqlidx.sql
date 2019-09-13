-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Author:      Tanel Poder (http://tanelpoder.com | @tanelpoder )
-- Purpose:     A temporary script/hack to display exadata-specific metrics along normal SQL stuff from V$SQL
 
col sql_sql_text head SQL_TEXT format a150 word_wrap
col sql_child_number head CH# for 999
col offl_attempted_mb HEAD OFFLOAD_MB FOR A14 JUST RIGHT

prompt Show SQL text, child cursors and execution stats for SQLID &1 child &2

select 
	hash_value,
	plan_hash_value,
	child_number	sql_child_number,
	sql_text sql_sql_text
from 
	v$sql 
where 
	sql_id = ('&1')
and child_number like '&2'
order by
	sql_id,
	hash_value,
	child_number
/

select 
	child_number	sql_child_number,
	address		parent_handle,
	child_address   object_handle,
	plan_hash_value plan_hash,
	parse_calls parses,
	loads h_parses,
	executions,
	fetches,
	rows_processed,
  rows_processed/nullif(fetches,0) rows_per_fetch,
	cpu_time/1000000 cpu_sec,
	cpu_time/NULLIF(executions,0)/1000000 cpu_sec_exec,
	elapsed_time/1000000 ela_sec,
	buffer_gets LIOS,
	disk_reads PIOS,
	sorts
--	address,
--	sharable_mem,
--	persistent_mem,
--	runtime_mem,
--  , PHYSICAL_READ_REQUESTS         
--  , PHYSICAL_READ_BYTES            
--  , PHYSICAL_WRITE_REQUESTS        
--  , PHYSICAL_WRITE_BYTES           
--  , OPTIMIZED_PHY_READ_REQUESTS
--  , IO_CELL_OFFLOAD_ELIGIBLE_BYTES 
--  , IO_INTERCONNECT_BYTES          
--  , IO_CELL_UNCOMPRESSED_BYTES     
--  , IO_CELL_OFFLOAD_RETURNED_BYTES 
  ,	users_executing
from 
	v$sql
where 
	sql_id = ('&1')
and child_number like '&2'
order by
	sql_id,
	hash_value,
	child_number
/

select 
	  child_number	sql_child_number
	, plan_hash_value plan_hash
  , LPAD(CASE WHEN io_cell_offload_eligible_bytes > 0 THEN TO_CHAR(ROUND(io_cell_offload_eligible_bytes  / 1048576)) ELSE 'NOT ATTEMPTED' END, 14) offl_attempted_mb
--  , ROUND(io_cell_offload_eligible_bytes  / 1048576)                            offl_attempted_mb
  , ROUND((1-(io_cell_offload_returned_bytes/NULLIF(io_cell_offload_eligible_bytes,0)))*100) scan_offl_saving
  , ROUND(io_interconnect_bytes / 1048576)                                      tot_ic_xfer_mb      
  , ROUND((1-(io_interconnect_bytes/NULLIF(physical_read_bytes,0)))*100)        tot_ic_xfer_saving
  , ROUND(physical_read_bytes  / NULLIF(executions,0)              / 1048576)   avg_mb_rd_exec
  , ROUND(physical_read_bytes  / NULLIF(physical_read_requests,0)  / 1024   )   avg_kb_rd_io
  , ROUND(physical_write_bytes / NULLIF(executions,0)              / 1048576)   avg_mb_wr_exec
  , ROUND(physical_write_bytes / NULLIF(physical_write_requests,0) / 1024   )   avg_kb_wr_io
  , ROUND(optimized_phy_read_requests / NULLIF(physical_read_requests,0) * 100) pct_optim
--  , io_cell_uncompressed_bytes     
from 
	v$sql
where 
	sql_id = ('&1')
and child_number like '&2'
order by
	sql_id,
	hash_value,
	child_number
/
--@pr

