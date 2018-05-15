-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col u_username head USERNAME for a23
col u_sid head SID for a14 
col u_spid head SPID for a14
col u_pid head OPID for 99999
col u_audsid head AUDSID for 9999999999
col u_osuser head OSUSER for a16   truncate
col u_machine head MACHINE for a18 truncate
col u_program head PROGRAM for a20 truncate


def usid_sql_hash_value=0
col usid_sql_hash_value head HASH_VALUE for 9999999999 new_value usid_sql_hash_value

select s.username u_username, ' ''' || s.sid || ',' || s.serial# || '''' u_sid, 
       s.audsid u_audsid,
       s.osuser u_osuser, 
       substr(s.machine,instr(s.machine,'\')) u_machine, 
--       s.action u_machine,
       substr(s.program,instr(s.program,'('),20) u_program,
       p.spid   u_spid, 
       p.pid    u_pid,
       s.process cpid,
       -- s.sql_address, 
       s.sql_id,
       s.sql_hash_value	usid_sql_hash_value,
       s.last_call_et lastcall, 
       s.status,
       s.saddr,
       s.paddr,
       s.taddr,
       s.logon_time
from 
    v$session s,
    v$process p
where
    s.paddr=p.addr
and s.sid in (&1)
--and s.type!='BACKGROUND'
--and s.status='ACTIVE'
/

def 1=&usid_sql_hash_value
def 2=%
