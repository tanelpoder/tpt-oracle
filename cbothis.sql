.
-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

exec e2sn_monitor.cbo_trace_on;

9999999 /* cbotrace &_DATE */
/

exec e2sn_monitor.cbo_trace_off

prompt Fetching tracefile...
set trimspool on termout off
spool &_tpt_tempdir/cbotrace_&_tpt_tempfile..txt

list
select column_value CBO_TRACE 
from table (e2sn_monitor.get_session_trace) 
where regexp_like(column_value, '&1', 'i') or lower(column_value) like lower('&1');

spool off
set termout on

set define ^
host mvim ^_tpt_tempdir/cbotrace_^_tpt_tempfile..txt &
set define &


