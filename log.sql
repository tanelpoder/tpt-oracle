-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Show redo log layout from V$LOG, V$STANDBY_LOG and V$LOGFILE...

col log_member head MEMBER for a100

select
    GROUP#       
  , THREAD#      
  , SEQUENCE#    
  , ROUND(BYTES/1024/1024) SIZE_MB     
  , BLOCKSIZE    
  , MEMBERS      
  , ARCHIVED     
  , STATUS       
  , FIRST_CHANGE#
  , FIRST_TIME   
  , NEXT_CHANGE# 
  , NEXT_TIME    
from
    v$log
order by
    group#
/

select * from v$standby_log order by group#;
select group#, status, type, is_recovery_dest_file, member log_member from v$logfile order by group#,member;
