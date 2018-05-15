-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- small tables

-- EXEC EXECUTE IMMEDIATE 'drop table t_hcc_query_low';    EXCEPTION WHEN OTHERS THEN NULL;
-- EXEC EXECUTE IMMEDIATE 'drop table t_hcc_query_high';   EXCEPTION WHEN OTHERS THEN NULL;
-- EXEC EXECUTE IMMEDIATE 'drop table t_hcc_archive_low';  EXCEPTION WHEN OTHERS THEN NULL;
-- EXEC EXECUTE IMMEDIATE 'drop table t_hcc_archive_high'; EXCEPTION WHEN OTHERS THEN NULL;
-- 
-- CREATE TABLE t_hcc_query_low    COMPRESS FOR QUERY LOW AS SELECT * FROM dba_source;
-- CREATE TABLE t_hcc_query_high   COMPRESS FOR QUERY HIGH AS SELECT * FROM dba_source;
-- CREATE TABLE t_hcc_archive_low  COMPRESS FOR ARCHIVE LOW AS SELECT * FROM dba_source;
-- CREATE TABLE t_hcc_archive_high COMPRESS FOR ARCHIVE HIGH AS SELECT * FROM dba_source;

-- large tables

-- EXEC EXECUTE IMMEDIATE 'drop table t_hcc_query_low';    EXCEPTION WHEN OTHERS THEN NULL;
-- EXEC EXECUTE IMMEDIATE 'drop table t_hcc_query_high';   EXCEPTION WHEN OTHERS THEN NULL;
-- EXEC EXECUTE IMMEDIATE 'drop table t_hcc_archive_low';  EXCEPTION WHEN OTHERS THEN NULL;
-- EXEC EXECUTE IMMEDIATE 'drop table t_hcc_archive_high'; EXCEPTION WHEN OTHERS THEN NULL;
-- 
-- CREATE TABLE t_hcc_query_low    COMPRESS FOR QUERY LOW AS SELECT * FROM dba_objects, (SELECT 'x' text FROM dual CONNECT BY LEVEL <=10);
-- CREATE TABLE t_hcc_query_high   COMPRESS FOR QUERY HIGH AS SELECT * FROM dba_objects, (SELECT 'x' text FROM dual CONNECT BY LEVEL <=10);
-- CREATE TABLE t_hcc_archive_low  COMPRESS FOR ARCHIVE LOW AS SELECT * FROM dba_objects, (SELECT 'x' text FROM dual CONNECT BY LEVEL <=10);
-- CREATE TABLE t_hcc_archive_high COMPRESS FOR ARCHIVE HIGH AS SELECT * FROM dba_objects, (SELECT 'x' text FROM dual CONNECT BY LEVEL <=10);

EXEC exatest.snap

SELECT SUM(LENGTH(text)) query_low FROM t_hcc_query_low;
SELECT * FROM TABLE(exatest.diff('EHCC.*'));
--SELECT * FROM TABLE(exatest.diff('EHCC CUs Decompressed|EHCC.*Length Decompressed'));

SELECT SUM(LENGTH(text)) query_high FROM t_hcc_query_high;
SELECT * FROM TABLE(exatest.diff('EHCC.*'));
--SELECT * FROM TABLE(exatest.diff('EHCC CUs Decompressed|EHCC.*Length Decompressed'));

SELECT SUM(LENGTH(text)) archive_low FROM t_hcc_archive_low;
SELECT * FROM TABLE(exatest.diff('EHCC.*'));
--SELECT * FROM TABLE(exatest.diff('EHCC CUs Decompressed|EHCC.*Length Decompressed'));

SELECT SUM(LENGTH(text)) archive_high FROM t_hcc_archive_high;
SELECT * FROM TABLE(exatest.diff('EHCC.*'));
--SELECT * FROM TABLE(exatest.diff('EHCC CUs Decompressed|EHCC.*Length Decompressed'));

