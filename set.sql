-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Show SEssion Time model values for SID &1....
select stat_name, value/1000000 SEC from v$sess_time_model where sid in (&1);
