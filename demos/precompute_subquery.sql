-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

drop table t1;
drop table t2;

set echo on

create table t1 as select rownum a from dual connect by level < 10;
create table t2 as select rownum+10 b from dual connect by level < 10;

exec dbms_stats.gather_table_stats(user,'T1');
exec dbms_stats.gather_table_stats(user,'T2');

--alter session set events '10053 trace name context forever';
--alter session set "_optimizer_trace"=all;
--alter session set events '10046 trace name context forever, level 4';

select * from t1;

select * from t2;


select a 
from   t1
where  a in (select b from t2);

@x

select a 
from   t1
where  a in (select /*+ PRECOMPUTE_SUBQUERY */b from t2);

@x

set echo off
