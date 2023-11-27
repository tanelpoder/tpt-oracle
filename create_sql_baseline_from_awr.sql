-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------------------------------
-- this script allows you to create SQL baseline based on AWR.
-- usage:
--
-- @create_sql_baseline_from_awr <sql_id> <sql_plan_value>
--
--
-- Query baseline info from: DBA_SQL_PLAN_BASELINES
-- Drop baselines: @drop_sql_baseline &sql_handle
--             or: exec DBMS_SPM.DROP_SQL_PLAN_BASELINE('&sql_handle')
--
-- You can get the SQL_HANDLE from DBA_SQL_PLAN_BASELINES
--
-- More info:
--    SQL Plan Baselines - DBMS_SPM in EE licenses 
--      - https://jonathanlewis.wordpress.com/2011/01/12/fake-baselines/
--    DBMS_SPM basic baseline use is included in Oracle EE in 11g+ and SE from 18c+
--      - https://blogs.oracle.com/optimizer/does-the-use-of-sql-plan-management-and-the-dbmsspm-database-package-require-a-tuning-or-diagnostic-pack-license
--
--------------------------------------------------------------------------------------------------------
SET SERVEROUT ON SIZE 1000000

DEF sql_id = &1
DEF sql_phv = &2
DECLARE
    v_ret               PLS_INTEGER;
    v_begin_snap        NUMBER;
    v_end_snap          NUMBER;
    v_sts_name          VARCHAR2(17) := 'STS_' || '&sql_id';
    v_cur               SYS_REFCURSOR;
    v_sql_baseline_name dba_sql_plan_baselines.plan_name%TYPE;
    v_sql_handle        dba_sql_plan_baselines.sql_handle%TYPE;
--    v_first_seen TIMESTAMP;
--    v_last_seen  TIMESTAMP;
BEGIN
    --drop STS
    BEGIN
        dbms_sqltune.drop_sqlset(sqlset_name => v_sts_name);
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;
    
    --get snap IDs
    SELECT MIN(snap.snap_id) - 1,
           MAX(snap.snap_id) + 1
    INTO
        v_begin_snap,
        v_end_snap
    FROM dba_hist_sqlstat  sqlstat,
         dba_hist_snapshot snap
    WHERE sql_id = '&sql_id'
          AND sqlstat.plan_hash_value = &sql_phv
          AND snap.snap_id = sqlstat.snap_id
          AND sqlstat.executions_delta > 0;
    
    --create STS
    dbms_sqltune.create_sqlset(sqlset_name => v_sts_name);
    OPEN v_cur FOR SELECT value(p)
                   FROM TABLE ( dbms_sqltune.select_workload_repository(begin_snap => v_begin_snap,
                                                                        end_snap => v_end_snap,
                                                                        basic_filter => 'sql_id = ''&sql_id'' and plan_hash_value = &sql_phv',
                                                                        attribute_list => 'ALL') ) p;

    dbms_sqltune.load_sqlset(sqlset_name => v_sts_name, populate_cursor => v_cur);
    CLOSE v_cur;
    
    --create baseline from the STS
    v_ret := dbms_spm.load_plans_from_sqlset(sqlset_name => v_sts_name, 
                                             basic_filter => 'sql_id = ''&sql_id'' and plan_hash_value = &sql_phv', fixed => 'YES', enabled => 'YES');
    
    --drop STS
    dbms_sqltune.drop_sqlset(sqlset_name => v_sts_name);
    
    SELECT plan_name, sql_handle 
    INTO v_sql_baseline_name, v_sql_handle
    FROM (SELECT plan_name, sql_handle
          FROM dba_sql_plan_baselines 
          ORDER BY created DESC)
    WHERE rownum = 1;
    
    dbms_output.put_line(chr(10));
    dbms_output.put_line(q'[SQL Baseline Name      : ]' || v_sql_baseline_name);
    dbms_output.put_line(q'[SQL Handle             : ]' || v_sql_handle);
    dbms_output.put_line(q'[Number of plans loaded : ]' || v_ret);
END;
/
SET SERVEROUT OFF

