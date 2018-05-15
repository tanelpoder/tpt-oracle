-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

drop table t;

set echo on

create or replace function f(x in number) return number as
begin
   dbms_output.put_line('F='||to_char(x));
   return x;
end;
/

set serverout on size 1000000

select * from dual
where 
   rownum = f(2)
or rownum = f(1)
/

create table t (a, b) as select 1, 1 from dual connect by level <= 100000;
insert into t values (1,2);
commit;

@gts t

truncate table t;
insert into t values (1,2);
commit;

--exec dbms_stats.set_table_stats(user, 'T', numrows=>1000000, numblks=>10000, avgrlen=>10, no_invalidate=>false);

select * from t where b=f(2) or a=f(1);

set echo off serverout off

/

@x

