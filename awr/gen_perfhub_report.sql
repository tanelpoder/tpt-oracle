spool perfhub.html
SELECT DBMS_PERF.REPORT_PERFHUB (
    is_realtime         => 0 -- 0 = dba_hist, 1 = v$ash
  , outer_start_time    => sysdate-1
  , outer_end_time      => sysdate
  , selected_start_time => TIMESTAMP'2022-09-13 11:00:00'
  , selected_end_time   => TIMESTAMP'2022-09-13 12:00:00'
  , type=>'ACTIVE'
)
FROM dual
/
spool
spool off
