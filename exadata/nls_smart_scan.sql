-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SET ECHO ON

-- DROP TABLE t;
-- CREATE TABLE t AS SELECT a.* FROM dba_objects a, dba_objects b WHERE rownum <= 10000000;
-- EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'T');

SET TIMING ON

SELECT /* test 1 */ SUM(LENGTH(owner)) FROM t WHERE owner > 'S';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR);

ALTER SESSION SET nls_comp = LINGUISTIC;
ALTER SESSION SET nls_sort = BINARY_CI;

SELECT /* test 2 */ SUM(LENGTH(owner)) FROM t WHERE owner > 'S';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR);

-- ALTER SESSION SET "_cursor_plan_hash_version"=2;
-- 
-- SELECT /* test 3 */ SUM(LENGTH(owner)) FROM t WHERE owner > 'S';
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR);
-- 
-- ALTER SESSION SET nls_comp = BINARY;
-- ALTER SESSION SET nls_sort = BINARY;
-- 
-- SELECT /* test 4 */ SUM(LENGTH(owner)) FROM t WHERE owner > 'S';
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR);


SET ECHO OFF

