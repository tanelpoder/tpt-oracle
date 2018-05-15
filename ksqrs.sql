-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col ksqrs_addrlen new_value ksqrs_addrlen

set termout off
select vsize(addr)*2 ksqrs_addrlen from x$dual;
set termout on

select * from x$ksqrs where addr = hextoraw(lpad(upper('&1'), &ksqrs_addrlen, '0'));