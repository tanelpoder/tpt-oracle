-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   demos/drop_logmine.sql
--
-- Purpose:     Advanced Oracle Troubleshooting Seminar demo script
--
--              A logminer demo script showing logged DDL statement texts
--
-- Author:      Tanel Poder ( http://www.tanelpoder.com )
--
-- Copyright:   (c) 2007-2009 Tanel Poder
--
--------------------------------------------------------------------------------

@ti

--alter session set events '1349 trace name context forever, level 131071';

set echo on

create table tanel_drop_test( a int ) enable supplemental log data (all) columns;

--insert into t select rownum from dba_objects where rownum <= 25000;

alter system switch logfile;

connect tanel/oracle@lin11g

col member new_value member
col sequence# new_value sequence
select member from v$logfile where group# = (select group# from v$log where status = 'CURRENT');
select to_char(sequence#) sequence# from v$log where status = 'CURRENT';

prompt drop /* tanel_blah_&sequence */ table tanel_drop_test purge;;
drop /* tanel_blah_&sequence */ table tanel_drop_test purge;

delete from TANEL_DEL_TEST where rownum <= 1;
--delete from TANEL_DEL_TEST where rownum <= 1000;
commit;


@date 

select 
    sid
  , serial#
  , audsid
  , '0x'||trim(to_char(sid, 'XXXX')) "0xSID"
  , '0x'||trim(to_char(serial#, 'XXXXXXXX')) "0xSERIAL"
  , '0x'||trim(to_char(audsid, 'XXXXXXXX')) "0xAUDSID"
from
    v$session
where
    sid = userenv('SID')
/

connect tanel/oracle@lin11g

alter system switch logfile;

alter system dump logfile '&member';

set echo off

@minelog &member

select * from v$logmnr_contents where table_name = 'TANEL_DROP_TEST' and rbasqn = &sequence
.

@pr

select * from v$logmnr_contents where table_name = 'TANEL_DEL_TEST' or table_name like '%80184%' and rbasqn = &sequence
.

@pr

col member clear
col sequence# clear


alter system checkpoint;

host pscp oracle@linux03:&member c:\tmp\ddl.log
