-- Copyright 2018 Tanel Poder. All rights reserved. More info at http://tanelpoder.com
-- Licensed under the Apache License, Version 2.0. See LICENSE.txt for terms & conditions.

--------------------------------------------------------------------------------
--
-- File name:   lh.sql ( Latch Holder )
-- Purpose:     Show latch holding SIDs and latch details from V$LATCHHOLDER
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @lh <sid>
-- 	        	@lh %
--
--------------------------------------------------------------------------------
SELECT
	*
FROM
	V$LATCHHOLDER
WHERE
	sid LIKE '&1'
/



