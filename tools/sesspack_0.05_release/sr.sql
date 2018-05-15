-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- Author:     Tanel Poder
-- Copyright:  (c) http://www.tanelpoder.com
-- 
-- Notes:      This software is provided AS IS and doesn't guarantee anything
--             Proofread before you execute it!
--
--------------------------------------------------------------------------------

set feedback off lines 200 trimspool on

define _tptmode   = normal
define grouping   = &1
define start_snap = &2
define end_snap   = &3

col wait_ms       for 9999999999
col avg_wait_ms   for 99999999.9
col ms_per_sec    for 999999.9 noprint
col pct_in_wait   head "% of|Time" for 99999.9
col module        for a30 truncate
col action        for a30 truncate
col program       for a30 truncate
col username      for a15 truncate
col osuser        for a20 truncate
col name          for a30 truncate
col machine       for a20 truncate
col histgm        for a10 truncate

col grouping_break noprint new_value grouping_break
col mandatory_name_col noprint new_value name_col
--set termout off
select replace('&grouping', ',', ' on ') as grouping_break
,      case
          when replace(lower('&grouping'), ',', ' ') like '% name %'
          or   replace(lower('&grouping'), ',', ' ') like '% name'
          or   replace(lower('&grouping'), ',', ' ') like 'name %'
          or   trim(lower('&grouping')) = 'name'
          then '--,name'
          else ',name'
       end as mandatory_name_col
from   dual;
--set termout on

break on &grouping_break skip 1


select
   to_char(a.snaptime, 'YYYYMMDD HH24:MI:SS') snapshot_begin,
   to_char(b.snaptime, 'YYYYMMDD HH24:MI:SS') snapshot_end,
   (b.snaptime - a.snaptime)*86400 dur_sec,
   (b.snaptime - a.snaptime)*86400/60 dur_min
from
   (select snaptime from sawr$snapshots where snapid = &2) a,
   (select snaptime from sawr$snapshots where snapid = &3) b
/


rem Events delta report
rem ==================================================================================

with deltas as (
        select e2.sid
        ,      nvl(e1.snapid, &start_snap)                                       as begin_snapid
        ,      e2.snapid                                                         as end_snapid
        ,      nvl(e1.snaptime, e2.logon_time)                                   as begin_snaptime
        ,      e2.snaptime                                                       as end_snaptime
        ,      greatest((e2.snaptime - nvl(e1.snaptime, e2.logon_time))*86400,1) as snap_interval
        ,      e2.audsid
        ,      e2.username
        ,      e2.program
        ,      e2.terminal
        ,      e2.machine
        ,      e2.osuser
        ,      e2.module
        ,      e2.action
        ,      substr(e2.name,1,45)                                              as name
        ,      e2.time_waited_micro - nvl(e1.time_waited_micro,0)                as wait_us
        ,      e2.total_waits - nvl(e1.total_waits,0)                            as waits
        from   sawr$sess_event e1
                  right outer join
               sawr$sess_event e2
                  on (e1.audsid     = e2.audsid
                  and e1.sid        = e2.sid 
                  and e1.serial#    = e2.serial#
                  and e1.logon_time = e2.logon_time
                  and e1.event#     = e2.event#
                  and e1.snapid     = &start_snap)
        where  e2.snapid = &end_snap
        )
,    micros as (
        select d.*
        ,      round(d.wait_us/d.snap_interval) as us_per_sec
        from   deltas d
        where  d.waits != 0
        or     d.wait_us != 0
        )
select &grouping
       &name_col
,      rpad('#',trunc(ratio_to_report(sum(wait_us)) over (partition by &grouping)*10),'#') as histgm
,      sum(us_per_sec)/1000                                                                as ms_per_sec
,      round(sum(us_per_sec)/10000,2)                                                      as pct_in_wait
,     (sum(wait_us)/decode(sum(waits),0,1,sum(waits))/1000)                                as avg_wait_ms
,      sum(wait_us)/1000                                                                   as wait_ms
,      sum(waits)                                                                          as waits
from   micros
group  by
       &grouping
       &name_col
order  by
       &grouping, ms_per_sec desc;


rem Stats delta report
rem ==================================================================================

col delta head Delta for 999999999999999
col delta_per_sec head D/sec for 999999999999.9

with deltas as (
        select s2.sid
        ,      nvl(s1.snapid, &start_snap)                                       as begin_snapid
        ,      s2.snapid                                                         as end_snapid
        ,      nvl(s1.snaptime, s2.logon_time)                                   as begin_snaptime
        ,      s2.snaptime                                                       as end_snaptime
        ,      greatest((s2.snaptime - nvl(s1.snaptime, s2.logon_time))*86400,1) as snap_interval
        ,      s2.audsid
        ,      s2.username
        ,      s2.program
        ,      s2.terminal
        ,      s2.machine
        ,      s2.osuser
        ,      s2.module
        ,      s2.action
        ,      substr(s2.name,1,45)                                              as name
        ,      s2.value - nvl(s1.value,0)                                        as delta
        from   sawr$sess_stat s1
                  right outer join
               sawr$sess_stat s2
                  on (s1.audsid     = s2.audsid
                  and s1.sid        = s2.sid 
                  and s1.serial#    = s2.serial#
                  and s1.logon_time = s2.logon_time
                  and s1.statistic# = s2.statistic#
                  and s1.snapid     = &start_snap)
        where  s2.snapid = &end_snap
        )
select &grouping
       &name_col
,      rpad('#',trunc(ratio_to_report(sum(delta)) over (partition by &grouping)*10),'#') as histgm
,      sum(delta)/avg(snap_interval)                                                     as delta_per_sec
,      sum(delta)                                                                        as delta
from   deltas
where  delta != 0
group  by
       &grouping
       &name_col
order  by
       &grouping, abs(delta) desc;
                          


break on _nonexistent
set feedback on null ""
