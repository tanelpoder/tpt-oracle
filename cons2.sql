-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

column cons_column_name heading COLUMN_NAME format a30
column R_CONSTRAINT_NAME for a30
column CONSTRAINT_NAME for a30

select
	co.owner,
	co.table_name,
	co.constraint_name,
	co.constraint_type,
	cc.column_name		cons_column_name,
	cc.position
from
	dba_constraints co,
	dba_cons_columns cc
where
	co.owner		= cc.owner
and	co.table_name		= cc.table_name
and	co.constraint_name	= cc.constraint_name
and	lower(co.table_name) 	like lower('&1')
order by
	owner,
	table_name,
	constraint_type,
	column_name,
	constraint_name,
	position
/

