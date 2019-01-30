-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt eXplain the execution plan for sqlid &1 child &2....

select * from table(dbms_xplan.display_cursor('&1',CASE WHEN '&2' = '%' THEN null ELSE '&2' END,'ALLSTATS ALL +PEEKED_BINDS +PARTITION'));
