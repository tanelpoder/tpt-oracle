-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- BUG 10259620
-- https://supporthtml.oracle.com/ep/faces/secure/km/DocumentDisplay.jspx?id=10259620.8

drop table t;
create table t(c1 number, c2 number, c3 as (c1 + 2));

insert into t(c1, c2) values (1, 2);
insert into t(c1, c2) values (2, 3);
commit;

create index btix_1 on t (c2 desc);
create index btix_2 on t (c3, c2);

@sl all

select c2, c3 
from t where c2 = 3 or (c3 = 3) 
order by c2, c3;
@x

select /*+ use_concat index(t) */ c2, c3 
from t where c2 = 3 or (c3 = 3) 
order by c2, c3;
@x

