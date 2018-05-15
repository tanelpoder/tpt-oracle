-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select     &1 , count(*) 
from       &2 
group by   &1
order by   count(*) desc
/
