-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   02_choosing_join_order.sql
--
-- Purpose:     Advanced Oracle SQL Tuning demo script
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       You can run the query against Oracle's sample schemas (SH)
--              The optimizer stats have to be updated to cause trouble.
--               See the commented out code below
--                
--------------------------------------------------------------------------------

-- in Oracle 11gR2, set the cardinality feedback option to false for demo stability purposes
-- alter session set "_optimizer_use_feedback"=false;
--
-- Set statistics_level = all for measuring optimizer misestimate (or use V$SQL_MONITOR):
-- alter session set statistics_level = all;
--
-- Cause trouble for the optimizer:
-- EXEC DBMS_STATS.SET_TABLE_STATS('SH','CUSTOMERS', NUMROWS=>1, NUMBLKS=>1, NO_INVALIDATE=>FALSE);

SELECT /*+ MONITOR */
    ch.channel_desc
  , co.country_iso_code co 
  , cu.cust_city
  , p.prod_category
  , sum(s.quantity_sold)
  , sum(s.amount_sold)
FROM
    sh.sales     s
  , sh.customers cu
  , sh.countries co
  , sh.products  p
  , sh.channels  ch
WHERE
    -- join
    s.cust_id     = cu.cust_id
AND cu.country_id = co.country_id
AND s.prod_id     = p.prod_id
AND s.channel_id  = ch.channel_id
    -- filter
AND ch.channel_class = 'Direct'  
AND co.country_iso_code = 'US'  
AND p.prod_category = 'Electronics'
GROUP BY
    ch.channel_desc
  , co.country_iso_code
  , cu.cust_city
  , p.prod_category
/


--------------------------------------------------------------------------------------------------------
-- SQL Profiles (require Tuning + Diag Pack):
--------------------------------------------------------------------------------------------------------
--
--   VAR sql_fulltext CLOB
--   EXEC SELECT sql_fulltext INTO :sql_fulltext FROM v$sql WHERE sql_id = '1ka5g0kh4h6pc' AND rownum = 1;
--
-- Example 1: Set Join order:
--   EXEC DBMS_SQLTUNE.IMPORT_SQL_PROFILE(sql_text=>:sql_fulltext, profile=>sys.sqlprof_attr('LEADING(@"SEL$1" "CO"@"SEL$1" "CH"@"SEL$1" "CU"@"SEL$1" "S"@"SEL$1" "P"@"SEL$1")'), name=> 'MANUAL_PROFILE_1ka5g0kh4h6pc');
--
-- Example 2: Adjust cardinality:
--   EXEC DBMS_SQLTUNE.IMPORT_SQL_PROFILE(sql_text=>:sql_fulltext, profile=>sys.sqlprof_attr('CARDINALITY(@"SEL$1" "CU"@"SEL$1" 100000)'), name=> 'MANUAL_PROFILE_1ka5g0kh4h6pc');
--
-- Example 3: Set multiple hints:
--   DECLARE
--       hints sys.sqlprof_attr := sys.sqlprof_attr(
--           ('LEADING(@"SEL$1" "CO"@"SEL$1" "CH"@"SEL$1"')
--         , ('CARDINALITY(@"SEL$1" "CU"@"SEL$1" 100000)')
--       );
--   BEGIN
--       DBMS_SQLTUNE.IMPORT_SQL_PROFILE(sql_text=>:sql_fulltext, profile=> hints, name=> 'MANUAL_PROFILE_1ka5g0kh4h6pc');
--   END;
--   /
--
-- Drop the profile:
--   EXEC DBMS_SQLTUNE.DROP_SQL_PROFILE('MANUAL_PROFILE_1ka5g0kh4h6pc');
--
--
--------------------------------------------------------------------------------------------------------
-- SQL Plan Baselines - DBMS_SPM in EE licenses - see http://jonathanlewis.wordpress.com/2011/01/12/fake-baselines/
--------------------------------------------------------------------------------------------------------
-- bad_sqlid  = 1ka5g0kh4h6pc
-- good_sqlid = 1fzf3vqv0f49q 

-- 1) Manually run the query with hints, params, etc to get the plan you want (the good query)
--
-- 2) Create a disabled plan baseline for the "bad query":
--    VAR x NUMBER
--    EXEC :x:= DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE('&bad_sqlid', enabled=>'NO');
--
-- 3) SELECT sql_handle FROM dba_sql_plan_baselines WHERE sql_text = '<your sql_text>';
--
-- 4) Associate the "good query" plan with the "bad query" SQL plan baseline:
--    DEF good_sql_id = 1fzf3vqv0f49q
--    DEF good_plan_hash_value = 2863714589
--    DEF sql_handle_for_original = SQL_4b3ef772af37954d

--    VAR x NUMBER
--    
--    exec :x := dbms_spm.load_plans_from_cursor_cache( -
--            sql_id => '&good_sql_id', -
--            plan_hash_value => &good_plan_hash_value, -
--            sql_handle => '&sql_handle_for_original');
--
