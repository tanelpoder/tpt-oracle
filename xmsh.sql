-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   xmsh (eXplain from Memory with Statistics lookup by Hash value)
--
-- Purpose:     Explain a SQL statements execution plan with execution 
--              profile directly from library cache
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       1) alter session set statistics_level = all;
--              2) Run the statement you want to explain
--              3) @xmsh <hash_value> <child#>
--          
-- Other:       You can add a GATHER_PLAN_STATISTICS hint to the statement instead 
--              if you dont want to use "alter session set statistics_level" 
--              for some reason (this hint works on Oracle 10.2 and higher)
--
--------------------------------------------------------------------------------

set verify off heading off feedback off linesize 299 pagesize 5000 tab off


column xms_child_number     heading "Ch|ld" format 99
break on xms_child_number   skip 1

column xms_id           heading Op|ID format 999
column xms_id2          heading Op|ID format a6
column xms_pred         heading Pr|ed format a2
column xms_optimizer        heading Optimizer|Mode format a10
column xms_plan_step        heading Operation for a55
column xms_object_name      heading Object|Name for a30
column xms_opt_cost     heading Optimizer|Cost for 99999999999
column xms_opt_card     heading "Estimated|output rows" for 999999999999
column xms_opt_bytes        heading "Estimated|output bytes" for 999999999999
column xms_predicate_info   heading "Predicate Information (identified by operation id):" format a100 word_wrap
column xms_cpu_cost     heading CPU|Cost for 9999999
column xms_io_cost      heading IO|Cost for 9999999

column xms_last_output_rows heading "Real #rows|returned" for 999999999
column xms_last_starts          heading "Rowsource|starts" for 999999999
column xms_last_cr_buffer_gets  heading "Consistent|gets" for 999999999
column xms_last_cu_buffer_gets  heading "Current|gets" for 999999999
column xms_last_disk_reads      heading "Physical|reads" for 999999999
column xms_last_disk_writes     heading "Physical|writes" for 999999999
column xms_last_elapsed_time_ms heading "ms spent in|operation" for 9,999,999.99


--select
--  'Warning: statistics_level is not set to ALL!'||chr(10)||
--  'Run: alter session set statistics_level=all before executing your query...' warning
--from
--  v$parameter
--where
--  name = 'statistics_level'
--and   lower(value) != 'all'
--/

select  --+ ordered use_nl(mys ses) use_nl(mys sql)
    'SQL hash value: '  xms_sql_hash_value_text,
    sql.hash_value      xms_hash_value,
    '   Cursor address: '   xms_cursor_address_text,
    sql.address     xms_sql_address,
    '   |   Statement first parsed at: '|| sql.first_load_time ||'  |  '||
    round( (sysdate - to_date(sql.first_load_time,'YYYY-MM-DD/HH24:MI:SS'))*86400 ) || ' seconds ago' xms_seconds_ago
from
    v$sql       sql,
    all_users   usr
where
    sql.parsing_user_id = usr.user_id
and sql.hash_value in (&1)
--and   sql.hash_value = &1
and to_char(sql.child_number) like '&2'
order by
    sql.hash_value asc,
    sql.child_number asc
/

set heading on

select  --+ ordered use_nl(p ps)
    p.child_number      xms_child_number,
    case when p.access_predicates is not null then 'A' else ' ' end ||
    case when p.filter_predicates is not null then 'F' else ' ' end xms_pred,
    p.id        xms_id,
    lpad(' ',p.depth*1,' ')|| p.operation || ' ' || p.options xms_plan_step, 
    p.object_name   xms_object_name,
--  p.search_columns,
--  p.optimizer     xms_optimizer,
    round(ps.last_elapsed_time/1000,2)
                xms_last_elapsed_time_ms,
    p.cardinality       xms_opt_card,
    ps.last_output_rows xms_last_output_rows,
    ps.last_starts      xms_last_starts,
    ps.last_cr_buffer_gets  xms_last_cr_buffer_gets,
    ps.last_cu_buffer_gets  xms_last_cu_buffer_gets,
        ps.last_disk_reads      xms_last_disk_reads,
        ps.last_disk_writes     xms_last_disk_writes,
    p.cost          xms_opt_cost
--  p.bytes         xms_opt_bytes,
--  p.cpu_cost      xms_cpu_cost,
--  p.io_cost       xms_io_cost,
--  p.other_tag,
--  p.other,
--  p.distribution,
--  p.access_predicates,
--  p.filter_predicates,
from 
    v$sql_plan p,
    v$sql_plan_statistics ps
where 
    p.address = ps.address(+)
and p.hash_value = ps.hash_value(+)
and p.child_number = ps.child_number(+)
and p.id = ps.operation_id(+)
and p.hash_value in (&1)
--and   p.hash_value = &1
and to_char(p.child_number) like '&2'  -- to_char is just used for convenient filtering using % for all children
order by
    p.hash_value asc,
    p.address asc,
    p.child_number asc,
    p.id asc    
/

prompt


select
    xms_child_number,
    xms_id2,
    xms_predicate_info 
from (
    select
        hash_value                  xms_hash_value,
        child_number                xms_child_number,
        lpad(id, 5, ' ')            xms_id2,
        ' - access('|| substr(access_predicates,1,3980) || ')' xms_predicate_info
    from
        v$sql_plan
    where
        hash_value in (&1)
    and to_char(child_number) like '&2'
    and access_predicates is not null
    union all
    select
        hash_value                  xms_hash_value,
        child_number                xms_child_number,
        lpad(id, 5, ' ')            xms_id2,
        ' - filter('|| substr(filter_predicates,1,3980) || ')' xms_predicate_info
    from
        v$sql_plan
    where
        hash_value in (&1)
--      hash_value = &1
    and to_char(child_number) like '&2'
    and filter_predicates is not null
)
order by
    xms_hash_value asc,
    xms_child_number asc,
    xms_id2 asc,
    xms_predicate_info asc
/


prompt

set feedback on
