-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

PROMPT Show system default compilation environment, parameter &1

SELECT
--    pnum_qkscesyrow             
    pname_qkscesyrow            parameter
  , DECODE(BITAND(flags_qkscesyrow, 2), 0, 'NO', 'YES') isdefault
  , UPPER(pvalue_qkscesyrow)    value
FROM   sys.x$qkscesys
WHERE
    LOWER(pname_qkscesyrow) LIKE LOWER('%&1%')
--    BITAND(flags_qkscesyrow, 8) = 0
--AND (BITAND(flags_qkscesyrow, 4) = 0 OR BITAND(flags_qkscesyrow, 2) = 0)
/
