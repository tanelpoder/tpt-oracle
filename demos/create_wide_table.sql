-- Copyright 2020 Tanel Poder. All rights reserved. More info at https://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

DECLARE
    cmd CLOB := 'CREATE TABLE widetable ( id NUMBER PRIMARY KEY ';
    ins CLOB := 'INSERT INTO widetable SELECT rownum';
BEGIN
    FOR x IN 1..999 LOOP
        cmd := cmd || ', col'||TRIM(TO_CHAR(x))||' VARCHAR2(10)';
        ins := ins || ', TRIM(TO_CHAR(rownum))';
    END LOOP;
    cmd := cmd || ')';
    ins := ins || ' FROM dual CONNECT BY level <= 100';
    EXECUTE IMMEDIATE cmd;
    EXECUTE IMMEDIATE ins;
END;
/

COMMIT;

-- stats with histograms
EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'WIDETABLE',method_opt=>'FOR TABLE, FOR ALL COLUMNS SIZE 254');

-- no histograms
-- EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'WIDETABLE',method_opt=>'FOR TABLE, FOR ALL COLUMNS SIZE 1');

-- EXEC sys.dbms_shared_pool.purge('SYSTEM', 'WIDETABLE', 1, 1);
