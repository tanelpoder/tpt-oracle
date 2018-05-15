-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

EXEC EXECUTE IMMEDIATE 'drop table t_children'; EXCEPTION WHEN OTHERS THEN NULL;

CREATE TABLE t_children AS SELECT rownum a, 'zzz' b FROM dual CONNECT BY LEVEL<=1000;

CREATE INDEX i_children ON t_children(a);

-- deliberately gathering a histogram 
EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'T_CHILDREN',method_opt=>'FOR COLUMNS A SIZE 254');

-- this is the crap setting 
ALTER SESSION SET cursor_sharing = similar;

@saveset

SET PAGES 0 HEAD OFF TRIMOUT OFF TRIMSPOOL OFF ARRAYSIZE 5000 TERMOUT OFF
SPOOL tmp_lotschildren.sql
SELECT 'SELECT COUNT(*) FROM t_children WHERE a = '||TO_CHAR(ABS(DBMS_RANDOM.RANDOM))||';'
FROM dual CONNECT BY LEVEL <= 100000;
SPOOL OFF

@loadset

PROMPT Now run @tmp_lotschildren.sql

-- this hack is not working, must use plain SQL instead of plsql
-- ALTER SESSION SET session_cached_cursors = 0;
-- ALTER SESSION SET "_close_cached_open_cursors" = TRUE;
-- ALTER SESSION SET plsql_optimize_level = 0;
-- 
-- DECLARE
--     j NUMBER;
--     x NUMBER;
-- BEGIN
--     EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM t_children WHERE a = '||TO_CHAR(ABS(DBMS_RANDOM.RANDOM)) INTO j;
--     x:=x+j;
--     COMMIT;
-- END;
-- /

