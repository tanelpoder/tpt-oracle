-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   sqlmon_hist.sql
-- Purpose:     Spool a SQL Monitoring report to a local file and open it
--              in your browser.
--
-- Authors:     Tomasz Sroka
--
-- Usage:       @sqlmon_hist <sql_id> <time_threshold>
--
--------------------------------------------------------------------------------

COL db_name         FOR a13     NEW_VALUE _v_db_name
COL sql_id          FOR a13     NEW_VALUE _v_sql_id
COL sql_exec_id     FOR a25     NEW_VALUE _v_sql_exec_id
COL sql_exec_start  FOR a25     NEW_VALUE _v_sql_exec_start
COL duration        FOR a15
COL db_time         FOR 9999.99
COL plan_hash       FOR a10

SELECT
    report_id                                                                                 AS report_id
  , extractvalue(xmltype(report_summary), '/report_repository_summary/sql/@sql_id')           AS sql_id
  , extractvalue(xmltype(report_summary), '/report_repository_summary/sql/@sql_exec_id')      AS sql_exec_id
  , extractvalue(xmltype(report_summary), '/report_repository_summary/sql/@sql_exec_start')   AS sql_exec_start
  , regexp_substr(key4, '[^#]+',1,1)                                                          AS duration
  , round(regexp_substr(key4, '[^#]+',1,2)/1000/1000,2)                                       AS db_time
  , extractvalue(xmltype(report_summary), '/report_repository_summary/sql/plan_hash')         AS plan_hash
  , sys_context('USERENV', 'DB_NAME')                                                         AS db_name
FROM dba_hist_reports
WHERE component_name = 'sqlmonitor' 
    --AND extractvalue(xmltype(report_summary), '/report_repository_summary/sql/@sql_id') = '&1'
    AND key1 = '&1'
    AND generation_time > sysdate-&2
ORDER BY to_date(sql_exec_start,'mm/dd/yyyy hh24:mi:ss')
/

PROMPT
ACCEPT report_id NUMBER PROMPT 'Enter report id: '

SET HEADING OFF LINESIZE 32767 PAGESIZE 0 TRIMSPOOL ON TRIMOUT ON LONG 9999999 VERIFY OFF LONGCHUNKSIZE 100000 FEEDBACK OFF
SET TERMOUT OFF 
SET TIMING OFF

SPOOL sqlmon_&_v_db_name._&_v_sql_id._&_v_sql_exec_id..html
SELECT DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL(RID => &report_id, TYPE => 'active') FROM dual
/
SPOOL OFF
--Windows
HOST start "C:\Program Files\internet explorer\iexplore.exe" sqlmon_&_v_db_name._&_v_sql_id._&_v_sql_exec_id..html
--Linux
--HOST open sqlmon_&_v_db_name._&_v_sql_id._&_v_sql_exec_id..html
SET HEADING ON
@init
