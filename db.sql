-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col db_scn for 99999999999999999 head SCN

select 
    dbid
  , name
  , log_mode
  , open_mode
  , current_scn db_scn
  , '0x'||trim(to_char(current_scn,'XXXXXXXXXXXXXX')) hex_scn 
  , platform_name
from 
    v$database
/

