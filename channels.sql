-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   channels.sql
-- Purpose:     Report KSR channel message counts by channel endpoints
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--
-- Usage:       @channels <where-condition>
--
-- Example:     @channels context_ptr=HEXTORAW('000000008FED7240')
--              @channels 1=1
--              @channels sid=123
--
--------------------------------------------------------------------------------


--break on channel_name skip 1
COL program head PROGRAM FOR a20 TRUNCATE
COL channels_descr HEAD DESCR FOR A10
COL channels_username HEAD USERNAME FOR A20

SELECT * FROM (
    SELECT 
        cd.name_ksrcdes     channel_name
      , cd.id_ksrcdes       channels_descr
      , CASE WHEN BITAND(c.flags_ksrchdl, 1)  =  1 THEN 'PUB ' END || 
        CASE WHEN BITAND(c.flags_ksrchdl, 2)  =  2 THEN 'SUB ' END ||  
        CASE WHEN BITAND(c.flags_ksrchdl, 16) = 16 THEN 'INA'  END flags
      , c.mesgcnt_ksrchdl mesg_count
      , NVL(s.sid, -1)      sid
      , p.spid
      , SUBSTR(NVL(s.program,p.program),INSTR(NVL(s.program,p.program),'('))   program
      ,  CASE WHEN BITAND(cd.scope_ksrcdes, 1)   = 1   THEN 'ANY '  END || 
         CASE WHEN BITAND(cd.scope_ksrcdes, 2)   = 2   THEN 'LGWR ' END || 
         CASE WHEN BITAND(cd.scope_ksrcdes, 4)   = 4   THEN 'DBWR ' END || 
         CASE WHEN BITAND(cd.scope_ksrcdes, 8)   = 8   THEN 'PQ '   END || 
         CASE WHEN BITAND(cd.scope_ksrcdes, 256) = 256 THEN 'REG '  END || 
         CASE WHEN BITAND(cd.scope_ksrcdes, 512) = 512 THEN 'NFY '  END scope 
      , c.ctxp_ksrchdl context_ptr
      , c.kssobown  owning_so
      , p.addr paddr
      , c.owner_ksrchdl owning_proc
      , s.serial#
      , s.username channels_username
      , s.type
      , cd.maxsize_ksrcdes
      , EVTNUM_KSRCHDL
    FROM 
        x$ksrchdl c
      , v$process p
      , v$session s
      , X$KSRCCTX ctx
      , X$KSRCDES cd
    WHERE
        s.paddr (+) = c.owner_ksrchdl
    AND p.addr (+)  = c.owner_ksrchdl 
    AND c.ctxp_ksrchdl = ctx.addr
    AND cd.indx = ctx.name_ksrcctx
--    AND bitand(c.kssobflg,1) = 1
--    AND lower(cd.name_ksrcdes) like '%&1%'
)
WHERE &1
ORDER BY
    channel_name
  , flags
/
