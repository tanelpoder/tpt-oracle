-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select 
  distinct s.kqrstcln latch#,r.cache#,r.parameter name,r.type,r.subordinate#
from v$rowcache r,x$kqrst s, v$latch_children lc
where r.cache#=s.kqrstcid
and lc.child# = r.cache#
and lc.name = 'row cache objects'
order by 1,4,5;
