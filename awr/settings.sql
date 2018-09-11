-- Copyright 2018 Tanel Poder. All rights reserved. More info at https://blog.tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms and conditions.

SELECT * FROM dba_hist_wr_control
@pr

PROMPT Use syntax like this to change AWR settings:
PROMPT -- EXEC SYS.DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(interval=>15, retention=>60*24*375);
