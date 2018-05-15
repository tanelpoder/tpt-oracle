-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select 
/*+
  no_unnest(@my_sub)
  leading  (@my_sub emp_inner@my_sub)
  use_merge (@my_sub dept_inner@my_sub)
*/
   *
from 
   scott.emp emp_outer
where 
   emp_outer.deptno in (
       select /*+ qb_name(my_sub) */
           dept_inner.deptno
       from 
           scott.dept dept_inner
         , scott.emp  emp_inner
       where 
           dept_inner.dname like 'S%'
       and emp_inner.ename   = dept_inner.dname
       and dept_inner.deptno = emp_outer.deptno
   )
/
