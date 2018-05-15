-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

drop table t;
exec dbms_random.seed(0);
create table t(a) tablespace users as select dbms_random.random from dual connect by level <= 10000;
create index i on t(a);
@gts t

@stat changes "update (select a from t where a < 10000) set a = a + 1"


drop table t;
exec dbms_random.seed(0);
create table t(a) tablespace users as select dbms_random.random from dual connect by level <= 10000;
create index i on t(a);
@gts t

@stat changes "update (select /*+ index(t) */ a from t where a < 10000) set a = a + 1"


drop table t;
exec dbms_random.seed(0);
create table t(a) tablespace users as select dbms_random.random from dual connect by level <= 10000 order by 1;
create index i on t(a);
@gts t

@stat changes "update (select /*+ index(t) */ a from t where a < 10000) set a = a + 1"
