-- GRANT SELECT ON v_$process TO system;
-- GRANT SELECT ON v_$session TO system;


-- Put OS PID into v$session.client_identifier so that it'd get recorded in ASH
-- This works with dedicated sessions. With Oracle shared servers (MTS)
-- the OS PID that was used during logon will be recorded (not necessarily the
-- process ID that gets used later)

-- If you don't want to overwrite the client_identifier, you could just append
-- the ospid= string into the end of current client id.

CREATE OR REPLACE TRIGGER logon_trigger_ospid
    AFTER LOGON ON DATABASE
DECLARE
    ospid NUMBER;
BEGIN
    SELECT spid INTO ospid 
    FROM v$process 
    WHERE addr = (SELECT paddr FROM v$session WHERE sid = USERENV('sid'));

    DBMS_SESSION.SET_IDENTIFIER('ospid='||TRIM(TO_CHAR(ospid)));
END;
/

