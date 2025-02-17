SELECT DBMS_PERF.REPORT_PERFHUB (
    is_realtime         => 0 -- 0 = dba_hist, 1 = v$ash
  , outer_start_time    => sysdate-1
  , outer_end_time      => sysdate
  , selected_start_time => TIMESTAMP'2023-05-15 20:15:00'
  , selected_end_time   => TIMESTAMP'2023-05-15 20:45:00'
  , type=>'ACTIVE'
)
FROM dual
.

SET HEADING OFF LINESIZE 32767 PAGESIZE 0 TRIMSPOOL ON TRIMOUT ON LONG 9999999 VERIFY OFF LONGCHUNKSIZE 100000 FEEDBACK OFF
SET TERMOUT OFF

spool perfhub.html
/

spool off
SET TERMOUT ON HEADING ON PAGESIZE 5000 LINESIZE 999 FEEDBACK ON 

