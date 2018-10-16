-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   xb (eXplain Better)
--
-- Purpose:     Explain a SQL statements execution plan with execution 
--              profile directly from library cache - for the last
--              SQL executed in current session (see also xbi.sql)
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       1) alter session set statistics_level = all;
--              2) Run the statement you want to explain
--              3) @xb.sql
--          
-- Other:       You can add a GATHER_PLAN_STATISTICS hint to the statement instead 
--              if you dont want to use "alter session set statistics_level" 
--              for some reason (this hint works on Oracle 10.2 and higher)
--
--------------------------------------------------------------------------------

prompt xb: eXplain Better (prev SQL in current session)

--set verify off pagesize 5000 tab off lines 999

column xms_child_number     heading "Ch|ld" format 99
break on xms_child_number   skip 1

column xms_id                                       heading "Op|ID" format 999
column xms_parent_id                                heading "Par.|ID" format a5
column xms_id2                                      heading "Op|ID" format a6
column xms_pred                                     heading "Pred|#Col" format a5
column xms_pos                                      heading "#Sib|ling" for 99999
column xms_optimizer                                heading "Optimizer|Mode" format a10
column xms_plan_step                                heading "Operation" for a55
column xms_plan_line                                heading "Row Source" for a70
column xms_qblock_name                              heading "Query Block|name" for a20
column xms_object_name                              heading "Object|Name" for a30
column xms_opt_cost                                 heading "Optimizer|Cost" for 99999999999
column xms_opt_card                                 heading "Est. rows|per Start" for 999999999999
column xms_opt_card_times_starts                    heading "Est. rows|total" for 999999999999
column xms_opt_card_misestimate                     heading "Opt.Card.|misestimate" for a15
column xms_opt_bytes                                heading "Estimated|output bytes" for 999999999999
column xms_predicate_info                           heading "Predicate Information (identified by operation id):" format a100 word_wrap
column xms_cpu_cost                                 heading "CPU|Cost" for 9999999
column xms_io_cost                                  heading "IO|Cost" for 9999999

column xms_last_output_rows                         heading "Real #rows|returned" for 999999999
column xms_last_starts                              heading "Rowsource|starts" for 999999999
column xms_last_rows_start                          heading "#Rows ret/|per start" for 999999999
column xms_last_cr_buffer_gets                      heading "Consistent|gets" for 999999999
column xms_last_cr_buffer_gets_row                  heading "Consistent|gets/row" for 999999999
column xms_last_cu_buffer_gets                      heading "Current|gets" for 999999999
column xms_last_cu_buffer_gets_row                  heading "Current|gets/row" for 999999999
column xms_last_disk_reads                          heading "Physical|reads" for 999999999
column xms_last_disk_writes                         heading "Physical|writes" for 999999999
column xms_last_elapsed_time_ms                     heading "cumulative ms|spent in branch" for 9,999,999.99
column xms_self_elapsed_time_ms                     heading "ms spent in|this operation" for 9,999,999.99
column xms_last_memory_used                         heading "Memory|used (MB)" for 9,999,999.99
column xms_last_execution                           heading "Workarea|Passes" for a15

column xms_sql_plan_hash_value                      heading "Plan Hash Value" for 9999999999
column xms_plan_hash_value_text                     noprint

-- column xbi_sql_id                                   heading "SQL_ID" for a13  new_value xbi_sql_id 
-- column xbi_sql_child_number                         heading "CHLD" for 9999 new_value xbi_sql_child_number
-- column xms_prev_sql_addr                            heading "ADDRESS" new_value xms_prev_sql_addr
-- column xbi_sql_id clear
-- column xbi_sql_child_number clear
-- column xms_prev_sql_addr    clear

column xms_outline_hints                            heading "Outline Hints" for a120 word_wrap

DEF xbi_sql_id=&1
DEF xbi_sql_child_number=&2

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
    'SQL ID: '              xbi_sql_id_text,
    sql.sql_id              xbi_sql_id,
    sql.child_number        xbi_sql_child_number,
    sql.address             xml_prev_sql_addr,
    '  PLAN_HASH_VALUE: '   xms_plan_hash_value_text,
    sql.plan_hash_value     xms_sql_plan_hash_value,
    '   |   Statement first parsed at: '|| sql.first_load_time ||'  |  '||
    round( (sysdate - to_date(sql.first_load_time,'YYYY-MM-DD/HH24:MI:SS'))*86400 ) || ' seconds ago' xms_seconds_ago
from
    v$sql       sql,
    all_users   usr
where
    sql.parsing_user_id = usr.user_id
and sql.sql_id =        '&xbi_sql_id'
and sql.child_number =  TO_NUMBER('&xbi_sql_child_number')
--and sql.address      =  (SELECT prev_sql_addr FROM v$session WHERE sid = USERENV('SID'))
order by
    sql.sql_id asc,
    sql.child_number asc
/

--set heading on

WITH sq AS (
    SELECT /*+ MATERIALIZE */
        sp.id, sp.parent_id, sp.operation, sp.options
      , sp.object_owner, sp.object_name, ss.last_elapsed_time
    FROM v$sql_plan_statistics_all ss INNER JOIN
         v$sql_plan sp
      ON (
            sp.sql_id=ss.sql_id
        AND sp.child_number=ss.child_number
        AND sp.address=ss.address
        AND sp.id=ss.id
      )
    AND sp.sql_id='&1'
    and sp.child_number = TO_NUMBER('&xbi_sql_child_number')
),  deltas AS (
    SELECT par.id, par.last_elapsed_time - SUM(chi.last_elapsed_time) self_elapsed_time
    FROM sq par LEFT OUTER JOIN
         sq chi
      ON chi.parent_id = par.id
    GROUP BY par.id, par.last_elapsed_time
), combined AS (
    SELECT sq.id, sq.parent_id, sq.operation, sq.options
         , sq.object_owner, sq.object_name, sq.last_elapsed_time 
         , NVL(deltas.self_elapsed_time, sq.last_elapsed_time) self_elapsed_time
    FROM
        sq, deltas
    WHERE
        sq.id = deltas.id
)
select  
    p.child_number                                     xms_child_number,
    CASE WHEN p.filter_predicates IS NOT NULL THEN 'F' ELSE ' ' END ||
    CASE WHEN p.access_predicates IS NOT NULL THEN CASE WHEN p.options LIKE 'STORAGE %' THEN 'S' ELSE 'A' END ELSE ' ' END ||
    CASE p.search_columns WHEN 0 THEN NULL ELSE '#'||TO_CHAR(p.search_columns) END   xms_pred,
    p.id                                                               xms_id,
--    nvl2(p.parent_id, trim(to_char(p.parent_id, '9999')), ' root')||'.'||trim(p.position)                    xms_uniq_step,
    nvl2(p.parent_id, to_char(p.parent_id, '9999'), ' root')                                   xms_parent_id,
--    LPAD(' ',p.depth*1,' ')|| to_char(p.position, '999') xms_pos,
    CASE WHEN p.id != 0 THEN p.position END xms_pos,
--    LPAD(' ',p.depth*1,' ')||''||to_char(p.position, '999') || '...' || p.operation || ' ' || p.options ||' '
    LPAD(' ',p.depth*1,' ')|| p.operation || ' ' || p.options ||' '
         ||nvl2(p.object_name, '['||p.object_name||']', null)
         ||nvl2(p.object_node, ' {'||p.object_node||'}', null)
        -- ||nvl2(p.qblock_name, ' @ '||p.qblock_name, null)  
                                                                       xms_plan_line, 
    p.qblock_name                                                      xms_qblock_name,
--    p.object_name                                                      xms_object_name,
--  LPAD(' ',p.depth*1,' ')|| p.operation || ' ' || p.options          xms_plan_step, 
--  p.object_name                                                      xms_object_name,
--  p.qblock_name                                                      xms_qblock_name,
--    p.other,
--    p.other_tag,
--    p.distribution,
--  p.optimizer                                                        xms_optimizer,
--  p.object#,
--    p.object_instance,
--    p.object_type,
--   p.other_tag,
--   p.distribution,
-- DEV
--    round (lag(ps.last_elapsed_time/1000,2,1) over (
--                                           order by nvl2(p.parent_id, (to_char(p.parent_id, '9999')), '      ')||'.'||trim(p.position)
--                                        )) - round(ps.last_elapsed_time/1000,2)  xms_last_elapsed_time_d,
    round(c.self_elapsed_time /1000,2)                                  xms_self_elapsed_time_ms,
    round(ps.last_elapsed_time/1000,2)                                  xms_last_elapsed_time_ms,
    lpad(to_char(round(1 - (1 / NULLIF(ps.last_output_rows / NULLIF(p.cardinality * ps.last_starts, 0),0))))||NVL2(ps.last_output_rows / NULLIF(p.cardinality * ps.last_starts, 0),'x', NULL),15)   xms_opt_card_misestimate,
    p.cardinality                                                                  xms_opt_card,
    p.cardinality * ps.last_starts                                                 xms_opt_card_times_starts,
    ps.last_output_rows                                                            xms_last_output_rows,
    ps.last_starts                                                                 xms_last_starts,
    ps.last_output_rows / DECODE(ps.last_starts,0,1,ps.last_starts)                xms_last_rows_start,
    ps.last_cr_buffer_gets                                                         xms_last_cr_buffer_gets,
    ps.last_cr_buffer_gets / DECODE(ps.last_output_rows,0,1,ps.last_output_rows)   xms_last_cr_buffer_gets_row,
    ps.last_cu_buffer_gets                                                         xms_last_cu_buffer_gets,
    ps.last_cu_buffer_gets / DECODE(ps.last_output_rows,0,1,ps.last_output_rows)   xms_last_cu_buffer_gets_row,
    ps.last_disk_reads                                                             xms_last_disk_reads,
    ps.last_disk_writes                                                            xms_last_disk_writes,
    ps.last_memory_used/1048576                                                    xms_last_memory_used,
    ps.last_execution                                                              xms_last_execution,
    p.cost                                                                         xms_opt_cost
--  p.bytes                                                                        xms_opt_bytes,
--  p.cpu_cost                                                                     xms_cpu_cost,
--  p.io_cost                                                                      xms_io_cost,
--  p.other_tag,
--  p.other,
--  p.access_predicates,
--  p.filter_predicates,
from 
    v$sql_plan p
  , v$sql_plan_statistics_all ps
  , combined c
where
    p.address           =  ps.address          (+)          
and p.sql_id            =  ps.sql_id           (+)                  
and p.plan_hash_value   =  ps.plan_hash_value  (+)              
and p.child_number      =  ps.child_number     (+)
and p.id                =  ps.id               (+) 
and p.sql_id = '&xbi_sql_id'
and p.child_number = TO_NUMBER(&xbi_sql_child_number)
and ps.id = c.id (+)
order by
    p.sql_id asc,
    p.address asc,
    p.child_number asc,
--    nvl2(p.parent_id, (to_char(p.parent_id, '9999')), '      ')||'.'||trim(p.position)
    p.id asc    
/

select
    xms_child_number,
    xms_id2,
    xms_qblock_name,
    substr(dummy,1,0)||'-' " ", -- there's an ugly reason (bug) for this hack
    xms_predicate_info
from (
    select
        sql_id                      xbi_sql_id,
        child_number                xms_child_number,
        lpad(id, 5, ' ')            xms_id2,
        filter_predicates           dummy, -- looks like there's a bug in 11.2.0.3 where both pred cols have to be selected
        CASE WHEN options LIKE 'STORAGE %' THEN 'storage' ELSE 'access' END||'('|| substr(access_predicates,1,3989) || ')' xms_predicate_info,
        qblock_name                 xms_qblock_name
    from
        v$sql_plan
    where
        sql_id = '&xbi_sql_id'
    and child_number = TO_NUMBER(&xbi_sql_child_number)
    and access_predicates is not null
    union all
    select
        sql_id                  xbi_sql_id,
        child_number                xms_child_number,
        lpad(id, 5, ' ') xms_id2,
        access_predicates           dummy,
        'filter('|| substr(filter_predicates,1,3989) || ')' xms_predicate_info,
        qblock_name                 xms_qblock_name
    from
        v$sql_plan
    where
        sql_id = '&xbi_sql_id'
    and child_number = TO_NUMBER(&xbi_sql_child_number)
    and filter_predicates is not null
)
order by
    xbi_sql_id asc,
    xms_child_number asc,
    xms_id2 asc,
    xms_predicate_info asc
/

-- WITH sq AS (
--     SELECT child_number, other_xml 
--     FROM v$sql_plan p
--     WHERE
--         p.sql_id = '&xbi_sql_id'
--     AND p.child_number LIKE '&xbi_sql_child_number'
--     AND p.id = 1
-- )
-- SELECT 
--     child_number xms_child_number,
--     SUBSTR(EXTRACTVALUE(VALUE(d), '/hint'),1,4000)  xms_outline_hints
-- FROM
--     sq
--   , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(sq.other_xml), '/*/outline_data/hint'))) D
-- UNION ALL SELECT sq.child_number, '' FROM sq 
-- UNION ALL SELECT sq.child_number, 'Cardinality feedback was used for this child cursor.' FROM sq WHERE extractvalue(xmltype(sq.other_xml), '/*/info[@type = "cardinality_feedback"]') = 'yes'
-- UNION ALL SELECT sq.child_number, 'SQL Stored Outline used = '  ||extractvalue(xmltype(sq.other_xml), '/*/info[@type = "outline"]')     FROM sq WHERE extractvalue(xmltype(sq.other_xml), '/*/info[@type = "outline"]')     IS NOT NULL
-- UNION ALL SELECT sq.child_number, 'SQL Patch used = '           ||extractvalue(xmltype(sq.other_xml), '/*/info[@type = "sql_patch"]')   FROM sq WHERE extractvalue(xmltype(sq.other_xml), '/*/info[@type = "sql_patch"]')   IS NOT NULL
-- UNION ALL SELECT sq.child_number, 'SQL Profile used = '         ||extractvalue(xmltype(sq.other_xml), '/*/info[@type = "sql_profile"]') FROM sq WHERE extractvalue(xmltype(sq.other_xml), '/*/info[@type = "sql_profile"]') IS NOT NULL
-- UNION ALL SELECT sq.child_number, 'SQL Plan Baseline used = '   ||extractvalue(xmltype(sq.other_xml), '/*/info[@type = "baseline"]')    FROM sq WHERE extractvalue(xmltype(sq.other_xml), '/*/info[@type = "baseline"]')    IS NOT NULL
-- /

