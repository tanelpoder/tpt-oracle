-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- Name:      i.sql
-- Purpose:   the Who am I script (also sets terminal title)
--
-- Author:    Tanel Poder
-- Copyright: (c) http://blog.tanelpoder.com
-- 
-- Other:     Some settings client OS specific (search for title)
--
--------------------------------------------------------------------------------

def   mysid="NA"
def _i_spid="NA"
def _i_cpid="NA"
def _i_opid="NA"
def _i_serial="NA"
def _i_inst="NA"
def _i_host="NA"
def _i_user="&_user"
def _i_conn="&_connect_identifier"

col i_username head USERNAME for a20
col i_sid head SID for a5 new_value mysid
col i_serial head SERIAL# for a8 new_value _i_serial
col i_cpid head CPID for a15 new_value _i_cpid
col i_spid head SPID for a10 new_value _i_spid
col i_opid head OPID for a5 new_value _i_opid
col i_host_name head HOST_NAME for a25 new_value _i_host truncate
--col i_instance_name head CON@INST_NAME for a20 new_value _i_inst
col i_instance_name head INST_NAME for a20 new_value _i_inst
col i_ver head VERSION for a10
col i_startup_day head STARTED for a8
col _i_user noprint new_value _i_user
col _i_conn noprint new_value _i_conn
col i_myoraver noprint new_value myoraver

select 
	s.username			i_username, 
--  i.instance_name i_instance_name,
  (CASE SUBSTR(i.version, 1, instr(i.version,'.',1)-1) WHEN '12' THEN (SELECT SYS_CONTEXT('userenv', 'con_name') FROM dual)||'-'||i.instance_name ELSE i.instance_name END) i_instance_name,
	i.host_name			i_host_name, 
	to_char(s.sid) 			i_sid, 
	to_char(s.serial#)		i_serial, 
	(select substr(banner, instr(banner, 'Release ')+8,10) from v$version where rownum = 1) i_ver,
	(select  substr(substr(banner, instr(banner, 'Release ')+8),
	 		1,
			instr(substr(banner, instr(banner, 'Release ')+8),'.')-1)
	 from v$version 
	 where rownum = 1) i_myoraver,
	to_char(startup_time, 'YYYYMMDD') i_startup_day, 
	trim(p.spid)	i_spid, 
	trim(to_char(p.pid))		i_opid, 
	s.process			i_cpid, 
	s.saddr				saddr, 
	p.addr				paddr,
	lower(s.username) "_i_user",
	upper('&_connect_identifier') "_i_conn"
from 
	v$session s, 
	v$instance i, 
	v$process p
where 
	s.paddr = p.addr
and 
	sid = (select sid from v$mystat where rownum = 1);

-- Windows CMD.exe specific stuff

--host title &_i_user@&_i_conn [sid=&mysid ser#=&_i_serial spid=&_i_spid inst=&_i_inst host=&_i_host cpid=&_i_cpid opid=&_i_opid]
--host doskey /exename=sqlplus.exe desc=set lines 80 sqlprompt ""$Tdescribe $*$Tset lines 299 sqlprompt "SQL> "

-- short xterm title
host echo -ne "\033]0;&_i_user@&_i_inst &mysid[&_i_spid]\007"
-- long xterm title
--host echo -ne "\033]0;host=&_i_host inst=&_i_inst sid=&mysid ser#=&_i_serial spid=&_i_spid cpid=&_i_cpid opid=&_i_opid\007"


def myopid=&_i_opid
def myspid=&_i_spid
def mycpid=&_i_cpid

-- undef _i_spid _i_inst _i_host _i_user _i_conn _i_cpid

