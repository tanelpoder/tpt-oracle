-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col sql_sql_text head SQL_TEXT format a150 word_wrap
col sql_child_number head CH# for 9999


col cpu_sec_exec   FOR 999999.999
col ela_sec_exec   FOR 999999.999
col lios_per_exec  FOR 9999999999
col pios_per_exec  FOR 9999999999

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
	plan_hash_value plan_hash,
	parse_calls parses,
	loads h_parses,
	executions,
	fetches,
	rows_processed,
  rows_processed/nullif(fetches,0) rows_per_fetch,
	ROUND(cpu_time/NULLIF(executions,0)/1000000,3)     cpu_sec_exec,
	ROUND(elapsed_time/NULLIF(executions,0)/1000000,3) ela_sec_exec,
	ROUND(buffer_gets/NULLIF(executions,0),3)  lios_per_exec,
	ROUND(disk_reads/NULLIF(executions,0),3)   pios_per_exec,
	ROUND(cpu_time/1000000,3) total_cpu_sec,
	ROUND(elapsed_time/1000000,3) total_ela_sec,
  user_io_wait_time/1000000 total_iowait_sec,
	buffer_gets total_LIOS,
	disk_reads total_pios,
	sorts
--	address,
--	sharable_mem,
--	persistent_mem,
--	runtime_mem,
--   , PHYSICAL_READ_REQUESTS         
--   , PHYSICAL_READ_BYTES            
--   , PHYSICAL_WRITE_REQUESTS        
--   , PHYSICAL_WRITE_BYTES           
--   , IO_CELL_OFFLOAD_ELIGIBLE_BYTES 
--   , IO_INTERCONNECT_BYTES          
--   , IO_CELL_UNCOMPRESSED_BYTES     
--   , IO_CELL_OFFLOAD_RETURNED_BYTES 
  ,	users_executing
  , last_active_time
	, address		parent_handle
	, child_address   object_handle
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

