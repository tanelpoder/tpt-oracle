-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

col dblinks_owner head OWNER for a20
col dblinks_db_link head DB_LINK for a40
col dblinks_username head USERNAME for a20
col dblinks_host head HOST for a40

select 
	owner dblinks_owner,
	db_link dblinks_db_link,
	username dblinks_username,
	host dblinks_host,
	created
from
	dba_db_links;
