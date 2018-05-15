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

-- add on script for pre-10g databases which need to record CPU usage
-- for long-running calls (as 9i doesnt update session cpu usage in 
-- v$ views before end of call)
--
-- this script needs tidying up
--


-- rm /tmp/sawr_vmstat_pipe
-- rm /tmp/sawr_ps_pipe

-- mknod /tmp/sawr_vmstat_pipe p
-- mknod /tmp/sawr_ps_pipe p

-- create directory osstat as 'c:/tmp';
-- drop directory sawr$osstat;

create directory sawr$osstat as '/tmp';

grant read,write on directory sawr$osstat to &spuser;


drop table vmstat;
drop table ps;

CREATE TABLE sawr$ext_vmstat (
	value number,
	parameter varchar2(100)
)
ORGANIZATION EXTERNAL (
  TYPE oracle_loader
  DEFAULT DIRECTORY sawr$osstat
    ACCESS PARAMETERS (
    FIELDS TERMINATED BY ';'
    MISSING FIELD VALUES ARE NULL
    (value, parameter)
    )
    LOCATION ('sawr_vmstat_pipe')
  )
;

CREATE TABLE sawr$ext_ps (
	ospid varchar2(100),
	value varchar2(100)
)
ORGANIZATION EXTERNAL (
  TYPE oracle_loader
  DEFAULT DIRECTORY sawr$osstat
    ACCESS PARAMETERS (
    FIELDS TERMINATED BY ';'
    MISSING FIELD VALUES ARE NULL
    (ospid, value)
    )
    LOCATION ('sawr_ps_pipe')
  )
;

