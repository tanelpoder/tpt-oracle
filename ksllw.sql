-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select 
    indx,
    trim(to_char(indx, 'XXXX')) ihex,
    ksllwnam, 
    ksllwlbl 
from x$ksllw 
where 
    lower(to_char(indx)) like lower('&1')
or  lower(trim(to_char(indx, 'XXXX'))) like lower('&1')
/