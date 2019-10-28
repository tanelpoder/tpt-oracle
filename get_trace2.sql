/*----------------------------------------------------------------------------------------------------------------------------
Usage: get_trace2 <trace_file_name>
----------------------------------------------------------------------------------------------------------------------------*/
--on Windows
--SPOOL %TEMP%/&1
--on Mac
SPOOL $TMPDIR/&1
SELECT payload 
FROM GV$diag_trace_file_contents
WHERE trace_filename = '&1'
ORDER BY line_number;
SPOOL OFF

