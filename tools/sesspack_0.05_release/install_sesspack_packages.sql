-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- Author:  Tanel Poder
-- Copyright:  (c) http://www.tanelpoder.com
-- 
-- Notes:   This software is provided AS IS and doesn't guarantee anything
--       Proofread before you execute it!
--
--------------------------------------------------------------------------------

create or replace package sesspack

   authid definer -- using definer authid so executing users don't have to have explicit grants on
                     -- schema and V$ objects

--   authid current_user  -- safer option, allows use of privileges granted through roles
is

   function  in_list( p_sql in varchar2 ) return sawr$SIDlist;

   function valid_stat_modes return sawr$ModeList;

   procedure snap_sidlist_internal( p_sidlist in sawr$SIDlist, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null );
   procedure snap_sidlist_internal( p_sql in varchar2, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null );

   -- snap current session
   procedure snap_me ( p_session_stats in varchar2 default 'ALL', p_snapid in number default null );
   
   -- snap session with given SID
   procedure snap_sid ( p_sid in number, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null );
   procedure snap_sid ( p_sid in varchar2, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null );

   -- snap all sessions by oracle user
   procedure snap_orauser( p_username in varchar2 default user, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null );

   -- snap all sessions by os user
   procedure snap_osuser( p_username in varchar2, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null );

   -- snap all sessions by program name (v$session.program)
   procedure snap_program( p_program in varchar2, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null );

   -- snap all sessions by terminal (v$session.terminal)
   procedure snap_terminal( p_terminal in varchar2, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null );

   -- snap all sessions by machine (v$session.machine)
   procedure snap_machine( p_machine in varchar2, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null );

   -- snap the session being served by SPID (v$process.spid)
   procedure snap_spid( p_spid in varchar2, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null );
   procedure snap_spid( p_spid in number, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null );

   -- snap all sessions by client PID (v$session.process)
   procedure snap_cpid( p_cpid in varchar2, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null );
   procedure snap_cpid( p_cpid in number, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null );
      
   -- snap all sessions
   procedure snap_all ( p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null );
   
   -- snap background sessions
   procedure snap_bg ( p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null );
   
   -- snap user sessions
   procedure snap_fg ( p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null );

   -- purge repository data
   procedure purge_data ( p_days_threshold in number default 7, p_snapid in number default null );

end sesspack;
/




create or replace package body sesspack as

--==================================================================================================================
--================================================================================================================== 
--
-- Global Variables
--
--==================================================================================================================
--==================================================================================================================

   -------------------------------------------------------------------------------------------------------------------- 
   -- g_snap_mode is inserted into sawr$snapshots table during first call to assign_snapid()
   -- the global variable is changed in the beginning of each external procedure which can be
   -- called directly. this means the directly-called procedure's g_snap_mode will be recorded
   -- to sawr$snapshots table and its values will be ignored from there on
   -------------------------------------------------------------------------------------------------------------------- 

   g_snap_mode varchar2(100) := 'Undefined';
   


--==================================================================================================================
--================================================================================================================== 
--
-- Internal Procs used by sesspack itself
--
--==================================================================================================================
--==================================================================================================================

   -------------------------------------------------------------------------------------------------------------------- 
   -- FUNCTION:   assign_snapid
   -- PURPOSE: generate new snapid if the the parent snap function is executed standalone.
   --       if its executed from proper top-level function, a snapid to use should have been 
   --       passed down from there.
   --       the reason for that is that we might need to run several different snap commands
   --       for getting a snapshot (e.g. get all sessions where USERNAME = 'SYS' and all with
   --       MODULE='HR')
   -------------------------------------------------------------------------------------------------------------------- 

   function assign_snapid (p_snapid in number, l_snap_comment varchar2 default '' ) return number
   as
      l_snapid number;
   begin
      if (p_snapid is null) then 
         -- insert a line for each distinct snapshot. primary method of entry for querying
         -- snapshot data
         --
         -- TODO: update the snapshot row with snapshot end sysdate too
         --  or put the number of milliseconds spent taking the snapshot

         select sawr$snapid_seq.nextval into l_snapid from dual;
         insert into sawr$snapshots values ( l_snapid, sysdate, user, g_snap_mode, l_snap_comment );      

         return l_snapid;
      else
         return p_snapid;
      end if;
   end assign_snapid;
   
   -------------------------------------------------------------------------------------------------------------------- 
   -- FUNCTION:   in_list
   -- PURPOSE: generic function for returning a collection of numbers from the dynamic query
   --       passed in p_sql parameter. 
   --       for example, it's used for getting list of SIDs based on dynamic query 
   --       against v$session
   -- PARAMETERS:    
   -- p_sql    : SQL text string which should return a list of session IDs (in number format)
   --       : no restriction where and how the list of SIDs is retrieved, such SIDs should
   --       : just exist in V$SESSION, otherwise nothing is sampled
   --       : for example, value can be 'select sid from v$session where username = '''APPS''''
   --       : or 'select sid from v$session where status = '''ACTIVE''' and last_call_et > 5'
   -------------------------------------------------------------------------------------------------------------------- 
   function in_list( p_sql in varchar2 ) return sawr$SIDlist
   as
      type rc is  ref cursor;
      l_cursor rc;
      l_tmp    number;
      l_data      sawr$sidlist := sawr$SIDlist();

   begin
      open l_cursor for p_sql;
      loop
      
         fetch l_cursor into l_tmp;
         exit when l_cursor%notfound;
         l_data.extend;
         l_data(l_data.count) := l_tmp;
   
      end loop;
      close l_cursor;

      return l_data;
   end in_list;  -- ( p_sql in varchar2 )

   --------------------------------------------------------------------------------------------------------------------
   -- FUNCTION:   valid_stat_modes
   -- PURPOSE: Function for returning a collection of valid snap modes as determined by
   --          the sawr$session_stat_mode table.
   --------------------------------------------------------------------------------------------------------------------
   function valid_stat_modes return sawr$ModeList is
      l_modes sawr$ModeList;
   begin
      select distinct upper(mode_id) bulk collect into l_modes
      from   sawr$session_stat_mode;
      return l_modes;
   end valid_stat_modes;

   -------------------------------------------------------------------------------------------------------------------- 
   -- FUNCTION:      snap_sidlist_internal (overloaded, p_sidlist as sawr$SIDlist type)
   --
   -- PURPOSE:    this is the low-level procedure doing the actual sampling from V$ views 
   --       and inserting the result to SAWR$ tables
   --
   -- PARAMETERS:    
   -- p_sidlist   : sawr$SIDlist collection, this is array of SIDs to be sampled from V$SESSION
   -- p_snapid : snapshot ID to be inserted into SAWR$ tables. normally this comes from
   --         parent functions, but is autogenerated when the low-level function is
   --         executed manually and by leaving p_snapid as NULL.
   -------------------------------------------------------------------------------------------------------------------- 
   procedure snap_sidlist_internal( p_sidlist in sawr$SIDlist, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null)
   as
      l_snapid number;
      l_codeloc varchar2(200) := 'SNAP_SIDLIST_INTERNAL(P_SIDLIST): BEGIN';
   begin

      -- this variable is here for easier catching of exception sources in pre-10g dbs
      l_codeloc:= 'SNAP_SIDLIST_INTERNAL(P_SIDLIST): CALL ASSIGN_SNAPID';

      -- allocate a new snapid if a global one hasn't been passed down from caller
      -- new snapid allocation inserts a line to SAWR$SNAPSHOTS table
      l_snapid := assign_snapid(p_snapid);

      ------------------------------------------------------------------------------------------------------------
      -- insert sessions matching parameter conditions into SAWR$SESSIONS table
      ------------------------------------------------------------------------------------------------------------
      l_codeloc := 'SNAP_SIDLIST_INTERNAL(P_SIDLIST): INSERT INTO SAWR$SESSIONS';
      insert into 
         sawr$sessions (
       		  snapid
				, snaptime
				, program
				, username
				, machine
				, osuser
				, terminal
				, module
				, action
				, audsid
				, sid
				, serial#
				, process
				, logon_time
      )
      select 
         	  l_snapid
         	, sysdate as snaptime
				, nvl(s.program  , '-')
				, nvl(s.username , '-')
				, nvl(s.machine  , '-')
				, nvl(s.osuser   , '-')
				, nvl(s.terminal , '-')
				, nvl(module     , '-')
				, nvl(action     , '-')
				, s.audsid
				, s.sid
				, s.serial#
				, s.process
				, s.logon_time
      from 
         v$session s 
      where
         sid in (
            select * from ( table(cast(p_sidlist as sawr$SIDlist)) )
         );


      ------------------------------------------------------------------------------------------------------------
      -- insert matching session wait events into SAWR$SESSION_EVENTS table
      ------------------------------------------------------------------------------------------------------------
      l_codeloc := 'SNAP_SIDLIST_INTERNAL(P_SIDLIST): INSERT INTO SAWR$SESSION_EVENTS';
      insert into 
         sawr$session_events (
           snapid              
  			, snaptime         
  			, audsid           
  			, sid              
  			, serial#          
  			, event#           
  			, total_waits      
  			, total_timeouts   
  			, average_wait     
  			, max_wait         
  			, time_waited_micro
		)
      select  --+ ORDERED tanel9
           l_snapid,
           sysdate as snaptime,
           s.audsid,
           e.sid,
           s.serial#,
           en.event#, 
           e.total_waits,
           e.total_timeouts,
           e.average_wait,
           e.max_wait,
--         e.time_waited_micro + ( decode(e.event||w.state, w.event||'WAITING', w.seconds_in_wait, 0) * 1000000 ) time_waited_micro
           e.time_waited_micro + NVL( CASE e.event||w.state
                                       WHEN w.event||'WAITING' THEN 
                                             CASE 
                                                WHEN w.event IN ( select event from v$system_event where total_timeouts != 0 ) THEN 0
                                                ELSE w.seconds_in_wait
                                             END
                                       ELSE 0
                                   END 
                                   * 1000000, 0 ) time_waited_micro
           
        from
           v$session s,
           v$session_event e,
           v$session_wait w,
           v$event_name en
        where
            e.sid = s.sid
        and s.sid = w.sid
        and w.sid = e.sid
        and e.event = en.name
      and   s.sid in (
            select * from ( table(cast(p_sidlist as sawr$SIDlist)) )
      );


      
      ------------------------------------------------------------------------------------------------------------
      -- insert used CPU time to session events table as well
      -- in 9i V$SESSTAT (CPU used by this session) is used
      -- from 10g V$SESS_TIME_MODEL is used as this is more accurate and is updated every 5 seconds
      -- even during database CALL
      --
      -- note that the installer script automatically comments out the irrelevant part depending on db version
      ------------------------------------------------------------------------------------------------------------

-- the line below is substituted by "/*" by sqlplus during installation onto 9i database
&version_9_enable
      
      -- 9i version for getting session CPU usage
      insert into 
         sawr$session_events (
           snapid
         , snaptime
         , audsid
         , sid
         , serial#
         , event#
         , total_waits
         , time_waited_micro
      )
      select  --+ ORDERED USE_NL(s st)
         l_snapid,
         sysdate as snaptime, 
         s.audsid, 
         s.sid,
         s.serial#,
         -1,      -- naming CPU usage as event# -1
         1,    -- setting total waits for CPU to 1 for now (this can be got from perhaps number of calls or sum(events) later on)
         st.value * 10000  -- x10000 makes microseconds out of centiseconds
      from 
         v$session s,
         v$sesstat st
      where    
         st.statistic# = (select statistic# from v$statname where name = 'CPU used by this session')
      and   s.sid = st.sid
      and   s.sid in (
            select * from ( table(cast(p_sidlist as sawr$SIDlist)) )
      );

-- end: version_9_enable
-- */ 

-- the line below is substituted by "/*" by sqlplus during installation onto 10g and above database
&version_10_enable
      
      -- 10g+ version for getting session CPU usage
      insert into 
         sawr$session_events (
           snapid
         , snaptime
         , audsid
         , sid
         , serial#
         , event#
         , total_waits
         , time_waited_micro
      )
      select  --+ ORDERED USE_NL(s st)
         l_snapid,
         sysdate as snaptime, 
         s.audsid, 
         s.sid,
         s.serial#,
         -1,      -- naming CPU usage as event# -1
         1,    -- setting total waits for CPU to 1 for now (this can be got from perhaps number of calls or sum(events) later on)
         st.value -- v$sess_time_model reports times in microseconds
      from 
         v$session s,
         v$sess_time_model st
      where    
         st.stat_name = 'DB CPU'
      and   s.sid = st.sid
      and   s.sid in (
            select * from ( table(cast(p_sidlist as sawr$SIDlist)) )
      );

-- end: version_10_enable
-- */ 

      ------------------------------------------------------------------------------------------------------------   
      -- insert matching session statistics into SAWR$SESSION_STATS table
      ------------------------------------------------------------------------------------------------------------
      l_codeloc := 'SNAP_SIDLIST_INTERNAL(P_SIDLIST): INSERT INTO SAWR$SESSION_STATS';
      insert into 
         sawr$session_stats (
             snapid
           , snaptime
           , audsid
           , sid
           , serial#
           , statistic#
           , value
      ) 
      select --+ ORDERED USE_NL(s ss) INDEX(s) tanel2
         l_snapid, 
         sysdate as snaptime, 
         s.audsid, 
         s.sid,
         s.serial#,
         ss.statistic#,
         ss.value
      from 
         v$session s,
         v$sesstat ss
      where
         s.sid = ss.sid
      and   s.sid in (
            select * from ( table(cast(p_sidlist as sawr$SIDlist)) )
      )
      and   ss.statistic# in (
         select  --+ ORDERED NO_UNNEST
            statistic# 
         from 
            sawr$session_stat_mode cfg,
            v$statname sn
         where
            sn.name = cfg.statistic_name
         and   cfg.mode_id = p_session_stats
      )
      and ss.value != 0;
   


      l_codeloc := 'SNAP_SIDLIST_INTERNAL(P_SIDLIST): END';

   exception
      when NO_DATA_FOUND then null; -- its ok to find no matches for snapshot query
      when others then raise_application_error(-20001, 'Error '||SQLCODE||': '||SQLERRM||' : FAILED AT '|| l_codeloc) ;


   end snap_sidlist_internal; -- ( p_sidlist in sawr$SIDlist )
   
   -------------------------------------------------------------------------------------------------------------------- 
   -- FUNCTION:      snap_sidlist_internal (overloaded, p_sidlist as VARCHAR2 type)
   --
   -- PURPOSE:    this is a procedure accepting any SQL which returns array of
   --       SIDs (NUMBER format) which are then used for calling the 
   --       snap_sidlist_internal sister function to extract session info
   --       from V$SESSION
   --
   -- PARAMETERS:    
   -- p_sidlist   : sawr$SIDlist collection, this is array of SIDs to be sampled from V$SESSION
   -- p_snapid : snapshot ID to be inserted into SAWR$ tables. normally this comes from
   --         parent functions, but is autogenerated when the low-level function is
   --         executed manually and by leaving p_snapid as NULL.
   -------------------------------------------------------------------------------------------------------------------- 
   procedure snap_sidlist_internal(p_sql in varchar2, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null)
   is
      l_snapid number;
   begin

      -- allocate a new snapid if a global one hasn't been passed down from caller
      l_snapid := assign_snapid(p_snapid);

      -- call the overloaded snap_sidlist_internal sister-function 
      -- which accepts sawr$SIDlist collection as a parameter
      snap_sidlist_internal( in_list(p_sql), p_session_stats, l_snapid );

   end snap_sidlist_internal; -- ( p_sql in varchar2 )


--==================================================================================================================
--================================================================================================================== 
--
-- External Procs to be executed by users
--
--==================================================================================================================
--==================================================================================================================


   -------------------------------------------------------------------------------------------------------------------- 
   -- procedure for snapping current session
   -- useful for ad-hoc instrumentation and performance diagnosis for SQL tuning
   --------------------------------------------------------------------------------------------------------------------
   procedure snap_me(p_session_stats in varchar2 default 'ALL', p_snapid in number default null) is
      pragma autonomous_transaction;
   begin
      g_snap_mode:='SNAP_ME: '||user;
      snap_sidlist_internal( 'select sid from v$mystat where rownum = 1', p_session_stats );
      commit;
   end snap_me;


   -------------------------------------------------------------------------------------------------------------------- 
   -- snap session with given SID
   -------------------------------------------------------------------------------------------------------------------- 
   procedure snap_sid ( p_sid in number, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null ) is
      pragma autonomous_transaction;
   begin
      g_snap_mode:='SNAP_SID: '||to_char(p_sid);
      snap_sidlist_internal( 'select sid from v$session where sid in ('||to_char(p_sid)||')' , p_session_stats );
      commit;
   end snap_sid;


   -------------------------------------------------------------------------------------------------------------------- 
   -- snap session with given SID
   -------------------------------------------------------------------------------------------------------------------- 
   procedure snap_sid ( p_sid in varchar2, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null ) is
      pragma autonomous_transaction;
   begin
      g_snap_mode:='SNAP_SID: '||p_sid;
      snap_sidlist_internal( 'select sid from v$session where sid in ('||p_sid||')' , p_session_stats );
      commit;
   end snap_sid;


   -------------------------------------------------------------------------------------------------------------------- 
   -- procedure for snapping all sessions
   -------------------------------------------------------------------------------------------------------------------- 
   procedure snap_all(p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null) is
      pragma autonomous_transaction;
   begin
      g_snap_mode:='SNAP_ALL:';
      snap_sidlist_internal( 'select sid from v$session' , p_session_stats );
      commit;
   end snap_all;
   

   -------------------------------------------------------------------------------------------------------------------- 
   -- procedure for snapping all BACKGROUND sessions
   -------------------------------------------------------------------------------------------------------------------- 
   procedure snap_bg(p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null) is
      pragma autonomous_transaction;
   begin
      g_snap_mode:='SNAP_BG:';
      snap_sidlist_internal( 'select sid from v$session where type = ''BACKGROUND''' , p_session_stats );
      commit;
   end snap_bg;


   -------------------------------------------------------------------------------------------------------------------- 
   -- procedure for snapping all USER sessions
   -------------------------------------------------------------------------------------------------------------------- 
   procedure snap_fg(p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null) is
      pragma autonomous_transaction;
   begin
      g_snap_mode:='SNAP_FG:';
      snap_sidlist_internal( 'select sid from v$session where type = ''USER''' , p_session_stats );
      commit;
   end snap_fg;
   

   -------------------------------------------------------------------------------------------------------------------- 
   -- procedure for snapping all sessions estabilished by specified Oracle user
   -- default value null will snap all sessions by current user
   -------------------------------------------------------------------------------------------------------------------- 
   procedure snap_orauser(p_username in varchar2 default user, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null) is
      pragma autonomous_transaction;
   begin
      g_snap_mode:='SNAP_ORAUSER: '||p_username;
      snap_sidlist_internal('select sid from v$session where username like '''|| p_username ||'''' , p_session_stats );
      commit;
   end snap_orauser;


   -------------------------------------------------------------------------------------------------------------------- 
   -- procedure for snapping all sessions estabilished by specified OS user
   -------------------------------------------------------------------------------------------------------------------- 
   procedure snap_osuser(p_username in varchar2, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null) is
      pragma autonomous_transaction;
   begin
      g_snap_mode:='SNAP_OSUSER: '||p_username;
      snap_sidlist_internal('select sid from v$session where osuser like '''|| p_username ||'''' , p_session_stats );
      commit;
   end snap_osuser;


   -------------------------------------------------------------------------------------------------------------------- 
   -- snap all sessions by program name (v$session.program)
   -------------------------------------------------------------------------------------------------------------------- 
   procedure snap_program( p_program in varchar2, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null ) is
      pragma autonomous_transaction;
   begin
      g_snap_mode:='SNAP_PROGRAM: '||p_program;
      snap_sidlist_internal('select sid from v$session where program like '''|| p_program ||'''' , p_session_stats );
      commit;
   end snap_program;
   

   -------------------------------------------------------------------------------------------------------------------- 
   -- snap all sessions by terminal (v$session.terminal)
   -------------------------------------------------------------------------------------------------------------------- 
   procedure snap_terminal( p_terminal in varchar2, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null ) is
      pragma autonomous_transaction;
   begin
      g_snap_mode:='SNAP_TERMINAL: '||p_terminal;
      snap_sidlist_internal('select sid from v$session where terminal like '''|| p_terminal ||'''' , p_session_stats );
      commit;
   end snap_terminal;


   -------------------------------------------------------------------------------------------------------------------- 
   -- snap all sessions by machine (v$session.machine)
   -------------------------------------------------------------------------------------------------------------------- 
   procedure snap_machine( p_machine in varchar2, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null ) is
      pragma autonomous_transaction;
   begin
      g_snap_mode:='SNAP_MACHINE: '||p_machine;
      snap_sidlist_internal('select sid from v$session where machine like '''|| p_machine ||'''' , p_session_stats);
      commit;
   end snap_machine;


   -------------------------------------------------------------------------------------------------------------------- 
   -- snap the session being served by SPID (v$process.spid)
   -------------------------------------------------------------------------------------------------------------------- 
   procedure snap_spid( p_spid in varchar2, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null ) is
      pragma autonomous_transaction;
   begin
      g_snap_mode:='SNAP_CPID: '||p_spid;
      snap_sidlist_internal('select sid from v$session where paddr in ( select addr from v$process where spid in ('''|| p_spid ||'''))' , p_session_stats );
      commit;
   end snap_spid;

   -------------------------------------------------------------------------------------------------------------------- 
   -- snap the session being served by SPID (v$process.spid)
   -------------------------------------------------------------------------------------------------------------------- 
   procedure snap_spid( p_spid in number, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null ) is
      pragma autonomous_transaction;
   begin
      g_snap_mode:='SNAP_CPID: '||p_spid;
      snap_sidlist_internal('select sid from v$session where paddr in ( select addr from v$process where spid in ('''|| to_char(p_spid) ||'''))' , p_session_stats );
      commit;
   end snap_spid;


   -------------------------------------------------------------------------------------------------------------------- 
   -- snap all sessions by client PID (v$session.process)
   -------------------------------------------------------------------------------------------------------------------- 
   procedure snap_cpid( p_cpid in varchar2, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null ) is
      pragma autonomous_transaction;
   begin
      g_snap_mode:='SNAP_CPID: '||p_cpid;
      snap_sidlist_internal('select sid from v$session where process in ('''|| p_cpid ||''')' , p_session_stats );
      commit;
   end snap_cpid;
   

   -------------------------------------------------------------------------------------------------------------------- 
   -- snap all sessions by client PID (v$session.process)
   -------------------------------------------------------------------------------------------------------------------- 
   procedure snap_cpid( p_cpid in number, p_session_stats in varchar2 default 'TYPICAL', p_snapid in number default null ) is
      pragma autonomous_transaction;
   begin
      g_snap_mode:='SNAP_CPID: '||to_char(p_cpid);
      snap_sidlist_internal('select sid from v$session where process in ('''|| to_char(p_cpid) ||''')' , p_session_stats );
      commit;
   end snap_cpid;
   
   --------------------------------------------------------------------------------------------------------------------
   -- purge repository data over a certain age threshold
   --------------------------------------------------------------------------------------------------------------------
   procedure purge_data ( p_days_threshold in number default 7, p_snapid in number default null ) is

      type sawr$TableList is table of varchar2(30);
      l_tables sawr$TableList := sawr$TableList('SAWR$SNAPSHOTS',
                                                'SAWR$SESSIONS',
                                                'SAWR$SESSION_EVENTS',
                                                'SAWR$SESSION_STATS');

      l_snaptime date          := trunc(sysdate)-nvl(p_days_threshold,7);
      l_codeloc  varchar2(200) := 'PURGE_DATA: BEGIN';
      l_ddl      varchar2(200);

      pragma autonomous_transaction;

   begin

      l_codeloc := 'PURGE_DATA: DELETE DATA';
      for i in 1 .. l_tables.count loop
         l_codeloc := 'PURGE_DATA: DELETE ' || l_tables(i);
         execute immediate ' delete from ' || l_tables(i) ||
                           ' where snaptime < :snaptime ' ||
                           ' and (snapid = :snapid or :snapid is null)'
         using l_snaptime, p_snapid, p_snapid;
      end loop;

      l_codeloc := 'PURGE_DATA: REBUILD_TABLES';
      for i in 1 .. l_tables.count loop

         l_ddl := case l_tables(i)
                     when 'SAWR$SNAPSHOTS'
                     then 'alter index SAWR$SNAPSHOTS_PK coalesce'
                     else 'alter table ' || l_tables(i) || ' move online'
                  end;
         l_codeloc := 'PURGE_DATA: REBUILD ' || l_tables(i);
         execute immediate l_ddl;
      end loop;

      l_codeloc := 'PURGE_DATA: END';

   exception
      when others then 
         raise_application_error(-20001, 'Error '||SQLCODE||': '||SQLERRM||' : FAILED AT '|| l_codeloc) ;
   end purge_data;

end sesspack;
/

show errors



