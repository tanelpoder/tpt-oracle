-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- prototype script for displaying execution plan profile as a flame chart
-- @sqlflame.sql <sqlid> <child#>

SET HEADING OFF LINESIZE 32767 PAGESIZE 0 TRIMSPOOL ON TRIMOUT ON LONG 9999999 VERIFY OFF LONGCHUNKSIZE 100000 FEEDBACK OFF APPINFO OFF
SET TERMOUT OFF
--SET TIMING OFF

WITH sq AS (
    SELECT /*+ MATERIALIZE */ 
        sp.id, sp.parent_id, sp.operation, sp.options
      , sp.object_owner, sp.object_name, ss.last_elapsed_time, ss.elapsed_time
    FROM v$sql_plan_statistics ss, v$sql_plan sp 
    WHERE 
        sp.sql_id=ss.sql_id 
    AND sp.child_number=ss.child_number 
    AND sp.address=ss.address 
    AND sp.id=ss.operation_id 
    AND sp.sql_id='&1'
    AND sp.child_number=&2
)
SELECT
    '0 - SELECT STATEMENT'||TRIM(SYS_CONNECT_BY_PATH(id||' - '||operation||NVL2(options,' '||options,NULL)||NVL2(object_owner||object_name, ' ['||object_owner||'.'||object_name||']', NULL), ';'))||' '||TRIM(ROUND(elapsed_time/1000))
FROM
    sq 
CONNECT BY
    parent_id = PRIOR id 
    START WITH parent_id = 0
.

spool $HOME/sqlflame_stacks.txt
/
spool off


SET TERMOUT ON HEADING ON PAGESIZE 5000 LINESIZE 999 FEEDBACK ON 
--SET TIMING ON

HOST $HOME/dev/FlameGraph/flamegraph.pl --countname=Milliseconds --title="sql_id=&1" $HOME/sqlflame_stacks.txt > $HOME/sqlflame_&1..svg
HOST OPEN $HOME/sqlflame_&1..svg

