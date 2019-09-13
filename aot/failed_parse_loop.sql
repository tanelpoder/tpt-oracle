-- ALTER SESSION SET plsql_optimize_level=0;

VAR n NUMBER
BEGIN 
  LOOP
    BEGIN
      EXECUTE IMMEDIATE 'select count(*) into :n from nonexistent'||TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,1000000)));
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
  END LOOP; 
END;
/

