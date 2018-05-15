-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   sampleaddr.sql 
-- Purpose:     High-frequency sampling of contents of a SGA memory address
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @sampleaddr <hex_addr> <sample_count>
-- 	        @sampleaddr 
--	        
-- Other:       Requires the sample.sql script:
--
--                http://www.tanelpoder.com/files/scripts/sample.sql
--
--              Also requires access to X$KSMMEM and X$DUAL tables
--              
--------------------------------------------------------------------------------

col sampleaddr_addrlen new_value _sampleaddr_addrlen

set termout off
select vsize(addr)*2 sampleaddr_addrlen from x$dual;
set termout on

@@sample ksmmmval x$ksmmem "addr=hextoraw(lpad('&1',&_sampleaddr_addrlen,'0'))" &2
