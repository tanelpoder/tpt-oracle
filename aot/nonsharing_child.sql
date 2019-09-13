VAR n NUMBER

DECLARE 
    scn NUMBER;
BEGIN
    scn := dbms_flashback.GET_SYSTEM_CHANGE_NUMBER;
    LOOP
        SELECT COUNT(*) INTO :n FROM t AS OF SCN scn;
    END LOOP;
END;
/

