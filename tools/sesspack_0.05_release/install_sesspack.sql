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

spool sesspack_install.log

prompt
prompt =================================================================================
prompt
prompt Welcome to the Semi-Automatic Workload Repository installer!
prompt
prompt This script will create some SAWR tables and SESSPACK package in specified schema
prompt 
prompt Refer to README.txt for usage and further information
prompt
prompt (c) Tanel Poder http://www.tanelpoder.com
prompt
prompt =================================================================================
prompt
prompt
prompt You must be already connected to your target database as SYS or any other user
prompt who can grant privileges on some V$ objects for preparing SAWR user
prompt


-- this section is for initializing couple of "preprocessor" variables which create 
-- different PLSQL based on target database version

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
	case when db_version =  '9'    then '--' else '/*' end sesspack_v9,
	case when db_version != '9'    then '--' else '/*' end sesspack_v10
from sq;
-- end of preprocessor initialization


-- Defines for non-interactive installation
define spuser="&1"
define sppassword="&2"
define spconn="@&3"

-- Uncomment for interactive installation
--define spuser="SESSPACK"
--define spconn=""
--accept spuser default &spuser prompt "Specify the schema for SAWR and SESSPACK installation [&spuser]: "
--accept sppassword prompt "Specify the password for &spuser user: " hide
--accept spconn prompt "Enter connect string PREFIXED WITH @ if installing into remote database [&spconn]: "

@@prepare_user.sql

connect &spuser/&sppassword&spconn

@@install_sesspack_schema.sql
@@install_sesspack_packages.sql
@@install_grants_syns.sql

prompt Installation completed.
prompt Currently connected as &spuser&spconn....
prompt

spool off
