-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Display Parallel Execution QC and slave sessions for QC &1....

col pxs_degr head "Degree (Req)" for a12
col pxs_username head "USERNAME" for a20

select 
    s.username          pxs_username
  , s.sql_id
  , pxs.qcsid
  , pxs.qcinst_id       qc_inst
  , pxs.server_group    dfo_tree
  , pxs.server_set
  , pxs.server#
  , lpad(to_char(pxs.degree)||' ('||to_char(pxs.req_degree)||')',12,' ') pxs_degr
  , pxs.inst_id         sl_inst
  , pxs.sid             slave_sid
  , p.server_name
  , p.spid
  , CASE WHEN state != 'WAITING' THEN 'WORKING'
         ELSE 'WAITING'
    END AS state
  , CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue'
         ELSE event
    END AS sw_event  
--  , CASE WHEN state != 'WAITING' THEN 'On CPU / runqueue'
--         ELSE CASE
--              WHEN event = 'PX Deq: Execution Msg'    THEN 'Waiting for consumer: next command'
--              WHEN event = 'PX Deq Credit: send blkd' THEN 'Waiting for consumer: to consume more data'
--              WHEN event = 'PX qref latch'            THEN 'Waiting for access to table queue buffer'
--              ELSE null    
--              END 
--    END AS human_readble_event
  , s.blocking_session_status
  , s.blocking_instance
  , s.blocking_session
  , s.seq#
  , s.seconds_in_wait
  , s.p1text
  , s.p1raw
  , s.p2text
  , s.p2raw
  , s.p3text
  , s.p3raw
from 
    gv$px_session pxs 
  , gv$session    s
  , gv$px_process p
where 
    pxs.qcsid in (&1)
--and s.sid     = pxs.qcsid
and s.sid     = pxs.sid
and s.serial# = pxs.serial#
--and s.serial# = pxs.qcserial# -- null
and p.sid     = pxs.sid
and pxs.inst_id = s.inst_id
and s.inst_id = p.inst_id
order by
    pxs.qcsid
  , pxs.server_group
  , pxs.server_set
  , pxs.qcinst_id
  , pxs.server#
/

