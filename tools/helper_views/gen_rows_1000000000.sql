-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

CREATE OR REPLACE VIEW gen_rows_1000000000 AS
SELECT r FROM (
           SELECT ROWNUM r
           FROM
                   (SELECT ROWNUM r FROM dual CONNECT BY ROWNUM <= 1000) a,
                   (SELECT ROWNUM r FROM dual CONNECT BY ROWNUM <= 1000) b,
                   (SELECT ROWNUM r FROM dual CONNECT BY ROWNUM <= 1000) c
   )
/

