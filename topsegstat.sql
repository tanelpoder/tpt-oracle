-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col segstat_statistic_name head STATISTIC_NAME for a35
col segstat_owner FOR A25
col segstat_object_name FOR A30

SELECT * FROM (
  SELECT 
	owner          segstat_owner, 
	object_name    segstat_object_name, 
	statistic_name segstat_statistic_name,
	value 
  FROM 
	v$segment_statistics 
  WHERE 
	lower(statistic_name) LIKE lower('%&1%')
   order by value desc
)
WHERE rownum <= 40
/
