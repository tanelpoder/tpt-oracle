-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

prompt Show wait event descriptions matching &1...

col sed_name            head EVENT_NAME for a55
col sed_p1              head PARAMETER1 for a25
col sed_p2              head PARAMETER2 for a25
col sed_p3              head PARAMETER3 for a25
col sed_event#          head EVENT# for 99999
col sed_req_description HEAD REQ_DESCRIPTION for a100 WORD_WRAP
col sed_req_reason      HEAD REQ_REASON for a32 WRAP
col sed_wait_class      HEAD WAIT_CLASS for a20
col sed_eq_name         HEAD ENQUEUE_NAME for a30

SELECT 
    e.event# sed_event#
  , e.name sed_name 
  , e.wait_class sed_wait_class
  , e.parameter1 sed_p1 
  , e.parameter2 sed_p2 
  , e.parameter3 sed_p3
  , s.eq_name         sed_eq_name
  , s.req_reason      sed_req_reason
  , s.req_description sed_req_description
--  , e.display_name sed_display_name  -- 12c
FROM 
    v$event_name e
  , v$enqueue_statistics s
WHERE 
    e.event# = s.event# (+)
AND lower(e.name) like lower('&1') 
ORDER BY 
    sed_name
/
