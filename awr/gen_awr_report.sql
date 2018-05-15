-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

VAR dbid NUMBER

PROMPT Listing latest AWR snapshots ...
SELECT snap_id, end_interval_time 
FROM dba_hist_snapshot 
--WHERE begin_interval_time > TO_DATE('2011-06-07 07:00:00', 'YYYY-MM-DD HH24:MI:SS') 
WHERE end_interval_time > SYSDATE - 1
ORDER BY end_interval_time;

ACCEPT bid NUMBER PROMPT "Enter begin snapshot id: "
ACCEPT eid NUMBER PROMPT "Enter   end snapshot id: "

BEGIN
  SELECT dbid INTO :dbid FROM v$database;
END;
/

SET TERMOUT OFF PAGESIZE 0 HEADING OFF LINESIZE 1000 TRIMSPOOL ON TRIMOUT ON TAB OFF

SPOOL awr_local_inst_1.html
SELECT * FROM TABLE(DBMS_WORKLOAD_REPOSITORY.AWR_REPORT_HTML(:dbid, 1, &bid, &eid));

-- SPOOL awr_local_inst_2.html
-- SELECT * FROM TABLE(DBMS_WORKLOAD_REPOSITORY.AWR_REPORT_HTML(:dbid, 2, &bid, &eid));
-- 
-- SPOOL awr_local_inst_3.html
-- SELECT * FROM TABLE(DBMS_WORKLOAD_REPOSITORY.AWR_REPORT_HTML(:dbid, 3, &bid, &eid));

-- SPOOL awr_global.html
-- SELECT * FROM TABLE(DBMS_WORKLOAD_REPOSITORY.AWR_GLOBAL_REPORT_HTML(:dbid, CAST(null AS VARCHAR2(10)), &bid, &eid));

SPOOL OFF
SET TERMOUT ON PAGESIZE 5000 HEADING ON

