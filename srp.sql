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

set linesize 156
set pagesize 5000
set verify off


select
	to_char(a.snaptime, 'YYYYMMDD HH24:MI:SS') snapshot_begin,
	to_char(b.snaptime, 'YYYYMMDD HH24:MI:SS') snapshot_end,
	(b.snaptime - a.snaptime)*86400 dur_sec,
	(b.snaptime - a.snaptime)*86400/60 dur_min
from
	(select snaptime from sawr$snapshots where snapid = &1) a,
	(select snaptime from sawr$snapshots where snapid = &2) b
/



-- reports all sessions wait events

col ms_per_sec head ms/|sec for 999999
col pct_per_sec head %|sec for 999999
col wait_ms head "ms in|snapshot" for 9999999999
col waits head "Waits in|snapshot" for 99999999
col event_name head "Event Name" for a45
col avgdelta head "Avg|Wait" for 990.99 justify right
col avg_wait_ms head "Avg Wait|ms" for 9999990 justify right
col AVGDLT% head "%" for a1
col %TOTAL head "% Total" for a12 justify right


break on sid skip 1 on audsid

select
	sid,
	audsid,
	'    ' " ",
	name EVENT_NAME,
	'|'||
		rpad(
			nvl(
				lpad('#',
					ceil( (nvl(round(us_per_sec/1000000,2),0))*10 ),
				'#'),
			' '),
		10,' ')
	||'|' "%TOTAL",
	round(us_per_sec/1000,3) ms_per_sec,
--	round(us_per_sec/10000,2) pct_per_sec,
	wait_us/1000 wait_ms,
--	intrvl,
	waits,
	round(wait_us/decode(waits,0,1,waits)/1000) avg_wait_ms
--	to_number(decode(avgdelta,0,null,avgdelta)) avgdlt,
--	avgdelta,
--	decode(avgdelta,0,null,'%') "AVGDLT%"
from
	sawr$sess_event_delta 
where
	begin_snapid = &1
and	end_snapid = &2
and	wait_us != 0	-- might want to remove that
order by
	sid, us_per_sec desc, wait_us desc, waits desc
/


