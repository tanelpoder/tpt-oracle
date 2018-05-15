-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

PROMPT Querying V$SQL_MONITOR_STATNAME...

SELECT
    id
  , group_id 
  , CASE type
        WHEN 1 THEN 'CUMULATIVE'
        WHEN 2 THEN 'RESOURCE'
        WHEN 3 THEN 'DISCRETE_MAX'
        WHEN 4 THEN 'DISCRETE_REFMAX1'
        WHEN 5 THEN 'DISCRETE_REF1'
        WHEN 7 THEN 'DIFFERENCE'
      ELSE TO_CHAR(type)
    END stat_type
  , name
  , description
FROM
    v$sql_monitor_statname
/

