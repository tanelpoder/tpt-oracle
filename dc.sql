-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col table_name for a30
col column_name for a30
col comments for a60

select table_name, column_name, comments
from dict_columns
where column_name like '%&1%'
order by table_name, column_name
/
