-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT
    *
FROM
    v$db_object_cache 
WHERE 
    addr = HEXTORAW(LPAD('&1',16,0))
@pr

