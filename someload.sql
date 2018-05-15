-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Generate some load for &1 hours....

DECLARE
  j NUMBER;
  begin_date DATE := SYSDATE;
BEGIN
    WHILE TRUE LOOP
        SELECT SUM(LENGTH(TEXT)) INTO j FROM dba_source;
        DBMS_LOCK.SLEEP(60 * DBMS_RANDOM.VALUE(0,1));
    END LOOP;
END;
/

