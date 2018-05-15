-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col u_username for a20
col u_sid for a12 
col u_osuser for a12
col u_machine for a18
col u_program for a20

select s.username u_username, ' ''' || s.sid || ',' || s.serial# || '''' u_sid, 
       s.osuser u_osuser, substr(s.machine,instr(s.machine,'\')) u_machine, 
       substr(s.program,1,20) u_program,
       p.spid, s.sql_address, s.sql_hash_value, s.last_call_et lastcall, s.status
from 
    v$session s,
    v$process p
where
    s.paddr=p.addr
and s.type!='BACKGROUND'
and s.username is not null
--and s.status='ACTIVE'
/

exit
