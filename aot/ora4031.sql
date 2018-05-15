-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- metalink bug 7340448
-- oracle 10.2.0.4 

drop table t;
drop table t1;
drop table t2;


create table t ( pat varchar2(10) );

begin
  for i in 1 .. 1000 loop
    insert into t values('abcdedghi');
  end loop;
end;
/

commit;

create table t1 ( pk number , val varchar2(100) );

begin
  for i in 1 .. 1000 loop
    insert into t1 values(i,'a');
  end loop;
end;
/

commit;

create table t2 as
select /*+ USE_NL(t) ordered */
    pk, val, pat
from 
    t1,t
where 
    regexp_like(val,pat)
/
