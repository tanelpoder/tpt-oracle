-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col hp_addrlen new_value _hp_addrlen

set termout off
select vsize(addr)*2 hp_addrlen from x$dual;
set termout on

select * from x$ksmhp where KSMCHDS = hextoraw(lpad('&1', &_hp_addrlen, '0'));