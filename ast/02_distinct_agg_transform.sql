-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- TODO: not working yet
-- LEADING hint sets the order properly but not the ORDERED hint

drop table t1;
drop table t2;

create table t1 as select * from all_objects;
create table t2 as select * from all_objects;

create index i1 on t2(object_id);

exec dbms_stats.gather_table_stats(user,'T1');
exec dbms_stats.gather_table_stats(user,'T2');

-- ordered hint "ignored" starting from 11.2.0.1 thanks to distinct aggregation transformation

select /*+ ORDERED */ t1.owner, count(distinct t2.object_type) from t2, t1 where t1.object_id = t2.object_id group by t1.owner;
@x

select /*+ ORDERED NO_TRANSFORM_DISTINCT_AGG */ t1.owner, count(distinct t2.object_type) from t2, t1 where t1.object_id = t2.object_id group by t1.owner;
@x

