-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--prompt Running DBMS_SQLTUNE.REPORT_SQL_MONITOR for SID &3....

SET HEADING OFF

SELECT
	DBMS_SQLTUNE.REPORT_SQL_MONITOR(   
	   &3=>&4,   
	   report_level=>'&1',
	   type => '&2') as report   
FROM dual
/

SET HEADING ON

