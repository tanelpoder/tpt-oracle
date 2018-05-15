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

define spuser=perfstat
define sphost=ora92
define sppass=oracle
define sysuser=sys
define syspass=oracle

connect &spuser/&sppass@&sphost

column sesspack_v9 noprint new_value version_9_enable
column sesspack_v10 noprint new_value version_10_enable

with SQ as (
	select  substr(
		substr(banner, instr(banner, 'Release ')+8),
		1,
		instr(substr(banner, instr(banner, 'Release ')+8),'.')-1
	) db_version
	from v$version 
	where rownum = 1
)
select 
	case when db_version = '9' then '--' else '/*' end sesspack_v9,
	case when db_version = '10' then '--' else '/*' end sesspack_v10
from sq;



prompt Uninstalling schema...


@@drop_sesspack_packages.sql
@@drop_sesspack_schema.sql

--connect &sysuser/&syspass@&sphost

-- @@prepare_user.sql

-- connect &spuser/oracle

prompt Installing schema...

@@install_sesspack_schema.sql
@@install_sesspack_packages.sql
@@install_grants_syns.sql

-- connect / as sysdba
