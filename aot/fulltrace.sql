EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE(binds=>TRUE, waits=>TRUE);
ALTER SESSION SET EVENTS '10051 trace name context forever, level 1';
ORADEBUG SETMYPID
ORADEBUG TRACEFILE_NAME
-- ORA-10079: trace data sent/received via SQL*Net
ORADEBUG EVENT 10079 TRACE NAME CONTEXT FOREVER, LEVEL 1;

-- looks like this event disabled in newer Oracle versions when using ALTER SESSION:
--
-- SQL> ALTER SESSION SET EVENTS '10079 trace name context forever, level 1';
-- ERROR:
-- ORA-01031: insufficient privileges
--
-- This is to prevent users with a simple ALTER SESSION privilege from setting
-- events that could expose sensitive data or crash/hang the system
-- MOS note: ORA-1031 When Setting The Event 10079 (or how to set event 10079 in session) (Doc ID 2199860.1)
-- 
-- An alternative would be to use:
-- ORADEBUG SETMYPID
-- ORADEBUG DUMP SQLNET_SERVER_TRACE 16

-- trace wait event stack traces (this will slow stuff down)
--
-- ALTER SESSION SET EVENTS 'wait_event[all] trace(''event="%" ela=% p1=% p2=% p3=%\n'', evargs(5), evargn(1), evargn(2), evargn(3), evargn(4))';

-- trace enqueue get waits
-- ALTER SESSION SET EVENTS '10704 trace name context forever, level 4';

