-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- oracle 11.2+

SELECT
  LISTAGG (CHR(27)||'[48;5;'||
              ( 16 + MOD(r,6) + MOD(TRUNC(r/6),6)*6 + MOD(TRUNC(r/36),6)*6*6 )||'m'||
              LPAD(16 + MOD(r,6) + MOD(TRUNC(r/6),6)*6 + MOD(TRUNC(r/36),6)*6*6,4)||
              CHR(27)||'[0m'
  ) WITHIN GROUP (ORDER BY MOD(TRUNC(r/6),6))
FROM
    (SELECT rownum r FROM dual CONNECT BY LEVEL <= 216)
GROUP BY
    MOD(TRUNC(r/36),6)
/
