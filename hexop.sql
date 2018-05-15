-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select 
    to_char( to_number('&1', 'XXXXXXXXXXXXXXXXXX') &2 to_number('&3', 'XXXXXXXXXXXXXXXXXX'), 'XXXXXXXXXXXXXXXXXX') hex,
    to_number('&1', 'XXXXXXXXXXXXXXXXXX') &2 to_number('&3', 'XXXXXXXXXXXXXXXXXX') dec
from 
    dual
/
