-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt eXplain with Profile: Running DBMS_SQLTUNE.REPORT_SQL_MONITOR for SQL_ID &1.... (11.2+)

SET TERMOUT OFF
SPOOL &SQLPATH/tmp/xprof_&_i_inst..html

@@xprof ALL ACTIVE SQL_ID "'&1'"

SPOOL OFF
HOST &_start &SQLPATH/tmp/xprof_&_i_inst..html
SET TERMOUT ON

