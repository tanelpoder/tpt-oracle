-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col u_username head USERNAME for a23
col u_sid head SID for a14 
col u_audsid head AUDSID for 9999999999
col u_osuser head OSUSER for a16
col u_machine head MACHINE for a25 truncate
col u_program head PROGRAM for a20

select s.username||CASE WHEN s.sid = SYS_CONTEXT('userenv','sid') THEN ' (me)' WHEN s.type = 'BACKGROUND' THEN ' (bg)' END u_username, ' ''' || s.sid || ',' || s.serial# || '''' u_sid, 
       p.spid, 
       s.sql_id, --s.sql_hash_value, 
       s.audsid u_audsid,
       s.osuser u_osuser, 
       substr(s.machine,instr(s.machine,'\')) u_machine,
       CASE WHEN s.type = 'BACKGROUND' OR REGEXP_LIKE(s.program, '.*\([PJ]\d+\)') THEN
          REGEXP_REPLACE(SUBSTR(s.program,INSTR(s.program,'(')), '\d', 'n')
       ELSE
          '('||REGEXP_REPLACE(REGEXP_REPLACE(s.program, '(.*)@(.*)(\(.*\))', '\1'), '\d', 'n')||')'
       END u_program,
       --substr(s.program,instr(s.program,'(')) u_program, 
       -- s.sql_address, 
       s.last_call_et lastcall, 
       s.status 
       --, s.logon_time
from 
    v$session s,
    v$process p
where
    s.paddr=p.addr
--and s.type!='BACKGROUND'
and (lower(s.username) like lower('&1') or (nvl(s.username,'%') = '%' and s.type = 'USER'))
--and s.status='ACTIVE'
/

