-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- show which locks' id1/id2 columns have matching columns in v$session_wait/ASH

select /*+ leading(e) */
    e.name
  , lt.type
  , lt.id1_tag
  , lt.id2_tag
  , lt.description lock_description
from
    v$lock_type lt
  , v$event_name e
where 
    substr(e.name, 6,2) = lt.type
and e.parameter2 = lt.id1_tag
and e.parameter3 = lt.id2_tag
and e.name like 'enq: %'
order by
    e.name
/

