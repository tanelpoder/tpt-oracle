-- Cause CBC latch contention

-- CREATE TABLE lookup AS SELECT * FROM dba_objects
-- WHERE object_id IS NOT NULL
-- AND rownum <= 50;
-- 
-- CREATE INDEX idx_lookup ON lookup(object_id);
-- ALTER TABLE lookup ADD CONSTRAINT pk_lookup PRIMARY KEY (object_id);
-- 
-- @gts lookup

ALTER SESSION SET plsql_optimize_level = 0;

VAR x NUMBER

BEGIN
  LOOP 
    SELECT data_object_id INTO :x 
    FROM lookup 
    WHERE object_id IN (10,-1,-2,-3,-4,-5,-6,-7,-8,-9);
  END LOOP;
END;
/

