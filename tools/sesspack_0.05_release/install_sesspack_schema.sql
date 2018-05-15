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

create or replace type sawr$SIDList is table of number;
/

create or replace type sawr$ModeList is table of varchar2(30);
/

create sequence sawr$snapid_seq cache 10 order;

create table sawr$snapshots (
      snapid number, 
      snaptime date not null, 
      takenby varchar2(100) default user not null, 
      snap_mode varchar2(100) not null,
      snap_comment varchar2(4000)
);
create index sawr$snapshots_pk on sawr$snapshots ( snapid, snaptime );
alter table sawr$snapshots add constraint sawr$snapshots_pk primary key (snapid) using index sawr$snapshots_pk;

create table sawr$sessions (
        snapid                                   number        not null
      , snaptime                                 date          not null
      , program                                  varchar2(48)  not null
      , module                                   varchar2(48)  not null
      , action                                   varchar2(32)  not null
      , username                                 varchar2(30)  not null
      , machine                                  varchar2(64)  not null
      , osuser                                   varchar2(30)  not null
      , terminal                                 varchar2(30)  not null
      , audsid                                   number        not null
      , sid                                      number        not null
      , serial#                                  number        not null
      , process                                  varchar2(12)
      , logon_time                               date
      , sql_hash_value                           number
      , prev_hash_value                          number
      , client_info                              varchar2(64)
      , row_wait_obj#                            number
      , row_wait_file#                           number
      , row_wait_block#                          number
      , row_wait_row#                            number
      , last_call_et                             number
      , client_identifier                        varchar2(64)
      , constraint sawr$sessions_pk primary key (
           snapid    
         , snaptime  
         , program
         , module
         , action
         , username  
         , machine   
         , osuser    
         , terminal  
         , sid       
         , serial#   
         , audsid    
      )  -- so many PK columns and such column order is used for achieving good compressed IOT storage
)
organization index compress;

create table sawr$session_events (
       snapid                       number   
     , snaptime                     date     
     , audsid                       number   
     , sid                          number   
     , serial#                      number   
     , event#                       number   
     , total_timeouts               number   
     , total_waits                  number   
     , average_wait                 number   
     , max_wait                     number   
     , time_waited_micro            number   
     , event_id                     number
     , constraint sawr$session_events_pk primary key (
         snapid,
         snaptime,
         audsid,
         sid,
         serial#,
         event#
     )
)
organization index compress;

create table sawr$session_stats (
       snapid                       number   
     , snaptime                     date     
     , audsid                       number   
     , sid                          number   
     , serial#                      number   
     , statistic#                   number   
     , value                        number   
     , constraint sawr$session_stats_pk primary key (
         snapid,
         snaptime,
         audsid,
         sid,
         serial#,
         statistic#
     )
)
organization index compress;


---------------------------------------------------------------------------------
-- Table for V$SESSTAT sampling templates
---------------------------------------------------------------------------------

create table sawr$session_stat_mode (
   mode_id varchar(30) not null,
   statistic_name varchar2(250) not null,
   constraint sawr$session_stat_mode_pk primary key (mode_id, statistic_name)
) 
organization index;

insert into sawr$session_stat_mode 
select 
   'MINIMAL',
   name
from
   v$statname
where
   name in (
      'user calls',
      'user commits'
   )
/

insert into sawr$session_stat_mode 
select 
   'TYPICAL',
   name
from
   v$statname
where
   name in (
      'user calls',
      'user commits',
      'parse count (total)',
      'parse count (hard)',
      'execute count',
      'consistent gets',
      'db block gets'
   )
/

insert into sawr$session_stat_mode 
select 
   'DETAILED',
   name
from
   v$statname
where
   name in (
      'user calls',
      'user commits',
      'parse count (total)',
      'parse count (hard)',
      'execute count',
      'consistent gets',
      'consistent gets - examination',
      'db block gets',
      'parse time cpu',
      'parse time elapsed',
      'sorts (memory)',
      'sorts (disk)',
      'sorts (rows)',
      'transaction rollbacks',
      'user rollbacks'
   )
/

insert into sawr$session_stat_mode 
select 
   'ALL',
   name
from
   v$statname
/


commit;


-- SAWR$SESS_EVENT
-- View consolidating sessions events and values over taken snapshots

create or replace view sawr$sess_event as
   select 
      snap.snapid,   snap.snaptime,    
      s.sid,         s.audsid,         s.serial#,
      s.username,    s.program,        s.terminal, s.machine,  
      s.osuser,      s.process,        s.module,   s.action,
      en.event#,     en.name,          e.time_waited_micro, 
      e.total_waits, e.average_wait,   s.logon_time
   from 
      sawr$snapshots snap, 
      sawr$sessions s, 
      sawr$session_events e,
      (  select event#, name from v$event_name
         union all
         select -1, 'CPU Usage' from dual
      ) en
   where
      snap.snapid = s.snapid
   and   snap.snapid = e.snapid
   and   s.audsid = e.audsid
   and   s.sid = e.sid
   and   s.serial# = e.serial#
   and   en.event# = e.event#
/

-- SAWR$SESS_STAT
-- View consolidating sessions stats and values over taken snapshots

create or replace view sawr$sess_stat as
   select 
      snap.snapid,   snap.snaptime,    
      s.sid,         s.audsid,      s.serial#,
      s.username,    s.program,     s.terminal, s.machine,
      s.osuser,      s.process,     s.module,   s.action,
      sn.statistic#, sn.name,       ss.value,   s.logon_time
   from 
      sawr$snapshots snap, 
      sawr$sessions s, 
      sawr$session_stats ss,
      v$statname sn
   where
         snap.snapid = s.snapid
   and   snap.snapid = ss.snapid
   and   s.audsid = ss.audsid
   and   s.sid = ss.sid
   and   s.serial# = ss.serial#
   and   sn.statistic# = ss.statistic#
/


