-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col sqlf_sql_fulltext head SQL_FULLTEXT for a100 word_wrap

select sql_fulltext sqlf_sql_fulltext from v$sql where sql_id like '&1';
