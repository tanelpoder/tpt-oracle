-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT
    indx,
    LPAD('0x'||TRIM(TO_CHAR(indx, 'XXXX')),7) hex,
    ksllwnam,
    ksllwlbl
FROM
    x$ksllw
WHERE
    indx     like '&1'
OR  TRIM(TO_CHAR(indx, 'XXXX'))	 LIKE UPPER('&1')
OR  ksllwnam like '&1'
OR  ksllwlbl like '&1'
/
