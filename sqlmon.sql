-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   sqlmon.sql 
-- Purpose:     Spool a SQL Monitoring report to a local HTML file and open it
--              in your browser.
--
-- Authors:     Adrian Billington and Tanel Poder
-- Copyright:   (c) Gluent, Inc. [http://gluent.com]
--              
-- Usage:       @sqlmon <session_id>
--
-- Other:       This script will report the latest/newest monitored SQL statement
--              of a provided session.
--              Ideally you should run this script from sqlplus running in your
--              workstation, as this way sqlplus will spool it to a local file
--              (and your local browser can open it)
--
--------------------------------------------------------------------------------

SET HEADING OFF LINESIZE 32767 PAGESIZE 0 TRIMSPOOL ON TRIMOUT ON LONG 9999999 VERIFY OFF LONGCHUNKSIZE 100000 FEEDBACK OFF
SET TERMOUT OFF 
SET TIMING OFF
SET DEFINE ON

col _dbname             NEW_VALUE _v_dbname
col _sid                NEW_VALUE _v_sid
col _sql_id             NEW_VALUE _v_sql_id
col _sql_exec_id        NEW_VALUE _v_sql_exec_id
col _sql_exec_start     NEW_VALUE _v_sql_exec_start
col _sql_exec_start_glu NEW_VALUE _v_sql_exec_start_glu
col _plan_hash_value    NEW_VALUE _v_plan_hash_value
col _sql_child_number   NEW_VALUE _v_sql_child_number

SELECT 
       SYS_CONTEXT('USERENV', 'INSTANCE_NAME')                  AS "_dbname"
,      m.sid                                                    AS "_sid"
,      MAX(m.sql_id) KEEP
          (DENSE_RANK FIRST ORDER BY m.last_refresh_time DESC)  AS "_sql_id"
,      TO_CHAR(MAX(m.sql_exec_id) KEEP
          (DENSE_RANK FIRST ORDER BY m.last_refresh_time DESC)) AS "_sql_exec_id"
,      TO_CHAR(MAX(m.sql_exec_start) KEEP
          (DENSE_RANK FIRST ORDER BY m.last_refresh_time DESC),
          'YYMMDD_HH24MISS')                                    AS "_sql_exec_start"
,      TO_CHAR(MAX(m.sql_exec_start) KEEP
          (DENSE_RANK FIRST ORDER BY m.last_refresh_time DESC),
          'YYYYMMDD_HH24MISS')                                  AS "_sql_exec_start_glu"
,      MAX(m.sql_plan_hash_value) KEEP
          (DENSE_RANK FIRST ORDER BY m.last_refresh_time DESC)  AS "_plan_hash_value"
,      MAX(s.child_number) KEEP
          (DENSE_RANK FIRST ORDER BY m.last_refresh_time DESC)  AS "_sql_child_number"
FROM   v$sql_monitor    m
       INNER JOIN
       v$sql            s
       ON (    s.sql_id        = m.sql_id
           AND s.child_address = m.sql_child_address)
WHERE  m.sid = &1
AND    UPPER(m.sql_text) NOT LIKE 'EXPLAIN PLAN%'
GROUP  BY
       m.sid
;

SPOOL sqlmon_&_v_dbname._&_v_sql_id._&_v_sql_exec_start._&_v_sql_exec_id..html

SELECT
  REGEXP_REPLACE(
    DBMS_SQLTUNE.REPORT_SQL_MONITOR(
      session_id     => &_v_sid,
      sql_id         => '&_v_sql_id',
      sql_exec_id    => '&_v_sql_exec_id',
      sql_exec_start => TO_DATE('&_v_sql_exec_start', 'YYMMDD_HH24MISS'),
      report_level   => 'ALL',
      type           => 'ACTIVE'),
    'overflow:hidden', '')
FROM dual
/

SPOOL OFF

SET TERMOUT ON HEADING ON PAGESIZE 5000 LINESIZE 999 FEEDBACK ON 
SET TIMING ON

HOST open sqlmon_&_v_dbname._&_v_sql_id._&_v_sql_exec_start._&_v_sql_exec_id..html
--HOST open http://localhost:8000/sqlmon_&_v_dbname._&_v_sql_id._&_v_sql_exec_start._&_v_sql_exec_id..html

undefine _v_dbname
undefine _v_sid
undefine _v_sql_id
undefine _v_sql_exec_id
undefine _v_sql_exec_start
undefine _v_plan_hash_value
undefine _v_sql_child_number
