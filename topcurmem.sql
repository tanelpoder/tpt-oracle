-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT * FROM (
    SELECT
        sharable_mem, sql_id, hash_value, SUBSTR(sql_text,1,100) sql_text_partial
    FROM
        v$sql
    ORDER BY
        sharable_mem DESC
)
WHERE rownum <= 20
/

