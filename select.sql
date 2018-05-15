-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select
    qcsid,qcserial#,degree,req_degree,count(*)
from
    gv$px_session pxs
  , gv$session    s
where
    pxs.inst_id = s.inst_id
and pxs.qcsid   = s.sid
and pxs.
group by 
    qcsid,qcserial#,degree,req_degree 
order by count(*) desc


