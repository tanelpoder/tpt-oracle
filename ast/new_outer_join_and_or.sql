-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- DROP TABLE s;
-- DROP TABLE t;
-- 
-- CREATE TABLE s AS SELECT * FROM dba_segments;
-- CREATE TABLE t AS SELECT * FROM dba_tables;
-- 
-- SET TIMING ON

-- SELECT COUNT(*) 
-- FROM
--     t
--   , s 
-- WHERE
--        (t.owner = s.owner AND t.table_name = s.segment_name) 
--     OR (t.owner = s.owner AND UPPER(t.table_name) = UPPER(s.segment_name))
-- /
-- 
-- @x

SELECT 
  /*+
      ALL_ROWS
      MERGE(@"SEL$2")
      FULL(@"SEL$64EAE176" "T"@"SEL$2")
      NO_ACCESS(@"SEL$64EAE176" "from$_subquery$_004"@"SEL$2")
      LEADING(@"SEL$64EAE176" "T"@"SEL$2" "from$_subquery$_004"@"SEL$2")
      USE_HASH(@"SEL$64EAE176" "from$_subquery$_004"@"SEL$2")
      FULL(@"SEL$1" "S"@"SEL$1")
  */
  COUNT(*) 
FROM
    t 
   LEFT OUTER JOIN
    s 
ON (
       (t.owner = s.owner AND t.table_name = s.segment_name) 
    OR (t.owner = s.owner AND UPPER(t.table_name) = UPPER(s.segment_name))
);

-- @x

-- SELECT COUNT(*) FROM (
--     SELECT * FROM t LEFT JOIN s ON (t.owner = s.owner AND t.table_name = s.segment_name)
--     UNION 
--     SELECT * FROM t LEFT JOIN s ON (t.owner = s.owner AND UPPER(t.table_name) = UPPER(s.segment_name))
-- );
-- 
-- @x

