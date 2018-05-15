-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT
    POWER(2, TRUNC(LOG(2,NULLIF(time_waited,0)))) up_to_microsec
  , COUNT(*)
  , SUM(time_waited)
  , MAX(time_waited)
FROM
    v$active_session_history a
WHERE
    a.event = 'log file sync'
GROUP BY
    POWER(2, TRUNC(LOG(2,NULLIF(time_waited,0)))) 
ORDER BY
    up_to_microsec
/

