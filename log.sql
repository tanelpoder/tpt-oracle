-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Show redo log layout from V$LOG and V$LOGFILE...

col log_member head MEMBER for a100

select * from v$log order by group#;
select group#, status, type, is_recovery_dest_file, member log_member from v$logfile order by group#,member;
