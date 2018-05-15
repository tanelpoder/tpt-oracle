-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

SELECT
     hladdr
--  , blsiz
--  , nxt_hash
--  , prv_hash
--  , nxt_repl
--  , prv_repl
  , flag
  , rflag
  , sflag
  , lru_flag
  , ts#
  , file#
--  , dbarfil
  , dbablk
  , class
  , state
  , mode_held
  , changes
  , cstate
  , le_addr
  , dirty_queue
  , set_ds
  , obj
  , ba
  , cr_scn_bas
  , cr_scn_wrp
  , cr_xid_usn
  , cr_xid_slt
  , cr_xid_sqn
  , cr_uba_fil
  , cr_uba_blk
  , cr_uba_seq
  , cr_uba_rec
  , cr_sfl
  , cr_cls_bas
  , cr_cls_wrp
  , lrba_seq
  , lrba_bno
  , hscn_bas
  , hscn_wrp
  , hsub_scn
  , us_nxt
  , us_prv
  , wa_nxt
  , wa_prv
  , obj_flag
  , tch
  , tim
FROM
    x$bh
WHERE
    obj IN (&1)
/

