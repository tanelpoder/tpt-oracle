-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.                                                                                

/*----------------------------------------------------------------------------------------------------------------------------
Usage: get_trace <trace_file_name>
----------------------------------------------------------------------------------------------------------------------------*/

DEFINE trc_file = &1

COL trace_filename FOR A45
COL adr_home FOR A45
SELECT trace_filename, to_char(change_time, 'dd-mm-yyyy hh24:mi:ss') AS change_time, to_char(modify_time, 'dd-mm-yyyy hh24:mi:ss') AS modify_time, adr_home, con_id
FROM gv$diag_trace_file
WHERE lower(trace_filename) LIKE lower('%&trc_file%')
ORDER BY modify_time;

PROMPT
ACCEPT trc_file PROMPT 'Trace file name: '
PROMPT Getting trace file ...
SET HEAD OFF
SET FEEDBACK OFF
SET TERM OFF
@get_trace2 &trc_file
SET HEAD ON
SET FEEDBACK ON
SET TERM ON

--on Mac
host &_start $TMPDIR/&trc_file
--on Windows
--host start %TEMP%/&trc_file
PAUSE
host &_delete $TMPDIR/&trc_file
--on Windows
--host &_delete %TEMP%/&trc_file

