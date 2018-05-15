-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   demos/bind_peeking_nested_loops.sql
-- Purpose:     this script demos how a "wrong" bind variable value
--              can cause an execution plan to be compiled which is 
--              very inefficient for the next execution with different bind variable
--              values (with large number of matching rows) 
--              the second execution of the query takes very long time to complete
--              despite adaptive bind variable peeking, which would kick in during the 
--              next (3rd) execution
--
--              This problem happens even on Oracle 11.2 despite adaptive bind peeking
--              and cardinality feedback (due to design, not a bug)
--              
-- Author:      Tanel Poder (tanel@e2sn.com)
-- Copyright:   (c) http://tech.e2sn.com
--
--------------------------------------------------------------------------------
alter session set optimizer_use_sql_plan_baselines = false;

DROP TABLE t_bp1;
DROP TABLE t_bp2;
DROP TABLE t_bp3;
DROP TABLE t_bp4;
DROP TABLE t_bp5;

CREATE TABLE t_bp1 AS SELECT * FROM dba_objects WHERE rownum <= 50000;
CREATE TABLE t_bp2 AS SELECT * FROM dba_objects WHERE rownum <= 10000;
CREATE TABLE t_bp3 AS SELECT * FROM dba_objects WHERE rownum <= 10000;
CREATE TABLE t_bp4 AS SELECT * FROM dba_objects WHERE rownum <= 10000;
CREATE TABLE t_bp5 AS SELECT * FROM dba_objects WHERE rownum <= 10000;

CREATE INDEX i_bp1 ON t_bp1(owner);
CREATE INDEX i_bp2 ON t_bp2(owner);
CREATE INDEX i_bp3 ON t_bp3(owner);
CREATE INDEX i_bp4 ON t_bp4(owner);
CREATE INDEX i_bp5 ON t_bp5(owner);

EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'T_BP1',cascade=>TRUE, method_opt=>'FOR ALL INDEXED COLUMNS SIZE 254');
EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'T_BP2',cascade=>TRUE, method_opt=>'FOR ALL INDEXED COLUMNS SIZE 254');
EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'T_BP3',cascade=>TRUE, method_opt=>'FOR ALL INDEXED COLUMNS SIZE 254');
EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'T_BP4',cascade=>TRUE, method_opt=>'FOR ALL INDEXED COLUMNS SIZE 254');
EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'T_BP5',cascade=>TRUE, method_opt=>'FOR ALL INDEXED COLUMNS SIZE 254');
-- EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'T1',cascade=>TRUE, method_opt=>'FOR ALL INDEXED COLUMNS SIZE 1');
-- EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'T2',cascade=>TRUE, method_opt=>'FOR ALL INDEXED COLUMNS SIZE 1');
-- EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'T3',cascade=>TRUE, method_opt=>'FOR ALL INDEXED COLUMNS SIZE 1');
-- EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'T4',cascade=>TRUE, method_opt=>'FOR ALL INDEXED COLUMNS SIZE 1');
-- EXEC DBMS_STATS.GATHER_TABLE_STATS(user,'T5',cascade=>TRUE, method_opt=>'FOR ALL INDEXED COLUMNS SIZE 1');

-- this hack might be needed to "help" this problem to show up sometimes:
-- ALTER SESSION SET OPTIMIZER_INDEX_COST_ADJ=10;

CREATE OR REPLACE PROCEDURE test_bp (num_loops IN NUMBER, sleep IN NUMBER
                                    , v1 IN VARCHAR2, v2 IN VARCHAR2, v3 IN VARCHAR2, v4 IN VARCHAR2, v5 IN VARCHAR2)
AS
    r1 DATE;
    r2 DATE;
    s  NUMBER;
BEGIN
    FOR i IN 1..num_loops LOOP
        SELECT /*+ opt_param('_optimizer_use_feedback', 'false') */
            MIN(t_bp1.created), MAX(t_bp5.created) INTO r1, r2
        FROM
            t_bp1
          , t_bp2
          , t_bp3
          , t_bp4
          , t_bp5
        WHERE
            t_bp1.object_id = t_bp2.object_id
        AND t_bp2.object_id = t_bp3.object_id
        AND t_bp3.object_id = t_bp4.object_id
        AND t_bp4.object_id = t_bp5.object_id
        AND t_bp1.owner = v1
        AND t_bp2.owner = v2
        AND t_bp3.owner = v3
        AND t_bp4.owner = v4
        AND t_bp5.owner = v5;
 
        s := s + (r2 - r1); -- dummy calculation
        IF sleep > 0 THEN DBMS_LOCK.SLEEP(sleep); END IF;
    END LOOP;
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(s));
END;
/

PROMPT Running query first time, this should be fast (and should use nested loops execution plan)


--SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(null,null));

SET TIMING ON

PROMPT Now running the same query with different bind variables (this query should take very long time)

