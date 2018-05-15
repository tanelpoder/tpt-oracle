-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt eXplain with Profile: Running DBMS_SQLTUNE.REPORT_SQL_MONITOR for SID &1.... (11.2+)

set termout off heading off linesize 10000 trimspool on trimout on

spool &SQLPATH/tmp/xprof_&_i_inst..html

@@xprof ALL ACTIVE SESSION_ID &1

spool off

host &_start &SQLPATH/tmp/xprof_&_i_inst..html
set termout on heading on linesize 999

