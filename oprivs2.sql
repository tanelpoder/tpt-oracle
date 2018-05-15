-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col grantee for a25

select grantee, owner, table_name, privilege from dba_tab_privs where upper(table_name) like upper('&1');
