-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- Author:	Tanel Poder
-- Copyright:	(c) http://www.tanelpoder.com
-- 
-- Notes:	This software is provided AS IS and doesn't guarantee anything
-- 		Proofread before you execute it!
--
--------------------------------------------------------------------------------

-- whenever sqlerror exit 1 rollback
set verify off

-- create sesspack roles
create role sesspack_user_role;
create role sesspack_admin_role;

-- grant the roles to sesspack schema holder
grant sesspack_user_role to &spuser with admin option;
grant sesspack_user_role  to sesspack_admin_role;
grant sesspack_admin_role to &spuser with admin option;

-- two additional privs to sesspack owner to avoid ORA-01720
grant select on sys.v_$event_name to &spuser with grant option;
grant select on sys.v_$statname to &spuser with grant option;

-- grant privs required for taking and scheduling snapshots
grant select on sys.v_$mystat to sesspack_user_role;
grant select on sys.v_$session to sesspack_user_role;
grant select on sys.v_$session_wait to sesspack_user_role;
grant select on sys.v_$session_event to sesspack_user_role;
grant select on sys.v_$system_event to sesspack_user_role;
grant select on sys.v_$sess_time_model to sesspack_user_role;
grant select on sys.v_$sesstat to sesspack_user_role;
grant select on sys.v_$event_name to sesspack_user_role;
grant select on sys.v_$statname to sesspack_user_role;
grant execute on sys.dbms_job to &spuser;
-- for 10g
grant create job to &spuser;

grant create table to &spuser;
grant create view to &spuser;
grant create type to &spuser;
grant create procedure to &spuser;
grant create public synonym to &spuser;

grant select on sys.v_$mystat to &spuser;
grant select on sys.v_$session to &spuser;
grant select on sys.v_$session_wait to &spuser;
grant select on sys.v_$session_event to &spuser;
grant select on sys.v_$system_event to &spuser;
grant select on sys.v_$sess_time_model to &spuser;
grant select on sys.v_$sesstat to &spuser;
grant select on sys.v_$event_name to &spuser;
grant select on sys.v_$statname to &spuser;

set verify on
whenever sqlerror continue