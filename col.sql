-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

column col_owner head OWNER for a20
column col_table_name head TABLE_NAME for a30
column col_column_name head COLUMN_NAME for a30
column col_data_type head DATA_TYPE for a20

break on col_owner skip 1 on table_name

select 
	owner			col_owner,
	table_name		col_table_name,
	column_name		col_column_name,
	data_type		col_data_type,
	nullable,
	num_distinct,
	low_value,
	high_value,
	density,
	num_nulls,
	num_buckets
from
	dba_tab_columns
where
	lower(column_name) like lower('%&1%')
order by
	col_owner,
	col_table_name,
	col_column_name
/
