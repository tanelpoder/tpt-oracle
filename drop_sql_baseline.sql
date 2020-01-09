DEF sql_handle=&1

-- TODO: Additionally look up the correct SQL_HANDLE using dba_sql_plan_baselines.plan_name 
-- as this is what DBMS_XPLAN reports as used... (so no manual lookup from plan_name -> sql_handle
-- is needed)

-- You can get the SQL_HANDLE from DBA_SQL_PLAN_BASELINES

-- DBMS_SPM basic baseline use is included in Oracle EE in 11g+ and SE from 18c+
--   https://blogs.oracle.com/optimizer/does-the-use-of-sql-plan-management-and-the-dbmsspm-database-package-require-a-tuning-or-diagnostic-pack-license

SET SERVEROUT ON SIZE 1000000

DECLARE
  x NUMBER;
BEGIN
  x:=DBMS_SPM.DROP_SQL_PLAN_BASELINE('&sql_handle');
  DBMS_OUTPUT.PUT_LINE('ret='||x);
END;
/

SET SERVEROUT OFF

