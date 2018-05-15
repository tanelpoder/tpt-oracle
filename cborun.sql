-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

exec e2sn_monitor.cbo_trace_on;

def cbo_suffix ="/* cbotrace &_DATE */"

clear buffer
1 &1 &cbo_suffix
/

exec e2sn_monitor.cbo_trace_off

prompt Fetching tracefile...
set trimspool on termout off
spool &_tpt_tempdir/cbotrace_&_tpt_tempfile..txt

prompt &1 &cbo_suffix
select column_value CBO_TRACE 
from table (e2sn_monitor.get_session_trace) 
where regexp_like(column_value, '&2', 'i') or lower(column_value) like lower('&2');

spool off
set termout on

set define ^
host mvim ^_tpt_tempdir/cbotrace_^_tpt_tempfile..txt &
set define &


