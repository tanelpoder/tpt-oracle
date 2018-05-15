-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- starting from 10g, the push_subq hint must be specified in the subquery block
-- you wish to push earlier (or with the @subq hint addressing)

select
   e.*
 , d.dname
from
   scott.emp   e
 , scott.dept  d
where
    e.deptno = d.deptno
and exists (
        select /*+ no_unnest push_subq */
            1
        from 
            scott.bonus b
        where
            b.ename = e.ename
        and b.job   = e.job
)
/

