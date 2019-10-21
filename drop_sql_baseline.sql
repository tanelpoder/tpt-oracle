DEF sql_handle=&1

-- TODO: Additionally look up the correct SQL_HANDLE using dba_sql_plan_baselines.plan_name 
-- as this is what DBMS_XPLAN reports as used... (so no manual lookup from plan_name -> sql_handle
-- is needed)

SET SERVEROUT ON SIZE 1000000

DECLARE
  x NUMBER;
BEGIN
  x:=DBMS_SPM.DROP_SQL_PLAN_BASELINE('&sql_handle');
  DBMS_OUTPUT.PUT_LINE('ret='||x);
END;
/

SET SERVEROUT OFF

