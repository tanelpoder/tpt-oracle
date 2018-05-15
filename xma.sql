-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   xma.sql (eXplain from Memoryi all)
--
-- Purpose:     Explain a SQL statements execution plan directly from library cache
--              for all SQL statements cached there (or multiple)
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       Identify the hash value and and child cursor number for the query 
--              you want to explain (either from v$session.sql_hash_value or by
--              searching through v$sql.sql_text
--
--              Then run:
--                @xm <hash_value> <child_number>
--
--              For example:
--                @xm 593239587 0      -- this would show plan for child 0 of cursor
--                                     -- with hash value 593239587
--
--                @xm 593239587 %      -- this would show all child cursors for the SQL
--          
--------------------------------------------------------------------------------

column xms_hash_value heading Hash_value format 9999999999 print
column xms_child_number heading Ch|ld format 9 print
column xms_id       heading Op|ID format 999
column xms_id2      heading Op|ID format a6
column xms_pred     heading Pr|ed format a2
column xms_optimizer    heading Optimizer|Mode format a10
column xms_plan_step    heading Operation for a55
column xms_object_name  heading Objcect|Name for a30
column xms_opt_cost heading Optimizer|Cost for 9999999
column xms_opt_card heading "Optim rows|from step" for 999999999
column xms_opt_bytes    heading "Optim bytes|from step" for 999999999
column xms_predicate_info heading "Predicate Information (identified by operation id):" format a100 word_wrap

break on xms_child_number skip 1 on xms_hash_value skip 1

select 
    hash_value xms_hash_value,
    child_number    xms_child_number,
    case when access_predicates is not null then 'A' else ' ' end ||
    case when filter_predicates is not null then 'F' else ' ' end xms_pred,
    id      xms_id,
    lpad(' ',depth*1,' ')||operation || ' ' || options xms_plan_step, 
    object_name     xms_object_name,
--  search_columns,
    cost        xms_opt_cost,
    cardinality xms_opt_card,
    bytes       xms_opt_bytes,
    optimizer   xms_optimizer
--  other_tag,
--  other,
--  distribution,
--  access_predicates,
--  filter_predicates
from 
    v$sql_plan 
where 
    hash_value in (&1)
and to_char(child_number) like '&2'  -- to_char is just used for convenient filtering using % for all children
/

select * from (
select
        child_number    xms_child_number,
    lpad(id, 5, ' ') xms_id2,
    ' - access('|| substr(access_predicates,1,3989) || ')' xms_predicate_info
from
    v$sql_plan
where
    hash_value in (&1)
and to_char(child_number) like '&2'
and access_predicates is not null
union all
select
        child_number,
    lpad(id, 5, ' ') xms_id2,
    ' - filter('|| substr(filter_predicates,1,3989) || ')' xms_predicate_info
from
    v$sql_plan
where
    hash_value in (&1)
and to_char(child_number) like '&2'
and filter_predicates is not null
)
order by xms_child_number, xms_id2
/
