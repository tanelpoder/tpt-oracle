-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col username for a25
col default_Tablespace for a25
col temp_tablespace for a20

prompt Show database usernames from dba_users matching %&1%

select 
	username, 
	default_tablespace, 
	temporary_tablespace, 
	user_id,
	created,
  account_status,
	profile
from 
	dba_users 
where 
	upper(username) like upper('%&1%');
