-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_AWR('&1', CASE WHEN '&2' = '%' THEN null ELSE '&2' END, format=>'+PEEKED_BINDS'));
