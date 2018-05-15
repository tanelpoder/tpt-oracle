-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

DROP TABLE t_commit;
CREATE TABLE t_commit AS SELECT 1 a FROM dual;

-- experiment with
-- ALTER SESSION  SET COMMIT_LOGGING = IMMEDIATE;
-- ALTER SESSION  SET COMMIT_WRITE = WAIT;

BEGIN
  FOR i IN 1..1000000 LOOP
    UPDATE t_commit SET a=a+1;
    COMMIT;
  END LOOP;
END;
/

