-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   smem.sql 
-- Purpose:     Show process memory usage breakdown - lookup by process SPID
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @pmem <SPID>
-- 	        
-- Other:       Uses v$process_memory which is available from Oracle 10g onwards
--
--------------------------------------------------------------------------------
PROMPT Display process memory usage for SPID &1....

COL pmem_allocated HEAD ALLOCATED FOR 9,999,999,999,999
COL pmem_used HEAD USED FOR 9,999,999,999,999
COL pmem_max_allocated HEAD MAX_ALLOCATED FOR 9,999,999,999,999
COL pmem_spid HEAD OSPID FOR A15

SELECT
    s.sid
  , p.spid           pmem_spid
  , p.pid            opid
  , p.serial#
  , pm.category
  , pm.used          pmem_used
  , pm.allocated     pmem_allocated
  , pm.max_allocated pmem_max_allocated
FROM 
    v$session s
  , v$process p
  , v$process_memory pm
WHERE
    s.paddr = p.addr
AND p.pid = pm.pid
AND p.spid IN (&1)
ORDER BY
    sid
  , category
/
