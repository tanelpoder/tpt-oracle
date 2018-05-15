-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col msh_obj_name   head OBJECT_NAME for  a60 word_wrap
col msh_obj_owner  head OBJECT_OWNER for a20 wrap
col msh_mutex_type head MUTEX_TYPE for a15 truncate
col msh_location   head GET_LOCATION for a20 truncate  

with s1 as    (
        select /*+ ORDERED USE_NL(o) */ 
            count(*)
          , sum(sleeps) sleeps
          , sum(gets)   gets
          , mutex_type  
          , location    
        --  , p1raw, p2, p3, p4, p5
          , kglnaown    
          , kglnaobj    
        from
            v$mutex_sleep_history m
          , x$kglob o
        where 
            m.mutex_identifier = o.kglnahsh (+)
        group by 
            mutex_type
          , location
        --  , p1raw, p2, p3, p4, p5
          , kglnaown
          , kglnaobj
    )
   , sleep as (select /*+ NO_MERGE MATERIALIZE */ tptsleep(&1) x from dual)
   , s2 as    (
        select /*+ ORDERED USE_NL(o) */ 
            count(*)    cnt
          , sum(sleeps) sleeps
          , sum(gets)   gets
          , mutex_type  
          , location    
        --  , p1raw, p2, p3, p4, p5
          , kglnaown    
          , kglnaobj    
        from
            v$mutex_sleep_history m
          , x$kglob o
        where 
            m.mutex_identifier = o.kglnahsh (+)
        group by 
            mutex_type
          , location
        --  , p1raw, p2, p3, p4, p5
          , kglnaown
          , kglnaobj
)
select * from (
    select
        cnt
      , sleeps
      , gets
      , 
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

