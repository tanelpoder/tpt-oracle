-- generated using this OS command (and manually edited to remove duplicates):
-- for word in $(grep -i 'v\$' snapper.sql) ; do echo $word ; done | sort | fgrep 'v$' | sort | uniq > snapper_privs.txt
--
-- You have to run this script as SYS!

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


-- On Oracle 18 and higher, Snapper automatically uses DBMS_SESSION.SLEEP which is accessible to PUBLIC by default
-- On Oracle 12.2 and lower, DBMS_LOCK access is needed:
GRANT EXECUTE ON sys.dbms_lock TO &snapper_role;

-- This optional, if you want Snapepr to log its output into a tracefile instead of DBMS_OUTPUT:
-- GRANT EXECUTE ON sys.dbms_system TO &snapper_role;

-- If you granted the privileges to a role (SNAPPER_ROLE) now you can grant this role to users that need it
