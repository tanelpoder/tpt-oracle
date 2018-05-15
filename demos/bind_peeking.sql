-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   demos/bind_peeking.sql
--
-- Purpose:     Advanced Oracle Troubleshooting Seminar demo script
--
-- Author:      Tanel Poder ( http://www.tanelpoder.com )
--
-- Copyright:   (c) 2007-2009 Tanel Poder
--
--------------------------------------------------------------------------------

set echo on

drop table t;
create table t as select * from dba_objects, (select rownum from dual connect by level <= 20);
create index i on t(object_id);

exec dbms_stats.gather_table_stats(user, 'T');

select count(*), min(object_id), max(object_id) from t;

pause

var x number

exec :x := 100000

pause

set timing on

select sum(length(object_name)) from t where object_id > :x;



select * from table(dbms_xplan.display_cursor(null,null,'ALLSTATS LAST'));

pause

exec :x := 1

select sum(length(object_name)) from t where object_id > :x;



select * from table(dbms_xplan.display_cursor(null,null,'ALLSTATS LAST'));

pause

select sum(length(object_name)) from t where object_id > :x;



select * from table(dbms_xplan.display_cursor(null,null,'ALLSTATS LAST'));

set echo off
