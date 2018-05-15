-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- oracle 11.2
PROMPT Display top-level call names matching %&1% (Oracle 11.2+)
SELECT
    *
FROM 
    v$toplevelcall
WHERE
    UPPER(top_level_call_name) LIKE UPPER('%&1%')
/

