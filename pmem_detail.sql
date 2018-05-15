-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   pmem_detail.sql (EXPERIMENTAL!) 
-- Purpose:     Show process memory usage breakdown details - lookup by process SPID
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @pmem_detail <SPID>
-- 	        
--	        
-- Other:       Uses v$process_memory_detail which is available from Oracle 10g
--              Also, this view is populated with help of an ORADEBUG command
--              so you must run this script with SYSDBA privileges.
--
--              PROOFREAD AND TEST THIS IN A TEST ENVIRONMENT FIRST!
--
--------------------------------------------------------------------------------

-- identify target session's process
SET TERMOUT OFF
COL pid NEW_VALUE get_pid
SELECT pid FROM v$process WHERE spid = TRIM(&1);
COL pid CLEAR
SET TERMOUT ON

PROMPT
PROMPT WARNING! About to run an undocumented ORADEBUG command
PROMPT for getting heap details.
PROMPT This script is EXPERIMENTAL, use this at your own risk!
PROMPT
PROMPT Press ENTER to continue, or CTRL+C to cancel
PAUSE

-- send message to target for memory detail array population
SET TERMOUT OFF
ORADEBUG SETMYPID
ORADEBUG DUMP PGA_DETAIL_GET &get_pid
SET TERMOUT ON

EXEC DBMS_LOCK.SLEEP(1)

SELECT status FROM v$process_memory_detail_prog WHERE pid = &get_pid; 

PROMPT If the status above is not COMPLETE then you need to wait
PROMPT for the target process to do some work and re-run the 
PROMPT v$process_memory_detail query in this script manually
PROMPT (or just take a heapdump level 29 to get heap breakdown
PROMPT in a tracefile)

-- 
SELECT
    s.sid
   ,pmd.category
   ,pmd.name
   ,pmd.heap_name
   ,pmd.bytes
   ,pmd.allocation_count
--   ,pmd.heap_descriptor
--   ,pmd.parent_heap_descriptor
FROM 
    v$session s
  , v$process p
  , v$process_memory_detail pmd
WHERE
    s.paddr = p.addr
AND p.pid = pmd.pid
AND p.spid IN (&1)
ORDER BY
    sid
  , spid
  , bytes DESC
/
