-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

VAR dbid NUMBER
VAR inst_num NUMBER
VAR eid NUMBER
VAR bid NUMBER

BEGIN
SELECT dbid, USERENV('instance') INTO :dbid, :inst_num FROM v$database;
SELECT MAX(snap_id) INTO :eid FROM dba_hist_snapshot WHERE dbid = :dbid AND instance_number = :inst_num;
SELECT MAX(snap_id) INTO :bid FROM dba_hist_snapshot WHERE dbid = :dbid AND instance_number = :inst_num AND snap_id < :eid;
END;
/

SET TERMOUT OFF PAGESIZE 0
SELECT * FROM TABLE(DBMS_WORKLOAD_REPOSITORY.AWR_REPORT_HTML(:dbid, :inst_num, :bid, :eid))
.
SPOOL /tmp/awr_tmp.html
/
SPOOL OFF
SET TERMOUT ON PAGESIZE 5000
