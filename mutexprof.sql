-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   mutexprof.sql ( Mutex sleep Profiler )
--
-- Purpose:     Display KGX mutex sleep history from v$mutex_sleep_history
--              along library cache object names protected by these mutexes.
--              Only top 20 rows are shown by default
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @mutexprof <grouping columns> <filter condition>
--
--              The main grouping (and filtering) columns are:
--
--                  id  - mutex ID (which is the object hash value for library
--                                  cache object mutexes)
--                  ts  - timestamp of mutex sleep beginning
--                  loc - code location where the waiter slept for the mutex
--                  val - mutex value (shows whether mutex was held in exclusive or
--                                     shared mode) 
--                  req - requesting session SID
--                  blk - blocking session SID
--
--              The filter condition allows filtering mutex sleep rows based on certain
--              criteria, such:
--
--                  1=1      - show all mutex sleeps (which are still in memory)
--                  blk=123  - show only these mutex sleeps where blocking sid was 123
--                  hash=2741853041 - show only these sleeps where mutex ID (KGL object hash value)
--                                    was 2741853041
--
--
--                  Its also possible to have multiple "AND" filter conditions, as long as you keep
--                  them in double quotes so that sqlplus would recognize them as one parameter
--                  
--                  For example: "name like '%DUAL%' and blk in (115,98)" 
--
-- Examples:
--
--              @mutexprof loc 1=1    
--              @mutexprof id,loc,req,blk "lower(name) like 'select%from dual%'"
--              @mutexprof loc,val blk=98
--              @mutexprof id,loc,req,blk "blk in (select sid from v$session where username = 'SYS')"
--
-- Other:       When the relevant object is aged out you will see (name not found)
--              as object_name.
--
--              On 10.2.0.1 the V$mutex_sleep_history does not have mutex_identifier
--              column externalized. In this case use X$mutex_sleep_history instead
--
--------------------------------------------------------------------------------

col msh_obj_name   head OBJECT_NAME for  a80 word_wrap
col msh_mutex_type head MUTEX_TYPE for a15 truncate
col loc   head GET_LOCATION for a33 truncate  

col mutexprof_gets   head GETS for 9999999999999
col mutexprof_sleeps head SLEEPS for 999999

col mutexprof_p2 head P2 for a16 wrap
col mutexprof_p3 head P3 for a16 wrap
col mutexprof_p4 head P4 for a16 wrap
col mutexprof_p5 head P5 for a20 wrap

def MSH_NUMROWS=10

prompt
prompt -- MutexProf by Tanel Poder (http://www.tanelpoder.com)
prompt -- Showing profile of top &MSH_NUMROWS sleeps...

select * from (
    select /*+ ORDERED USE_NL(o) */ 
      -- TODO the sleep/get counting needs fixing!
      MAX(sleeps)               sleeps
      --count(*)                sleeps
      , decode(max(sleeps)-min(sleeps),0,to_number(null),max(sleeps)-min(sleeps)) mutexprof_sleeps -- may not be very accurate but give an idea
      --, decode(max(gets)-min(gets),0,to_number(null),max(gets)-min(gets)) mutexprof_gets -- may not be very accurate but give an idea
      --  avg(sleeps)         sleeps
      --, avg(gets)           gets
      , mutex_type          msh_mutex_type
      , &1
      , nvl(decode(kglnaown, null, kglnaobj, kglnaown||'.'||kglnaobj), '(name not found)')   msh_obj_name
      --, p1raw
      --, CASE WHEN p2 < 536870912 THEN TO_CHAR(p2) ELSE TRIM(TO_CHAR(p2, 'XXXXXXXXXXXXXXXX')) END mutexprof_p2
      --, CASE WHEN p3 < 536870912 THEN TO_CHAR(p3) ELSE TRIM(TO_CHAR(p3, 'XXXXXXXXXXXXXXXX')) END mutexprof_p3
      --, CASE WHEN p4 < 536870912 THEN TO_CHAR(p4) ELSE TRIM(TO_CHAR(p4, 'XXXXXXXXXXXXXXXX')) END mutexprof_p4
      --, p5 mutexprof_p5
    from
        (select
            mutex_identifier   id
          , sleep_timestamp    ts
          , mutex_type
          , gets
          , sleeps
          , requesting_session req
          , blocking_session   blk
          , location           loc
          , mutex_value        val
          , p1
          , p1raw
          , p2
          , p3
          , p4
          , p5
         from v$mutex_sleep_history) m
      , (select kglnahsh, kglnahsh hash_value, kglnahsh hash,
                kglhdpar, kglhdadr, kglnaown, kglnaobj, 
                decode(kglnaown, null, kglnaobj, kglnaown||'.'||kglnaobj) object_name,
                decode(kglnaown, null, kglnaobj, kglnaown||'.'||kglnaobj) name 
         from x$kglob) o
    where 
        m.id = o.kglnahsh (+)
    and (o.kglhdadr = o.kglhdpar or (o.kglhdpar is null)) -- only parent KGL objects if still in cache
    and &2
    group by 
        mutex_type
      , &1
      , kglnaown
      , kglnaobj
      , p1raw
      , CASE WHEN p2 < 536870912 THEN TO_CHAR(p2) ELSE TRIM(TO_CHAR(p2, 'XXXXXXXXXXXXXXXX')) END
      , CASE WHEN p3 < 536870912 THEN TO_CHAR(p3) ELSE TRIM(TO_CHAR(p3, 'XXXXXXXXXXXXXXXX')) END
      , CASE WHEN p4 < 536870912 THEN TO_CHAR(p4) ELSE TRIM(TO_CHAR(p4, 'XXXXXXXXXXXXXXXX')) END
      --, p5
    order by
        sleeps desc
)
where rownum <= &MSH_NUMROWS
/
