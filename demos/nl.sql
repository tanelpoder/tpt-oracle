-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

drop table t1;
drop table t2;

create table t1 as select * from dba_users;
create table t2 as select * from dba_objects;

select /*+ ordered use_nl(t2) gather_plan_statistics */
     t1.user_id, t1.username, sum(length(t2.object_name))
from t1, t2
where t1.username = t2.owner
and t1.username = 'SYSTEM'
group by t1.user_id, t1.username
/

@x

select /*+ ordered use_nl(t2) gather_plan_statistics */
     t1.user_id, t1.username, sum(length(t2.object_name))
from t1, t2
where t1.username = t2.owner
and t1.username like 'SYS%'
group by t1.user_id, t1.username
/

@x