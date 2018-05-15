-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

DROP TABLE t;

CREATE TABLE t (a int, b varchar2(100))
PARTITION BY RANGE (a) (
  PARTITION p1 VALUES LESS THAN (10)
 ,PARTITION p2 VALUES LESS THAN (20)
)
/

INSERT INTO t SELECT 5, 'axxxxxxxxxxxxxxxxx' FROM dual;
INSERT INTO t SELECT 5, 'bxxxxxxxxxxxxxxxxx' FROM dual;
INSERT INTO t SELECT 5, 'cxxxxxxxxxxxxxxxxx' FROM dual;

INSERT INTO t SELECT 15, 'axxxxxxxxxxxxxxxxx' FROM dual;
INSERT INTO t SELECT 15, 'bxxxxxxxxxxxxxxxxx' FROM dual;
INSERT INTO t SELECT 15, 'cxxxxxxxxxxxxxxxxx' FROM dual CONNECT BY LEVEL <= 10000;

CREATE INDEX i1 ON t(a) LOCAL;
CREATE INDEX i2 ON t(b) LOCAL;

@gts t

