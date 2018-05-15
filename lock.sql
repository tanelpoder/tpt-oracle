-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col lock_mode_held head MODE_HELD for a15
col lock_mode_reqd head MODE_REQUESTED for a15
col lock_lock_id1  head LOCK_ID1 for a10
col lock_lock_id2  head LOCK_ID2 for a10
col lock_sid       head SID for 999999

select 
    sid  lock_sid,
    type,
    lmode,
decode(lmode,
    0, 'None',           
    1, 'Null',           
    2, 'Row-S (SS)',     
    3, 'Row-X (SX)',     
    4, 'Share',          
    5, 'S/Row-X (SSX)',  
    6, 'Exclusive',      
to_char(lmode))             lock_mode_held,
    request,
decode(request,
    0, 'None',           
    1, 'Null',           
    2, 'Row-S (SS)',     
    3, 'Row-X (SX)',     
    4, 'Share',          
    5, 'S/Row-X (SSX)',  
    6, 'Exclusive',      
to_char(request))           lock_mode_reqd,
to_char(id1)                lock_lock_id1, 
to_char(id2)                lock_lock_id2,
ctime,
block
from
    v$lock
where &1
/
