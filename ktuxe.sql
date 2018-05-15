-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

-- KTU Xact Entry table

SELECT
    ktuxeusn            usn#     -- 65535 = no-undo transaction
  , ktuxeslt            slot#    -- 65535 = invalid slot#
  , ktuxesqn            seq#
  , ktuxesta            status
  , ktuxecfl            flags
  , ktuxesiz            undo_blks
  , ktuxerdbf           curfile 
  , ktuxerdbb           curblock
  , ktuxescnw * power(2, 32) + ktuxescnb cscn -- commit/prepare commit SCN
  , ktuxeuel            
  -- distributed xacts
  --, ktuxeddbf           r_rfile
  --, ktuxeddbb           r_rblock
  --, ktuxepusn           r_usn#
  --, ktuxepslt           r_slot#
  --, ktuxepsqn           r_seq#
FROM
    x$ktuxe
WHERE ktuxesta != 'INACTIVE'
ORDER BY
    ktuxeusn
  , ktuxeslt
/
