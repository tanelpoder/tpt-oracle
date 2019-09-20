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
-- Copyright:   (c) https://blog.tanelpoder.com
--              
-- Usage:       1) alter session set statistics_level = all;
--              2) Run the statement you want to explain
--              3) @xb.sql
--          
-- Other:       You can add a GATHER_PLAN_STATISTICS hint to the statement instead 
--              if you dont want to use "alter session set statistics_level" 
--              for some reason (this hint works on Oracle 10.2 and higher)
--
-- TODO:        Noteworthy outstanding items are:
--              * hide inactive (pass-through) plan steps in adaptive plans
--              * add total buffer gets/physical reads somewhere into the output
--              * formatting, decide what columns to show by default
--              * clone to an @xbx.sql (eXtended version) with wider output and stuff like plan outline hints shown etc
--                currently you can just comment/uncomment sections in this script
--
--------------------------------------------------------------------------------

prompt -- xb.sql: eXplain Better v0.99 for prev SQL in the current session - by Tanel Poder (https://blog.tanelpoder.com)

set verify off pagesize 5000 tab off lines 999

column xbi_child_number                             heading "Ch|ld" format 999

column xbi_sql_id                                   heading "SQL_ID" for a13 
column xbi_sql_child_number                         heading "CHLD" for 9999
column xbi_sql_addr                                 heading "ADDRESS"
column xbi_sql_id_text                              heading "" 
column xbi_seconds_ago                              heading "First Load Time"
column xbi_id                                       heading "Op|ID" format 999 justify right
column xbi_parent_id                                heading "Par.|ID" format a5 justify right
column xbi_id2                                      heading "Op|ID" format a5 justify right
column xbi_pred                                     heading "Pred|#Col" format a5 justify right
column xbi_pos                                      heading "#Sib|ling" for 9999
column xbi_optimizer                                heading "Optimizer|Mode" format a10
column xbi_plan_step                                heading "Operation" for a55
column xbi_plan_line                                heading "Row Source" for a72
column xbi_qblock_name                              heading "Query Block|name" for a20
column xbi_object_name                              heading "Object|Name" for a30
column xbi_object_node                              heading "Object|Node" for a10
column xbi_opt_cost                                 heading "Optimizer|Cost" for 99999999999
column xbi_opt_card                                 heading "Est. rows|per Start" for 999999999999
column xbi_opt_card_times_starts                    heading "Est. rows|total" for 999999999999
column xbi_opt_card_misestimate                     heading "Opt. Card.|misestimate" for a15 justify right
column xbi_opt_bytes                                heading "Estimated|output bytes" for 999999999999
column xbi_predicate_info                           heading "Predicate Information (identified by operation id):" format a100 word_wrap
column xbi_cpu_cost                                 heading "CPU|Cost" for 9999999
column xbi_io_cost                                  heading "IO|Cost" for 9999999

column xbi_last_output_rows                         heading "Real #rows|returned" for 999999999
column xbi_last_starts                              heading "Rowsource|starts" for 999999999
column xbi_last_rows_start                          heading "#Rows ret/|per start" for 999999999
column xbi_last_cr_buffer_gets                      heading "Consistent|gets" for 999999999
column xbi_last_cr_buffer_gets_row                  heading "Consistent|gets/row" for 999999999
column xbi_last_cu_buffer_gets                      heading "Current|gets" for 999999999
column xbi_last_cu_buffer_gets_row                  heading "Current|gets/row" for 999999999
column xbi_last_disk_reads                          heading "Physical|reads" for 999999999
column xbi_last_disk_writes                         heading "Physical|writes" for 999999999
column xbi_last_elapsed_time_ms                     heading "cumulative ms|spent in branch" for 9,999,999.99
column xbi_self_elapsed_time_ms                     heading "ms spent in|this operation" for 9,999,999.99
column xbi_self_cr_buffer_gets                      heading "Consistent|gets" for 999999999
column xbi_self_cr_buffer_gets_row                  heading "Consistent|gets/row" for 999999999
column xbi_self_cu_buffer_gets                      heading "Current|gets" for 999999999
column xbi_self_cu_buffer_gets_row                  heading "Current|gets/row" for 999999999
column xbi_self_disk_reads                          heading "Physical|reads" for 999999999
column xbi_self_disk_writes                         heading "Physical|writes" for 999999999
column xbi_last_memory_used                         heading "Memory|used (MB)" for 9,999,999.99
column xbi_last_execution                           heading "Workarea|Passes" for a15

column xbi_sql_plan_hash_value                      heading "Plan Hash Value" for 9999999999
column xbi_plan_hash_value_text                     noprint

column xbi_outline_hints                            heading "Outline Hints" for a120 word_wrap
column xbi_notes                                    heading "Plan|Notes" for a120 word_wrap

column xbi_sql_id                                   heading "SQL_ID" for a13  new_value xbi_sql_id 
column xbi_sql_child_number                         heading "CHLD" for 9999 new_value xbi_sql_child_number
column xbi_sql_addr                                 heading "ADDRESS" new_value xbi_sql_addr


set feedback off

select 
    'Cursor: '              xbi_sql_id_text,
    sql.sql_id              xbi_sql_id,
    sql.child_number        xbi_sql_child_number,
    sql.address             xbi_sql_addr,
    '  PLAN_HASH_VALUE: '   xbi_plan_hash_value_text,
    sql.plan_hash_value     xbi_sql_plan_hash_value,
    'Statement first parsed at: '|| sql.first_load_time ||' - '||
    round( (sysdate - to_date(sql.first_load_time,'YYYY-MM-DD/HH24:MI:SS'))*86400 ) || ' seconds ago' xbi_seconds_ago
from
    v$sql       sql,
    all_users   usr
where
    sql.parsing_user_id = usr.user_id
and (sql.sql_id,sql.child_number,sql.address) = (SELECT prev_sql_id,prev_child_number,prev_sql_addr 
                                                 FROM v$session WHERE sid = USERENV('SID'))
/

WITH sq AS (
    SELECT /*+ MATERIALIZE */ 
         -- using materialize hint to avoid the chance of a nested loop join accessing the V$ views in a loop
        sp.id, sp.parent_id, sp.operation, sp.options, sp.object_owner, sp.object_name
      , ss.last_elapsed_time, ss.last_cr_buffer_gets, ss.last_cu_buffer_gets, ss.last_disk_reads, ss.last_disk_writes
    FROM v$sql_plan_statistics_all ss INNER JOIN
         v$sql_plan sp
      ON (
            sp.sql_id=ss.sql_id
        AND sp.child_number=ss.child_number
        AND sp.address=ss.address
        AND sp.id=ss.id
      )
    AND sp.sql_id='&xbi_sql_id'
    AND sp.child_number = TO_NUMBER('&xbi_sql_child_number')
),  deltas AS (
    SELECT 
        par.id
      , par.last_elapsed_time   - SUM(chi.last_elapsed_time  ) self_elapsed_time
      , par.last_cr_buffer_gets - SUM(chi.last_cr_buffer_gets) self_cr_buffer_gets
      , par.last_cu_buffer_gets - SUM(chi.last_cu_buffer_gets) self_cu_buffer_gets
      , par.last_disk_reads     - SUM(chi.last_disk_reads    ) self_disk_reads  
      , par.last_disk_writes    - SUM(chi.last_disk_writes   ) self_disk_writes  
    FROM sq par LEFT OUTER JOIN
         sq chi
      ON chi.parent_id = par.id
    GROUP BY 
        par.id
      , par.last_elapsed_time, par.last_cr_buffer_gets, par.last_cu_buffer_gets, par.last_disk_reads, par.last_disk_writes   
), combined AS (
    SELECT sq.id, sq.parent_id, sq.operation, sq.options
         , sq.object_owner, sq.object_name, sq.last_elapsed_time 
         , NVL(deltas.self_elapsed_time   , sq.last_elapsed_time)   self_elapsed_time
         , NVL(deltas.self_cr_buffer_gets , sq.last_cr_buffer_gets) self_cr_buffer_gets
         , NVL(deltas.self_cu_buffer_gets , sq.last_cu_buffer_gets) self_cu_buffer_gets
         , NVL(deltas.self_disk_reads     , sq.last_disk_reads)     self_disk_reads
         , NVL(deltas.self_disk_writes    , sq.last_disk_writes)    self_disk_writes
    FROM
        sq, deltas
    WHERE
        sq.id = deltas.id
)
select  
    LPAD(
      CASE WHEN p.filter_predicates IS NOT NULL THEN 'F' ELSE ' ' END ||
      CASE WHEN p.access_predicates IS NOT NULL THEN CASE WHEN p.options LIKE 'STORAGE %' THEN 'S' ELSE 'A' END ELSE '' END ||
      CASE p.search_columns WHEN 0 THEN NULL ELSE '#'||TO_CHAR(p.search_columns) END
    ,5)   xbi_pred,
    p.id                                                               xbi_id,
    nvl2(p.parent_id, to_char(p.parent_id, '9999'), ' root')                                   xbi_parent_id,
    CASE WHEN p.id != 0 THEN p.position END xbi_pos,
    LPAD(' ',p.depth*1,' ')|| p.operation || ' ' || p.options ||' '
         ||nvl2(p.object_name, '['||p.object_name||']', null)
                                                                       xbi_plan_line, 
    p.qblock_name                                                      xbi_qblock_name,
--  p.object_node                                                      xbi_object_node,
--  p.distribution                                                     xbi_distribution,
    round(c.self_elapsed_time /1000,2)                                  xbi_self_elapsed_time_ms,
    round(ps.last_elapsed_time/1000,2)                                  xbi_last_elapsed_time_ms,
    regexp_replace(lpad(to_char(round(
                      CASE WHEN (NULLIF(ps.last_output_rows / NULLIF(p.cardinality * ps.last_starts, 0),0)) > 1 THEN  -(NULLIF(ps.last_output_rows / NULLIF(p.cardinality * ps.last_starts, 0),0))
                           WHEN (NULLIF(ps.last_output_rows / NULLIF(p.cardinality * ps.last_starts, 0),0)) < 1 THEN 1/(NULLIF(ps.last_output_rows / NULLIF(p.cardinality * ps.last_starts, 0),0))
                           WHEN (NULLIF(ps.last_output_rows / NULLIF(p.cardinality * ps.last_starts, 0),0)) = 1 THEN 1
                      ELSE null
                      END
                 ,0))||'x',15),'^ *x$')   xbi_opt_card_misestimate,
    p.cardinality * ps.last_starts                                                 xbi_opt_card_times_starts,
    ps.last_output_rows                                                            xbi_last_output_rows,
    ps.last_starts                                                                 xbi_last_starts,
    c.self_cr_buffer_gets                                                         xbi_self_cr_buffer_gets,
    c.self_cr_buffer_gets / DECODE(ps.last_output_rows,0,1,ps.last_output_rows)   xbi_self_cr_buffer_gets_row,
    c.self_cu_buffer_gets                                                         xbi_self_cu_buffer_gets,
    c.self_cu_buffer_gets / DECODE(ps.last_output_rows,0,1,ps.last_output_rows)   xbi_self_cu_buffer_gets_row,
    c.self_disk_reads                                                             xbi_self_disk_reads,
    c.self_disk_writes                                                            xbi_self_disk_writes,
--  ps.last_cr_buffer_gets                                                         xbi_last_cr_buffer_gets,
--  ps.last_cr_buffer_gets / DECODE(ps.last_output_rows,0,1,ps.last_output_rows)   xbi_last_cr_buffer_gets_row,
--  ps.last_cu_buffer_gets                                                         xbi_last_cu_buffer_gets,
--  ps.last_cu_buffer_gets / DECODE(ps.last_output_rows,0,1,ps.last_output_rows)   xbi_last_cu_buffer_gets_row,
--  ps.last_disk_reads                                                             xbi_last_disk_reads,
--  ps.last_disk_writes                                                            xbi_last_disk_writes,
    ps.last_memory_used/1048576                                                    xbi_last_memory_used,
    ps.last_execution                                                              xbi_last_execution,
    p.cost                                                                         xbi_opt_cost
--  p.bytes                                                                        xbi_opt_bytes,
--  p.cpu_cost                                                                     xbi_cpu_cost,
--  p.io_cost                                                                      xbi_io_cost,
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
and p.address = hextoraw('&xbi_sql_addr')
and p.child_number = TO_NUMBER(&xbi_sql_child_number)
and ps.id = c.id (+)
order by
    p.id asc    
/

select
    xbi_id2,
    xbi_qblock_name,
    substr(dummy,1,0)||'-' " ", -- there's an ugly reason (bug) for this hack
    xbi_predicate_info
from (
    select
        sql_id                      xbi_sql_id,
        lpad(id, 5, ' ')            xbi_id2,
        filter_predicates           dummy, -- looks like there's a bug in 11.2.0.3 where both pred cols have to be selected
        CASE WHEN options LIKE 'STORAGE %' THEN 'storage' ELSE 'access' END||'('|| substr(access_predicates,1,3989) || ')' xbi_predicate_info,
        qblock_name                 xbi_qblock_name
    from
        v$sql_plan
    where
        sql_id = '&xbi_sql_id'
    and child_number = TO_NUMBER(&xbi_sql_child_number)
    AND address = HEXTORAW('&xbi_sql_addr')
    and access_predicates is not null
    union all
    select
        sql_id                      xbi_sql_id,
        lpad(id, 5, ' ')            xbi_id2,
        access_predicates           dummy,
        'filter('|| substr(filter_predicates,1,3989) || ')' xbi_predicate_info,
        qblock_name                 xbi_qblock_name
    from
        v$sql_plan
    where
        sql_id = '&xbi_sql_id'
    and child_number = TO_NUMBER(&xbi_sql_child_number)
    and address = HEXTORAW('&xbi_sql_addr')
    and filter_predicates is not null
)
order by
    xbi_id2 asc,
    xbi_predicate_info asc
/

WITH sq AS (
    SELECT other_xml 
    FROM v$sql_plan p
    WHERE
        p.sql_id = '&xbi_sql_id'
    AND p.child_number = &xbi_sql_child_number
    AND p.other_xml IS NOT NULL -- (the other_xml is not guaranteed to always be on plan line 1)
)
          SELECT '    *' " ", 'Cardinality feedback was used for this child cursor.' xbi_notes FROM sq WHERE extractvalue(xmltype(sq.other_xml), '/*/info[@type = "cardinality_feedback"]') = 'yes'
UNION ALL SELECT '    *', 'SQL Stored Outline used = '  ||extractvalue(xmltype(sq.other_xml), '/*/info[@type = "outline"]')       FROM sq WHERE extractvalue(xmltype(sq.other_xml), '/*/info[@type = "outline"]')          IS NOT NULL
UNION ALL SELECT '    *', 'SQL Patch used = '           ||extractvalue(xmltype(sq.other_xml), '/*/info[@type = "sql_patch"]')     FROM sq WHERE extractvalue(xmltype(sq.other_xml), '/*/info[@type = "sql_patch"]')        IS NOT NULL
UNION ALL SELECT '    *', 'SQL Profile used = '         ||extractvalue(xmltype(sq.other_xml), '/*/info[@type = "sql_profile"]')   FROM sq WHERE extractvalue(xmltype(sq.other_xml), '/*/info[@type = "sql_profile"]')      IS NOT NULL
UNION ALL SELECT '    *', 'SQL Plan Baseline used = '   ||extractvalue(xmltype(sq.other_xml), '/*/info[@type = "baseline"]')      FROM sq WHERE extractvalue(xmltype(sq.other_xml), '/*/info[@type = "baseline"]')         IS NOT NULL
UNION ALL SELECT '    *', 'Adaptive Plan = '            ||extractvalue(xmltype(sq.other_xml), '/*/info[@type = "adaptive_plan"]') FROM sq WHERE extractvalue(xmltype(sq.other_xml), '/*/info[@type = "adaptive_plan"]')    IS NOT NULL
/

-- === Outline Hints ===
-- WITH sq AS (
--     SELECT other_xml 
--     FROM v$sql_plan p
--     WHERE
--         p.sql_id = '&xbi_sql_id'
--     AND p.child_number = &xbi_sql_child_number
--     AND p.id = 1
-- )
-- SELECT 
--     SUBSTR(EXTRACTVALUE(VALUE(d), '/hint'),1,4000)  xbi_outline_hints
-- FROM
--     sq
--   , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(sq.other_xml), '/*/outline_data/hint'))) D
-- /


PROMPT 
set feedback on
