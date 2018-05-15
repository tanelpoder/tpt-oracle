-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- test case from http://forums.oracle.com/forums/thread.jspa?threadID=2228426
--
--  When I choose a high_value > 100000 the grouping query runs < 1 sec.
--  With high_value = 100000: < 1 sec
--  With high_value = 90000: < 1 sec
--  With high_value = 80000: 3 sec
--  With high_value = 70000: 9 sec
--  With high_value = 60000: 17 sec
--  With high_value = 50000: 28 sec
--  With high_value = 40000: 34 sec
--  With high_value = 30000: 47 sec
--  With high_value = 20000: 61 sec
--  With high_value = 10000: 76 sec
--  With high_value = 1: 102 sec



set verify off
undefine high_value
 
drop table test_interval_p1_&&high_value;
 
create table test_interval_p1_&high_value
  partition by range (id)
  interval (1)
  (partition test_p1 values less than (&high_value))
as
select 100000 id
     , t.*
  from all_objects t
 where 1 = 0;
 
insert into test_interval_p1_&high_value
select 100000 id
     , t.*
  from all_objects t;
 
commit;
 
-- pause
  
select id, count(*)
  from test_interval_p1_&high_value
 group by id;

