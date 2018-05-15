-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col grantee for a25
col owner for a25
col table_name for a30

select grantee, granted_role, admin_option, default_role from dba_role_privs where upper(grantee) like upper('&1');

select grantee, privilege, admin_option from dba_sys_privs where upper(grantee) like upper('&1');

select grantee, owner, table_name, privilege from dba_tab_privs where upper(grantee) like upper('&1');
