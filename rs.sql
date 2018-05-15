-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   rs.sql
-- Purpose:     Display available Redo Strands
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @rs
--          
-- Other:       Shows both public and private redo strands
--
--------------------------------------------------------------------------------

COL rs_indx HEAD STR# FOR 999

prompt Display available redo strands in the instance (both private and public)...

SELECT 
    indx                            rs_indx,
    first_buf_kcrfa                 firstbufadr,
    last_buf_kcrfa                  lastbufadr,
    pnext_buf_kcrfa_cln             nxtbufadr, 
    next_buf_num_kcrfa_cln          nxtbuf#, 
    strand_header_bno_kcrfa_cln     flushed,
    total_bufs_kcrfa                totbufs#, 
    strand_size_kcrfa               strsz,
    space_kcrf_pvt_strand           strspc,
    bytes_in_buf_kcrfa_cln          "B/buf", 
    pvt_strand_state_kcrfa_cln      state,
    strand_num_ordinal_kcrfa_cln    strand#, 
    ptr_kcrf_pvt_strand             stradr, 
    index_kcrf_pvt_strand           stridx, 
    txn_kcrf_pvt_strand             txn
FROM 
        x$kcrfstrand
/


