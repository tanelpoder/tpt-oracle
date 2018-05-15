-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- Make sure that the USERS tablespace is ASSM-managed
DROP TABLE t;
CREATE TABLE t(a CHAR(100)) TABLESPACE users;

INSERT INTO t SELECT 'x' FROM dual CONNECT BY LEVEL <= 5000000;

COMMIT;

ALTER SESSION SET plsql_optimize_level = 0;

-- EXEC FOR i IN 1..1000 LOOP INSERT INTO t VALUES ('x'); END LOOP;

PROMPT Deleting all rows from t, do not commit...

DELETE t;

PROMPT Run this in another session, this should be very slow:
PROMPT   EXEC FOR i IN 1..1000 LOOP INSERT INTO t VALUES ('x'); END LOOP;;
PROMPT
