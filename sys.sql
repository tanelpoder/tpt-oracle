-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL sys_value HEAD "VALUE" FOR 9999999999999999999999999

select name, value sys_value from v$sysstat where lower(name) like lower('%&1%');
