-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select 
    decode(bitand(ksuseflg,19),17,'BACKGROUND',1,'USER',2,'RECURSIVE','?') status1
  , s.* 
from 
    x$ksuse s 
where 
    &1
/
