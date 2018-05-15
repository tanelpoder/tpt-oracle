-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- Author:	Tanel Poder
-- Copyright:	(c) http://www.tanelpoder.com
-- 
-- Notes:	This software is provided AS IS and doesn't guarantee anything
-- 		Proofread before you execute it!
--
--------------------------------------------------------------------------------

define   grouping=&1
define start_snap=&2
define   end_snap=&3

col grouping_break noprint new_value grouping_break

set termout off
select replace('&grouping', ',', ' on ') grouping_break from dual;
set termout on

break on &grouping_break skip 1

col wait_ms 		for 9999999999
col avg_wait_ms	for 99999999.9
col ms_per_sec		for 999999.9

select
	to_char(a.snaptime, 'YYYYMMDD HH24:MI:SS') snapshot_begin,
	to_char(b.snaptime, 'YYYYMMDD HH24:MI:SS') snapshot_end,
	(b.snaptime - a.snaptime)*86400 dur_sec,
	(b.snaptime - a.snaptime)*86400/60 dur_min
from
	(select snaptime from sawr$snapshots where snapid = &2) a,
	(select snaptime from sawr$snapshots where snapid = &3) b
/


select 
	&grouping,
	substr(name,1,45)				name,
	sum(us_per_sec)/1000			ms_per_sec,
	(sum(wait_us)/decode(sum(waits),0,1,sum(waits))/1000)	avg_wait_ms,
	sum(waits)						waits,
	sum(wait_us)/1000				wait_ms,
	avg(intrvl)/1000				sec_in_snap
from (
	select
		e2.sid,
		e2.audsid,
		nvl(e1.snapid, &start_snap)	begin_snapid,
		e2.snapid							end_snapid,
		e2.username,
		e2.program,
		e2.terminal,
		e2.machine,
		e2.osuser,
		e2.process,
		e2.name,	
		round(e2.time_waited_micro - nvl(e1.time_waited_micro,0)) wait_us,
		round(
					( e2.time_waited_micro - nvl(e1.time_waited_micro,0) ) / (
						decode((e2.snaptime - nvl(e1.snaptime,(select snaptime from sawr$snapshots where snapid = &start_snap)))*86400, 0, 1,
								 (e2.snaptime - nvl(e1.snaptime,(select snaptime from sawr$snapshots where snapid = &start_snap)))*86400)
						)
		) us_per_sec,
		(e2.snaptime - nvl(e1.snaptime,(select snaptime from sawr$snapshots where snapid = &start_snap)))*86400*1000 intrvl,
		e2.total_waits - nvl(e1.total_waits,0) waits
	--	e1.average_wait avg1,
	--	e2.average_wait avg2,
	--	e2.average_wait - nvl(e1.average_wait,0) avgdelta 
	from
		( select * from sawr$sess_event where snapid = &start_snap ) e1,
		( select * from sawr$sess_event where snapid = &end_snap ) e2 
	where
			e1.audsid		(+) = e2.audsid      
	and	e1.sid			(+) = e2.sid         
	and	e1.serial#		(+) = e2.serial#     
	and	e1.logon_time	(+) = e2.logon_time  
	and 	e1.event# 		(+) = e2.event#
) sq
group by
	&grouping, name
order by
	&grouping, ms_per_sec desc
/                                        

break on _nonexistent