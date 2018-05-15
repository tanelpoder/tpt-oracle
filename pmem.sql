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
SELECT
    s.sid,p.spid,pm.*
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
