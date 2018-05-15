-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

DROP TABLE selectivity_test;

CREATE TABLE selectivity_test AS
SELECT sysdate - rownum d
FROM dual connect by level <= 365;

@gts selectivity_test

@minmax d selectivity_test

@descxx selectivity_test

