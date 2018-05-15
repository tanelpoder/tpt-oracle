-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- count(columnX) is slower than count(*) or count(1)

drop table t;
create table t cache as select * from v$session;
insert into t select * from t;
insert into t select * from t;
insert into t select * from t;
insert into t select * from t;
insert into t select * from t;
insert into t select * from t;
insert into t select * from t;
insert into t select * from t;
insert into t select * from t;
insert /*+ append */ into t select * from t;
commit;
insert /*+ append */ into t select * from t;
commit;
insert /*+ append */ into t select * from t;
commit;
insert /*+ append */ into t select * from t;
commit;
insert /*+ append */ into t select * from t;
commit;
insert /*+ append */ into t select * from t;
commit;

exec dbms_stats.gather_table_stats(user, 'T');

-- to get better rowsource level timing accuracy
alter session set "_rowsource_statistics_sampfreq"=1;

select /*+ gather_plan_statistics */ count(*) from t;

set timing on

select /*+ gather_plan_statistics */ count(*) from t;
select * from table(dbms_xplan.display_cursor(null,null,'ALLSTATS LAST'));

select /*+ gather_plan_statistics */ count(1) from t;
select * from table(dbms_xplan.display_cursor(null,null,'ALLSTATS LAST'));

select /*+ gather_plan_statistics */ count(sid) from t;
select * from table(dbms_xplan.display_cursor(null,null,'ALLSTATS LAST'));

select /*+ gather_plan_statistics */ count(state) from t;
select * from table(dbms_xplan.display_cursor(null,null,'ALLSTATS LAST'));

-- set back to default
alter session set "_rowsource_statistics_sampfreq"=128;
