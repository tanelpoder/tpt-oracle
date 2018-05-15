-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

COL sqlfn_descr HEAD DESCRIPTION FOR A100 WORD_WRAP
COL sqlfn_name  HEAD NAME FOR A30

SELECT
    func_id
  , name sqlfn_name
  , offloadable
--  , usage
  , minargs
  , maxargs
    -- this is just to avoid clutter on screen
  , CASE WHEN name != descr THEN descr ELSE null END sqlfn_descr 
FROM
    v$sqlfn_metadata 
WHERE 
    UPPER(name) LIKE UPPER('%&1%')
/

