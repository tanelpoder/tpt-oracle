-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL process_name_ksbtabact HEAD PROCESS_NAME FOR A20

-- similar to X$MESSAGES

SELECT
    indx
  , process_name_ksbtabact      
  , action_description_ksbtabact
  , timeout_ksbtabact           
  , options_ksbtabact           
FROM
    X$KSBTABACT
WHERE
    LOWER(ACTION_DESCRIPTION_KSBTABACT) LIKE LOWER('%&1%')
OR  LOWER(PROCESS_NAME_KSBTABACT) LIKE LOWER('%&1%')
/


