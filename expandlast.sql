.
-- Copyright 2020 Tanel Poder. All rights reserved. More info at https://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL outsql FOR A100 WORD_WRAP
VAR outsql CLOB

0 c clob := q'\
0 declare

999999      \';;
999999 begin
999999     dbms_utility.expand_sql_text(c, :outsql);;
999999 end;;
/

PRINT outsql

