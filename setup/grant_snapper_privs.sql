-- generated using this OS command (and manually edited to remove duplicates):
-- for word in $(grep -i 'v\$' snapper.sql) ; do echo $word ; done | sort | fgrep 'v$' | sort | uniq > snapper_privs.txt

DEFINE snapper_role=SNAPPER_ROLE

CREATE ROLE &snapper_role;

GRANT SELECT ON sys.gv_$enqueue_stat TO &snapper_role;
GRANT SELECT ON sys.gv_$latch TO &snapper_role;
GRANT SELECT ON sys.gv_$lock_type TO &snapper_role;
GRANT SELECT ON sys.gv_$process TO &snapper_role;
GRANT SELECT ON sys.gv_$px_session TO &snapper_role;
GRANT SELECT ON sys.gv_$sess_time_model TO &snapper_role;
GRANT SELECT ON sys.gv_$session TO &snapper_role;
GRANT SELECT ON sys.gv_$session_event TO &snapper_role;
GRANT SELECT ON sys.gv_$session_wait TO &snapper_role;
GRANT SELECT ON sys.gv_$sesstat TO &snapper_role;
GRANT SELECT ON sys.gv_$sys_time_model TO &snapper_role;
GRANT SELECT ON sys.v_$event_name TO &snapper_role;
GRANT SELECT ON sys.v_$latchname TO &snapper_role;
GRANT SELECT ON sys.v_$mystat TO &snapper_role;
GRANT SELECT ON sys.v_$session TO &snapper_role;
GRANT SELECT ON sys.v_$statname TO &snapper_role;
GRANT SELECT ON sys.v_$version TO &snapper_role;


-- Oracle 12.2 and lower
GRANT EXECUTE ON sys.dbms_lock TO &snapper_role;

-- Oracle 18 and higher automatically use DBMS_SESSION.SLEEP which is accessible to everyone by default

