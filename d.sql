-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

column d_table_name heading TABLE_NAME format a30 
column d_comments heading COMMENTS format a80 word_wrap
break on d_table_name

prompt Show data dictionary views and x$ tables matching the expression "&1"...

select d.table_name d_table_name, d.comments d_comments
	from dict d
	where upper(d.table_name) like upper('%&1%')
union all
select t.table_name d_table_name, 'BASE TABLE' d_comments
	from dba_tables t
	where t.owner = 'SYS'
	and upper(t.table_name) like upper('%&1%')
/
select ft.name d_table_name, (select fvd.view_name 
			from v$fixed_view_definition fvd 
			where instr(upper(fvd.view_definition),upper(ft.name)) > 0
			and rownum = 1) used_in
	from v$fixed_table ft
	where ft.type in ('TABLE', 'VIEW')
	and replace(upper(ft.name),'V_$','V$') like upper('%&1%')
/

