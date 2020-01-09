-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col sql_sql_text head SQL_TEXT format a150 word_wrap
col sql_child_number head CH# for 999

prompt Show SQL text, child cursors and execution stats for SQLID &1 child &2

select 
	hash_value,
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
	cpu_time/1000 cpu_ms,
	elapsed_time/1000 ela_ms,
	buffer_gets LIOS,
	disk_reads PIOS,
	sorts, 
--	address,
--	sharable_mem,
--	persistent_mem,
--	runtime_mem,
	users_executing
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

