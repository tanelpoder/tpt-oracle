-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

column sqlt_sql_text	heading SQL_TEXT format a100 word_wrap

select 
	hash_value, 
    sql_id,
--	old_hash_value,
	child_number chld#, 
--	plan_hash_value plan_hash, 
	optimizer_mode opt_mode,
	sql_text sqlt_sql_text
from 
	v$sql 
where 
	lower(sql_text) like lower('%&1%')
--and	hash_value != (select sql_hash_value from v$session where sid = (select sid from v$mystat where rownum = 1))
/

