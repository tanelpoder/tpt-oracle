-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- This hard crashes the target process in 10.2.0.3 Solaris with SEGV

DROP VIEW v1;
DROP FUNCTION f1;


CREATE OR REPLACE FUNCTION f1 RETURN NUMBER AS
BEGIN
    RETURN 1;
END;
/


CREATE OR REPLACE view v1 AS SELECT f1 FROM dual;

CREATE OR REPLACE FUNCTION f1 RETURN NUMBER AS 
    i NUMBER;
BEGIN 
    SELECT f1 INTO i FROM v1;
    RETURN i;
END;
/

CREATE OR REPLACE view v1 AS SELECT f1 FROM dual;

