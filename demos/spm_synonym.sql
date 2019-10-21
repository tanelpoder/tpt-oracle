-- Copyright 2019 Tanel Poder. All rights reserved. More info at https://blog.tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- this demos that a SQL Plan Baseline will still apply, even a synonym repoints to a different table.
-- the table has to have the same name (as otherwise the plan hash value changes), but the schema
-- is not part of plan hash value.

PROMPT This script will drop some tables called "T". 
PROMPT Hit enter to continue, CTRL+C to cancel...
PAUSE 

ALTER SESSION SET optimizer_use_sql_plan_baselines=TRUE;

DROP TABLE system.t;
DROP TABLE scott.t;
DROP SYNONYM syn;

CREATE TABLE system.t AS SELECT * FROM dba_objects;
CREATE TABLE  scott.t AS SELECT * FROM system.t;

CREATE INDEX system.i ON system.t (object_id);
CREATE INDEX scott.i ON  scott.t (object_id);

EXEC DBMS_STATS.GATHER_TABLE_STATS('SYSTEM','T', cascade=>TRUE);
EXEC DBMS_STATS.GATHER_TABLE_STATS('SCOTT' ,'T', cascade=>TRUE);

-- First point SYN to system schema
CREATE SYNONYM syn FOR system.t;

SELECT COUNT(owner) FROM syn t WHERE object_id = 12345;

@x

SELECT /*+ FULL(t) */ COUNT(owner) FROM syn t WHERE object_id = 12345;

@x

@create_sql_baseline bfwpapz4cfwz2 2966233522 3v3yzqv6dp704

SELECT COUNT(owner) FROM syn t WHERE object_id = 12345;

@x

-- Then point SYN to scott schema and run the same query text
DROP SYNONYM syn;
CREATE SYNONYM syn FOR scott.t;

SELECT COUNT(owner) FROM syn t WHERE object_id = 12345;

@x

@drop_sql_baseline SQL_547b571057dbd3d4
