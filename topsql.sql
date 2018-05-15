-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   topsql.sql
-- Purpose:     Show TOP SQL ordered by user-provided criteria
--              Ordering columns are: 
--                 CPU_TIME
--                 ELAPSED_TIME
--                 EXECUTIONS
--                 FETCHES
--                 PARSE_CALLS
--                 DISK_READS
--                 BUFFER_GETS
--                 ROWS_PROCESSED
--                 CPU_PER_EXEC	
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @topsql <column> <snapshot_seconds>
--
--              @topsql cpu_time 6
--              @topsql executions 6
--              @topsql cpu_per_exec 30
--              @topsql cpu_time,executions,buffer_gets 6
--              @topsql buffer_gets/decode(executions,0,1,executions) 6
--	        
-- Other:       You need to download and install the TPT package from
--              http://www.tanelpoder.com/files/scripts/setup/tptcreate.sql
--              before using the topsql script
--
--              Use 6 seconds or more for interval as some v$sqlstats statistics
--              for long running statements are updated roughly every 5 seconds
--
--------------------------------------------------------------------------------

prompt
prompt -- TopSQL v1.0 by Tanel Poder ( http://www.tanelpoder.com ) 
prompt 
prompt Taking a &2 second snapshot from V$SQLSTATS and ordering by &1...

col topsql_sql_text head SQL_TEXT for a50 word_wrap

col topsql_filter_clause noprint new_value topsql_filter_clause
col topsql_order_clause  noprint new_value topsql_order_clause

set termout off
with sq as (
     select regexp_replace(
                regexp_replace(
                    regexp_replace('&1', '(\(.*?)(,)(.*?\))', '\1^\3')
                    , '(\(.*?)(,)(.*?\))', '\1^\3'
                ), '(\(.*?)(,)(.*?\))', '\1^\3'
             ) param 
     from dual
)
select 
     replace(replace(param, ',', ' > 0 OR '),'^',',')   topsql_filter_clause
   , replace(replace(param, ',', ' DESC, '),'^',',')    topsql_order_clause
from
     sq
/
set termout on

with s1 as    (select /*+ NO_MERGE MATERIALIZE */ sql_id, plan_hash_value, cpu_time, elapsed_time, executions, fetches, parse_calls, disk_reads, buffer_gets, rows_processed, sql_text from v$sqlstats)
   , sleep as (select /*+ NO_MERGE MATERIALIZE */ tpt.sleep(&2) x from dual)
   , s2 as    (select /*+ NO_MERGE MATERIALIZE */ sql_id, plan_hash_value, cpu_time, elapsed_time, executions, fetches, parse_calls, disk_reads, buffer_gets, rows_processed, sql_text from v$sqlstats)
select * from (
    select
        &1
      , sql_id
      , plan_hash_value
      , topsql_sql_text
    from (
        select /*+ ORDERED */
             s2.sql_id, 
             s2.plan_hash_value, 
             s2.sql_text                            topsql_sql_text,
             s2.cpu_time     - s1.cpu_time          cpu_time,
             s2.elapsed_time - s1.elapsed_time      elapsed_time, 
             s2.executions   - s1.executions        executions, 
             (s2.cpu_time    - s1.cpu_time) / greatest(s2.executions - s1.executions,1) cpu_per_exec,  
             s2.fetches      - s1.fetches           fetches,
             s2.parse_calls  - s1.parse_calls       parse_calls,
             s2.disk_reads   - s1.disk_reads        disk_reads,
             s2.buffer_gets  - s1.buffer_gets       buffer_gets,
             s2.rows_processed - s1.rows_processed  rows_processed
        from
             s1,
             sleep,
             s2
        where
             s2.sql_id = s1.sql_id (+)
        and  s2.plan_hash_value = s1.plan_hash_value (+)
        and  sleep.x = 1
        and  s2.sql_id not in (select sql_id from v$session where sid = userenv('SID'))
    ) sq
    where
        &topsql_filter_clause > 0
    order by 
        &topsql_order_clause DESC
)
where rownum <= 10
/

col topsql_filter_clause clear
col topsql_order_clause  clear

undef topsql_filter_clause
undef topsql_order_clause

