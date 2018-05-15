-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

DECLARE
    cmd VARCHAR2(1000);
BEGIN
    FOR i IN (SELECT owner,table_name FROM dba_tables WHERE owner = '&1') LOOP
        cmd := 'ALTER TABLE '||i.owner||'.'||i.table_name||' INMEMORY PRIORITY LOW MEMCOMPRESS FOR QUERY LOW';
        DBMS_OUTPUT.PUT_LINE(cmd);
        EXECUTE IMMEDIATE cmd;
    END LOOP;
END;
/

