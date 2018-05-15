-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SET PAGESIZE 5000 LINESIZE 1000 TRIMSPOOL ON TRIMOUT ON TAB OFF

DEF sqlset_name="GPN_MON18"

VAR dbid NUMBER
VAR inst_id NUMBER

COL bdate NEW_VALUE def_bdate
COL edate NEW_VALUE def_edate

SET TERMOUT OFF

SELECT
    TO_CHAR(SYSDATE-1/24, 'YYYY-MM-DD HH24:MI') bdate
  , TO_CHAR(SYSDATE     , 'YYYY-MM-DD HH24:MI') edate
FROM
    dual
/

SET TERMOUT ON

ACCEPT sqlid CHAR FORMAT A13 DEFAULT '%'                           PROMPT "Enter     SQL ID [       %        ]: "
SPOOL sql_activity_&sqlid..txt

ACCEPT bdate DATE FORMAT 'YYYY-MM-DD HH24:MI' DEFAULT '&def_bdate' PROMPT "Enter begin time [&def_bdate]: "
ACCEPT edate DATE FORMAT 'YYYY-MM-DD HH24:MI' DEFAULT '&def_edate' PROMPT "Enter   end time [&def_edate]: "

PROMPT Spooling into sql_activity_&sqlid..txt

BEGIN
SELECT inst_id, dbid INTO :inst_id, :dbid FROM gv$database;
END;
/


SELECT
    TO_CHAR(sample_time, 'YYYY-MM-DD HH24')||':00' sample_hour
  , sql_id
  , sql_plan_hash_value
  , COUNT(*) * 10 seconds
  , ROUND(COUNT(*) * 10 / 3600, 2) AAS
  , COUNT(DISTINCT sql_exec_start||sql_exec_id) sampled_execs
FROM 
    dba_hist_active_sess_history
WHERE
    dbid = :dbid
-- AND instance_number = :inst_id
AND sample_time BETWEEN TO_DATE('&bdate', 'YYYY-MM-DD HH24:MI:SS') AND TO_DATE('&edate', 'YYYY-MM-DD HH24:MI:SS')
AND sql_id LIKE '&sqlid'
GROUP BY
    TO_CHAR(sample_time, 'YYYY-MM-DD HH24')||':00'
  , sql_id
  , sql_plan_hash_value
ORDER BY
    sample_hour
  , sql_id
/

SET PAGESIZE 0 HEADING OFF

PROMPT
PROMPT =======================================================================================================
PROMPT =========================================== DISPLAY_SQLSET ============================================
PROMPT =======================================================================================================
PROMPT

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_SQLSET('&sqlset_name', '&sqlid', null, 'TYPICAL +ALIAS +MEMSTATS +NOTE'));

PROMPT
PROMPT =======================================================================================================
PROMPT ============================================= DISPLAY_AWR =============================================
PROMPT =======================================================================================================
PROMPT

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_AWR('&sqlid', null, null, 'ALL'))
/

PROMPT
PROMPT =======================================================================================================
PROMPT =============================== ASH Report for SQL ID &sqlid ===================================
PROMPT =======================================================================================================
PROMPT

SET VERIFY ON
-- Oracle 10.2 requires the :inst_id to be present (and not NULL)
SELECT * FROM TABLE(DBMS_WORKLOAD_REPOSITORY.ASH_REPORT_TEXT(:dbid, :inst_id, TO_DATE('&bdate', 'YYYY-MM-DD HH24:MI'), TO_DATE('&edate', 'YYYY-MM-DD HH24:MI'), null, null, null, DECODE('&sqlid', '%', NULL, '&sqlid')))
WHERE exists (SELECT version FROM v$instance WHERE version LIKE '10%')
UNION ALL
SELECT * FROM TABLE(DBMS_WORKLOAD_REPOSITORY.ASH_REPORT_TEXT(:dbid, NULL, TO_DATE('&bdate', 'YYYY-MM-DD HH24:MI'), TO_DATE('&edate', 'YYYY-MM-DD HH24:MI'), null, null, null, DECODE('&sqlid', '%', NULL, '&sqlid')))
WHERE exists (SELECT version FROM v$instance WHERE version LIKE '11%')
/

SET VERIFY OFF
SPOOL OFF
SET TERMOUT ON PAGESIZE 5000 HEADING ON
PROMPT Done. Output file: sql_activity_&sqlid..txt

