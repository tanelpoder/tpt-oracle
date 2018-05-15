-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col len_hex for a20

select 
    length('&1') len_dec 
  , '0x'||trim(to_char(length('&1'), 'XXXXXXXXXXXXXXXX')) len_hex 
from dual
/
