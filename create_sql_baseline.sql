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
    v_signature  NUMBER; -- hash value of normalized SQL text
    v_sql_text   CLOB;
    v_sql_handle VARCHAR2(100);
BEGIN
    ret := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE('&bad_sql_id', enabled=>'NO');
    
    DBMS_OUTPUT.PUT_LINE(q'[Looking up SQL_ID &bad_sql_id]');

    -- rownum = 1 because there may be multiple children with this SQL_ID
    SELECT sql_fulltext, exact_matching_signature INTO v_sql_text, v_signature 
    FROM v$sql 
    WHERE 
        sql_id          = '&bad_sql_id' 
    AND rownum = 1;

    DBMS_OUTPUT.PUT_LINE('Found: '||SUBSTR(v_sql_text,1,80)||'...');

    DBMS_OUTPUT.PUT_LINE(q'[Signature = ]'||v_signature);
    SELECT sql_handle INTO v_sql_handle FROM dba_sql_plan_baselines WHERE signature = v_signature;
    DBMS_OUTPUT.PUT_LINE(q'[Handle    = ]'||v_sql_handle);

    -- associate good SQL_IDs plan outline with the bad SQL_ID

    ret := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE(
               sql_id => '&good_sql_id'
             , plan_hash_value => &good_sql_phv
             , sql_handle => v_sql_handle
           );

    DBMS_OUTPUT.PUT_LINE(q'[SQL Baseline Name = SQL_BASELINE_&1] return=]'||ret);
END;
/

SET SERVEROUT OFF

