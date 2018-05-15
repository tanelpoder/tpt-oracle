-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT 
  --  sqlhashv
  -- , flags
    qcinstid
  , qcsid
  , bfm
  , 'BF'||TRIM(TO_CHAR(bfid,'0999')) bf_id
  , len   bytes_total
  , len*8 bits_total
  , nset  bits_set
  , TO_CHAR(ROUND((nset/(len*8))*100,1),'999.0')||' %' pct_set
  , flt filtered
  , tot total_probed
  , active 
FROM 
    x$qesblstat
WHERE
    sqlhashv = DBMS_UTILITY.SQLID_TO_SQLHASH('&1')
ORDER BY
    bfid
/

