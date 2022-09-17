-------------------------------------------------------------------------------------
--
-- File name:   oStackProf.sql ( Oradebug short_Stack Profiler )
-- Purpose:     Take target process stack samples and show an execution profile
--
-- Author:      Tanel Poder
-- Copyright:   2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
--              Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.
--              
-- Usage:       @ostackprof <sid> <interval> <#samples>
--               	        
--              @stackprof  <148> <0> <100>  

--                - takes 100 stack samples of server process tied to SID 148
--                  with not waiting between samples
--
--              @stackprof  <148> <1> <60>  

--                - takes 60 stack samples of process tied to sid 148 with 1
--                  second interval
--	        
-- Other:       WARNING!!! This tool is experimental and not meant for use in
--                         production environments. This is due oradebug short_stack
--                         being somewhat unstable on some platforms and it has              
--                         event crashed target processes on Windows platforms (9.2)
--
--                         Use an OS stack sampler instead when need to diagnose
--                         production issues (and test even those well in dev)
--
-- 
--              Note that this script uses a stack_helper.vbs VB script for post
--              processing oradebug short_stack output. Therefore you need to run
--              it on a Windows SQLPLUS client (the server can be on any platforms
--              as long as it supports oradebug short_stack - 10.2 on Solaris x64
--              doesn't seem to support it though, but you have DTrace there anyway ;)
--
-------------------------------------------------------------------------------------

PROMPT
PROMPT -- oStackProf v1.01 - EXPERIMENTAL script by Tanel Poder ( http://www.tanelpoder.com )
PROMPT
PROMPT WARNING! This script can crash the target process on Oracle 9.2 on Windows
PROMPT and maybe other versions/platforms as well. Test this script out thorouhgly 
PROMPT in your dev environment first!
PAUSE  Hit CTRL+C to cancel, ENTER to continue...

SET TERMOUT OFF FEEDBACK OFF VERIFY OFF

DEF ostackprof_sid=&1
DEF ostackprof_interval=&2
DEF ostackprof_samples=&3

COL spid NEW_VALUE ostackprof_spid
SELECT spid FROM v$process WHERE addr = (SELECT /*+ NO_UNNEST */ paddr FROM v$session WHERE sid = &1);
COL spid CLEAR

ORADEBUG SETOSPID &ostackprof_spid

SELECT
    'oradebug short_stack'||
    DECODE(TO_NUMBER(&ostackprof_interval), 
        0, '', 
        chr(13)||chr(10)||'exec dbms_lock.sleep('||TO_CHAR(&ostackprof_interval)||')'
    ) cmd 
FROM 
    (select 1 from dual CONNECT BY level <= &ostackprof_samples)
.

SPOOL ostackprof_&ostackprof_spid..tmp
SET HEADING OFF
PROMPT spool ostackprof_&ostackprof_spid..txt
/
PROMPT spool off
SET HEADING ON
SPOOL OFF

SET TERMOUT ON
PROMPT Sampling...
SET TERMOUT OFF
@ostackprof_&ostackprof_spid..tmp

SET TERMOUT ON FEEDBACK ON

DEF _nothing="" -- a hack
PROMPT
PROMPT Below is the stack prefix common to all samples:
PROMPT ------------------------------------------------------------------------&_nothing
PROMPT Frame->function()
PROMPT ------------------------------------------------------------------------&_nothing

HOST "cscript //nologo %SQLPATH%\stack_helper.vbs -strip < ostackprof_&ostackprof_spid..txt | sort | cscript //nologo %SQLPATH%\stack_helper.vbs -report | sort /r"
HOST del ostackprof_&ostackprof_spid..tmp ostackprof_&ostackprof_spid..txt
