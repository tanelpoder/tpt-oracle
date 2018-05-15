-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col sqll_sql_text head SQL_TEXT word_wrap

select sql_text sqll_sql_text from v$sqltext where hash_value = &1 order by piece;