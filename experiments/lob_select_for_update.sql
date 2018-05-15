-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

DROP TABLE tlob;
CREATE TABLE tlob (a INT, b CLOB);

INSERT INTO tlob VALUES(1, LPAD('x',2048,'x'));
UPDATE tlob SET b = b||b;
UPDATE tlob SET b = b||b;
UPDATE tlob SET b = b||b;
UPDATE tlob SET b = b||b;
UPDATE tlob SET b = b||b;
UPDATE tlob SET b = b||b;
UPDATE tlob SET b = b||b;
UPDATE tlob SET b = b||b;
UPDATE tlob SET b = b||b;

COMMIT;

SELECT DBMS_LOB.GETLENGTH(b) FROM tlob;

DROP TABLE tdummy;
CREATE table tdummy AS SELECT * FROM all_objects;

DELETE tdummy; 

ALTER SYSTEM CHECKPOINT;
ALTER SYSTEM SWITCH LOGFILE;

SELECT * FROM tlob WHERE a=1 FOR UPDATE;
COMMIT;

@log

ALTER SYSTEM SWITCH LOGFILE;

