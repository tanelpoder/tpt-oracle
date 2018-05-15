-- sqlmon.sql
--
-- Copyright 2015 Gluent Inc. All rights reserved
--

-- Backup sqlplus session settings...
-- ------------------------------------------------------------------------------------------
set termout off
store set sqlplus_session_settings.sql replace

-- Sqlmon session settings...
-- ------------------------------------------------------------------------------------------
set heading off pagesize 0 linesize 32767 trimspool on trimout on long 9999999 verify off longchunksize 9999999 feedback off
set serverout on size unlimited
set timing off autotrace off feedback off
set define on

-- Parameters section...
-- ------------------------------------------------------------------------------------------
undefine _sid
undefine _sql_id
undefine _sql_exec_id
undefine _sql_exec_start
undefine _sql_exec_start_format
undefine _get_mode
undefine _sqlmon_call_formats
undefine _report_name
undefine _report_data
undefine _report_warnings

column 1 new_value 1
column 2 new_value 2
column 3 new_value 3
column 4 new_value 4
SELECT NULL as "1"
,      NULL as "2"
,      NULL as "3"
,      NULL as "4"
FROM   dual
WHERE  1=2;

set termout on
prompt
prompt ================================================================================
prompt Gluent Augmented SQL Monitoring Report v2.9.0
prompt Copyright 2015-2018 Gluent Inc. All rights reserved.
prompt ================================================================================
set termout off

column _sid                   new_value _sid
column _sql_id                new_value _sql_id
column _sql_exec_id           new_value _sql_exec_id
column _sql_exec_start        new_value _sql_exec_start
column _get_mode              new_value _get_mode

SELECT CASE
           WHEN sid IS NOT NULL
           THEN sid
           WHEN arg_one IS NOT NULL AND INSTR(arg_one, '=') = 0
           THEN arg_one
           ELSE 'NULL'
       END                              AS "_sid"
,      NVL(sql_id, 'NULL')              AS "_sql_id"
,      NVL(sql_exec_id, 'NULL')         AS "_sql_exec_id"
,      NVL(sql_exec_start, 'NULL')      AS "_sql_exec_start"
,      UPPER(NVL(get_mode, 'NULL'))     AS "_get_mode"
FROM  (
        SELECT REGEXP_SUBSTR(args, '(sid=)([^\|;]+)', 1, 1, 'i', 2)             AS sid
        ,      REGEXP_SUBSTR(args, '(sql_id=)([^\|;]+)', 1, 1, 'i', 2)          AS sql_id
        ,      REGEXP_SUBSTR(args, '(sql_exec_id=)([^\|;]+)', 1, 1, 'i', 2)     AS sql_exec_id
        ,      REGEXP_SUBSTR(args, '(sql_exec_start=)([^\|;]+)', 1, 1, 'i', 2)  AS sql_exec_start
        ,      REGEXP_SUBSTR(args, '(get=)([^\|;]+)', 1, 1, 'i', 2)             AS get_mode
        ,      REGEXP_SUBSTR(arg_one, '[^;]+')                                  AS arg_one
        FROM  (
                SELECT q'[&1]'          AS arg_one
                ,      q'[&1|&2|&3|&4]' AS args
                FROM   dual
              )
      );

define _sql_exec_start_format = "YYYYMMDD_HH24MISS"

var sid            NUMBER
var sql_id         VARCHAR2(30)
var sql_exec_id    NUMBER
var sql_exec_start VARCHAR2(30)
var get_mode       VARCHAR2(10)
var sql_message    VARCHAR2(1000)

DECLARE
    v_sid                 NUMBER;
    v_sql_id              VARCHAR2(13);
    v_sql_exec_id         NUMBER;
    v_sql_exec_start      DATE;
    v_get_mode            VARCHAR2(10);
    v_sqlmon_call_formats VARCHAR2(1000);
    e_terminate           EXCEPTION;
BEGIN
    -- Parameter validations...
    BEGIN
        v_sid := &_sid;
    EXCEPTION
        WHEN VALUE_ERROR THEN
            :sql_message := q'{SQLMON-01: Invalid value for SID [&_sid]. Use a numeric literal or a USERENV/SYS_CONTEXT expression}';
            RAISE e_terminate;
    END;
    BEGIN
        v_sql_id := NULLIF(TRIM('&_sql_id'),'NULL');
    EXCEPTION
        WHEN OTHERS THEN
            :sql_message := q'{SQLMON-02: Invalid value for SQL_ID [&_sql_id]}';
            RAISE e_terminate;
    END;
    BEGIN
        v_sql_exec_id := TO_NUMBER(NULLIF('&_sql_exec_id','NULL'));
    EXCEPTION
        WHEN VALUE_ERROR THEN
            :sql_message := q'{SQLMON-03: Invalid value for SQL_EXEC_ID [&_sql_exec_id]. Use a numeric literal}';
            RAISE e_terminate;
    END;
    BEGIN
        v_sql_exec_start := TO_DATE(NULLIF(q'{&_sql_exec_start.}','NULL'), '&_sql_exec_start_format');
    EXCEPTION
        WHEN OTHERS THEN
            :sql_message := q'{SQLMON-04: Invalid value or format for SQL_EXEC_START [&_sql_exec_start]. Format must be &_sql_exec_start_format.}';
            RAISE e_terminate;
    END;
    BEGIN
        v_get_mode := NULLIF('&_get_mode','NULL');
        IF v_get_mode IS NOT NULL AND v_get_mode NOT IN (offload_tools.gc_latest, offload_tools.gc_longest_running) THEN
            RAISE VALUE_ERROR;
        END IF;
    EXCEPTION
        WHEN VALUE_ERROR THEN
            :sql_message := q'{SQLMON-09: Invalid value for GET mode. Valid values are LATEST or LONGEST}';
            RAISE e_terminate;
    END;
    IF (v_sid IS NOT NULL AND (v_sql_id IS NOT NULL OR v_sql_exec_id IS NOT NULL OR v_sql_exec_start IS NOT NULL))
    OR (v_sid IS NOT NULL AND v_get_mode IS NOT NULL)
    OR (v_get_mode IS NOT NULL AND (v_sql_id IS NOT NULL OR v_sql_exec_id IS NOT NULL OR v_sql_exec_start IS NOT NULL))
    OR (v_sid IS NULL AND v_sql_id IS NULL AND v_get_mode IS NULL)
    THEN
        RAISE e_terminate;
    END IF;
    -- Set parameter binds...
    :sid            := v_sid;
    :sql_id         := v_sql_id;
    :sql_exec_id    := v_sql_exec_id;
    :sql_exec_start := TO_CHAR(v_sql_exec_start, '&_sql_exec_start_format');
    :get_mode       := v_get_mode;
EXCEPTION
    WHEN e_terminate THEN
        IF :sql_message IS NULL THEN
            v_sqlmon_call_formats := '1. @sqlmon.sql sid=[n]' || CHR(10) ||
                                     '2. @sqlmon.sql sid=userenv(''sid'')' || CHR(10) ||
                                     '3. @sqlmon.sql sid=sys_context(''userenv'',''sid'')' || CHR(10) ||
                                     '4. @sqlmon.sql sql_id=[s]' || CHR(10) ||
                                     '5. @sqlmon.sql sql_id=[s] sql_exec_id=[n] sql_exec_start=[&_sql_exec_start_format.]'  || CHR(10) ||
                                     '6. @sqlmon.sql get=[latest|longest]';
            :sql_message := 'SQLMON-05: Invalid or missing parameters specified. Valid call formats are: ' || CHR(10) || '<pre>' || CHR(10) || v_sqlmon_call_formats || CHR(10) || '</pre>';
        END IF;
END;
/


-- Report generation...
-- ------------------------------------------------------------------------------------------
set termout on

prompt
prompt Generating report...

set termout off

var report_name     VARCHAR2(1000)
var report_data     REFCURSOR
var report_warnings VARCHAR2(30)

DECLARE
    v_sid             NUMBER         := :sid;
    v_sql_id          VARCHAR2(13)   := :sql_id;
    v_sql_exec_id     NUMBER         := :sql_exec_id;
    v_sql_exec_start  DATE           := TO_DATE(:sql_exec_start, '&_sql_exec_start_format');
    v_get_mode        VARCHAR2(10)   := :get_mode;
    v_sql_message     VARCHAR2(1000) := :sql_message;
    v_rep_warnings    VARCHAR2(20)   := ' (with warnings)';
    v_rep_invalid     VARCHAR2(20)   := '%invalid_inputs%';
BEGIN
    IF v_sql_message IS NOT NULL OR (v_sid IS NULL AND v_sql_id IS NULL AND v_get_mode IS NULL) THEN
        :report_warnings := v_rep_warnings;
        :report_name := offload_tools.sqlmon_report_name( p_sid => NULL );
        OPEN :report_data
        FOR
            SELECT NVL(v_sql_message, 'SQLMON-06: Unknown error or invalid user-inputs detected')
            FROM   dual;
    ELSIF v_sid IS NOT NULL THEN
        :report_name := offload_tools.sqlmon_report_name( p_sid => v_sid );
        IF :report_name NOT LIKE v_rep_invalid THEN
            OPEN :report_data
            FOR
                SELECT report_text
                FROM   TABLE( offload_tools.sqlmon( p_sid => v_sid ))
                ORDER  BY
                       report_id;
        ELSE
            :report_warnings := v_rep_warnings;
            OPEN :report_data
            FOR
                SELECT 'SQLMON-07: Non-existent SID detected'
                FROM   dual;
        END IF;
    ELSIF v_sql_id IS NOT NULL THEN
        :report_name := offload_tools.sqlmon_report_name( p_sql_id         => v_sql_id,
                                                          p_sql_exec_id    => v_sql_exec_id,
                                                          p_sql_exec_start => v_sql_exec_start );
        IF :report_name NOT LIKE v_rep_invalid THEN
            OPEN :report_data
            FOR
                SELECT report_text
                FROM   TABLE( offload_tools.sqlmon( p_sql_id         => v_sql_id,
                                                    p_sql_exec_id    => v_sql_exec_id,
                                                    p_sql_exec_start => v_sql_exec_start ))
                ORDER  BY
                       report_id;
        ELSE
            :report_warnings := v_rep_warnings;
            OPEN :report_data
            FOR
                SELECT 'SQLMON-08: Non-existent SQL_ID or combination of SQL_ID, SQL_EXEC_ID and SQL_EXEC_START detected'
                FROM   dual;
        END IF;
    ELSE
        :report_name := offload_tools.sqlmon_report_name( p_mode => v_get_mode );
        IF :report_name NOT LIKE v_rep_invalid THEN
            OPEN :report_data
            FOR
                SELECT report_text
                FROM   TABLE( offload_tools.sqlmon( p_mode => v_get_mode ))
                ORDER  BY
                       report_id;
        ELSE
            :report_warnings := v_rep_warnings;
            OPEN :report_data
            FOR
                SELECT 'SQLMON-10: No monitored hybrid SQL statements detected for ' || v_get_mode || ' get mode'
                FROM   dual;
        END IF;
    END IF;
END;
/

column _report_name     new_value _report_name
column _report_warnings new_value _report_warnings
SELECT :report_name     AS "_report_name"
,      :report_warnings AS "_report_warnings"
FROM   dual;

spool &_report_name
print :report_data
spool off

set termout on
prompt
prompt Report saved to &_report_name.
prompt
prompt ================================================================================
prompt Gluent Augmented SQL Monitoring Report completed&_report_warnings..
prompt ================================================================================
prompt
set termout off

-- Open the report...
-- ------------------------------------------------------------------------------------------
host open &_report_name

-- Restore sqlplus settings...
-- ------------------------------------------------------------------------------------------
@sqlplus_session_settings.sql

BEGIN
    :report_name     := NULL;
    :report_data     := NULL;
    :report_warnings := NULL;
    :sid             := NULL;
    :sql_id          := NULL;
    :sql_exec_id     := NULL;
    :sql_exec_start  := NULL;
    :get_mode        := NULL;
    :sql_message     := NULL;
END;
/

set termout on

undefine 1 2 3 4
undefine _sid
undefine _sql_id
undefine _sql_exec_id
undefine _sql_exec_start
undefine _sql_exec_start_format
undefine _get_mode
undefine _sqlmon_call_formats
undefine _report_name
undefine _report_data
undefine _report_warnings
