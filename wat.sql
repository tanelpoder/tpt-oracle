-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col wat_sql_text          head SQL_TEXT       format a80 word_wrap
col wat_max_tempseg_size  head MAX_TEMP       format 999999.99
col wat_last_tempseg_size head LAST_TEMP      format 999999.99
col wat_executions	  head EXECUTIONS     format 999999999
col wat_open_versions	  head OPEN|VER	      format 9999
col wat_users_opening     head USRS|OPEN      format 9999
col wat_disk_reads        head DISK|READS     format 999999999

select 
    s.sql_text 				wat_sql_text, 
    w.max_tempseg_size/1048576 		wat_max_tempseg_size,
    w.last_tempseg_size/1048576 	wat_last_tempseg_size,
    s.executions 			wat_executions,
    s.open_versions			wat_open_Versions,
    s.users_opening			wat_users_opening,
    s.disk_reads			wat_disk_reads
from 
    v$sql s, v$sql_workarea w
where
    w.address      = s.address
and w.hash_value   = s.hash_value
and w.child_number = s.child_number
and w.max_tempseg_size > (select max(max_tempseg_size)*0.2 from v$sql_workarea)
order by
    w.max_tempseg_size desc
;
