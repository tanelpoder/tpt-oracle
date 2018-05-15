-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

DROP TABLE t;

CREATE TABLE t AS SELECT * FROM dba_objects;

SELECT
     MIN(created)
  , MAX(created)
  , ROUND(MAX(created)-MIN(created)) range_days
  , COUNT(*) num_rows
  , COUNT(*) / ROUND(MAX(created)-MIN(created)) rows_per_day
  , SUM(NVL2(created,0,1)) nulls 
FROM 
    t
/

EXEC DBMS_STATS.GATHER_TABLE_STATS(user, 'T', method_opt=>'FOR TABLE', no_invalidate=>FALSE);

-- SELECT * FROM t WHERE created > SYSDATE - 1;
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null,'+PEEKED_BINDS'));
-- 
-- SELECT * FROM t WHERE created > SYSDATE;
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null,'+PEEKED_BINDS'));
-- 
-- SELECT * FROM t WHERE created > SYSDATE + 1;
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null,'+PEEKED_BINDS'));
-- 
-- SELECT * FROM t WHERE created > SYSDATE + 10;
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null,'+PEEKED_BINDS'));
-- 
-- SELECT * FROM t WHERE created > SYSDATE + 100;
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null,'+PEEKED_BINDS'));

-- SELECT * FROM t WHERE created > DATE'2012-09-01';
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null,'+PEEKED_BINDS'));

SELECT * FROM t WHERE created < DATE'2010-10-01';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null,'+PEEKED_BINDS'));



EXEC DBMS_STATS.GATHER_TABLE_STATS(user, 'T', method_opt=>'FOR TABLE FOR ALL COLUMNS SIZE 254', no_invalidate=>FALSE);

-- SELECT * FROM t WHERE created > SYSDATE - 1;
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null,'+PEEKED_BINDS'));
-- 
-- SELECT * FROM t WHERE created > SYSDATE;
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null,'+PEEKED_BINDS'));
-- 
-- SELECT * FROM t WHERE created > SYSDATE + 1;
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null,'+PEEKED_BINDS'));
-- 
-- SELECT * FROM t WHERE created > SYSDATE + 10;
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null,'+PEEKED_BINDS'));
-- 
-- SELECT * FROM t WHERE created > SYSDATE + 100;
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null,'+PEEKED_BINDS'));

-- SELECT * FROM t WHERE created > DATE'2012-09-01';
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null,'+PEEKED_BINDS'));

SELECT * FROM t WHERE created < DATE'2010-10-01';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null,'+PEEKED_BINDS'));


