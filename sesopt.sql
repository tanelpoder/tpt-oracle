-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

PROMPT Show compilation environment of session &1 parameter &2

SELECT
    sid_qksceserow              SID
--  , pnum_qksceserow             
  , pname_qksceserow            parameter
  , DECODE(BITAND(flags_qksceserow, 2), 0, 'NO', 'YES') isdefault
  , UPPER(pvalue_qksceserow)    value                                
FROM   x$qksceses
WHERE
    sid_qksceserow IN (&1)
AND LOWER(pname_qksceserow) LIKE LOWER('%&2%')
--    BITAND(flags_qksceserow, 8) = 0
--AND (BITAND(flags_qksceserow, 4) = 0 OR BITAND(flags_qksceserow, 2) = 0)
/
