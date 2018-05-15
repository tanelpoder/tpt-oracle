-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- oracle 10.1 version (in 10.2+ use x.sql)
select * from table(dbms_xplan.display_cursor(null,null));
--select * from table(dbms_xplan.display_cursor(null,null,'RUNSTATS_LAST'));
