-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select
     addr
   , indx
   , '0x'||trim(to_char(indx, 'XXXX')) hexidx
   , kcbwhdes
from
     x$kcbwh
where
     lower(kcbwhdes) like lower('%&1%')
or   lower('0x'||trim(to_char(indx, 'XXXX'))) like lower('%&1%')
or   to_char(indx) like lower('%&1%')
/
