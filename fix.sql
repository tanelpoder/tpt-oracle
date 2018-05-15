-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT
    *
FROM
    v$session_fix_control
WHERE
    session_id = SYS_CONTEXT('userenv', 'sid')
AND (
        LOWER(description)            LIKE LOWER('%&1%')
    OR  LOWER(sql_feature)            LIKE LOWER('%&1%')
    OR  TO_CHAR(bugno)                LIKE LOWER('%&1%')
    OR  optimizer_feature_enable LIKE LOWER('%&1%')
    )
/

