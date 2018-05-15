-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

set termout off

column trci_cmd new_value trci_cmd 
select decode(lower('&1'),'off','''''','&1') trci_cmd from dual;
column trci_cmd clear

set termout on

alter session set tracefile_identifier = &trci_cmd;

