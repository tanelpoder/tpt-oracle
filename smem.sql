-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   smem.sql 
-- Purpose:     Show process memory usage breakdown - lookup by session ID
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @smem <SID>
-- 	        
--	        
-- Other:       Uses v$process_memory which is available from Oracle 10g onwards
--
--------------------------------------------------------------------------------
PROMPT Display session &1 memory usage from v$process_memory....
SELECT
    s.sid,pm.*
FROM 
    v$session s
  , v$process p
  , v$process_memory pm
WHERE
    s.paddr = p.addr
AND p.pid = pm.pid
AND s.sid IN (&1)
ORDER BY
    sid
  , category
/
