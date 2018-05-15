-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select name,class,version,version_outline from v$sql_hint where lower(class) like lower('%&1%');
