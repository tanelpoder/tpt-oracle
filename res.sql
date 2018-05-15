-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Show reserved words matching %&1% from V$RESERVED_WORDS....
select keyword, reserved, res_type, res_attr, res_semi, duplicate 
from v$reserved_words 
where lower(keyword) like lower('%&1%')
/
