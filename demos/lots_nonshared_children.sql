-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

DROP TABLE t;
CREATE TABLE t AS SELECT * FROM dual;
INSERT INTO t VALUES ('Y');
COMMIT;

PROMPT Sleeping for 3 seconds...
EXEC DBMS_LOCK.SLEEP(5);

PROMPT Running...
DECLARE
    j NUMBER;
    t NUMBER := 0;
    curscn NUMBER;
BEGIN
    SELECT current_scn INTO curscn FROM v$database;
    FOR i IN 1..1000 LOOP
        EXECUTE IMMEDIATE 'select count(*) from t as of scn '||curscn INTO j;
        t := t + j; 
        DBMS_OUTPUT.PUT_LINE(j);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(t);
END;
/

@topcur

