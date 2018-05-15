-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   demos/kghupr1.sql
--
-- Purpose:     Advanced Oracle Troubleshooting Seminar demo script
--
-- Author:      Tanel Poder ( http://www.tanelpoder.com )
--
-- Copyright:   (c) 2007-2009 Tanel Poder
--
--------------------------------------------------------------------------------

col laddr new_value laddr
col wordsize new_value wordsize

alter system flush shared_pool;

select addr laddr, vsize(addr) wordsize 
from   v$latch_children 
where  gets + immediate_gets >= (
               select max(gets+immediate_gets)
               from v$latch_children
               where name = 'shared pool'
)
and name = 'shared pool'
/

-- oradebug watch 0x&laddr &wordsize self

alter session set session_cached_cursors = 0;
alter session set "_close_cached_open_cursors"=true;

prompt Running lots of soft parses. Use latchprofx on my SID in another session

declare
    x number;
begin
    for i in 1..10000000 loop
    	execute immediate 'select count(*) from dual where rownum = 1';
    end loop;
end;
/

col laddr clear
col wordsize clear