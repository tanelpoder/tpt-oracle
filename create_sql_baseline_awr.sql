-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------------------------------
-- this script allows you to transfer a plan from an existing (good) cursor to the problematic (bad) one.
-- usage:
--
-- @create_sql_baseline <from_good_sqlid> <good_sql_plan_hash_value> <to_bad_sqlid>
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

DEF good_sql_id  = &1
DEF good_sql_phv = &2
DEF bad_sql_id   = &3

DECLARE
    ret          NUMBER;
    ret2         NUMBER;
    v_signature  NUMBER; -- hash value of normalized SQL text
    v_sql_text   CLOB;
    v_sql_handle VARCHAR2(100);
    v_plan_name  VARCHAR2(100);
    v_begin_snap NUMBER;
    v_end_snap NUMBER;

BEGIN

    SELECT sql_text, DBMS_SQLTUNE.SQLTEXT_TO_SIGNATURE(sql_text, 0) exact_matching_signature INTO v_sql_text, v_signature 
    FROM dba_hist_sqltext
    WHERE sql_id = '&bad_sql_id'; -- AND dbid = ...

    SELECT MIN(snap_id), MAX(snap_id) INTO v_begin_snap, v_end_snap
    FROM dba_hist_sqlstat 
    WHERE sql_id = '&good_sql_id' AND plan_hash_value = TO_NUMBER('&good_sql_phv') AND rownum = 1;

    ret := DBMS_SPM.LOAD_PLANS_FROM_AWR(
               v_begin_snap - 1
             , v_end_snap
             , basic_filter => q'[sql_id = '&good_sql_id' AND plan_hash_value = TO_NUMBER('&good_sql_phv')]'
             , enabled=>'YES'
             , fixed=>'YES'
          );

    DBMS_OUTPUT.put_line('Number of plans loaded and fixed: '||ret);

    -- FOR i IN (SELECT sql_handle, plan_name FROM dba_sql_plan_baselines WHERE signature = v_signature) LOOP
    --     ret  := DBMS_SPM.ALTER_SQL_PLAN_BASELINE(i.sql_handle, i.plan_name, 'ENABLED', 'YES');
    --     ret2 := DBMS_SPM.ALTER_SQL_PLAN_BASELINE(i.sql_handle, i.plan_name, 'FIXED',   'YES');
    --     DBMS_OUTPUT.PUT_LINE('handle='||i.sql_handle||' plan_name='||i.plan_name||' ret='||ret ||' ret2='||ret2);
    -- END LOOP;

END;
/

SET SERVEROUT OFF

