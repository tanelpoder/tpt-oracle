-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT
    group_number
  , disk_number
  , mount_status
  , state
  , redundancy
  , library
  , total_mb
  , free_mb
  , name
  , path
  , product
  , create_date
FROM
    v$asm_disk
WHERE
    UPPER(name) LIKE UPPER('%&1%')
ORDER BY
    group_number
  , disk_number
/

