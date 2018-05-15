-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- DROP TABLE test_users;
-- DROP TABLE test_objects;
CREATE TABLE test_users  AS SELECT * FROM all_users;
CREATE TABLE test_objects AS SELECT * FROM all_objects;
@gts test_users
@gts test_objects

@53on 

SELECT /*+ GATHER_PLAN_STATISTICS */
    u.username
  , (SELECT MAX(created) FROM test_objects o WHERE o.owner = u.username)
FROM
    test_users u
WHERE
    username LIKE 'S%'
/

@53off
@xall
@53on

-- ALTER SESSION SET "_optimizer_unnest_scalar_sq" = FALSE;

SELECT /*+ GATHER_PLAN_STATISTICS NO_UNNEST(@ssq) */
    u.username
  , (SELECT /*+ QB_NAME(ssq) */ MAX(created) FROM test_objects o WHERE o.owner = u.username)
FROM
    test_users u
WHERE
    username LIKE 'S%'
/

@53off
@xall

