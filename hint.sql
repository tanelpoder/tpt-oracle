-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

select name,version,version_outline,inverse from v$sql_hint where lower(name) like lower('%&1%');
