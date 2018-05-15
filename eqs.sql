-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL eqs_req_reason HEAD REQ_REASON FOR A35 WORD_WRAP
PROMPT Display Enqueue Statistics from v$enqueue_statistics

SELECT
    eq_type
  , req_reason eqs_req_reason
  , total_req#
  , total_wait#
  , succ_req#
  , failed_req#
  , cum_wait_time
FROM
    v$enqueue_statistics
WHERE
    UPPER(eq_type) LIKE UPPER('&1')
/

