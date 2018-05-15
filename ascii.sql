-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select
    r*4+0, chr(r*4+0),
    r*4+1, chr(r*4+1),
    r*4+2, chr(r*4+2),
    r*4+3, chr(r*4+3)
from (
    select
        rownum-1 r
    from 
        dual connect by level <=64
)
/
