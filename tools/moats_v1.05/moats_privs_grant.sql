-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.


set pause on

define moats_priv_target = &moats_priv_target;

prompt
prompt
prompt **************************************************************************
prompt **************************************************************************
prompt
prompt    MOATS Installer: Privileges
prompt    ===========================
prompt
prompt    This will grant required privileges to &moats_priv_target..
prompt
prompt    To continue press Enter. To quit press Ctrl-C.
prompt
prompt    (c) oracle-developer.net, www.e2sn.com
prompt
prompt **************************************************************************
prompt **************************************************************************
prompt
prompt

pause

grant create view to &moats_priv_target;
grant create type to &moats_priv_target;
grant create table to &moats_priv_target;
grant create procedure to &moats_priv_target;
grant execute on dbms_lock to &moats_priv_target;
grant select on v_$session to &moats_priv_target;
grant select on v_$statname to &moats_priv_target;
grant select on v_$sysstat to &moats_priv_target;
grant select on v_$latch to &moats_priv_target;
grant select on v_$timer to &moats_priv_target;
grant select on v_$sql to &moats_priv_target;

undefine moats_priv_target;

set pause off
