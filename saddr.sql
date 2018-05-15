-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col u_username head USERNAME for a23
col u_sid head SID for a14 
col u_spid head SPID for a12 wrap
col u_audsid head AUDSID for 9999999999
col u_osuser head OSUSER for a16 truncate
col u_machine head MACHINE for a18 truncate
col u_program head PROGRAM for a20 truncate

select s.username u_username, ' ''' || s.sid || ',' || s.serial# || '''' u_sid, 
       s.audsid u_audsid,
       s.osuser u_osuser, 
       substr(s.machine,instr(s.machine,'\')) u_machine, 
--       s.machine u_machine, 
--       s.program u_program,
       substr(s.program,instr(s.program,'(')) u_program, 
--       p.pid,
       p.spid u_spid, 
       -- s.sql_address, 
       s.sql_hash_value, 
       s.last_call_et lastcall, 
       s.status 
       --, s.logon_time
from 
    v$session s,
    v$process p
where
    s.paddr=p.addr(+)
and s.saddr=hextoraw('&1')
/

