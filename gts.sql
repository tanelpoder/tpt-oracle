-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Gather Table Statistics for table &1....
exec dbms_stats.gather_table_stats(user, upper('&1'), null, method_opt=>'FOR TABLE FOR ALL COLUMNS SIZE REPEAT', cascade=>true, no_invalidate=>false);

