-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------------------------------
-- SQL Plan Baselines - DBMS_SPM in EE licenses - see http://jonathanlewis.wordpress.com/2011/01/12/fake-baselines/
--------------------------------------------------------------------------------------------------------
-- bad_sqlid  = 1ka5g0kh4h6pc
-- good_sqlid = 1fzf3vqv0f49q 

-- 1) Make sure your "bad query" is in library cache
-- 2) Manually optimize the query with hints, params, etc to get the plan you want (the "good query")

-- 3) Create a disabled plan baseline for the "bad query":

VAR x NUMBER
EXEC :x:= DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE('&bad_sqlid', enabled=>'NO');

-- 4) Find the SQL handle of your "bad" query:

SELECT sql_handle FROM dba_sql_plan_baselines WHERE sql_text = '<your sql_text>';

-- 5) Associate the "good query" plan with the "bad query" SQL plan baseline:

DEF good_sql_id = 1fzf3vqv0f49q
DEF good_plan_hash_value = 2863714589
DEF sql_handle_for_original = SQL_4b3ef772af37954d

VAR x NUMBER

exec :x := dbms_spm.load_plans_from_cursor_cache( -
        sql_id => '&good_sql_id', -
        plan_hash_value => &good_plan_hash_value, -
        sql_handle => '&sql_handle_for_original');

