-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

DROP TABLE t_child;
DROP TABLE t_parent;

CREATE TABLE t_parent(a INT PRIMARY KEY);
CREATE TABLE t_child(b INT, c INT, FOREIGN KEY (c) REFERENCES t_parent(a));

INSERT INTO t_parent SELECT rownum FROM dual CONNECT BY LEVEL<=10;
INSERT INTO t_child SELECT rownum, MOD(rownum,9)+1 FROM dual CONNECT BY LEVEL <= 10;

COMMIT;

PAUSE Press enter to update CHILD table:

PROMPT UPDATE t_child SET c = 10 WHERE c = 1;;
UPDATE t_child SET c = 10 WHERE c = 1;

PROMPT -- In another session run:
PROMPT UPDATE t_parent SET a = 7 WHERE a = 6;;
PROMPT

