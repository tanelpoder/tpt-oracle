-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

host " doskey /history /exename=sqlplus.exe | find /i /n "&1" | find /v "]@h " "
