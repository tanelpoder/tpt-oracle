-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

column	tab_owner	heading OWNER		format a20
column	tab_table_name	heading TABLE_NAME	format a30
column	tab_type	heading TYPE		format a4
column	tab_num_rows	heading NUM_ROWS	format 99999999999
column	tab_blocks heading BLOCKS		format 999999999999
column	tab_empty_blocks heading EMPTY		format 99999999
column	tab_avg_space	heading AVGSPC		format 99999
column	tab_avg_row_len	heading ROWLEN		format 99999
column  tab_degree head DEGREE for A10

prompt Show tables matching condition "&1" (if schema is not specified then current user's tables only are shown)...

select
	owner				tab_owner,
	table_name			tab_table_name,
	case 
		when cluster_name is not null then 'CLU'
		when partitioned = 'NO'  and iot_name is not null then 'IOT'
		when partitioned = 'YES' and iot_name is not null then 'PIOT'
		when partitioned = 'NO' and iot_name is null then 'TAB'
		when partitioned = 'YES' and iot_name is null then 'PTAB'
		when temporary = 'Y' then 'TEMP'
		else 'OTHR'
	end 				tab_type,
	num_rows			tab_num_rows,
	blocks				tab_blocks,
	empty_blocks			tab_empty_blocks,
	avg_space			tab_avg_space,
--	chain_cnt			tab_chain_cnt,
	avg_row_len			tab_avg_row_len,
--	avg_space_freelist_blocks 	tab_avg_space_freelist_blocks,
--	num_freelist_blocks		tab_num_freelist_blocks,
--	sample_size			tab_sample_size,
--	last_analyzed			tab_last_analyzed,
    LPAD(SUBSTR(TRIM(degree),1,10),10) tab_degree,
    compression
  , compress_for  -- 11.2
  , inmemory im
  , inmemory_distribute  im_dist
  , inmemory_compression im_comp
  , inmemory_duplicate   im_dupl
from
	dba_tables
where
    inmemory = 'ENABLED'
AND upper(table_name) LIKE 
				upper(CASE 
					WHEN INSTR('&1','.') > 0 THEN 
					    SUBSTR('&1',INSTR('&1','.')+1)
					ELSE
					    '&1'
					END
				     ) ESCAPE '\'
AND	owner LIKE
		CASE WHEN INSTR('&1','.') > 0 THEN
			UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
		ELSE
			user
		END ESCAPE '\'
/

