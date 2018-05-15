-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

CREATE TABLE row_filtering_test (id NUMBER, c CHAR(1000), vc VARCHAR2(1000));

INSERT /*+ APPEND */ INTO row_filtering_test
SELECT rownum, TO_CHAR(rownum), TO_CHAR(rownum)
FROM
    (SELECT 1 FROM dual CONNECT BY LEVEL <= 1000)
  , (SELECT 1 FROM dual CONNECT BY LEVEL <= 1000)
/

-- CREATE TABLE row_filtering_test AS
-- SELECT rownum r, LPAD('x',1000,'x') c1
-- FROM
--     (SELECT 1 FROM dual CONNECT BY LEVEL <= 1000)
--   , (SELECT 1 FROM dual CONNECT BY LEVEL <= 1000)
-- /
-- 
@gts row_filtering_test

ALTER SESSION SET "_serial_direct_read"=ALWAYS;

--VAR snapper REFCURSOR
--@snapper4 stats,begin 1 1 &mysid

SELECT /*+ MONITOR */ COUNT(*) FROM row_filtering_test WHERE id <= 500000;

SELECT /*+ MONITOR */ COUNT(*) FROM row_filtering_test WHERE id <= (SELECT 500000 FROM dual);

--@snapper4 stats,end 1 1 &mysid
@xp &mysid

CREATE TABLE row_filtering_helper (v NUMBER);
INSERT INTO row_filtering_helper VALUES (500000);
COMMIT;

SELECT /*+ MONITOR */ COUNT(*) FROM row_filtering_test WHERE r <= (SELECT v FROM row_filtering_helper);


SELECT /*+ MONITOR */ COUNT(*) FROM row_filtering_test WHERE id <= 500000 AND c = vc;



