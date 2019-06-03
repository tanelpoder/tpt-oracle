-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT * FROM TABLE(SELECT DBMS_XPLAN.DISPLAY_CURSOR(sql_id,sql_child_number,'+PEEKED_BINDS +PARALLEL +PARTITION ALLSTATS LAST') FROM v$session WHERE sid IN (&1));
