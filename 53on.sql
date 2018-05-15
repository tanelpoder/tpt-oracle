-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt alter session set events '10053 trace name context forever, level 1';;
prompt alter session set "_optimizer_trace"=all;;

alter session set events '10053 trace name context forever, level 1';
alter session set "_optimizer_trace"=all;
