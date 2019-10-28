-- Copyright 2019 Tanel Poder. All rights reserved. More info at https://blog.tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms and conditions.

PROMPT Show PGA manager stats from V$PGASTAT

SELECT
    name
  , CASE WHEN unit = 'bytes' THEN ROUND(value/1048576) ELSE value END value
  , CASE WHEN unit = 'bytes' THEN 'megabytes' ELSE unit END unit
  -- , value
  -- , unit
FROM v$pgastat
/

