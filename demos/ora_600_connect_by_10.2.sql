-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

alter session set "_old_connect_by_enabled"=true;
select 1 from dual connect by level < 2;

