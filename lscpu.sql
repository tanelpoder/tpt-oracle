-- Copyright 2020 Tanel Poder. All rights reserved. More info at https://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms and conditions.

SHOW PARAMETER cpu_count

SELECT * FROM v$osstat
WHERE 
   stat_name LIKE 'NUM_CPU%'
OR stat_name = 'LOAD'
ORDER BY
   stat_name
/

